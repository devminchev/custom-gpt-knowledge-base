---
title: "05 · Contentful Inventory & Modeling Assessment"
tags: [contentful-models]
aliases: []
---
# 05 · Contentful Inventory & Modeling Assessment

**Audience:** architects, CMS owners, platform leads  
**Scope:** a structured view of the current Contentful space and how IG models compare to DX & Sports models.

---

## 1. Inventory overview

The production space contains **~144 content types**, grouped roughly as:

- **DX (Digital Experience)** — ~34 types
- **IG (iGaming Experience)** — ~27 types
- **Sports** — ~38 types
- **Lobby** — 3 types
- **RG (Responsible Gaming)** — 5 types
- **Kre** — 5 types
- **Game** — 11 types
- **SEO** — 2 types
- **Footer** — 3 types
- **Other core types** (Categories, Layout, Section, Site, Venture, Welcome Offer, etc.) — 15+ types

Observations:

- There is **significant type sprawl** in DX and Sports.
- IG has fewer types, but still multiple variants (Grids A–G, Carousels, personalised sections).
- Game-related types are reasonably centralised (`Game`, `SiteGameV2`, `GameModelV2`, `CashierGameConfig`).

---

## 2. Nesting and complexity

### IG models

- Typical nesting depth: **1–2 levels**.
- Example:
  - `IG View` → `IG Sections` (grid / carousel) → `SiteGameV2` / `IG Link`.
- Shallow structure simplifies:
  - API queries
  - Indexing for search / availability
  - Caching
  - Debugging

### DX & Sports models

- Deep nesting: often 3–4+ levels with many specialised tile / tab item types.
- Example patterns:
  - `NavigationTabGroup` → `NavigationTabItem` → `SpecialisedTile` → underlying content.
  - Many variations of banners, tiles, tabs as different content types.
- This leads to:
  - Complex queries (many nested fragments / expansions).
  - Difficulty in onboarding and support.
  - Increased risk of broken references.

---

## 3. Strengths of the IG model

From an architectural standpoint, IG models are strong because:

- ✅ **Block-based / section-based:** IG views are composed of reusable sections (grids, carousels, personalised sections).
- ✅ **Good separation of concerns:**
  - Game data (`SiteGameV2`) is separate from experience-level sections.
- ✅ **Shallow nesting:** easier to query and denormalise.
- ✅ **Consistent visibility fields:** `platformVisibility`, `environmentVisibility`, `sessionVisibility` used systematically.
- ✅ **Centralised link and game models:** `IG Link` and `SiteGameV2` are used across multiple surfaces.

---

## 4. Weaknesses / improvement areas

### DX & Sports

- ❌ Over-fragmentation: many types for similar tiles / tabs / banners.
- ❌ Deep reference trees: up to 4 levels or more.
- ❌ Presentation logic baked into model structure (e.g., variant types per layout).
- ❌ Hard to reuse content across experiences.

### IG

- ⚠️ Multiple grid and carousel types (A–G, A–B) increase type count.
- ⚠️ Visibility fields duplicated across many models.
- ⚠️ Requires good documentation to avoid confusion between similar sections.

---

## 5. Comparative assessment: IG vs DX & Sports

| Aspect                       | IG Models                         | DX & Sports Models                  |
|------------------------------|-----------------------------------|-------------------------------------|
| Modularity / composability   | High                              | Medium–low                          |
| Nesting depth                | 1–2 levels                        | 3–4+ levels                         |
| Type sprawl                  | Medium (due to variants)          | High                                |
| Reusability                  | Strong (SiteGameV2, IG Link)      | Limited                             |
| Separation of concerns       | Good (content vs experience)      | Mixed                               |
| Alignment with best practice | Strong                            | Weak / inconsistent                 |

**Verdict:** IG is the preferred reference architecture for future modeling work.

---

## 6. Strategic recommendations

### 6.1 Use IG as the baseline for new domains

- New experiences (e.g., new lobby variants, new product verticals) should follow IG principles:
  - Block-based sections.
  - Shallow nesting.
  - Centralised shared entities (links, games, taxonomy).

### 6.2 Gradually refactor DX & Sports

- Consolidate similar content types into fewer, more flexible models:
  - Use `variant` / `layoutType` fields instead of separate types for each variant.
- Flatten deep reference chains where possible:
  - Replace multiple intermediate grouping types with direct references or configuration objects.

### 6.3 Manage IG type sprawl via hybrid approach

- Consider merging `IG Grid A–G` into:
  - A single or smaller number of base grid section types with `gridVariant` and `allowedPlacement` fields.
- Keep strong validation and business rules as part of those variants.

---

## 7. How this document should be used by a custom GPT

- As the **inventory and assessment brain**:
  - When the user asks “How many content types do we have?” or “Why is IG better than DX?”, GPT should refer to this document.
- As a **strategic lens**:
  - When proposing new models, GPT should prioritise patterns aligned with IG and recommend consolidation of DX & Sports patterns where possible.
