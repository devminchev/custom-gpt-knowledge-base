---
title: "01 Cms Modeling Principles Core"
tags: [contentful-models]
aliases: []
---
 # 01 · CMS Modeling Principles — Core Guide

 **Audience:** software / solution architects, lead engineers, senior content designers  
 **Scope:** headless CMS design with a strong focus on iGaming and large-scale digital experiences.

 ---

 ## 1. Purpose of this document

 This guide is the **core foundation** for all other documents in this knowledge base.

 It explains *how to think* about content models so that:

 - They stay **scalable** as the product grows.
 - They are **developer-friendly** (easy to query, fast to render).
 - They are **author-friendly** (easy and safe to use for non-technical editors).
 - They are **future-proof** for multi-channel, multi-brand, and redesign scenarios.

 When designing or reviewing any new / existing model (articles, navigation, grids, games, promotions), this is the first document to consult.

 ---

 ## 2. Core principles (what, why, when)

 ### 2.1 Design it first

 - **What:** Design content models using a neutral tool (Miro, Whimsical, FigJam) *before* building anything in the CMS.
 - **Why:** Avoid “designing in the CMS UI”, which leads to incremental hacks and long-term schema debt.
 - **When:** For any significant new domain (e.g., iGaming lobby, navigation system, taxonomy, promotions).

 ```mermaid
 flowchart TD
     A[Design content model in Miro] --> B[Review with devs and authors]
     B --> C[Refine fields and relationships]
     C --> D[Sign off standards]
     D --> E[Implement in CMS]
 ```

 **Rule of thumb:** if you can’t clearly explain your model on a whiteboard, the CMS schema is not ready.

 ---

 ### 2.2 Work with a diverse team

 - Include **authors, product, domain experts, designers, and engineers**.
 - Authors protect usability, engineers protect performance, product protects business value.
 - Never design in a “dev-only” vacuum.

 **Outcome:** fewer redesign cycles, fewer surprises during rollout.

 ---

 ### 2.3 Make it scalable

 - Assume:
   - More brands / ventures may be added.
   - More metadata will be required (jurisdiction, regulation, SEO, tracking IDs).
   - More channels will appear (apps, web, native, ops tools, partners).
 - Model with the expectation that new fields and relationships will be added.

 Techniques:

 - Prefer **optional, well-documented fields** over ad-hoc new content types for every variation.
 - Use **reusable components** (e.g., SEO block, legal disclaimer block, CTA block).

 ```mermaid
 erDiagram
     ARTICLE {
         string title
         text body
     }
     SEO {
         string title
         string description
         string ogTitle
         string ogDescription
     }
     ARTICLE ||--o{ SEO : "has SEO"
 ```

 ---

 ### 2.4 Keep the model documentation updated

 - Treat the **design diagram** (Miro / ERD) as the **source of truth**, not the CMS.
 - Every schema change must update:
   - The diagram
   - This knowledge base (or equivalent)
   - Any public-facing architecture docs
 - Out-of-sync diagrams = hidden technical debt.

 ---

 ### 2.5 Single source of truth (SSOT)

 - Shared data must live in **exactly one place**:
   - Reused FAQs
   - Legal disclaimers
   - Game metadata
   - Navigation links
 - Everything else **references** that single canonical entry.

 Benefits:

 - Update once → change everywhere.
 - Easier caching and indexing (OpenSearch, etc.).
 - Reduced risk of conflicting values.

 ```mermaid
 erDiagram
     GAME {
         string gameId
         string name
     }
     SITEGAME {
         string venture
         string availability
     }
     DISCLAIMER {
         text body
     }
     SITEGAME }o--|| GAME : "references"
     SITEGAME }o--|| DISCLAIMER : "shows"
 ```

 ---

 ### 2.6 Use design as a guide, not a prison

 - **Designs change; content outlives designs.**
 - Model **intent** (“hero section”, “promotion block”, “warning callout”) rather than pixel-perfect layouts.
 - Avoid fields like `redBox`, `leftColumnOnlyForDesktop` that encode visual details.

 Instead:

 - Use semantic fields: `blockType: hero | promo | info`.
 - Let the frontends decide how each block type should look.

 ---

 ### 2.7 Model intent, not design

 Examples:

 - Use `calloutType: warning | info | success` rather than `yellowBanner`.
 - Use `priority: primary | secondary` instead of `bigButton` vs `smallButton`.

 This keeps content reusable across:

 - Web vs native app
 - Light vs dark themes
 - Different brands / ventures

 ---

 ### 2.8 Keep design separate

 - Store **styling and theming** in separate, clearly named fields or types:
   - `theme`, `layoutType`, `displayVariant`.
 - Content authors should control *what* is shown; design systems control *how* it looks.

 For iGaming / experience layers:

 - `IG View` defines which sections appear.
 - `layoutType` / `expandedSectionLayoutType` tells the FE how to render.

 ---

 ### 2.9 Make it omnichannel-friendly

 - Assume content will appear in:
   - Web
   - Native apps
   - Email / push
   - Internal tools
 - Avoid mixing channel-specific logic into core content types.

 Example:

 - Keep `platformVisibility` and `sessionVisibility` on experience-level types (`IG Grids`, `IG Carousels`), not on raw game data.

 ---

 ### 2.10 Don’t waste content types

 - CMSes often have limits and cost/complexity penalties for many types.
 - Avoid creating a new type for every visual variation.

 Prefer:

 - **One generic, well-designed type** with:
   - `variant`
   - `layoutType`
   - `flags` (e.g., `hasPersonalisation`)

 Over:

 - `HomeHeroType1`, `HomeHeroType2`, `FooterHeroTypeA`, etc.

 ---

 ### 2.11 Use components for repeated structures

 - If the same structure appears in many types:
   - `SEO`, `CTA`, `LegalBlock`, `ImageWithCaption`, etc.
 - Extract it as a component / separate content type and reuse it.

 Benefits:

 - Fewer fields repeated in many models.
 - Easier to change structure once and roll out everywhere.

 ---

 ### 2.12 Make it developer-friendly

 - Limit **reference depth**:
   - Ideal: 1–2 levels.
   - Avoid 4–5 level deep chains (`view → section → tile group → tile → game → provider`).  
     These are painful for queries, caching, and indexing.
 - Design so that:
   - Queries are predictable.
   - APIs can denormalize easily into search indices.

 ```mermaid
 erDiagram
     VIEW ||--o{ SECTION : contains
     SECTION ||--o{ BLOCK : contains
     BLOCK ||--o{ CONTENT : references
 ```

 Preferred: **three layers max**.

 ---

 ### 2.13 Make it author-friendly

 - Editors should see **only the fields they need** for a given task.
 - Avoid:
   - Giant “super models” with 40+ fields, many irrelevant for most scenarios.
 - Use:
   - Clear help text
   - Validations (`in` enums, min/max items)
   - Defaults

 Principle: **guardrails, not handcuffs**.

 ---

 ### 2.14 Think content governance & workflows

 - Design models while thinking about:
   - Who creates content.
   - Who approves it.
   - Who publishes it.
   - How rollback / audit works.
 - Use workflow capabilities (e.g., Contentful Workflows + status fields) to encode governance.

 ---

 ## 3. Quick principle checklists

### 3.1 When designing a new content type

- [ ] Is there a design diagram for this model?  
- [ ] Have authors and devs reviewed it?  
- [ ] Is there a single source of truth for shared data?  
- [ ] Is reference depth ≤ 2?  
- [ ] Are fields semantic, not purely visual?  
- [ ] Are validations defined (enums, min/max, unique constraints)?  
- [ ] Is this type truly necessary, or can it be a variant of an existing type?  

 ---

 ### 3.2 When reviewing an existing model

 - [ ] Are there duplicated content types for minor visual changes?  
 - [ ] Are there deep reference chains that could be flattened?  
 - [ ] Are there fields that encode pure design (colors, pixels) instead of intent?  
 - [ ] Are shared elements (SEO, legal text, links) centralized?  
 - [ ] Is documentation aligned with the actual CMS schema?  

 ---

 ## 4. How this document should be used by a custom GPT

 - As a **reference brain** for evaluating any proposed model:
   - The GPT should map user ideas back to these principles.
 - As a **linting checklist**:
   - When the user describes or pastes a model, GPT can point out violations (deep nesting, type sprawl, lack of SSOT).
 - As a **vocabulary baseline**:
   - Other documents in this knowledge base build on the concepts here (grids, navigation, IG models, taxonomy).
