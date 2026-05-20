---
title: "Advanced Search Feasibility: As-Is Architecture Audit"
tags: [projects, work-app-orchestration, current]
aliases: []
---
# Advanced Search Feasibility: As-Is Architecture Audit

# Problem Statement (Concise)

The advanced search goals assume **fast, single-shot, tolerant, intent-aware retrieval** with **stable latency**. The current design enforces **multi-hop composition** and **joins at query time**, which is fundamentally misaligned with interactive search UX requirements.

# Current architecture: core facts

* **Request path** does: venture lookup → navigation & links → views → sections (filtering by **session/env/platform**) → **`games-v2`** query with **`has_parent`** join (**siteGame → game**) and **`inner_hits`**, then **merges** navigation names and media.
* **Availability chain** (Navigation→Link→View→Section→SiteGame) is validated **per request**.
* **Multiple indices** are touched per call; **response** depends on several entities’ states → **cache keys explode**, low hit-rate.
* **Localization & media** decisions (e.g., logged-in artwork) are **resolved at read time**.
* **Parent/child** joins and **N+1 lookups** cause **latency variance** and **cost amplification** as the catalog and menus grow.

---

# Must-Have Requirements — Feasibility Audit

> Legend: **Fits** (meets as-is), **Partial** (some aspects possible but fails acceptance criteria at scale/quality), **Fails** (cannot reasonably meet with current flow/design).

1. **Allow players to search using Elasticsearch** — **Partial**
   Yes, it already queries OpenSearch; however, reliance on **multi-index lookups** and **joins** means **end-to-end latency/reliability** falls short of implied product expectations at scale.

2. **Ability to search for results in the search bar** — **Partial**
   Functional today, but the current API **blocks** on several upstream reads; **typing experience** and immediate feedback required by the UI are **not reliably achievable** with this path.

3. **Fuzzy logic to always display results (tolerate typos)** — **Fails**
   The documented flow centers on exact/filtered retrieval and parent/child joins; **robust fuzzy** (with proximity fallbacks, no “dead ends”) is **not present** and **not compatible** with multi-hop dependency checks on the hot path.

4. **Implement Semantic Search (intent over keywords)** — **Fails**
   No semantic pipeline, embeddings, or reranking are part of the current flow; parent/child BM25 + filters cannot satisfy **intent** retrieval.

5. **Semantic search uses games metadata** — **Fails**
   Metadata exists across models, but current path **doesn’t compute or serve** semantic signals; joins at read time do not deliver **semantic** behavior.

6. **Search bar advises what can be searched (typed suggestions)** — **Fails**
   Typed suggestions require **fast, single-shot lookups**; the existing **multi-hop** path with availability validation cannot deliver **interactive keystroke-level** performance.

7. **Quick Filters displayed on search page** — **Partial**
   Contentful models exist, but **deriving filter options** from **views/sections/navigation** during the request collides with latency targets and **consistency** across locales/platforms.

8. **Quick Filters can be added in Contentful** — **Partial**
   Editorial control exists; however, **runtime dependence** on CMS composition increases **tail latency** and **fragility**. Meeting the goal “always there/fast” is **unlikely** as-is.

9. **Quick Filters are configurable in Contentful** — **Partial**
   Same as (8); config is possible, but **runtime materialization** degrades performance and reliability.

10. **Quick Filters follow a defined flow (UX)** — **Fails (at quality bar)**
    The flow presumes **snappy updates** as filters are toggled; current path’s **joins** and **multi-index** reads will not sustain the required responsiveness under load.

11. **Quick Filters display relevant games** — **Partial**
    Relevance can be computed, but filtering relies on **section membership and availability** recomputed on each call → **latency spikes** and **inconsistency** during editorial changes.

12. **Add Game Filter to the search page** — **Partial**
    Technically addable, but **join cost** + **per-request validation** make **multi-filter combinations** brittle and slow.

13. **Game Filters managed in Contentful** — **Partial**
    Modeling supports it, but **read-time** resolution remains a bottleneck; editorial updates will **thrash caches** and widen tail latency.

14. **Game Filters configurable in Contentful** — **Partial**
    Same constraints as (13); feasible in principle, **operationally weak** in practice under current flow.

15. **Ability to apply filters (Game Filter menu)** — **Partial → Fails at scale**
    Applying multiple filters forces larger **siteGame** sets and **heavier joins**, pushing p95/p99 above acceptable thresholds.

16. **When filters are applied, relevant games should be shown** — **Partial**
    Correctness is possible; **responsiveness and stability** under combinations are **not**.

17. **Bingo special case: direct to game** — **Partial**
    A shortcut is logically possible, but present path still **walks availability** and **venture/platform/session** checks; special-case behavior would **inherit** the same latency/failure modes.

18. **Ability to remove filters** — **Partial**
    UX action is simple; **recomputation cost** and **payload rebuild** persist.

19. **Ability to view applied filters** — **Fits (UI)** / **Partial (consistency)**
    Displaying state is trivial, but **consistency** (what is actually applied server-side vs. what UI shows) can drift during **concurrent CMS changes** due to **runtime dependency**.

20. **Handling of multiple languages** — **Partial**
    Localized fields exist, yet **resolving localization + media + availability** per request inflates payloads and **query complexity**, harming **latency** and **cost**.

21. **Search results should load quickly** — **Fails (at target bar)**
    The path’s **joins**, **N+1 lookups**, and **low cache locality** make consistent **sub-2s** (let alone sub-second interactive) unreliable at scale.

22. **Order results by Margin (commercial weighting)** — **Partial**
    You can re-order results post-query, but because results are **join-bound** and **multi-index dependent**, **stable ordering + fast delivery** across locales/platforms is **improbable** at the required latency/cost.

23. **Update search UI to latest designs** — **Partial (backend-bound)**
    UI can be updated, but the **backend behavior** (typed suggestions, instant filtering, no dead ends) **isn’t supported** by the current flow; the UI would **degrade**.

24. **Game Collections visible on the search page** — **Partial → Fails under load**
    Collections exist as sections; however, **deriving & merging** them per request (with availability/visibility checks) is **slow** and **costly** as quantities grow.

25. **Error Handling** — **Partial**
    The current flow enumerates multiple external dependencies per request; while errors can be caught, **blast radius** and **surface area** are large, increasing **timeouts**, **partial data**, and **inconsistent results**.

**Outcome:**

* **Fits:** 1 (backend exists), 19 (UI display), portions of 23 (UI only).
* **Partial:** most filter/collections/config items (7–16, 18–22, 28, 31) due to runtime dependency and performance/cost constraints.
* **Fails:** 3 (fuzzy at quality bar), 4–5 (semantic), 6 (typed suggestions), 21 (speed at target).
* Net effect: **The current flow and logic do not fit the advanced search goals** at the expected **quality/performance** bar.

---

# Cross-cutting technical audit

## Core issues & architectural limits

* **Runtime joins on the hot path** (Navigation→Link→View→Section→SiteGame + `has_parent` to Game) create **read amplification**, high **p95/p99** and **fragility** during editorial churn.
* **Parent/child (`has_parent` + `inner_hits`)** in **`games-v2`** yields **superlinear cost** as catalogs grow; it also increases **heap pressure** and **GC churn** on OpenSearch.
* **Low cache locality**: Responses depend on multiple indices + session/platform/env + localization + navigation labels; cache keys fragment → **low hit rate**.
* **Availability validation at read time** tightly couples **search** with **page composition**, expanding the **blast radius** of minor CMS changes.
* **Localization + media selection** resolved per request increases payload size and compute; combined with joins, it **stretches latency** beyond acceptable targets.

## Scalability

* **Poor**. Query cost grows faster than linearly with: number of **siteGames**, **sections**, **views**, and **links**. Peak traffic or content spikes (e.g., promos) push **p95/p99** beyond SLA.

## Performance

* **Latency scatter** from sequential lookups and OS joins; increased **timeouts** under load.
* **Typed interactions** (suggestions, interactive filtering) are **not viable** at keystroke cadence with this design.

## Flexibility

* Adding new filter types or changing editorial composition requires touching **multiple runtime steps**; the model is **brittle** to change.

## Simplicity

* **High cognitive load**: many moving parts per request; failures are hard to root-cause (was it navigation, links, views, sections, or game joins?).

## Cost

* **Elevated OpenSearch compute** (joins, large filtered sets), **Lambda time** (JSON stitching), and **cache misses** → **higher unit costs** per search.
* Frequent editorial updates **invalidate cache** implicitly, compounding cost.

---

# Report Summary

* **Feasibility (as-is):** **Not achievable in full.** Several Must-Haves fail outright; others are only partially met and miss the product quality bar due to latency variance and operational fragility.
* **Overall:** **Does not fit** the advanced search goals.

## Root Problems
* **Read-time composition:** Multi-hop navigation→view→section→siteGame checks per request.
* **Join-heavy queries:** Parent/child (`has_parent`) with `inner_hits` on the hot path.
* **Multi-index dependency:** Results depend on several indices and states simultaneously.
* **Per-request variability:** Localization, media, session/platform/environment resolved on each call, creating low cache locality and tail-latency spikes.

## Impact by Dimension
* **Performance:** High p95/p99 due to sequential lookups + joins; prone to timeouts under load and editorial churn.
* **Scalability:** Superlinear cost as catalogs/menus grow; poor cache hit rates.
* **Complexity:** Many dependencies per request; difficult fault isolation and recovery.
* **Flexibility:** Adding filters or UX behaviors touches multiple runtime steps; brittle to change.
* **Cost:** Elevated OpenSearch compute (joins, filtered sets) and Lambda time; cache fragmentation increases unit costs.
* **Operational Risk:** Large blast radius from minor CMS changes; inconsistent user experience during updates.
