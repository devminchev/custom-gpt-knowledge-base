# Work System AWS Config (Production Knowledge Pack)

## Purpose

This directory is the authoritative snapshot of production AWS service configuration for the work system. It is designed for operational troubleshooting, architecture validation, and onboarding of new product/project teams building on the same AWS stack.

## How to Navigate

Start with the service-level reports, then drill into raw JSON exports:

1. **API Gateway**
   - Summary/report: `apigw/apigw-report.md`
   - Core inventories: `apigw/apigw-rest-apis.json`, `apigw/apigw-v2-apis.json`, `apigw/apigw-domain-names.json`
   - Method/integration details: `apigw/apigw_rest_resources/`, `apigw/apigw_rest_integrations/`, `apigw/apigw_rest_stages/`
2. **Lambda**
   - Function-level config: `lambdas/lambda-function-configuration__*.json`
   - Async behavior: `lambdas/lambda-async-invoke-config__*.json`
   - Triggers: `lambdas/lambda-event-source-mappings__*.json`
   - Concurrency/aliases: `lambdas/lambda-concurrency__*.json`, `lambdas/lambda-aliases__*.json`
3. **OpenSearch**
   - Technical/leadership summaries: `opensearch/opensearch-technical-report.md`, `opensearch/opensearch-leadership-report.md`
   - Domain/security setup: `opensearch/domain__describe-domain.json`, `opensearch/domain__describe-domain-config.json`
   - Index/cluster data: `opensearch/*indices*`, `opensearch/*shards*`, `opensearch/*cache*`, `opensearch/opensearch-index-mappings__all.json`
4. **CloudWatch**
   - Monitoring summaries: `cloudwatch/cloudwatch-report.md`, `cloudwatch/production-ready-report.md`
   - Dashboard/alarm/log inventories: `cloudwatch/cloudwatch-dashboards.json`, `cloudwatch/cloudwatch-alarms.json`, `cloudwatch/cloudwatch-log-groups.json`
5. **WAF**
   - Web ACL and IP sets: `waf/wafv2-web-acl__*.json`, `waf/wafv2-ip-set__*.json`
   - Policy/rate-limit assessment: `waf/waf-rate-based-rules-report__*.json`

## Inventory Snapshot

- `apigw/`: 62 files
- `lambdas/`: 226 files
- `opensearch/`: 25 files
- `cloudwatch/`: 13 files
- `waf/`: 8 files

## Retrieval Guidance for GPT

- Prefer service reports (`*-report.md`) for quick answers and decision context.
- Use raw JSON exports for exact values (timeouts, cache keys, ARNs, memory, policies, stage variables, alarm thresholds).
- If a report and raw export differ, treat raw export as source of truth and flag the report for refresh.
