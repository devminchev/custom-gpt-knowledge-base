# Game Release Automation Knowledge Base Guide

## 🎯 Purpose

- Document target product goals, current release process, and solution proposals.
- Give the GPT a clear truth hierarchy for reasoning about release automation.

---

## 🧭 Truth Hierarchy (most authoritative first)

1) **`product/`** — Desired target behavior and requirements.  
2) **`current/`** — Authoritative as-is release process and schemas.  
3) **`target/`** — Proposed solutions and strategy notes.

---

## 📁 Structure

game-release-automation/
│
├─ product/
│  ├─ 01-initiative/
│  ├─ 02-vision/
│  ├─ 03-requirements/
│  └─ 04-jira-analysis/
│
├─ current/
│  ├─ current-game-release-process.md
│  ├─ game-release-process-tasks-example.json
│  ├─ game-release-process-tasks-schema.json
│  └─ game-ops-process-review.xlsx
│
└─ target/
   ├─ game-release-automation-solution-pack.md
   └─ solution-strategy-conversation.md

---

## 🔎 Quick Navigation

- **Initiative & vision (target)**  
  `product/01-initiative/` · `product/02-vision/`

- **Requirements & Jira analysis (target)**  
  `product/03-requirements/` · `product/04-jira-analysis/`

- **Current release process (as-is)**  
  `current/current-game-release-process.md`

- **Proposed solutions (target)**  
  `target/game-release-automation-solution-pack.md`

---

## ✍️ Conventions

- Filenames: `kebab-case.ext`. One H1 per Markdown file, stable H2/H3 anchors.
- Keep each document focused on a single topic; call out missing info explicitly.
