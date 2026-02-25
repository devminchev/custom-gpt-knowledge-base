# Custom GPT Knowledge Base

## Overview

This repository is organized into shallow, domain-based categories so the GPT can quickly locate authoritative information. Each category is at most 1–2 levels deep and uses descriptive kebab-case filenames.

## Top-Level Structure

```
custom-gpt-knowledge-base/
├─ projects/             # Project-specific knowledge bases
├─ architecture/         # Core system architecture diagrams and docs
├─ contentful-models/    # CMS content models and schemas
├─ search-pipeline/      # Search indexing, query logic, OpenSearch, etc.
├─ epics/                # Product epics, investigations, proposals
├─ shared-knowledge/     # Glossary, design patterns, cross-cutting guides
├─ guides/               # Supplemental guides (product processes, etc.)
├─ gpt-context-guides/   # GPT/retrieval usage guidelines
├─ index/                # Manifests or index files
├─ 90-appendix/          # Diagrams and supplemental visuals
└─ README.md             # This overview
```

## Conventions

- **Markdown-first**: prefer `.md` for all documentation.
- **Filenames**: kebab-case, descriptive, no spaces.
- **Headings**: exactly one H1 per Markdown file.
- **Truth hierarchy**: each project README defines authoritative sources in order.
- **Changelog**: major moves or additions should be recorded in `CHANGELOG.md`.

## Quick Links

- **Knowledge index**: `index/knowledge-index.yaml`
- **Projects**: `projects/`
- **Shared glossary**: `shared-knowledge/glossary.md`
- **Appendix (diagrams & assets)**: `90-appendix/`
