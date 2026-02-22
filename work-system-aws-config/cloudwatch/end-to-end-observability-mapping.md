## End-to-End Observability Mapping

This section documents how CloudWatch monitoring, alarms, and dashboards map to the production request path across services.

### Request Flow
Client  
→ CloudFront  
→ API Gateway (REST)  
→ Lambda  
→ OpenSearch  

---

### API Gateway

**Monitored via**
- CloudWatch metrics: `5XXError`, `Count`, `Latency`
- Alarm: API Gateway 5XX error rate (SNS notification enabled)

**Dashboards**
- Lobby-Personalisation*
- Videowall dashboard

**Gaps**
- No explicit latency percentile (p95/p99) alarms
- No integration latency alarms

---

### Lambda

**Monitored via**
- CloudWatch metrics: `Errors`, `Invocations`, `Duration`, `ConcurrentExecutions`
- Per-function **error rate alarms** with SNS notifications
- Minimum invocation guards prevent false positives

**Dashboards**
- Lambda-Stats
- Lambda-Stats-v3

**Gaps**
- No duration (p95/p99) alarms
- No throttle or concurrency saturation alarms

---

### OpenSearch

**Monitored via**
- Dashboards (search rate, latency, CPU, thread pools)
- Logs: application, audit, slow logs

**Alarms**
- ❌ No CloudWatch alarms for:
  - JVM memory pressure
  - Disk free space
  - CPU saturation

**Risk**
- OpenSearch issues may only be detected reactively via dashboards or downstream errors.

---

### Logs

**Coverage**
- Lambda logs: `/aws/lambda/*`
- API Gateway logs: `/aws/apigateway/*`

**Retention**
- 7–14 days (Lambda)
- Some API Gateway log groups have no explicit retention

**Metric Filters**
- ❌ None configured

---

### Summary

| Layer       | Metrics | Alarms | Dashboards | Gaps                       |
| ----------- | ------- | ------ | ---------- | -------------------------- |
| CloudFront  | Partial | ❌      | ❌          | Latency / error alarms     |
| API Gateway | ✅       | ⚠️      | ✅          | Latency alarms             |
| Lambda      | ✅       | ⚠️      | ✅          | Duration / throttle alarms |
| OpenSearch  | ⚠️       | ❌      | ✅          | Capacity alarms            |
| Logs        | ✅       | ❌      | ❌          | Metric filters             |

**Overall**: Good application-level observability, weaker infrastructure-level alerting.
