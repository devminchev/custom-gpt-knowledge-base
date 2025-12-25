# Current Search Overview - Analysis

Overview

Search must validate a full availability chain across five Contentful entities:

SiteGameV2 → Section → View → NavLink → Navigation + venture scoping.

Relationships are spread across multiple content types and stored in OpenSearch as separate documents.

This forces the Search Lambda to run sequential dependency-chained queries — effectively doing joins in application code.

The pattern causes:

N+1 query flows

Low cache hit ratios

High OpenSearch CPU/memory usage

→ p95 latency spikes and escalating cost.

API Gateway’s 5-min TTL cache is ineffective — high-entropy queries (free text + multi-filters) mean low cache locality.

Game Search Availability Rules

A SiteGameV2 is only available for a given venture if all conditions are true:

SiteGameV2
Published
Has Venture reference
Section (contains SiteGameV2 in games[])
Published
Has Venture reference
View
Published
Has Venture reference
NavLink
Published
Has Venture reference
Navigation

Contains the NavLink in its navigation[] array

(Published; acts as taxonomy/collection validator)

If any link/state/venture condition fails → SiteGameV2 is unavailable.

How the Current Search API Works
Runtime Request Flow
Client sends GET /search?q=...&filters=... to API Gateway.
API Gateway calls Search Lambda (TTL=5m; likely cache miss).
Search Lambda executes dependent OpenSearch queries:
Q1: Find candidate SiteGameV2 by text/fuzzy search.
Q2: Filter to published SiteGameV2 (venture check).
Q3: Find Sections containing these SiteGameV2.
Q4: Find Views linking those Sections.
Q5: Find NavLinks linking those Views.
Q6: Validate Navigation container includes those NavLinks.
Intersect all ID sets → Final allowed SiteGameV2 list.
Fetch and return documents.
OpenSearch Reality
games index contains GameV2 ↔ SiteGameV2 (parent–child).
Section/View/NavLink/Navigation live in other indices or doc types.
Cross-type venture validation forces runtime stitching.
Why It’s Inefficient & Expensive
Application-level joins
Multiple OS queries + client-side intersections.
CPU-heavy scans and 5–6 network round trips.
Sequential dependencies → added latency.
Low cache hit rate
High-entropy queries from free text + filters.
API Gateway cache sees little reuse.
Late filtering
Large candidate sets from text search before venture/publish filtering.
OS processes unnecessarily large working sets.
Partial parent–child coverage
Works only for Game↔SiteGame.
Section/View/NavLink still require cross-index lookups.
Underutilized OS cache layers
Query shapes rarely repeat.
Five+ dependent steps
Latency compounds with each ID-dependent query.
Sequence Diagrams
Current Request Flow
sequenceDiagram
    participant C as Client
    participant AGW as API Gateway (5m TTL)
    participant L as Search Lambda
    participant OS as OpenSearch

    C->>AGW: GET /search?q=...&filters=...
    AGW->>L: Invoke (likely miss)
    Note over L: Build 5+ step query plan

    L->>OS: Q1 SiteGameV2 (text/fuzzy)
    OS-->>L: siteGameIds[]
    L->>OS: Q2 Published & venture filter
    OS-->>L: publishedSiteGameIds[]
    L->>OS: Q3 Sections with siteGameIds
    OS-->>L: sectionIds[]
    L->>OS: Q4 Views with sectionIds
    OS-->>L: viewIds[]
    L->>OS: Q5 NavLinks with viewIds
    OS-->>L: navLinkIds[]
    L->>OS: Q6 Navigation container check
    OS-->>L: validNavLinkIds[]
    L->>OS: Fetch final docs
    OS-->>L: documents
    L-->>AGW: JSON
    AGW-->>C: 200 OK


Availability Chain
sequenceDiagram
    participant SG as SiteGameV2
    participant Sec as Section
    participant Lay as View
    participant Cat as NavLink
    participant Cats as Navigation
    participant Ven as Venture

    SG->>SG: published? AND venture linked?
    SG->>Sec: in games[]?
    Sec->>Sec: published? AND venture linked?
    Sec->>Lay: linked to View?
    Lay->>Lay: published? AND venture linked?
    Lay->>Cat: linked to NavLink?
    Cat->>Cat: published? AND venture linked?
    Cat->>Cats: present in Navigation?
    Note over SG,Cats: All checks pass → AVAILABLE


The Cost Spikes

API Gateway

Low hit ratio → passes most queries downstream.

Lambda

Executes N+1 queries.
In-memory intersections.
Serialization overhead.

OpenSearch

Multiple queries with changing ID filters.
Cross-index traversals act like joins.
Fuzzy search expands the working set early.
The Problem
Correctness depends on runtime deep graph traversal.
No pre-flattened ancestor/venture info in search docs.
Every query redoes the 5-hop chain.
Cache layers can’t help due to query uniqueness.
Scalability breaks as filters/relationships grow.
1 Feature Gaps
Filters require cross-index joins → slow & costly.
Facets can’t be computed instantly because attributes are not stored together.
Personalization requires availability checks mid-query → impractical for re-ranking.
Dynamic content blocks (Trending, Because you played X) can’t be built without pre-flattened data.
Cache reuse is almost zero for common filter sets.
2 Architecture Limits
Advanced Search Goal	Why Current Design Fails
Instant faceted filters	No single doc has all fields.
Explore blocks	Need theme/provider groupings in one doc.
Personalized ranking	Rejoins required; too slow.
Autosuggest	No central index with all searchable fields.
Promo weighting	Ranking signals not stored in search docs.
Recommended Approach — Taxonomy + Tagging + Denormalisation
1 Taxonomy
Stable hierarchical categories (Slots → Themes → Egypt/Greek/Fruit).
Store navLinkPath[] in each game doc.
Venture-aware, versioned, compliance-ready.
2 Tagging
Game-level tags: themes, mechanics, features.
Operational tags: featured, promoted, new.
Computed tags: similarity clusters, popularity segments.
Stored in tags[] in same doc.
3 Denormalization
One doc per SiteGameV2 × Venture in available-sitegames.
Include:
Availability boolean
Venture ID
Flattened ancestors
Taxonomy paths
Tags & facets
Ranking signals
Search text fields
4 Reverse Lookup Indices
Side indices for tag→gameIds, taxonomy→gameIds.
For real-time content block lookups.
5 Event-Driven Updates
Contentful App Functions trigger reindexing on publish/unpublish/link changes.
Keeps index always in sync.
Expected Outcomes
Latency: Single OS query instead of 5–6 chained queries.
Scalability: Handles high concurrency and burst traffic.
Feature Unlock: Advanced facets, personalization, dynamic explore.
Cost Reduction: Lower CPU/memory by eliminating redundant OS scans.
11. Non-Functional Requirements
Latency: p95 < 250 ms; autosuggest < 80 ms.
Correctness: Always enforce availability + venture scope.
Scalability: Handle bursty keystroke traffic.
Resilience: Timeouts, partial results, circuit breakers.
Observability: Query logs, zero-hit analysis, dashboards.
Governance: Taxonomy versioning, tag hygiene jobs.
🔁 Before vs After — High-Level Architecture (Flow)
flowchart LR
    %% BEFORE: CURRENT (LEFT)
    subgraph A[BEFORE — Current Search Architecture]
      direction TB
      C[Client (Web/App)]
      AGW[API Gateway (TTL=5m)]
      L[Search Lambda]

      subgraph OS1[OpenSearch Cluster]
        G[(games index\\nGameV2↔SiteGameV2 parent-child)]
        S[(sections index)]
        V[(views index)]
        NL[(navLinks index)]
        N[(navigations index)]
      end

      C --> AGW --> L
      L -->|Q1 text/fuzzy| G
      L -->|Q2 published+venture| G
      L -->|Q3 resolve sections| S
      L -->|Q4 resolve views| V
      L -->|Q5 resolve navLinks| NL
      L -->|Q6 validate in navigation| N
      L -->|Intersect ID sets| L
      L -->|Fetch final docs| G
      L --> AGW --> C
    end

    %% AFTER: TARGET (RIGHT)
    subgraph B[AFTER — Advanced Search Architecture]
      direction TB
      C2[Client (Web/App)]
      AGW2[API Gateway (param cache)]
      L2[Search Lambda]

      subgraph OS2[OpenSearch Cluster]
        AS[(available-sitegames index\\n1 doc per SiteGame×Venture\\n+ taxonomy + tags + facets + signals)]
        RL[(Optional reverse lookups\\n tag→gameIds, taxonomy→gameIds )]
      end

      subgraph ETL[Event-Driven Materialization]
        CF[Contentful App Functions\\n(webhooks on publish/unpublish/link)]
        M[Lambda: materialize-availability\\nflatten availability + ancestors + venture]
      end

      C2 --> AGW2 --> L2
      CF --> M --> AS
      L2 -->|Single bool query\\nmust: venture & isAvailable\\n+ text + filters + re-rank| AS
      L2 -. optional .-> RL
      L2 --> AGW2 --> C2
    end


⏱️ Before vs After — Request Sequence
A) BEFORE: Dependency-Chained Queries
sequenceDiagram
    participant C as Client
    participant AGW as API Gateway (5m TTL)
    participant L as Search Lambda
    participant OS as OpenSearch

    C->>AGW: GET /search?q=...&filters=...
    AGW->>L: Invoke (likely cache miss)
    Note over L: Build 5+ step plan (joins-in-app)

    L->>OS: Q1 SiteGameV2 text/fuzzy
    OS-->>L: siteGameIds[]
    L->>OS: Q2 publish+venture filter
    OS-->>L: publishedSiteGameIds[]
    L->>OS: Q3 sections containing games
    OS-->>L: sectionIds[]
    L->>OS: Q4 views for sections
    OS-->>L: viewIds[]
    L->>OS: Q5 navLinks for views
    OS-->>L: navLinkIds[]
    L->>OS: Q6 validate in navigation container
    OS-->>L: validNavLinkIds[]

    Note over L: Intersect all ID sets → finalAllowedIds[]
    L->>OS: Fetch final documents
    OS-->>L: docs
    L-->>AGW: 200 JSON
    AGW-->>C: Results


B) AFTER: Single Selective Query
sequenceDiagram
    participant C as Client
    participant AGW as API Gateway (param cache/CDN)
    participant L as Search Lambda
    participant OS as OpenSearch (available-sitegames)

    C->>AGW: GET /search?q=...&filters=...
    AGW->>L: Invoke
    L->>OS: Single bool query
    Note right of OS: must: ventureId & isAvailable\\n+ multi_match (title, aliases, provider, tags)\\n+ filter (RTP/volatility/provider/themes)\\n+ should (popularity/promo/similarTo)
    OS-->>L: hits + facets
    L-->>AGW: 200 JSON
    AGW-->>C: Results


Availability Chain (Unchanged Semantics, Different Timing)
flowchart LR
    SG[SiteGameV2] -->|linked in games[]| Sec[Section]
    Sec -->|linked| View[View]
    View -->|linked| NL[NavLink]
    NL -->|present in| Nav[Navigation (container)]
    classDef ok fill:#e3f7e9,stroke:#0a8f3c,color:#0a8f3c;
    classDef bad fill:#fde8e8,stroke:#d03a3a,color:#a12222;

    %% BEFORE: evaluated at query-time (expensive)
    subgraph BeforeEval[BEFORE]
      BE(Query-time traversal):::bad
    end

    %% AFTER: evaluated at index-time (cheap at query)
    subgraph AfterEval[AFTER]
      AE(Materialize isAvailable + venture at write-time):::ok
    end


Summary
BEFORE: Lambda performs 5–6 dependent OS queries + in-memory set intersections to prove availability per request.
AFTER: Contentful events precompute & store availability, taxonomy path, tags, and facets inside a single index (available-sitegames). Search is one selective query.
Dimension	BEFORE (Current)	AFTER (Target)
Availability proof	Runtime traversal across 5 content types	Precomputed at index-time (doc field isAvailable)
Venture scoping	Checked at each hop during query	Stored per doc (ventureId)
Filters & facets	Cross-index joins; slow	In-document fields; fast aggregations
Ranking signals	External/late	Embedded (popularity, promoWeight, similarTo)
Latency path	5–6 round trips + intersections	Single OS query
Cache locality	Low (high-entropy shapes)	Higher (stable filter shapes)
Cost profile	High CPU/mem; N+1	Lower; selective scans
Dynamic blocks	Hard (joins)	Easy (taxonomy/tags filters)
