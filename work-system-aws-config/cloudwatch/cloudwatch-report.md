# CloudWatch – Monitoring & Observability Report (Prod)

## Executive Summary

- **Strong monitoring coverage for core services**  
  API Gateway, Lambda, and OpenSearch all have active dashboards and alarms, indicating a mature baseline observability setup.

- **Alerting is well-defined but narrowly scoped**  
  Lambda error-rate and API Gateway 5XX alarms exist and notify via SNS, but infrastructure-level alerts (capacity, saturation) are limited.

- **Log hygiene is inconsistent**  
  Most Lambda log groups use short retention (7–14 days), which controls cost but may be insufficient for audit or incident investigation needs.

---

## Scope

Region: `eu-west-2`  
Environment: Production  
Sources:
- CloudWatch Logs (log groups & retention)
- CloudWatch Alarms
- CloudWatch Dashboards
- Metric Filters

---

## 1. Log Groups & Retention

### Inventory overview
- **Service coverage**
  - Lambda: extensive coverage (`/aws/lambda/*`)
  - API Gateway: present (`/aws/apigateway/*`)
- **Metric filters**: none defined (no log → metric extraction)

### Retention policy
Observed retention values:
- **7 days**: majority of application Lambdas
- **14 days**: control-plane / infra Lambdas
- **No retention specified**: some API Gateway log groups

Examples:
- `/aws/lambda/personalisation-lobby-game-config` → **7 days**
- `/aws/lambda/aws-controltower-NotificationForwarder` → **14 days**
- `/aws/apigateway/welcome` → **no explicit retention**

### Assessment
- Short retention reduces cost ✔
- Limited historical visibility for:
  - Incident retrospectives
  - Compliance / audit
  - Long-running investigations

### Recommendations
- Define **tiered retention**:
  - 7–14 days → high-volume, low-risk logs
  - 30–90 days → customer-impacting services
- Explicitly set retention for **all** API Gateway log groups
- Consider KMS encryption review if compliance requires it

---

## 2. CloudWatch Alarms

### Alarm coverage

#### API Gateway
- **5XX error rate alarm**
  - Threshold-based
  - Evaluates error percentage
  - Sends notifications to SNS (`lobby-personalisation-noc-notification`)

#### Lambda
Per-function **error rate alarms** for key Lambdas, including:
- `personalisation-lobby-game-config`
- `personalisation-lobby-game-info`
- `personalisation-lobby-game-titles`
- `personalisation-lobby-get-bulk-game-data`
- `personalisation-lobby-because-you-played`
- `personalisation-lobby-game-shuffle`
- Historical handlers

Alarm logic:
- Error rate percentage
- Minimum invocation guard (avoids noise on low traffic)
- Missing data treated as **not breaching**

### Assessment
✔ Good practices observed:
- Error rate (not raw count)
- SNS notifications wired
- Missing-data handling avoids false positives

⚠ Gaps:
- No alarms for:
  - Lambda duration p95/p99
  - Throttles / concurrency exhaustion
  - API Gateway latency
  - OpenSearch CPU, JVM memory, disk usage

### Recommendations
Add alarms for:
- Lambda:
  - Duration (p95 or p99)
  - Throttles
  - ConcurrentExecutions near limit
- API Gateway:
  - Latency (p95)
  - Integration latency
- OpenSearch:
  - JVM memory pressure
  - CPU utilization
  - Free storage space

---

## 3. Dashboards

### Inventory
Active dashboards include:
- `Lambda-Stats`
- `Lambda-Stats-v3`
- `Lobby-Personalisation`
- `Lobby-Personalisation-v2`
- `Lobby-Personalisation-v2-Videowall`
- `opensearch-nick`

### What’s visualised well
- Lambda:
  - Duration (per function)
  - Concurrent executions
- API Gateway:
  - Request count
  - 5XX error rate
  - Cache hit/miss rate
- OpenSearch:
  - Cluster health
  - Search rate & latency
  - Thread pool queue & rejections
  - CPU utilisation

### Assessment
✔ Dashboards are **service-aligned and operationally useful**  
✔ Videowall dashboard is well-suited for NOC / on-call visibility  
⚠ Some overlap and legacy dashboards may cause confusion

### Recommendations
- Consolidate:
  - Deprecate older dashboards (`Lambda-Stats` vs `Lambda-Stats-v3`)
- Standardise dashboard naming:
  - `<service>-prod-overview`
- Add:
  - Explicit “SLO view” (latency + errors together)
  - Links from alarms → dashboards

---

## 4. Metric Filters

### Current state
- **No metric filters defined**

### Impact
- No custom metrics derived from logs
- No ability to alert on:
  - Specific error patterns
  - Business-level signals
  - Known failure signatures

### Recommendations
Introduce metric filters for:
- Known error strings
- Dependency failures
- Timeout patterns
- Domain/business-level events (if applicable)

---

## 5. Observability Maturity Assessment

| Area       | Status                                  |
| ---------- | --------------------------------------- |
| Logs       | ⚠ Partial (short retention, no filters) |
| Metrics    | ✅ Strong for app layer                  |
| Alarms     | ⚠ App-focused, infra gaps               |
| Dashboards | ✅ Mature                                |
| Automation | ⚠ Limited                               |

Overall maturity: **Medium–High**

---

## 6. Key Risks & Actions

### R1 – Limited incident forensics (Medium)
**Cause**: Short log retention  
**Action**: Tiered retention strategy

### R2 – Infrastructure blind spots (Medium)
**Cause**: No infra-level alarms  
**Action**: Add OpenSearch & Lambda capacity alarms

### R3 – Signal-to-noise ceiling (Low–Medium)
**Cause**: No metric filters  
**Action**: Introduce targeted log-based metrics

---

## 7. Recommended Next Steps (30–60 days)

1. Standardise log retention across services
2. Add missing capacity & latency alarms
3. Consolidate dashboards
4. Introduce 2–3 high-value metric filters
5. Review alert routing and ownership

---

## 8. CloudWatch Hardening Checklist

### Log Management
- [ ] Explicitly set retention on **all** log groups
- [ ] Define tiered retention:
  - 7–14 days → low-risk / high-volume
  - 30–90 days → customer-impacting services
- [ ] Review KMS encryption requirements for compliance

---

### Alarms – Application Layer
- [ ] Add Lambda duration alarms (p95 or p99)
- [ ] Add Lambda throttle alarms
- [ ] Add concurrent execution saturation alarms
- [ ] Add API Gateway latency (p95) alarms
- [ ] Add API Gateway integration latency alarms

---

### Alarms – Infrastructure Layer
- [ ] OpenSearch JVM memory pressure alarm
- [ ] OpenSearch CPU utilization alarm
- [ ] OpenSearch free storage space alarm
- [ ] Optional: shard count / indexing pressure alarms

---

### Metric Filters (Logs → Metrics)
- [ ] Create metric filters for known error patterns
- [ ] Add filters for dependency failures (timeouts, connection errors)
- [ ] Consider business-level signals (if applicable)

---

### Dashboards
- [ ] Consolidate legacy dashboards
- [ ] Standardize naming (`<service>-prod-overview`)
- [ ] Link alarms → dashboards for faster triage

---

### Alert Routing & Ownership
- [ ] Verify SNS topics have clear ownership
- [ ] Ensure on-call coverage for all alarms
- [ ] Periodically test alarm notifications

---

### Review Cadence
- [ ] Quarterly review of alarms and dashboards
- [ ] Post-incident validation of signal quality


---

## Status

✅ CloudWatch resources inventoried  
✅ Alert coverage reviewed  
✅ Dashboard coverage validated  
⚠ Hardening & optimisation actions pending
