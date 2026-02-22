# Custom GPT Knowledge Base

## Overview

This repository is organized into shallow, domain-based categories so the GPT can quickly locate authoritative information. Each category is at most 1–2 levels deep and uses descriptive kebab-case filenames.

## Top-Level Structure

```text
custom-gpt-knowledge-base/
├─ projects/                # Project-specific knowledge bases
├─ architecture/            # Core architecture and AWS implementation docs
├─ contentful-models/       # CMS content models and schemas
├─ work-system-aws-config/  # Production AWS service exports + operational reports
├─ epics/                   # Product epics, investigations, proposals
├─ guides/                  # Supplemental guides (product/process/repo usage)
├─ gpt-context-guides/      # GPT/retrieval usage guidelines
├─ index/                   # Retrieval manifests/index files
├─ 90-appendix/             # Diagrams and supplemental visuals
└─ README.md                # This overview
```

## Conventions

- **Markdown-first**: prefer `.md` for documentation and reports.
- **Filenames**: kebab-case, descriptive, no spaces.
- **Headings**: exactly one H1 per Markdown file.
- **Truth hierarchy**: project READMEs and index manifests define authoritative source order.
- **Changelog**: major additions should be recorded in `CHANGELOG.md`.

## Quick Links

- **Knowledge index**: `index/knowledge-index.yaml`
- **Canonical sources**: `index/canonical-sources.yaml`
- **Work system AWS config entry point**: `work-system-aws-config/README.md`
- **Projects**: `projects/`
- **Architecture**: `architecture/`
- **Appendix (diagrams & assets)**: `90-appendix/`
