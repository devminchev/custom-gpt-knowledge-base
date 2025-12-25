# Work App Orchestration Knowledge Base Guide

## 🎯 Purpose

- Capture product intent, current search/contentful integration, and supporting schemas.
- Provide a clear grounding order for GPT answers.

---

## 🧭 Truth Hierarchy (most authoritative first)

1) **`product/`** — Desired target behavior and requirements.  
2) **`current/`** — Authoritative as-is architecture, integration docs, and schemas.

---

## 📁 Structure

work-app-orchestration/
│
├─ product/
│  ├─ 01-initiative/
│  ├─ 02-vision/
│  └─ 03-requirements/
│
└─ current/
   ├─ adv-search-viability-audit-as-is.md
   ├─ contentful-cms-modeling-guide.md
   ├─ contentful-game-models-blueprint.md
   ├─ contentful-opensearch-integration-guide.md
   ├─ contentful-opensearch-schema-guide.md
   ├─ contentful-opensearch-webhook-runbook.md
   ├─ contentful-opensearch-webhooks-guide.md
   ├─ contentful-opensearch-webhooks-guide-1.md
   ├─ current-search-architecture-guide.md
   ├─ current-search-capability-report.md
   ├─ available-game-metadata-details.json
   ├─ aws-api-gateway-prod-setup.json
   ├─ opensearch-index-mapping.json
   └─ opensearch-index-mapping-1.json

---

## 🔎 Quick Navigation

- **Initiative, vision, requirements (target)**  
  `product/01-initiative/` · `product/02-vision/` · `product/03-requirements/`

- **Current architecture & integration (as-is)**  
  `current/current-search-architecture-guide.md`  
  `current/contentful-opensearch-integration-guide.md`

- **Schemas & mappings (as-is)**  
  `current/available-game-metadata-details.json`  
  `current/opensearch-index-mapping.json`

---

## ✍️ Conventions

- Filenames: `kebab-case.ext`. One H1 per Markdown file, stable H2/H3 anchors.
- Keep each document focused on a single topic; call out missing info explicitly.
