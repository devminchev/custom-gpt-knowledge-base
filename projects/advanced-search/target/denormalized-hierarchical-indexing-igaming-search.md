# Denormalised Hierarchical Indexing for iGaming Search (Contentful → OpenSearch)

Guiding Principles

One query to OpenSearch for /api/search (no joins, no nested, no scripts).

Denormalised, flat keyword arrays for relationships.

Write-time propagation: compute hierarchy relationships when content changes, not at query time.

Push intelligence to AWS (Apps + Lambdas), keep OpenSearch dumb and fast.

Two apps:

App 1: Orchestrator – replaces all existing Contentful webhooks for existing indices.

App 2: Available-sitegames Indexer – owns the available-sitegames index.

This answer focuses on the indexing/search strategy and how your four indices work together:

navigation

views

game-sections

available-sitegames

1. OpenSearch mappings (DSL)
1.1 Common pattern

All relationship fields are:

type: "keyword"

Stored as flat arrays of IDs (no sys object).

Indexed for terms queries, used inside bool.filter.

We can optionally add a lowercase/ascii-folding normaliser if we want, but not mandatory for IDs.

1.2 navigation index

Stores both igNavigation and igLink entries.

PUT navigation
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "id": { "type": "keyword" },
      "contentType": { "type": "keyword" },        // "igNavigation" | "igLink"
      "updatedAt": { "type": "date" },

      // igNavigation docs:
      "links":       { "type": "keyword" },        // igLink ids
      "bottomLinks": { "type": "keyword" },        // igLink ids

      // igLink docs:
      "view":             { "type": "keyword" },   // one igView id
      "linkedNavigations":{ "type": "keyword" }    // all navigation ids that include this igLink
    }
  }
}

1.3 views index

Stores igView entries.

PUT views
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "id": { "type": "keyword" },
      "contentType": { "type": "keyword" },        // "igView"
      "updatedAt": { "type": "date" },

      // forward links:
      "sections":        { "type": "keyword" },    // section ids (game-bearing sections)

      // reverse / propagated links:
      "linkedNavLinks":  { "type": "keyword" },    // igLink ids that point to this view
      "linkedNavigations": { "type": "keyword" }   // navigation ids reachable via those navLinks
    }
  }
}

1.4 game-sections index

Stores all game-bearing section entries.

PUT game-sections
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "id": { "type": "keyword" },
      "contentType": { "type": "keyword" },        // "section-*"
      "updatedAt": { "type": "date" },

      // forward links:
      "games": { "type": "keyword" },              // siteGameV2 ids (flattened)

      // reverse / propagated links:
      "linkedViews":       { "type": "keyword" },  // view ids that include this section
      "linkedNavLinks":    { "type": "keyword" },  // igLink ids that reach this section via their views
      "linkedNavigations": { "type": "keyword" }   // navigation ids that reach this section
    }
  }
}

1.5 available-sitegames index

Stores one doc per siteGameV2.

PUT available-sitegames
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "id": { "type": "keyword" },                  // siteGameV2 id (or composite id)
      "contentType": { "type": "keyword" },         // "siteGameV2"
      "updatedAt": { "type": "date" },

      "linkedSections":     { "type": "keyword" },  // section ids
      "linkedViews":        { "type": "keyword" },  // view ids
      "linkedNavLinks":     { "type": "keyword" },  // igLink ids
      "linkedNavigations":  { "type": "keyword" },  // navigation ids

      "isAvailable":        { "type": "boolean" }
    }
  }
}


Important: by design, we omit fields when the array is empty. That lets us use exists in queries instead of array length checks (no scripts).

2. Bulk upsert strategy (no scripts, no nested)
2.1 Principle

Because we explicitly don’t want scripts:

The Indexer Lambda (App 2 backend) always builds the complete, merged array values per doc.

It uses doc_as_upsert: true to perform upsert with full doc state.

It prevents duplicates by merging arrays in memory (JS Set) before sending to OpenSearch.

This avoids:

Painless scripts

update_by_query with script

Nested queries

It trades one lightweight read per doc for predictable, transparent logic.

2.2 Example: Bulk upsert linking section → siteGame

We receive an event that a section was updated in Contentful and now references a set of siteGames.

Pseudo algo for Indexer (JS-style):

// For a single (sectionId, siteGameId) pair; you’ll batch per event
async function upsertAvailableSiteGame(siteGameId, sectionId, now) {
  // 1. Fetch current doc if exists
  const res = await osClient.get({
    index: 'available-sitegames',
    id: siteGameId,
    _source: ['linkedSections', 'linkedViews', 'linkedNavLinks', 'linkedNavigations', 'isAvailable']
  }).catch(e => (e.meta?.statusCode === 404 ? null : Promise.reject(e)));

  const current = res?._source ?? {};

  // 2. Recompute relationships for this siteGame from game-sections index
  const sections = await osClient.search({
    index: 'game-sections',
    size: 1000,
    query: { term: { "games": siteGameId } },
    _source: ['id', 'linkedViews', 'linkedNavLinks', 'linkedNavigations']
  });

  const linkedSections = [];
  const linkedViews = new Set();
  const linkedNavLinks = new Set();
  const linkedNavigations = new Set();

  for (const hit of sections.hits.hits) {
    const s = hit._source;
    linkedSections.push(s.id);
    (s.linkedViews || []).forEach(v => linkedViews.add(v));
    (s.linkedNavLinks || []).forEach(l => linkedNavLinks.add(l));
    (s.linkedNavigations || []).forEach(n => linkedNavigations.add(n));
  }

  // 3. Build doc
  const doc = {
    id: siteGameId,
    contentType: 'siteGameV2',
    updatedAt: now.toISOString()
  };

  if (linkedSections.length) doc.linkedSections = linkedSections;
  if (linkedViews.size) doc.linkedViews = [...linkedViews];
  if (linkedNavLinks.size) doc.linkedNavLinks = [...linkedNavLinks];
  if (linkedNavigations.size) doc.linkedNavigations = [...linkedNavigations];

  doc.isAvailable =
    linkedSections.length > 0 &&
    linkedViews.size > 0 &&
    linkedNavLinks.size > 0 &&
    linkedNavigations.size > 0;

  // 4. Upsert
  await osClient.update({
    index: 'available-sitegames',
    id: siteGameId,
    doc,
    doc_as_upsert: true
  });
}


Bulk payload this produces (conceptually):

POST _bulk
{ "update": { "_index": "available-sitegames", "_id": "siteGame123" } }
{
  "doc_as_upsert": true,
  "doc": {
    "id": "siteGame123",
    "contentType": "siteGameV2",
    "linkedSections": ["sec1","sec2"],
    "linkedViews": ["viewA","viewB"],
    "linkedNavLinks": ["navLinkX"],
    "linkedNavigations": ["navMain"],
    "isAvailable": true,
    "updatedAt": "2025-09-26T10:21:43.123Z"
  }
}


Note: no script, no partial array mutation. All arrays are recomputed from game-sections state.

3. Search query: only “fully linked” documents

Requirement:

/api/search must return only siteGames where:

linkedSections.length > 0

linkedViews.length > 0

linkedNavLinks.length > 0

linkedNavigations.length > 0

Two options:

Option A (recommended): write-time isAvailable

We already compute isAvailable when arrays are populated. Then your search filter is trivial:

{
  "query": {
    "bool": {
      "filter": [
        { "term": { "isAvailable": true } }
      ]
    }
  }
}


This is the simplest and fastest.

Option B: pure field-based filter (if we really want)

If we never index empty arrays (omit the field), then:

{
  "query": {
    "bool": {
      "filter": [
        { "exists": { "field": "linkedSections" } },
        { "exists": { "field": "linkedViews" } },
        { "exists": { "field": "linkedNavLinks" } },
        { "exists": { "field": "linkedNavigations" } }
      ]
    }
  }
}


No scripts; still a single query. In practice we’ll probably use isAvailable:true and keep the existence logic at write-time.

4. Content update flows (unordered & ordered)
4.1 Data ownership & propagation

Navigation index records:

For igNavigation: links[], bottomLinks[] (→ igLink ids)

For igLink: view (forward link) and linkedNavigations[] (reverse: nav ids that include this link)

Views index records:

sections[] (forward to sections)

linkedNavLinks[] and linkedNavigations[] (reverse: igLinks & navs that point to this view)

Game-sections index records:

games[] (siteGame ids)

linkedViews[], linkedNavLinks[], linkedNavigations[] (reverse from views/navLinks/navs)

Available-sitegames index records:

Fully materialized relationships at the siteGame level.

Key trick:
When we recompute available-sitegames for a particular siteGame, we only need to read the game-sections index:

game-sections already knows:

Which sections a siteGame is in (games[])

For each section: which views/navLinks/navigations reach it (linked*)

So for a siteGame we:

find all sections where games contains that siteGame

union their linked* arrays

write one doc

This avoids deep traversal per siteGame.

4.2 Unordered update cases

The flow for the 4 cases, in any order:

Section entry updated with siteGames

View entry updated with sections

NavLink entry updated with view

Navigation entry updated with navLinks

We’ll handle each at two levels:

update intermediate indices (navigation, views, game-sections)

then update available-sitegames as needed.

4.2.1 Section updated (games[] changed)

Event: section entry updated in Contentful.

Steps:

App 1: forwards envelope to Orchestrator writers → writes section doc to game-sections:

id

games[] (flattened siteGame ids)

linkedViews[], linkedNavLinks[], linkedNavigations[] remain as they were (or recomputed upstream).

App 2 → Indexer:

Compute changed siteGameIds = union(old games[], new games[]).

For each siteGameId in this set:

Recompute relationships from game-sections as in section 2.2.

Upsert doc in available-sitegames.

No traversal beyond game-sections.

4.2.2 View updated (sections[] changed)

Event: view entry updated in Contentful.

Steps:

App 1 writer:

Update views index doc:

sections[] (flattened section ids)

Indexer (hierarchical propagation):

Recompute this view’s reverse references:

linkedNavLinks[] (all igLink ids that have view = thisViewId)

Use navigation index, type=igLink, term on view.

linkedNavigations[] = all nav ids that include any of those navLink ids

Use navigation index, type=igNavigation, terms on links[]/bottomLinks[].

Update this view doc in views with:

sections[] (from event)

linkedNavLinks[] (recomputed)

linkedNavigations[] (recomputed)

Recompute impacted sections:

Find all sections where sections in views contains sectionId (we know them from the view doc’s sections[]).

For each section:

Update its linkedViews[], linkedNavLinks[], linkedNavigations[] with this view + its navLinks/navs.

Write to game-sections.

Recompute available-sitegames:

For each section impacted, for each siteGame in games[]:

Recompute available-sitegames doc for that siteGame as in 2.2.

4.2.3 NavLink updated (view changed)

Event: igLink entry updated; its view reference changed.

Steps:

App 1:

Update igLink doc in navigation index:

view = new view id

Indexer:

For old viewId and new viewId:

Recompute linkedNavLinks[] and linkedNavigations[] in views:

For each view, set linkedNavLinks[] = all igLinks where view = thisViewId.

linkedNavigations[] = all navs whose links[]/bottomLinks[] contain those igLinks.

For impacted views:

Update their docs in views.

From their sections[], recompute linked* arrays on sections (same pattern as 4.2.2).

For impacted sections:

From games[], recompute available-sitegames for all siteGames in those sections.

4.2.4 Navigation updated (navLinks changed)

Event: igNavigation entry updated (new links / bottomLinks).

Steps:

App 1:

Update igNavigation doc in navigation index: links[], bottomLinks[].

Indexer:

For each igLinkId in links[] + bottomLinks[]:

Update igLink doc in navigation index (linkedNavigations[]):

linkedNavigations[] = all nav ids where links[] or bottomLinks[] contain this igLink.

For each igLink impacted:

Its view id is known.

Update views index:

For that view, recompute linkedNavLinks[] and linkedNavigations[] as in 4.2.3.

From views → sections → game-sections:

For each view with changed linkedNavigations[]:

Find sections in view.sections[].

Update section linkedNavLinks[] & linkedNavigations[].

For impacted sections:

For each siteGameId in games[], recompute its doc in available-sitegames.

4.3 Ordered linking flows

Ordered flows are just compositions of the unordered cases.

4.3.1 Down-top: siteGame → section → view → navLink → navigation

This corresponds to an editor first linking siteGame into a section, then wiring that section into a view, then view into link, then link into navigation.

Event sequence:

Add siteGameV2 to Section.games[]
→ Section updated case (4.2.1) → game-sections + available-sitegames recomputed.

Add section to View.sections[]
→ View updated case (4.2.2) → views + game-sections + available-sitegames updated.

Set NavLink.view to that view
→ NavLink updated case (4.2.3).

Add NavLink to Navigation.links[] or bottomLinks[]
→ Navigation updated case (4.2.4).

At the end, available-sitegames for the siteGame will have all four arrays set, and isAvailable:true.

4.3.2 Top-down: navigation → navLink → view → section → siteGame

Event sequence in reverse:

Create navigation and add navLinks
→ Navigation updated case.

Set NavLink.view
→ NavLink updated case.

Add sections to view
→ View updated case.

Add games to sections
→ Section updated case.

The same logic runs in any order; the Indexer always recomputes from the current state of navigation / views / game-sections.

4.4 Handling missing siteGame docs

Whenever a recompute for a siteGameId happens:

If GET available-sitegames/_doc/{id} returns 404, we treat it as new:

Build doc as in 2.2.

doc_as_upsert: true handles creation.

If a siteGame is referenced by sections but has never been explicitly published to available-sitegames yet, the first structural change will create its doc (with isAvailable possibly false if the hierarchy is incomplete).

5. Comparison to script-based / edge-based approach

A script-based pattern recommendation :

Use Painless scripts on _update to append IDs to arrays, e.g.:

"source": "if (!ctx._source.linkedViews.contains(params.id)) ctx._source.linkedViews.add(params.id)"


Pros of script-based:

No pre-read of the document; OS mutates state in place.

Simpler payloads for clients.

Cons / why we avoid it here:

Scripts are harder to reason about, slower, and need careful sandboxing.

Difficult to keep business logic in a single place (some in scripts, some in app).

Harder to evolve safely at scale (versioning, rollback, testing).

You explicitly prefer no scripts / nested queries.

Chosen pattern:

Application-side recompute + full doc upsert:

All logic in Indexer Lambda (JS/TS, fully testable).

OpenSearch remains a dumb KV store with powerful filtering.

Reads are still cheap (one GET + one or a few term(s) queries per affected siteGame).

Write-time overhead is predictable and bounded by the small fan-out of relationships.

This matches patterns used by large systems: materialised view indexing, CQRS-style read models, denormalised search indices.

6. Recommendation Outcome

Simplicity

All queries are bool.filter with term / terms / exists. No joins, no nested, no scripts.

/api/search is one OpenSearch call over available-sitegames.

Reliability

Single Indexer owns the materialised view; no multi-writer races.

Idempotent events (via sysVersion) avoid double-processing and out-of-order issues.

App Functions fully replace webhooks, centralising rules and auth.

Performance

Read path:

Single index, no joins → very fast.

Flat keyword arrays → doc_values powered filters & aggs.

Write path:

Bounded fan-out (by your hierarchy volumes).

No recursive graph traversal per request; we leverage pre-propagated linked* fields in intermediate indices.

Maintainability

All business logic in JS/TS (Apps + Lambdas).

Mappings are simple and stable; index rollovers are easy.

No Contentful model changes required.

Cost efficiency

Minimised OS CPU per query (no complicated scoring / scripts).

Extra writes happen only for impacted siteGames/sections/views/navLinks/navigations, not global reindexing.

Optional SQS + DLQ to smooth spikes without overprovisioning.
