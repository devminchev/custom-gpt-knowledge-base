---
title: "1) Big picture: taxonomy vs. tags"
tags: [projects, advanced-search, contentful-docs]
aliases: []
---
Practical, “all-you-need” guide to Contentful’s taxonomy vs. tags—what they are, when to use which, how they show up in APIs, and patterns that work in real projects.

# 1) Big picture: taxonomy vs. tags

**Taxonomy (new, org-level)**

* Structured, hierarchical concepts you define centrally (e.g., Category → Subcategory → Topic).
* Created and governed in the **Taxonomy Manager** and then enabled on content types; editors assign concepts to entries during editing.
* Built for **searchability, discoverability, consistent classification** across teams and spaces; aligns with SKOS (thesaurus-like concepts/schemes). ([Contentful][1])

**Tags (environment-level)**

* Lightweight labels attached to entries and assets.
* Come in **private** (internal only) and **public** (exposed to delivery/preview/GraphQL) variants.
* Great for **editorial workflows, governance, and internal filtering**; public tags can also power simple front-end grouping. ([Contentful][2])

**Rule of thumb**

* Use **taxonomy** for user-facing classification, navigation, and consistent findability.
* Use **tags** mainly for **permissions, workflow management, and internal ops**; use public tags only for simple grouping when you don’t need hierarchy. ([Contentful][1])

---

# 2) Where they live & who can manage them

| Feature  | Scope                                                                       | Who manages                                                  | Editor experience                                                   |
| -------- | --------------------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------- |
| Taxonomy | **Organization level** (concepts & schemes), applied per space/content type | Org owners/admins/developers via **Taxonomy Manager**        | Editors pick concepts on entries; can filter/search by concepts     |
| Tags     | **Environment level** (unique per environment)                              | Space admins; creation permission can be delegated via roles | Editors add/remove tags on entries/assets; can filter by tags in UI |

Refs: taxonomy manager access & UI, tags scope & permissions. ([Contentful][3])

---

# 3) Limits to keep in mind (as of Sep 2025)

**Taxonomy**

* Up to **20 concept schemes**, **2000 concepts per scheme**, **6000 concepts total**, **5 levels** max hierarchy, **50 concepts per entry**, **10 validations per content type**. ([Contentful][1])

**Tags**

* Up to **1000 tags per environment**, **100 tags per entry/asset**. Tag **IDs immutable**; names can be changed. ([Contentful][2])

---

# 4) Visibility, permissions & governance

**Tags visibility**

* **Private**: internal only; returned **only by CMA** (management API).
* **Public**: returned by **CDA/CPA/GraphQL** and can be used on the front end. Visibility is chosen **at creation** and can’t be toggled later. ([Contentful][2])

**Governance patterns**

* Use **private tags** to drive **saved views**, **workflow filters**, or to mark “do not translate,” “legal hold,” etc.
* Use **taxonomy validations** on content types to **require** certain concepts (e.g., each Article must have at least one “Topic”). ([Contentful][4])

---

# 5) How they appear in APIs

## 5.1 REST – Content Delivery API (CDA)

Entries and assets include `metadata`:

```json
{
  "sys": { "...": "..." },
  "fields": { "...": "..." },
  "metadata": {
    "tags": [
      { "sys": { "type": "Link", "linkType": "Tag", "id": "news" } }
    ],
    "concepts": [
      { "sys": { "type": "Link", "linkType": "Concept", "id": "topic/sports/football" } }
    ]
  }
}
```

**Filter by public tags**:

* Any of (`in` / `all` / `exists`):

```
?metadata.tags.sys.id[in]=news,updates
?metadata.tags.sys.id[all]=news,updates
?metadata.tags[exists]=true
```

**Filter by taxonomy concepts**:

* Match any of the IDs:

```
?metadata.concepts.sys.id[in]=topic/sports,topic/news
```

* Require all:

```
?metadata.concepts.sys.id[all]=topic/news,region/emea
```

* Include descendants of a concept (helpful with hierarchies):

```
?metadata.concepts.descendants[in]=topic/sports
```

These operators are documented for tags and concepts on the CDA. ([Contentful][5])

> Note: Only **public tags** appear in CDA/CPA; **private tags** are not delivered. ([Contentful][2])

## 5.2 GraphQL Content API

Every entry/asset type exposes:

```graphql
contentfulMetadata {
  tags { id name }  # only public tags
}
```

**Filter by tag presence/IDs**:

```graphql
query ($tagIds: [String!]) {
  entryCollection(where: {
    contentfulMetadata: {
      tags_exists: true
      tags: { id_contains_some: $tagIds }
    }
  }) {
    items { sys { id } contentfulMetadata { tags { id name } } }
  }
}
```

Supported filters: `tags_exists`, and in `tags`: `id_contains_some`, `id_contains_all`, `id_contains_none`. ([Contentful][6])

## 5.3 REST – Content Management API (CMA)

* Manage tags programmatically (`/spaces/{spaceId}/environments/{env}/tags`) and read **private + public** tags.
* Query entries/assets with the same `metadata.tags.*` operators as CDA.
* Taxonomy (concepts/schemes) is also exposed for automation and content type validations. ([Contentful][7])

---

# 6) Modeling guidance & patterns

## When to choose taxonomy

* You need **navigation, category pages, or faceted search** with hierarchical filters (e.g., **Department → Category → Subcategory**).
* You need cross-space/large-team **consistency** and want a **controlled vocabulary** (no free-typing).
* You plan to **analyze content coverage** or **personalize** by defined concepts. ([Contentful][1])

**Pattern**

1. Define **concept schemes** (e.g., “Topic,” “Region,” “Audience”) and build hierarchies in Taxonomy Manager.
2. On each content type, enable **taxonomy validations** (e.g., “Require at least 1 Topic”).
3. Train editors to assign concepts; **saved views** + **concept filters** speed up editorial tasks. ([Contentful][3])

## When to stick with tags

* You need **internal flags** for workflow (“Needs review,” “Legal approved”), or to power **role-based content permissions** and editorial views.
* You need **simple public grouping** with no hierarchy (e.g., “featured”). ([Contentful][1])

**Do**

* Define a small, intentional set of tags; prefer **private** for operational flags.
* If you expose tags to the front end, make them **public** and **treat IDs as canonical** (IDs don’t change; names do). ([Contentful][2])

**Don’t**

* Overload tags to mimic deep category trees—use taxonomy for that. ([Contentful][1])

---

# 7) Editor experience & UI tips

* **Tags UI:** Quick add/remove on entries & assets; filter list views by tag; bulk-apply tags. Visibility filter shows **Public/Private** tag lists. ([Contentful][8])
* **Taxonomy UI:** Create **concepts** and **concept schemes**, manage broader/narrower relations, and assign to entries; only org owners/admins/devs can access the manager. ([Contentful][3])

---

# 8) Performance & API querying tips

* GraphQL’s `contentfulMetadata.tags` adds a **fixed small complexity** (1 per item), regardless of number of tags—handy for list pages that display tag chips. ([Contentful][6])
* Prefer **metadata filters** (tags/concepts) over text search when building content pickers or feeds—they’re **faster & more precise**. ([Contentful][2])
* For classic “category → entries” pages, use **concept descendant filters** in CDA to pull a category with all nested children. ([Contentful][5])

---

# 9) Code snippets you can reuse

## 9.1 GraphQL – entries by tag (Next.js, fetch)

```ts
const query = /* GraphQL */ `
  query PostsByTags($tagIds: [String!], $limit: Int = 20) {
    blogPostCollection(
      where: { contentfulMetadata: { tags: { id_contains_some: $tagIds } } }
      limit: $limit
      order: [sys_publishedAt_DESC]
    ) {
      items {
        sys { id }
        title
        contentfulMetadata { tags { id name } }
      }
    }
  }
`;
```

Uses `id_contains_some` filter on public tags. ([Contentful][6])

## 9.2 REST – entries by concepts (CDA)

```http
GET https://cdn.contentful.com/spaces/{SPACE}/environments/{ENV}/entries
  ?access_token=...
  &metadata.concepts.sys.id[in]=topic/technology,region/emea
```

or include descendants:

```http
&metadata.concepts.descendants[in]=topic/technology
```

([Contentful][5])

## 9.3 REST – entries by tags (CDA)

```http
GET .../entries?metadata.tags.sys.id[in]=featured,news
```

`[all]` requires all listed tags; `[exists]` tests presence. ([Contentful][5])

## 9.4 CMA – create a public tag (JS Management SDK)

```ts
import { createClient } from 'contentful-management';
const client = createClient({ accessToken: process.env.CTF_CMA_TOKEN });

const env = await (await client.getSpace(SPACE)).getEnvironment(ENV);
await env.createTag('news', { name: 'News', visibility: 'public' }); // ID immutable
```

(Managing tags is supported via CMA; IDs are immutable; visibility chosen at creation.) ([Contentful][2])

---

# 10) Migration guidance (from tags to taxonomy)

1. **Inventory current tags** (esp. public ones used on the front end).
2. **Design concept schemes** mirroring your IA (Topic/Region/Audience).
3. **Create concepts** in Taxonomy Manager; attach to content types with **validations** (optionally required). ([Contentful][3])
4. **Backfill assignments**:

   * Script via CMA: read tag usage → resolve to concept IDs → update entries’ **concept assignments**.
5. **Update queries**: switch front-end filters from `metadata.tags.*` to `metadata.concepts.*` (and use `descendants` where helpful). ([Contentful][5])
6. **De-emphasize legacy tags** used for classification; keep **private workflow tags**.

---

# 11) Common gotchas

* **Tag visibility can’t be changed later**; create the correct type (public/private) from the start. ([Contentful][2])
* **Tag IDs ≠ names**: front ends should key on **ID** (names are editable). ([Contentful][2])
* **Private tags won’t appear** in CDA/CPA/GraphQL; only via CMA. ([Contentful][2])
* **Hierarchies?** Use **taxonomy**, not tags. ([Contentful][1])
* **Regex validations** elsewhere (e.g., slugs) now use **RE2** (stricter); update patterns if you reference concepts/slugs in validations. ([Contentful][9])

---

# 12) Bonus: editor & AI assist

* Editors can **search/filter & save views** by concepts to speed up workflows. ([Contentful][10])
* You can auto-suggest or auto-apply concepts using **AI-powered taxonomy assignment**, then review before publishing. ([Contentful][11])

---

## TL;DR

* **Use taxonomy for classification** you (and your users) rely on—hierarchies, filters, nav, personalization.
* **Use tags for internal workflow and governance**, or simple public groupings when hierarchy isn’t needed.
* **APIs**: Tags show up under `metadata.tags` (public only in delivery); taxonomy under `metadata.concepts` with powerful filters (including descendants). ([Contentful][5])

If you want, tell me your use case (blog, product catalog, docs, etc.) and I’ll sketch the exact taxonomy schemes, content type validations, and the corresponding CDA/GraphQL queries you’ll need.

[1]: https://www.contentful.com/help/taxonomy/ "Taxonomy | Contentful Help Center"
[2]: https://www.contentful.com/help/tags/ "Tags | Contentful Help Center"
[3]: https://www.contentful.com/help/taxonomy/taxonomy-manager/ "Taxonomy manager | Contentful Help Center"
[4]: https://www.contentful.com/help/taxonomy/application-of-taxonomy/taxonomy-content-type-validations/ "Content type validations | Contentful Help Center"
[5]: https://www.contentful.com/developers/docs/references/content-delivery-api/?utm_source=chatgpt.com "Content Delivery API"
[6]: https://www.contentful.com/developers/docs/references/graphql/ "GraphQL Content API | Contentful"
[7]: https://www.contentful.com/developers/docs/references/content-management-api/?utm_source=chatgpt.com "Content Management API"
[8]: https://www.contentful.com/help/tags/creating-tags/?utm_source=chatgpt.com "Create tags | Contentful Help Center"
[9]: https://www.contentful.com/developers/api-changes/?utm_source=chatgpt.com "API Changes"
[10]: https://www.contentful.com/help/taxonomy/taxonomy-search-and-filter/ "Taxonomy: search and filter | Contentful Help Center"
[11]: https://www.contentful.com/help/ai-powered-taxonomy-assignment/?utm_source=chatgpt.com "AI-powered taxonomy assignment"
