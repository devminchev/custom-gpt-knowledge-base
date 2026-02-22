# Work System AWS Config Routing Guide

## Goal

Help GPT (and humans) route AWS operational questions to the exact source in `work-system-aws-config/`.

## Routing Rules

### API Gateway questions
Use `work-system-aws-config/apigw/`.

- Start: `apigw/apigw-report.md`
- Exact endpoint/method integration: `apigw/apigw_rest_integrations/`
- Stage cache/method settings: `apigw/apigw_rest_stages/`
- Resource path inventory: `apigw/apigw_rest_resources/`

### Lambda questions
Use `work-system-aws-config/lambdas/`.

- Runtime/environment/memory/timeout/VPC: `lambda-function-configuration__*.json`
- Reserved/provisioned concurrency: `lambda-concurrency__*.json`
- Alias/version behavior: `lambda-aliases__*.json`
- Trigger mapping (SQS/Kinesis/etc.): `lambda-event-source-mappings__*.json`
- Async retry & destination behavior: `lambda-async-invoke-config__*.json`

### OpenSearch questions
Use `work-system-aws-config/opensearch/`.

- Executive summary: `opensearch-leadership-report.md`
- Deep technical analysis: `opensearch-technical-report.md`
- Cluster/domain settings: `domain__describe-domain*.json`
- Index mappings/settings: `opensearch-index-mappings__all.json`, `opensearch-index-settings__all.json`
- Health/perf/cache stats: numbered `*_cluster_health*`, `*_cache_stats*`, `_cat` exports

### CloudWatch/observability questions
Use `work-system-aws-config/cloudwatch/`.

- Overview: `cloudwatch-report.md`
- Readiness assessment: `production-ready-report.md`
- Dashboards: `cloudwatch-dashboard__*.json`
- Alarm/log inventory: `cloudwatch-alarms.json`, `cloudwatch-log-groups.json`

### WAF/security edge questions
Use `work-system-aws-config/waf/`.

- ACL structure: `wafv2-web-acl__*.json`
- Source allow/deny sets: `wafv2-ip-set__*.json`
- Rate limiting assessment: `waf-rate-based-rules-report__*.json`

## Retrieval Priority

1. `*-report.md` files for fast context.
2. Raw JSON/TXT exports for exact and current values.
3. If report statements conflict with export data, trust raw export and mark report as stale.
