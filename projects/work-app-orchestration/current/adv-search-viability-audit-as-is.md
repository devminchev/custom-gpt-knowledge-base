---
title: "Advanced Search Technical Viability Audit: As-Is System Analysis"
tags: [projects, work-app-orchestration, current]
aliases: []
---
# Advanced Search Technical Viability Audit: As-Is System Analysis

> Context addenda you gave just now are **treated as ground truth** (OpenSearch cluster screenshots, API Gateway cache TTL, and the clarification that FE currently does the “search” by filtering BE’s *full* game list by name). I’ve merged those facts with the Work App System knowledge base below and **cited** the relevant internal docs wherever possible.

---

## 1. Problem Framing & Intent

* **Business intent**: turn Search into a *fast*, *forgiving*, *intent-aware* discovery surface that increases launches and supports curated/commercial priorities (popular searches, collections, quick filters) while preserving strict venture/platform/environment/session visibility.
* **User intent**: keystroke-level UX (no results until 2 chars, then live updates) with fuzzy tolerance, semantic understanding of metadata (“Big Wins”, “Provider: Pragmatic”, stake range, themes), and *always show something* behavior.
* **Current reality**: API returns *availability-scoped* site games; FE filters by **name only** and calls this “search”. There is **no fuzzy/semantic relevance** and no server-side typed suggestions. (From your side-note + docs).
* **Core tension**: product demands **interactive**, tolerant, intent-driven retrieval; current backend enforces **read-time composition** across multiple indices plus **parent/child** joins—antagonistic to keystroke SLAs and reranking.

---

## 2. Product Feature Goals & Success Criteria

### 2.1 Typed search & interaction model

* **No results until at least two characters** are entered. Then the **results grid updates dynamically** while the keyboard remains open (mobile). **Sort controls** may be used with the keyboard up. **Finishing** typing shows the full relevant set.
* **Recent Searches** and **Popular Searches** appear in a drawer below the field; tapping any **executes immediately** and may **auto-fill** the field and navigate to results.

### 2.2 Fuzzy + “never a dead end”

* **Fuzzy logic** to **always display results** and tolerate typos/misspellings—explicit requirement to avoid “dead ends.” (Fails as-is per audit; noted here strictly as goal.)

### 2.3 Semantic search

* **Semantic search** prioritizing *intent over keywords* and **using game metadata** (e.g., providers, features, jackpots/high multipliers). (Fails as-is per audit; listed here as goal.)

### 2.4 Quick Filters (always visible) & Game Filter modal

* **Quick Filters (chips) are always visible** on the Search page; tapping chips adds **active filter chips** under the field; they are removable individually and via **clear all**; grid **updates immediately**. Comparative patterns: **Amazon** counters, **Spotify** clear-all. **Must Have**.

* **Quick Filters can be added in Contentful**; Product/Gaming Ops curates them. **Must Have**.

* **Quick Filters are configurable in Contentful** (order/flow). **Must Have**.

* **Quick Filters follow a defined flow** (e.g., Slots → Feature → Provider → Reel). **Must Have**.

* **Game Filter modal** exposes the same facet flow with **“SHOW X GAMES”** confirmation; categories include Slots, Jackpots, Live Casino, Table; facets: **Stake Range**, **Game Provider**, **Type of Game**, **Reels/lines**, **Themes**, etc.

### 2.5 Default content & collections

* **Configure default content** for the Search Page (to avoid blank state) via CMS: **Game Collections**, **Popular Games**, etc. **Should Have**.
* **Game Collections** visible as a carousel; clicking navigates to the corresponding results. **Could Have**.

### 2.6 Analytics & error handling

* **Google Analytics** updated to capture enhanced search behaviors. **Must Have**.
* **Error handling**: when data issues occur, fall back to a **basic search** behavior (graceful degradation). **Must Have**.

### 2.7 Open questions (product)

* Logged-in vs logged-out **experience parity**; **which filters** to include; how to define **Popular Searches** (curated vs “most searched”).

### 2.8 Summary

* **Typed results from 2 characters, live updates** → **Fails at quality bar**: the UX requires keystroke-speed updates, but the current flow **blocks** on venture→navigation→views→sections lookups **before** it can even query `games-v2` and join parent game fields. Keystroke cadence isn’t compatible with those sequential dependencies.  
* **“Fuzzy logic”: never a dead end** → **Fails**: no fuzzy pipeline is implemented; the hot path is optimized for **exact** availability-scoped retrieval and parent/child joins, not tolerant matching. 
* **Semantic search (intent over keywords)** → **Fails**: no embeddings, no reranker; BM25 + filters cannot satisfy “intent” retrieval such as “Big Wins”→jackpots/high multipliers.  
* **Semantic uses metadata** → **Fails**: metadata exists, but the runtime design doesn’t compute or serve **semantic** signals; the join-bound flow cannot express intent mapping.  
* **Quick Filters (always visible) + immediate recompute** → **Partial → fails at quality bar**: every toggle implies re-walking availability and re-joining `games-v2`, which creates tail latency spikes.  
* **Collections/Default content surfaced on Search** → **Partial→fragile**: collections are sections; surfacing them **per request** with availability checks adds cost and variance. 
* **Commercial weighting (order by margin/personalisation)** → **Partial**: post-query rerank is possible, but **stable low-latency** ordering under the join-bound path is unlikely. 
* **Speed (“fast results”)** → **Fails** at target: joins + N+1 lookups + low cache locality prevent consistent sub-second/interactive performance. 

> Net: **Multiple Must-Haves fail outright** (Fuzzy, Semantic, Typed suggestions), others are **partial** but miss the UX quality bar.  


---

## 3. Scope, Assumptions & Constraints

* **Scope**: Web + native apps across *all ventures* (tenants), platforms (**web/ios/android**), locales; honors **venture/platform/environment/session** visibility.
* **Assumptions**: Quick Filters curated by Product/Gaming Ops via CMS; **2-character** threshold for live results; **typed suggestions** expected.
* **Operational constraints**:

  * **API Gateway caching = 5 min TTL** (your note); high-entropy query keys mean **low hit rates** for search even with caching.
  * **OpenSearch prod cluster (eu-west-2)** from screenshots:

    * **3 data nodes**: `r5.2xlarge.search`, **EBS gp3 100 GiB**, **3,000 IOPS**, **125 MiB/s**; **3 dedicated masters** `m5.large.search`; **3-AZ with standby**; **public access**; **IPv4**.
    * **Snapshots**: **hourly**; **Field data cache allocation: 20**; **Max clause count: 1024**; **Natural language query generation: enabled**.
    * **Shards**: **291 total** (97/active-AZ); **Searchable docs** ≈ **5.0M**; **Cluster Green**; **JVM memory pressure** ~30–60% (varies); **max system memory util** often >90% (host-level); **Auto-Tune events** ≈ none in the window. *(All qualitative readings from your screenshots.)*
  * **Write policy**: prod uses **`refresh=true`** (immediate visibility), non-prod **`wait_for`**.
  * **Parent/child routing** for `siteGameV2` → shard co-location.

---

## 4. Current System Overview (As-Is Architecture)

* **Public contract & flow**: API Gateway → Search Lambda → multi-index reads (**ventures → navigation → links → views → sections**) → final query to **`games-v2`** with **`has_parent`** (`siteGame` child → `game` parent) + **`inner_hits`** → Lambda **merges** (game/siteGame + media/tags/nav) → JSON list.
* **Availability chain** (hard gate): a site game is **available** only if **Navigation → Link → View → Section → SiteGame** all pass venture/publish rules.
* **FE behavior today**: receives the **available site game list** and **filters client-side by game name**; no server-side fuzzy/semantic; **BE is not a real search** engine from the UX standpoint. *(Your side-note.)*

---

## 5. Current Capabilities & Limitations

### Overview
* **Hot-path multi-hop composition**: The request *must* resolve **venture → navigation → links → views → sections** before it can query `games-v2` and then **join** to parent `game` with `inner_hits`. This bakes in **sequential dependency latency** and **read amplification**.   
* **Availability validated at read time** across **five** entities (Navigation→Link→View→Section→SiteGame). Any minor editorial change affects search immediately, increasing **blast radius** and tail variance.  
* **Parent/child join** (`has_parent` + `inner_hits`) on `games-v2` **scales superlinearly** with catalog/sections growth; increases heap/GC pressure and p95/p99.  
* **Low cache locality by design**: results depend on **many indices + venture/platform/env + locale + session + navigation labels**; cache keys fragment, so API Gateway’s **5-min TTL** (your note) brings **low hit rates** for search. 
* **Per-request localisation & media selection** further expands compute and payload size.  

### 5.1 Capabilities

* **Correct venture/platform/environment/session scoping** via the availability chain and filters.
* **Parent/child enrichment**: pulls canonical `gameV2` fields with **`has_parent`** join.
* **Indexing discipline**: environment-aware **write aliases**, **routing** for `siteGameV2`, **archive** handling, and curated payloads (minimal JSON).

### 5.2 Limitations / Incapabilities (technical)

* **Runtime joins on hot path** (multi-hop + `has_parent`/`inner_hits`) → **read amplification**, **heap/GC pressure**, **p95/p99 spikes**.
* **Low cache locality** because results depend on many indices + session/platform/env + localization + nav labels → **poor API Gateway cache efficacy** (even with 5-min TTL).
* **Interactive UX not viable**: typed suggestions/live updates conflict with **sequential lookups** and joins. **Fuzzy** and **semantic** capabilities are **absent**.
* **Operational fragility**: editorial churn modifies multiple entities → **blast radius** and inconsistent user experience during updates.

---

## 6. Baseline Metrics (Performance, Reliability, Cost)

> We avoid inventing numbers; below are **observable** or **documented** signals.

* **Cluster health**: **Green**; **3 data nodes**; **291 shards**; **~5.0M** searchable docs; **JVM pressure** mostly 30–60% with spikes; **host memory** often high (>90%); **no persistent snapshot failures**; **Auto-Tune events** ≈ none. *(Screenshots.)*
* **Search latency (cluster KPI panel)**: tight band with visible variance; spikes correlate with traffic peaks and indexing bursts. *(Screenshots.)*
* **Indexing rate/latency**: periodic high spikes (editorial/webhook bursts), occasional latency outliers; deleted docs spikes (rollovers/edits). *(Screenshots.)*
* **API cache**: **5-min TTL** for all endpoints; for `/search`, **cache hit rate is low** by design (free-text + multi-filters + user/session dimensions).
* **Cost drivers** (qualitative): parent/child joins, multiple index scans, low cache hits, Lambda stitching → **higher unit cost** per call.

---

## 7. Content Model Review (Contentful)

* **Canonical vs wrapper**

  * `gameV2`: vendor-agnostic, localized, rich media and **gamePlatformConfig** metadata.
  * `siteGameV2`: venture-scoped envelope (visibility, venture link, optional overrides), **required reference** to `gameV2`.
* **Visibility & compliance rules**: render only if **both** `gameV2.platformVisibility` and `siteGameV2.platformVisibility` allow the platform and `siteGameV2.environmentVisibility` includes the runtime environment; `liveHidden` acts as kill switch.
* **Field catalogs & enums**: explicit enum vocabularies (vendors, tags, platform visibility); defaults for required booleans; tag case hygiene caveats.
* **`gamePlatformConfig`**: authored via a **custom Contentful App**; structured schema representing features, types, providers, volatility, stakes, languages, etc.; downstream systems should **read from this object**.

---

## 8. Webhook & Indexing Review (Contentful → OpenSearch)

* **Suites**: **V2 (10 hooks)** and **V3 (12 hooks)** covering ventures, navigation, views, **game-sections**, marketing, themes, ML, `games (v3)`, `siteGames (v3)`, and deletes/archives.
* **Events by env**: **prod** uses publish/unpublish; **dev/stg** also use save/auto_save to speed iteration. **Archive** pushes to a dedicated archive index.
* **Write pattern**: always to **aliases**, not raw indices; **`games-v2-w`** receives both `gameV2` (no routing) and `siteGameV2` (**routed by `gameId`**); **`game-sections-w`, `views-w`, `navigation-w`** etc.
* **Refresh behavior**: **prod `refresh=true`**, non-prod `wait_for`.
* **Payloads**: **minimal, normalized** JSONs with environment filter baked in, and Bynder/media fields denormalized for direct rendering.

---

## 9. Search Behaviour & Relevance Review

* **Actual behavior today**: FE filters a **pre-filtered availability list** by **name**. No server-side **fuzzy**, **synonyms**, **semantic**, **reranking**, or **typed suggestions**. (Your side-note + audit.)
* **As-is engine**: OpenSearch **BM25**-style matching over `games-v2` with **parent/child** enrichment and runtime availability checks; relevance is implicitly constrained by section membership and venture scoping rather than *intent*.
* **Product expectation gap**: *typo-tolerant* results, *intent → metadata mapping*, and *commercial/curation* signals (Popular Searches, Collections) shaping results and **typed** UX. These **do not exist** in the current path.

---

## 10. API Contracts & Data Flows (Read/Write Paths)

* **Read path** (Search): parse request → **venture lookup** → **navigation→links→views→sections** (with **session/env/platform** filtering) → `games-v2` query (**`has_parent` + `inner_hits`**) → **merge** into final games array.
* **Availability/Correctness gates**: all five entities + venture must *simultaneously* pass (publish + venture link) or the site game is **unavailable**.
* **Write path** (indexing): Contentful webhooks → **write aliases** with env filters, routing, archive flows; **prod** refresh immediate.

---

## 11. Operational Readiness (Runbooks, Monitoring, DR)

* **Runbook guardrails**: write to **aliases** only (`*-w`), include **env filters**, **routing** for `siteGameV2`, and set **refresh policy** appropriately.
* **Error handling**: structured `{code, message}` with logged diagnostic `ErrorCode`.
* **Observability today**: OpenSearch dashboards show **SearchRate**, **SearchLatency**, **IndexingRate/Latency**, **JVMPressure**, **InvalidHostHeaderRequests**; cluster status Green across the window. *(Screenshots.)*
* **Backups**: **Automated hourly snapshots**. *(Screenshot.)*
* **DR posture**: not explicitly documented beyond snapshots; no active cross-region read replica noted in the docs or screenshots.

---

## 12. Feasibility Evidence (Spikes/Experiments & Findings)

* **As-is feasibility judgement**: several **Must-Haves fail outright** (fuzzy, typed suggestions, semantic); others are only **partial** and miss the UX quality bar due to **latency variance** and **operational fragility**.
* **Root causes verified**: **read-time composition** + **join-heavy** queries + **multi-index dependency** + **per-request localization/media** → tail latency and cost.

---

## 13. Risks, Constraints & Unknowns

### 13.1 Risks (technical & operational)

* **Performance risk**: **superlinear** cost growth with catalog/menu breadth; **p95/p99** instability under content/traffic spikes.
* **Operational fragility**: any editorial update affecting navigation/view/section **ripples into availability**, widening the blast radius and cache thrash.
* **Cost risk**: OS compute (joins), Lambda stitching, cache misses.
* **Correctness risk**: enforcing availability at read time invites transient inconsistencies during publish/unpublish churn.

### 13.2 Constraints

* **Strict visibility** (venture/platform/env/session) must remain non-negotiable.
* **CMS-driven curation** (Quick Filters, default Search content, Popular Searches) is a product requirement.
* **Existing cluster shape** (3× r5.2xlarge + gp3 100 GiB + 291 shards) and **public endpoint** posture as shown; any major change implies infra planning. *(Screenshots.)*

### 13.3 Unknowns to resolve

* Target **SLOs/SLA** for `/search` (p50/p95/p99, error budget), by **venture/platform/locale**.
* **Peak and sustained RPS**, concurrency, and request mix (free-text vs filtered).
* Current **cache hit rate** at API Gateway/Lambda layer for search.
* **Index mappings** alignment to `gamePlatformConfig` (which fields must be queryable/sortable/aggregatable).
* **Personalization/commercial weighting** data signals source (GGR, most played, stake) and refresh cadence.
* **DR** objectives (RPO/RTO) beyond automated snapshots.

---

## 14. Gap Analysis (As-Is vs To-Be)

| Dimension                                    | To-Be (product)                                                         | As-Is (system)                                                                         | Gap & Why                                                                    |
| -------------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **Typed search (≥2 chars, live grid)**       | Interactive, low and stable latency; keyboard open; instant recompute   | Multi-hop reads + parent/child join + Lambda merge; FE filters name only               | **Large**: sequential dependencies + joins prevent keystroke responsiveness. |
| **Fuzzy tolerance (“never a dead end”)**     | Robust typo tolerance & proximity fallbacks                             | No fuzzy on BE; FE name filter only                                                    | **Large**: no fuzzy pipeline; multi-hop gates block tolerant fallbacks.      |
| **Semantic intent**                          | Metadata-aware intent mapping & rerank                                  | BM25 + availability filtering; no embeddings/reranker                                  | **Large**: no semantic infra or features present.                            |
| **Quick Filters (chips) always visible**     | Chips add/remove, immediate recompute, clear-all                        | Recompute would traverse availability + joins; tail spikes                             | **Medium–Large**: compute heavy for each toggle.                             |
| **Game Filter modal (facets)**               | Multiple facets (stake/provider/type/reel/themes) with **SHOW X GAMES** | Multi-facet = larger candidate sets + heavier joins                                    | **Medium–Large**: superlinear growth in join cost.                           |
| **CMS-curated Popular Searches/Collections** | Configurable & surfaced in UI                                           | Possible to store, but surfacing at keystroke speed conflicts with runtime composition | **Medium**: needs fast retrieval path for curated lists.                     |
| **Analytics**                                | GA events for enhanced search                                           | Existing basic tagging; not tailored to advanced search                                | **Small–Medium**: instrumentation work.                                      |
| **Reliability under editorial churn**        | Stable                                                                  | Read-time availability checks amplify churn                                            | **Large**: high blast-radius and cache thrash.                               |
| **Cost efficiency**                          | Predictable unit cost per query                                         | Joins + low cache locality + Lambda stitching                                          | **Large**: elevated OS compute & Lambda time.                                |

### * **Why Advanced Search Goals Don’t Fit the Current Architecture**

**Core mismatch:** The product assumes **fast, single-shot, tolerant, intent-aware retrieval**. The current design imposes **multi-hop composition + parent/child joins at query time** with runtime availability validation. Those two worldviews are **incompatible** for keystroke-level UX. 

* **Typed suggestions / live updates** conflict with **sequential dependencies** and **join cost**. You can’t hit the “results on second character” requirement consistently while walking five indices and then joining parent fields per keystroke.  
* **Fuzzy** requires broad candidate retrieval and tolerant ranking. The current pipeline is **availability-gated first**, which prunes aggressively **before** relevance logic can help; result: “dead ends.” 
* **Semantic** requires embeddings/rerankers and stable candidate sets. Join-bound, multi-index reads with low cache locality provide **neither** the performance headroom **nor** the deterministic candidate formation needed. 
* **Immediate filter recompute** (chips/modal) implies repeated **full availability resolution** and **join work** on each toggle — tail spikes, timeouts, UX stutter. 


---

## 15. Comparative Summary (Trade-offs & Impacts)

* **Strengths of current design**

  * Strong **visibility correctness** (venture/platform/env/session).
  * Clear **indexing discipline** (aliases, routing, env filters, archive).
* **Trade-offs incurred**

  * **High read amplification** (multi-index lookups + joins), **low cache locality**, **tail latency** and **cost**—especially at interaction cadence (typing, chip toggling).
  * **Operational fragility** with editorial changes (large blast radius).
  * **Feature ceiling**: fuzzy/semantic & typed suggestions fundamentally misfit the architecture.

*  **Where the Cost Spikes (anatomy):**
    1. **OpenSearch compute (dominant):**

    * `has_parent` + `inner_hits` on `games-v2` drives high CPU and heap churn as the number of **siteGames × sections** increases → **superlinear** query cost and GC pauses. 
    2. **Read amplification across indices:**

    * Venture, navigation, links, views, sections **per request** → multiple I/O and context filters **before** the final query; increases overall latency and **lowers cache hit ratio**. 
    3. **Lambda stitching time:**

    * Post-query **merge** of siteGame + parent game + derived navigation + localisation/media adds CPU & memory → **longer Lambda durations** per call. 
    4. **Cache fragmentation:**

    * High-entropy keys (free-text + multi-facet + venture/platform/env/locale/session) mean API Gateway’s 5-min TTL (as configured) delivers **minimal** reuse; every new keystroke becomes a near-unique cache key. 
    5. **Editorial churn → rework:**

    * Because visibility is validated **at read time**, routine publishes/unpublishes expand the **blast radius**, thrash caches, and **inflate unit cost** during busy edit windows. 

---

## 16. Decision-Readiness Checklist

* [ ] Target **latency SLOs** (p50/p95/p99) & **error budgets** for `/search` by platform/venture/locale.
* [ ] **Traffic profile**: current/peak RPS, query mix, facet usage, distribution of free-text vs filtered.
* [ ] **Cache telemetry**: API Gateway + any Lambda/edge cache hit/miss rates for search.
* [ ] **Index schema coverage** for **gamePlatformConfig** attributes that must support: full-text, filters, sort, and aggregation.
* [ ] **Curation inputs**: definition and data sources for *Popular Searches*, *Collections*, and *commercial weighting* (bets, GGR, play count).
* [ ] **DR posture**: confirm restore process and RPO/RTO targets beyond hourly snapshots.
* [ ] **Security posture**: confirm public access constraints, IP allowlists, and invalid-host-header patterns seen in dashboards (to ensure noise isn’t hiding issues). *(Screenshots show many InvalidHostHeaderRequests.)*
* [ ] **Shard strategy**: with **291 shards** on **3 data nodes**, confirm shard sizing/doc counts vs heap & GC patterns under peak.

---

## 17. Findings Summary (No Solutions)

* The **core issue** is architectural: **read-time composition** across Navigation→Link→View→Section→SiteGame combined with **`has_parent` + `inner_hits`** in `games-v2` turns every search into a **multi-stage join**. This design inherently produces **read amplification**, **low cache locality**, **heap/GC pressure**, and **tail latency spikes**—all of which are **toxic to keystroke-level, fuzzy, semantic, and multi-facet** experiences.
* Current FE “search” is **name-filtering** over a backend-filtered list; it **cannot** meet the product’s **fuzzy/semantic/interactive** expectations.
* The system’s **strength**—strict visibility correctness—comes at the cost of **performance variability**, **operational fragility** during editorial churn, and **elevated unit cost** per search.
* Given these facts, the **as-is** approach **does not fit** the advanced search goals and would require significant changes before discovery of solution options even begins.

* **Why the Current System Is Inefficient & Expensive**
    * **Read-time composition is the root inefficiency.** Each request performs **N+1 lookups** (venture→navigation→links→views→sections) and only then executes a **join-heavy** query to `games-v2`. This inflates latency and compute *per request*, independent of whether the user typed 2 or 20 characters.  
    * **Parent/child joins on the hot path** scale *worse than linearly* with catalog/menu breadth; they increase **heap pressure** and **GC churn** on OpenSearch — directly converting traffic spikes or broader menus into **cost spikes** and **p95/p99** instability. 
    * **Low cache locality** means more requests actually **hit compute** instead of cache — especially bad for **keystroke interactions** (every new prefix is a new, uncached query). Your 5-min TTL at API Gateway doesn’t change that fundamental characteristic. 
    * **Per-request localisation/media selection** adds branching and payload work **after** the join, compounding Lambda time and response size. 
    * **Operational fragility** (availability gating at read time) widens the **blast radius** of minor CMS edits and causes **cache thrash**, further driving cost and tail latency. 

    > Given these facts, the current **architecture flow puts expensive, variable work in the hot path** (multi-hop reads + parent/child joins + per-request localisation), which inherently **fights** the product’s advanced search objectives (keystroke responsiveness, fuzzy/semantic behavior, instant filter recompute) and makes the system **costly and fragile** as traffic and catalog complexity grow.  

