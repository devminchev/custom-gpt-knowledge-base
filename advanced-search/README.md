# Advanced Search Knowledge Base Guide

## 🎯 Purpose

- Define **target capabilities** and **constraints** for Advanced Search / Lobby Enhancements.
- Capture the **as-is** search system and Contentful integration.
- Provide **definitive Contentful docs** relevant to our integration.
- Enable the GPT to act as a **senior architect + product advisor** grounded in this repo only.

---

## 🧭 Truth Hierarchy (most authoritative first)

1) **`product/`** — Desired target architecture/behavior (capabilities, constraints).  
2) **`current architecture overview/`** — Authoritative **as-is** system, APIs, infra, indexes.  
3) **`contentful-docs/`** — Definitive platform docs for Contentful usage and taxonomy.  
4) *(Optional)* `solution architecture/` — Drafts and proposals when present.

> The goal is to implement `product/` within (and evolving) the current system described in `current architecture overview/`, using `contentful-docs/` for platform constraints and best practices.

---
## 🧠 Grounding Order (how the GPT reasons)

1) **product/** (Requirements → Vision → Initiative)  
2) **current architecture overview/** (compare/contrast with as-is)  
3) **contentful-docs/** (platform specifics & constraints)  
4) *(Optional)* solution architecture drafts

**If something is missing**, the GPT must reply:  
**“Not covered in the current knowledge base.”**  
…and list the **minimal** files/details needed to proceed. No off-KB assumptions.

---

## 📁 Structure

ADVANCED-SEARCH-KNOWLEDGE-BASE/
│
├─ contentful-docs/                          # Contentful usage & taxonomy guidance (definitive platform docs)
│  └─ contentful-taxonomy-tags-guides.md
│  └─ contentful-app-framework-function-guides.md
│
├─ current architecture overview/            # As-is system, APIs, infra, indexes (definitive current state)
│  ├─ contentful-cms-modeling-guide.md
│  ├─ contentful-opensearch-integration-guide.md
│  ├─ contentful-opensearch-schema-guide.md
│  ├─ contentful-opensearch-webhook-runbook.md
│  ├─ contentful-opensearch-webhooks-guide.md
│  ├─ current-search-architecture-guide.md
│  └─ current-search-capability-report.md
│  └─ opensearch-index-mapping.json
│
├─ product/                                  # Target capabilities & constraints (definitive desired behavior)
│  ├─ 01-initiative/
│  │  └─ business-initiative.md
│  ├─ 02-vision/
│  │  └─ vision-board.md
│  └─ 03-requirements/
│     └─ product-requirements.md
│
└─ solution architecture/
   └─ 000-template-solution-architecture.md  # Template for adding new solution docs

## 🔎 Quick Navigation

- **Target capabilities & acceptance criteria**  
  `product/03-requirements/product-requirements.md`

- **Vision & UX intent (target)**  
  `product/02-vision/vision-board.md`

- **Business context & scope (target)**  
  `product/01-initiative/business-initiative.md`

- **Current system & search overview (as-is)**  
  `current architecture overview/current-search-architecture-guide.md`

- **OpenSearch schema & integration (as-is)**  
  `current architecture overview/contentful-opensearch-schema-guide.md`  
  `current architecture overview/contentful-opensearch-integration-guide.md`  
  `current architecture overview/opensearch-index-mapping.json`

- **Contentful modeling & taxonomy (platform docs)**  
  `current architecture overview/contentful-cms-modeling-guide.md`  
  `contentful-docs/contentful-taxonomy-tags-guides.md`  
  `contentful-docs/contentful-app-framework-functions-guides.md`

- **Webhooks & runbook (as-is)**  
  `current architecture overview/contentful-opensearch-webhooks-guide.md`  
  `current architecture overview/contentful-opensearch-webhook-runbook.md`

- **Capability gaps/status (as-is)**  
  `current architecture overview/current-search-capability-report.md`

- **Author new solution docs**  
  `solution architecture/000-template-solution-architecture.md`

---

## ✨ Golden rules
- Prefer the simplest viable design; avoid over-engineering.

## ✍️ Conventions
- Filenames: `kebab-case.md`. One H1 per file, stable H2/H3 anchors.
- Keep existing requirement identifiers; add short IDs for new sections if needed.
- Do not invent KPIs, policies, or data outside the KB; call out conflicts explicitly.

## 🔄 How to update this KB
1. Keep the directory layout above; commit Markdown and diagrams (PNG/SVG).
2. Update this README when adding/moving files.
3. Zip the folder preserving the root directory name:
   - `advanced-search-knowledge-base/…`
4. Upload the ZIP to the Custom GPT project.
5. Sanity check: ask the GPT to show **Quick navigation** and confirm new docs appear.

## 📌 Changelog
Maintain a simple list (date, summary, paths changed) to help reviewers and GPT users understand context.

---

## Risks & mitigations

* **Reasoning drift** away from `product/` → Pin the truth hierarchy in README (done) and keep “Not covered…” policy.
* **Doc sprawl / stale sections** → Maintain Quick navigation & Changelog; prune obsolete docs during updates.
* **Upload path errors** → Preserve root folder name when zipping; verify via post-upload sanity prompt.

---

## Next steps

1. Replace the root README with the version above.
2. Re-zip with the correct root folder name and upload to the Custom GPT project.
3. Run a quick QA prompt: “List the Quick navigation and identify which directory is the target truth.”

---
