# Production Readiness Report – Personalisation Platform

## Executive Summary

- **Platform is production-ready and stable**  
  Core services (API Gateway, Lambda, OpenSearch) are healthy, multi-AZ, and correctly sized for current demand.

- **Observability is strong at the application layer**  
  Errors are well-monitored, dashboards are mature, and alert noise is controlled.

- **Key improvements required in security and infrastructure alerting**  
  Access control hardening (OpenSearch) and deeper capacity alarms (CloudWatch) are the highest priorities.

---

## Architecture Overview

Client  
→ CloudFront  
→ API Gateway (REST)  
→ Lambda  
→ OpenSearch  

All components operate in `eu-west-2` with high availability.

---

## Service Readiness Summary

| Service     | Availability       | Security          | Observability | Status              |
| ----------- | ------------------ | ----------------- | ------------- | ------------------- |
| API Gateway | Multi-AZ           | TLS, auth         | ⚠️ Partial     | Ready               |
| Lambda      | Regional HA        | IAM               | ⚠️ Partial     | Ready               |
| OpenSearch  | Multi-AZ + standby | ⚠️ Needs hardening | ⚠️ Partial     | Conditionally Ready |
| CloudWatch  | N/A                | IAM               | ⚠️ Partial     | Ready               |

---

## Observability Assessment

**Strengths**
- Error-rate based alarms
- SNS notifications wired
- Service-aligned dashboards
- Cache-aware monitoring for APIs and OpenSearch

**Gaps**
- Limited infrastructure-level alarms
- Short log retention for some critical paths
- No log-based metric filters

---

## Security Assessment

**Strong**
- TLS everywhere
- Encryption at rest
- Audit logging enabled
- Fine-grained access control enabled

**Gaps**
- Overly permissive OpenSearch access policy
- Unclear VPC isolation posture

---

## Key Risks & Actions

### High Priority
1. Restrict OpenSearch access policy to approved IAM roles
2. Ensure OpenSearch is VPC-only with private subnets
3. Add OpenSearch capacity alarms

### Medium Priority
4. Add Lambda duration and throttle alarms
5. Add API Gateway latency alarms
6. Extend log retention for critical services

### Low Priority
7. Dashboard consolidation
8. Introduce log-based metrics

---

## Readiness Verdict

**Production-ready with required hardening actions.**

The platform is stable and fit for purpose today.  
Addressing the identified security and observability gaps will significantly reduce operational and security risk.

---

## Next Review

- Security & access controls: **Immediate**
- Observability improvements: **30–60 days**
- Full production readiness reassessment: **Quarterly**
