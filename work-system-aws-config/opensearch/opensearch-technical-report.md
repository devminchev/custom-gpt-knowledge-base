# OpenSearch – Configuration & Operations Report (Prod)


## Executive Summary

- **Platform is stable and correctly sized**  
  The OpenSearch cluster is healthy (green), multi-AZ, and appropriately provisioned for current production load, with sufficient storage headroom and strong read performance.

- **Performance is good, but cache pressure is visible**  
  Request cache delivers high value (~70% hit rate) but shows very high eviction counts, indicating memory pressure and an opportunity for tuning or capacity optimisation.

- **Security hardening is required**  
  While encryption, TLS, logging, and fine-grained access control are enabled, the domain access policy is overly permissive and should be restricted to approved IAM roles and/or VPC-only access to reduce exposure risk.

---

## Scope

Domain: `personalisation-lobby` (eu-west-2)  
Engine: OpenSearch `2.13` (cluster reports 2.13.0):contentReference[oaicite:0]{index=0}:contentReference[oaicite:1]{index=1}

This report covers:
- Cluster sizing and availability (nodes, instance types, storage, AZs)
- Security posture (TLS, encryption, FGAC, access policy, logging)
- Index and shard inventory (docs + store)
- Shard distribution notes
- Cache analysis and behaviour (query cache + request cache)
- Risks and recommended actions

---

## 1) Cluster sizing summary

### Topology & HA
- Cluster health: **green**:contentReference[oaicite:2]{index=2}
- Nodes: **6 total**, **3 data nodes**:contentReference[oaicite:3]{index=3}
- Shards: **103 primary shards**, **309 total shards** (replicas in effect):contentReference[oaicite:4]{index=4}
- Zone awareness enabled across **3 AZs**:contentReference[oaicite:5]{index=5}
- **Multi-AZ with Standby: enabled**:contentReference[oaicite:6]{index=6}

### Instance Types
- Data nodes: `r5.2xlarge.search`
- Dedicated masters: `m5.large.search`
- 
### Node sizing (control plane config)
- Data nodes: `r5.2xlarge.search` × **3**:contentReference[oaicite:7]{index=7}
- Dedicated masters: enabled, `m5.large.search` × **3**:contentReference[oaicite:8]{index=8}

### Storage (EBS)
- EBS enabled (gp3): **100 GiB per data node** (3 nodes):contentReference[oaicite:9]{index=9}
- gp3 performance: **3000 IOPS**, **125 MB/s throughput**:contentReference[oaicite:10]{index=10}
- Volume size: **100 GiB per data node**
- Total provisioned data storage: **300 GiB**

### Current data footprint (from `_stats/docs,store`)
- Primaries:
  - Docs: **9,505,165**
  - Deleted docs: **1,496,973**
  - Store: **38,729,788,147 bytes (~36.1 GiB)**:contentReference[oaicite:11]{index=11}
- Total (includes replicas):
  - Docs: **28,515,495**
  - Deleted docs: **4,228,741**
  - Store: **118,691,625,501 bytes (~110.6 GiB)**:contentReference[oaicite:12]{index=12}

### Current Usage (approx.)
- Primary data: ~36 GiB
- Total data (incl. replicas): ~110 GiB

Disk utilization (approx):
- Provisioned EBS raw capacity: 3 × 100 GiB = 300 GiB (data nodes only):contentReference[oaicite:13]{index=13}
- Current total store: ~110.6 GiB across replicas (~36.1 GiB primaries):contentReference[oaicite:14]{index=14}

**Assessment**  
The cluster is appropriately sized with comfortable storage headroom. No immediate scaling action required.

---

## 2) Security posture

### Transport security (TLS)
- HTTPS enforced: **true**
- TLS policy: **Policy-Min-TLS-1-2-2019-07**
- Custom endpoint enabled: `lobbycontent-opsearch.prod.eu00.aws.ballys.tech`:contentReference[oaicite:15]{index=15}

### Encryption
- Encryption at rest: **enabled** (KMS key configured):contentReference[oaicite:16]{index=16}:contentReference[oaicite:17]{index=17}
- Node-to-node encryption: **enabled**:contentReference[oaicite:18]{index=18}

### Fine-grained access control (FGAC)
- Advanced security: **enabled**
- Internal user DB: **enabled**
- Anonymous auth: **disabled**:contentReference[oaicite:19]{index=19}

### Logging
CloudWatch log publishing enabled for:
- SEARCH_SLOW_LOGS
- ES_APPLICATION_LOGS
- AUDIT_LOGS
- INDEX_SLOW_LOGS:contentReference[oaicite:20]{index=20}

### Access policy (HIGH RISK)
Current access policy allows:
- Principal: `"AWS":"*"`
- Action: `"es:ESHttp*"`
- Resource: domain `personalisation-lobby/*`:contentReference[oaicite:21]{index=21}

This is extremely permissive. If the domain is reachable from outside trusted networks, this is a critical exposure.

### VPC attachment (unclear / likely NOT VPC-restricted)
Config shows `VPCOptions: {}` (no subnet/security group details):contentReference[oaicite:22]{index=22}  
This usually indicates the domain is **not** VPC-attached (or VPC data is not configured/returned). Treat as **not VPC-restricted** until proven otherwise.

---

## 3) Index inventory (docs + store size)

Source: `_cat/indices?v&s=store.size:desc`:contentReference[oaicite:23]{index=23}

Top indices by total store size:

| Index                                                              |  Pri |  Rep |      Docs | Deleted |   Store | Pri Store |
| ------------------------------------------------------------------ | ---: | ---: | --------: | ------: | ------: | --------: |
| vitruvian-ml-eu-games-recommender-v2                               |    3 |    2 | 2,026,612 | 423,459 |  49.8gb |    17.7gb |
| ml-recently-played                                                 |    1 |    2 | 1,767,483 | 334,671 |  28.6gb |     7.6gb |
| vitruvian-ai-because-you-played-x-recommendations-v1               |    3 |    2 | 1,370,814 | 151,494 |   8.9gb |     2.9gb |
| vitruvian-ai-because-you-played-z-recommendations-v1               |    3 |    2 | 1,155,317 | 254,473 |   8.1gb |     2.7gb |
| vitruvian-ai-because-you-played-y-recommendations-v1               |    3 |    2 | 1,094,475 | 233,749 |   7.5gb |     2.5gb |
| vitruvian-ml-eu-games-recommender-content-based-recommendations-v1 |    3 |    2 | 1,407,135 |  97,033 |   7.0gb |     2.3gb |
| games-v2                                                           |    1 |    2 |    23,170 |   1,584 | 119.7mb |      40mb |
| ab-variants                                                        |    1 |    2 |   620,907 |       0 | 112.1mb |    37.6mb |
| games                                                              |    1 |    2 |    23,163 |      62 |  98.1mb |    32.7mb |
| vitruvian-ai-games-similarity-v1                                   |    3 |    2 |     3,239 |       0 |  28.3mb |     9.4mb |
| sections                                                           |    1 |    2 |     5,453 |     242 |  28.2mb |     9.4mb |
| game-sections                                                      |    1 |    2 |     1,365 |      85 |  13.7mb |     4.5mb |

Notes:
- Many large indices are configured with **replicas = 2** (3 copies total), which increases HA but also increases storage and memory overhead.:contentReference[oaicite:24]{index=24}

**Observations**
- Several large, read-heavy ML/recommendation indices
- Replica count = 2 on most large indices (3 copies total)

---

## 4) Shard distribution notes

Source: `_cat/shards?v&s=store:desc`:contentReference[oaicite:25]{index=25}

### Largest observed shard copies
- `ml-recently-played` shard 0 (replica): **13.1gb**:contentReference[oaicite:26]{index=26}
- `ml-recently-played` shard 0 (primary): **7.6gb**:contentReference[oaicite:27]{index=27}
- `vitruvian-ml-eu-games-recommender-v2` primaries are ~**5.4–6.2gb** per shard:contentReference[oaicite:28]{index=28}

### Shard count pressure (macro view)
- Total shards: **309**
- Data nodes: **3**
- Average shards per data node: ~103 shards/node (309 ÷ 3):contentReference[oaicite:29]{index=29}

This is not inherently bad, but it’s a number to monitor if index count grows (shard overhead accumulates).

**Assessment**
- Shard sizes are within acceptable bounds.
- Shard count is reasonable today but should be monitored as index count grows.

---

## 5) Cache analysis

### Request cache (high utilization)
Cluster totals (`_stats/query_cache,request_cache`):
- Primaries request cache:
  - Memory: **300,222,439 bytes (~286 MB)**
  - Memory usage (total): **~859 MB**
  - Hits: **208,972,500**
  - Hit rate: **~70%**
  - Misses: **89,049,382**
  - Evictions: **75,243,101**:contentReference[oaicite:30]{index=30}
  - Evictions status: **Very high**

**Interpretation**
- Request cache is highly valuable for workload.
- High eviction count suggests memory pressure and cache churn.

- Total request cache (includes replicas):
  - Memory: **901,078,942 bytes (~859 MB)**
  - Hits: **627,546,780**
  - Hit rate: **<0.1%**
  - Misses: **267,363,099**
  - Very high miss and eviction counts
  - Evictions: **225,269,574**:contentReference[oaicite:31]{index=31}

Derived:
- Approx request-cache hit rate = hits / (hits + misses)
  - 627,546,780 / (627,546,780 + 267,363,099) ≈ **70%**

Interpretation:
- Request cache is doing a lot of work (good), but eviction counts are very high → cache churn / memory pressure.

Node-level view shows request cache load concentrated on data nodes (masters show 0), as expected:contentReference[oaicite:32]{index=32}.

### Query cache (very low efficiency)
Cluster totals:
- Primaries query cache:
  - Memory: **14,924,105 bytes (~14 MB)**
  - Hit rate: **<0.1%**
  - Hits: **2,270,040**
  - Misses: **6,287,868,049**
  - Evictions: **12,002,233**:contentReference[oaicite:33]{index=33}
  - Very high miss and eviction counts

- Total query cache:
  - Memory: **45,409,705 bytes (~43 MB)**
  - Hits: **6,739,375**
  - Misses: **18,795,165,369**
  - Evictions: **36,303,381**:contentReference[oaicite:34]{index=34}

Derived:
- Approx query-cache hit rate ≈ **0.036%** (near-zero).

**General Interpretation**:
- Query cache is thrashing (huge miss & eviction counts).
- This is common when queries are not cache-friendly (high cardinality filters, frequent updates, or queries not eligible for query-cache).
- Not necessarily a “bug,” but it’s not providing meaningful benefit right now.
- Query cache provides negligible benefit for current query patterns.
- This is common for high-cardinality or frequently changing queries.


### Request cache enablement
A query for explicit `index.requests.cache.enable` returned `{}` (no explicit per-index setting).  
This typically means the setting is not overridden at index level (defaults apply), and/or caching is driven by query shape/flags.

---

## 6) Key risks & recommended actions

---

### R1 — **Critical**: Access policy allows `Principal: "*"` for `es:ESHttp*`
Evidence: access policy in config permits any AWS principal (`"*"`).:contentReference[oaicite:35]{index=35}

**Risk**
- If the domain is reachable beyond intended networks, this is a high-severity exposure (data exfiltration, deletion, ransom indexing, etc.).

**Actions**
1. Restrict domain access policy to **specific IAM roles** (and/or specific AWS accounts), not wildcard.
2. Prefer **VPC-only** domain (private subnets + SG) so the service is not internet reachable.
3. Add/confirm network controls even if VPC-only:
   - SG inbound limited to app/bastion/VPN
   - NACLs as appropriate
4. Ensure Dashboards access is similarly controlled.

## Overly Permissive Access Policy (**Critical**)
**Risk**: Potential unintended access to OpenSearch APIs  
**Action**: Restrict policy to approved IAM roles and/or VPC-only access

---

### R2 — High cache churn (request cache) + very low utility (query cache)
Evidence: request cache evictions are very high (225M total evictions); query cache hit rate is near-zero with high evictions.:contentReference[oaicite:36]{index=36}

**Risk**
- Request cache churn can drive heap pressure and unpredictable latency under load.
- Query cache is consuming some memory but yielding negligible benefit.

**Actions**
1. Identify top cached indices (by request_cache hits/evictions) and confirm queries are intended to be cached.
2. Consider tuning:
   - Reduce needless cacheability (avoid caching for high-variance queries).
   - If request cache is truly beneficial (70% hit rate suggests yes), evaluate more heap capacity (larger nodes) or fewer competing workloads.
3. If query cache is not useful for workload, consider reducing reliance on it by changing query patterns rather than “turning knobs” blindly.

## Cache Memory Pressure (**Medium**)
**Risk**: Latency spikes under load  
**Action**:  
- Review cache-eligible queries  
- Consider increasing heap capacity or tuning cache usage

---

### R3 — Replica count = 2 on large indices (cost vs benefit)
Evidence: multiple large indices use `rep = 2` (3 copies).:contentReference[oaicite:37]{index=37}

**Risk**
- Increased storage and memory overhead (roughly ~3x storage across replicas).
- More shards overall → higher per-node shard overhead.

**Actions**
1. Validate HA/RPO/RTO requirements:
   - With 3 AZs + dedicated masters + standby enabled, **replicas=1** may still be acceptable for some use cases.
2. If replicas can be reduced safely, it will reduce storage, shard count, and cache pressure.

## Replica Cost vs Benefit (**Medium**)
**Risk**: Higher storage and memory overhead  
**Action**: Re-evaluate whether replica count = 2 is required for all indices

---

### R4 — Deleted docs are material (segment bloat / merge cost)
Evidence: primaries deleted docs ~1.5M (and total deleted ~4.2M).:contentReference[oaicite:38]{index=38}

**Risk**
- Larger segments, heavier merges, more disk I/O.

**Actions**
1. Review update patterns on biggest indices.
2. Consider ILM/ISM-like lifecycle patterns (rollover + delete) where applicable (especially for time-based data).
3. Monitor merge times and disk I/O (CloudWatch + slow logs).

## Deleted Docs Accumulation (**Low–Medium**)
**Risk**: Segment bloat and merge overhead  
**Action**: Review update patterns and consider rollover/retention strategies

---

## 7) Appendix – Evidence files

Control plane (AWS CLI):
- `domain__describe-domain.json`
- `domain__describe-domain-config.json`

Data plane (Dashboards Dev Tools exports):
- `1_cluster_health.json`
- `2_cat_indices__store_desc.txt`
- `3_cat_shards__store_desc.txt`
- `4_index_stats__docs_store.json`
- `5_cache_stats__index_query_request.json`
- `7_cache_stats__nodes_query_request.json`

---

## 8. Security Hardening Checklist

### Access Policy (High Priority)
- [ ] Replace wildcard principal (`"AWS": "*"`) with explicit IAM roles
- [ ] Limit `es:ESHttp*` actions to required services only
- [ ] Review policy quarterly

### VPC Isolation
- [ ] Confirm whether domain is VPC-attached
- [ ] If not, migrate to **VPC-only OpenSearch**
- [ ] Place domain in private subnets
- [ ] Restrict Security Group ingress to app + bastion/VPN

### Dashboards Access
- [ ] Restrict Dashboards to IAM-approved users
- [ ] Avoid broad human access

### Monitoring & Audit
- [ ] Retain audit logs per compliance requirements
- [ ] Alert on unauthorized access attempts
- [ ] Alert on disk and heap pressure

---

## Status

✅ Cluster sizing documented  
✅ Security posture documented  
✅ Index inventory captured (top by size)  
✅ Shard distribution reviewed  
✅ Cache analyzed (cluster + nodes)  
✅ Risks & actions identified
⚠️ Security hardening actions pending