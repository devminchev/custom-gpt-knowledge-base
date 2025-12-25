# Recommendations for using architecture review details in the Custom GPT knowledge base

These recommendations show how to organize and surface the architecture review details already documented in this repo so a Custom GPT can answer questions with higher accuracy and fewer follow-up prompts. The goal is to improve navigation, retrieval, and response quality without changing or overriding existing content.

## 1) Treat the architecture review as a curated entry point

Use the review details as a **curated “map”** to the most authoritative sources, rather than duplicating the underlying docs. This improves retrieval while preserving a single source of truth.

Recommended structure:
- **Single navigation doc** (this file) that summarizes *where* to find authoritative details.
- **Link to source docs** for full context and exact wording.

Suggested canonical sources (as documented in this repo):
- Search flow, request/response, OpenSearch query chain: `projects/advanced-search/current/current-search-architecture-guide.md`
- Current limitations + caching behavior + target design: `projects/advanced-search/current/current-search-overview-analysis.md`
- Contentful → OpenSearch integration details: `projects/advanced-search/current/contentful-opensearch-integration-guide.md`
- Webhook runbook + env behavior + alias lists: `projects/advanced-search/current/contentful-opensearch-webhook-runbook.md`
- Webhook payload matrix: `projects/advanced-search/current/contentful-opensearch-webhooks-guide.md`
- API Gateway + Lambda integration example: `projects/work-app-orchestration/current/aws-api-gateway-prod-setup.json`

## 2) Add retrieval “routing hints” for common question types

When a user asks a question, steer retrieval to the most relevant doc first. This reduces context noise and improves answer precision.

**Suggested routing rules for a Custom GPT:**
- “How does search work?” → `current-search-architecture-guide.md`
- “Why is search slow?” “Cache hit rate?” → `current-search-overview-analysis.md`
- “Where is Contentful data indexed?” → `contentful-opensearch-integration-guide.md`
- “What webhook event triggers what index?” → `contentful-opensearch-webhook-runbook.md`
- “What is the payload for siteGameV2?” → `contentful-opensearch-webhooks-guide.md`
- “What does the API Gateway config look like?” → `aws-api-gateway-prod-setup.json`

## 3) Prefer “cite then summarize” responses

When answering questions, the Custom GPT should:
1. Cite the exact doc path.
2. Summarize the behavior in short, direct language.
3. Call out gaps when the repo doesn’t include implementation code or infra.

Example response pattern:
> The search flow is documented in `projects/advanced-search/current/current-search-architecture-guide.md` under “End-to-end flow.” In short: client → API Gateway → Lambda → OpenSearch (multiple indices) → response assembly. The repo does not include runnable search code or IaC for all services.

## 4) Add explicit “known gaps” guidance

When the repo lacks implementation code or full infrastructure manifests, the GPT should say so upfront. This prevents hallucinations and overconfident answers.

Suggested gap phrasing:
- “This repo documents the flow but does not include the runnable service code.”
- “Only a single API Gateway example spec is present; it is not a full IaC deployment.”

## 5) Provide reusable prompt templates for internal users

Adding ready-to-use prompts improves retrieval quality by nudging users toward the right doc paths.

**Prompt templates to include in GPT instructions or usage docs:**
- “Explain the current search API flow and cite the exact doc sections.”
- “Summarize API Gateway caching behavior and list the source files.”
- “List Contentful webhook events and which OpenSearch aliases they write to.”
- “Provide the JSON payload for siteGameV2 from the webhook matrix doc.”
- “Compare current search architecture vs. the target design proposal.”

## 6) Keep the review doc in sync with repo changes

Because the knowledge base is doc-driven, periodically re-check:
- Whether paths moved or were renamed.
- Whether new architecture docs should be added as canonical sources.

A lightweight monthly audit (or after major doc changes) will prevent outdated guidance.

## 7) Suggested placement in the repo

- This file lives in `guides/` to avoid overwriting any existing architecture documentation.
- Keep links to source docs rather than copying content.
- Update `guides/README.md` to point to this guide.

---

## Quick navigation checklist for the Custom GPT

Use this checklist to answer common questions accurately:

- **Search flow / request-response:** `projects/advanced-search/current/current-search-architecture-guide.md`
- **Cache & limitations:** `projects/advanced-search/current/current-search-overview-analysis.md`
- **Contentful → OpenSearch ingestion:** `projects/advanced-search/current/contentful-opensearch-integration-guide.md`
- **Webhook runbook & aliases:** `projects/advanced-search/current/contentful-opensearch-webhook-runbook.md`
- **Webhook payload mapping:** `projects/advanced-search/current/contentful-opensearch-webhooks-guide.md`
- **API Gateway example config:** `projects/work-app-orchestration/current/aws-api-gateway-prod-setup.json`
