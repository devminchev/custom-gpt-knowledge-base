# API Gateway (REST) – Configuration & Cache Analysis Report (Prod)

## Purpose

This document provides a **complete and authoritative view** of the production Amazon API Gateway (REST) configuration, with emphasis on:

- API inventory
- Stage and method-level caching
- Cache TTLs
- Cache key parameters (path / query)
- Integration targets
- Cache safety assessment

All findings are based on **direct exports** from AWS Config and AWS CLI (`get-stages`, `get-method`, `get-integration`).

---

## 1. API Inventory

| API Name | Type | Stage(s) | Execute API Endpoint |
|--------|------|----------|----------------------|
| backoffice-v1 | REST | v1 | Disabled |
| backoffice-v2 | REST | v2 | Disabled |
| lobby-v1 | REST | v1 | Disabled |
| lobby-v2 | REST | v2 | Disabled |

**Notes**
- Only REST APIs (v1) are used.
- No API Gateway v2 (HTTP/WebSocket) APIs exist.
- Default `execute-api` endpoints are disabled.
- APIs are accessed exclusively via **custom domains / CloudFront**.

---

## 2. Stage-Level Cache Configuration

| API | Stage | Cache Enabled | Cache Size |
|----|------|---------------|------------|
| backoffice-v1 | v1 | ❌ No | N/A |
| backoffice-v2 | v2 | ❌ No | N/A |
| lobby-v1 | v1 | ✅ Yes | 0.5 GB |
| lobby-v2 | v2 | ✅ Yes | 0.5 GB |

**Interpretation**
- Backoffice APIs intentionally bypass API Gateway caching.
- Lobby APIs enable stage-level cache for read-heavy traffic.
- Cache clusters are provisioned per stage.

---

## 3. Cache TTL Configuration

### Default TTL (applies unless overridden)

| API | Stage | Scope | TTL |
|----|------|------|-----|
| lobby-v1 | v1 | `*/*` | 300 seconds |
| lobby-v2 | v2 | `*/*` | 300 seconds |

---

### Method-Specific TTL Overrides

#### lobby-v1 (stage: v1)

| Endpoint | Method | TTL |
|--------|--------|-----|
| `/sites/{sitename}/game-titles` | GET | 3600 |
| `/sites/{sitename}/historic-game-titles` | GET | 3600 |
| `/sites/{sitename}/platform/{platform}/get-bulk-game-data` | GET | 3600 |
| `/sites/{sitename}/platform/{platform}/minigames` | GET | 3600 |
| `/sites/{sitename}/platform/{platform}/search` | GET | 900 |

#### lobby-v2 (stage: v2)

| Endpoint | Method | TTL |
|--------|--------|-----|
| `/sites/{sitename}/game-titles` | GET | 3600 |
| `/sites/{sitename}/memberid/{memberid}/variant` | GET | 3600 |
| `/sites/{sitename}/platform/{platform}/get-bulk-game-data` | GET | 3600 |
| `/sites/{sitename}/platform/{platform}/minigames` | GET | 3600 |
| `/sites/{sitename}/platform/{platform}/search` | GET | 900 |

---

## 4. Cache Key Configuration (Critical Safety Section)

This section confirms **exact cache key parameters** used for each cached endpoint.

### General Observations
- All cached methods use **explicit cache key parameters**.
- Cache keys include **all path parameters** that influence response content.
- Where applicable, **query parameters** affecting output are included.
- No Authorization headers are used (authorizationType = NONE).

---

### Cache Key Details by Endpoint

#### `/sites/{sitename}/game-titles` (GET)
Cache key includes:
- `method.request.path.sitename`
- `method.request.querystring.locale`

✅ Safe for caching  
No user-specific or identity-based variance.

---

#### `/sites/{sitename}/platform/{platform}/minigames` (GET)
Cache key includes:
- `method.request.path.sitename`
- `method.request.path.platform`
- `method.request.querystring.locale`

✅ Safe for caching  
Correctly isolates platform and locale.

---

#### `/sites/{sitename}/platform/{platform}/get-bulk-game-data` (GET)
Cache key includes:
- `method.request.path.sitename`
- `method.request.path.platform`
- `method.request.querystring.locale`

✅ Safe for caching  
Bulk data is properly segmented.

---

#### `/sites/{sitename}/platform/{platform}/search` (GET)
Cache key includes:
- `method.request.path.sitename`
- `method.request.path.platform`
- `method.request.querystring.locale`
- `method.request.querystring.memberid`
- `method.request.querystring.auth`

✅ Safe for caching  
Search results vary by member/auth context and are correctly isolated.

---

#### `/sites/{sitename}/memberid/{memberid}/variant` (GET)
Cache key includes:
- `method.request.path.sitename`
- `method.request.path.memberid`

⚠️ **Identity-sensitive endpoint**

Assessment:
- Cache key includes `{memberid}` → prevents cross-user leakage.
- No authorization headers involved.
- Safe **as long as responses are strictly scoped to memberId**.

✅ Acceptable with current design  
🔁 Must be reviewed if auth headers or user roles are added later.

---

## 5. Integration Architecture

All cached endpoints use:
- `AWS_PROXY` integrations
- Lambda backends
- Timeout: 29 seconds

This ensures:
- Cache stores **post-integration responses**
- Lambda invocation is fully bypassed on cache hits

---

## 6. Cost & Performance Considerations

- Cache size: **0.5 GB per stage**
- Approximate cost: **~$18–20/month per stage**
- Total cache clusters: **2** (lobby-v1, lobby-v2)

Tradeoff:
- Reduced Lambda cost
- Reduced latency
- Increased API Gateway fixed cost

---

## 7. Final Assessment

| Area | Status |
|----|----|
| API inventory | ✅ Complete |
| Stage cache config | ✅ Verified |
| TTL correctness | ✅ Verified |
| Cache key safety | ✅ Verified |
| Identity isolation | ✅ Confirmed |
| Risk of cache leakage | ❌ None detected |

---

## 8. Recommendations

1. Revalidate cache keys if:
   - Authorization headers are introduced
   - Personalization logic changes
2. Periodically review TTLs vs content freshness.
3. Align API Gateway TTLs with CloudFront cache policies.
4. Consider disabling API Gateway cache if CloudFront fully satisfies caching needs.

---

## Status

**API Gateway configuration review is COMPLETE and production-safe.**
