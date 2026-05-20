---
title: "Game Release Automation Solution Pack"
tags: [projects, game-release-automation, target]
aliases: []
---
Background

The Game Release Automation initiative aims to streamline and harden the end-to-end lifecycle of game releases by centralizing orchestration, enforcing role-based approvals, and making all changes auditable and compliant. This refined version incorporates updated business goals and expanded product requirements, including:

A Contentful Custom CF App (React) that implements App Action Functions, App Event Functions, and App Filter Functions to orchestrate the release flow.
A separate CF Workflow UI App (from the Contentful Marketplace) to define workflow stages and role-based approvals aligned to your requirements and criteria.
Event-driven asset stage with Bynder webhooks (no polling).
Manual approval gates: QA, Director, Compliance.
Jira updates strictly limited to:
failures/errors or manual rejections,
awaiting manual approvals,
staging/production setup done,
overall success.
Audit logging for every operation (success/failure, reason, duration, traceId).
Bulk operations up to 100 concurrent titles using AWS Lambda (with SQS worker-pool) rather than relying only on Contentful Function apps.
Legacy Process (High-Level Pain Points)

(Retained intent; elaborated details are preserved in Appendix A as originally written.)

Fragmented process across tools; inconsistent handoffs.
Manual, error-prone steps and lack of reliable stage-state visibility.
Incomplete audit trails and inconsistent Jira hygiene.
Parallelization risks and data validation late in the flow.
Proposed Solution

Centralised Contentful CMS solution:

CF Game Release Orchestrator Custom App (React UI + CF App Functions)
Orchestrates the automated parts of the flow end-to-end (Jira, CABO, Wallet, Tableau, UKGC/Legal) and drives the “happy path” and all error paths.
Implements App Action Functions to perform external calls and to drive transitions.
Implements App Event Functions to react to Contentful entry changes.
Implements App Filter Functions for governance (RBAC/visibility/guardrails).
Captures audit logs to Audit Store.
CF Workflow UI App (CF Marketplace)
Defines and presents workflow stages and role-based approvals.
Collects approval/rejection decisions (QA, Director, Compliance).
Signals results back to the Orchestrator (which then updates Jira & audit logs).

In the sequence diagram, these two are shown as a single participant for clarity, but remain separate apps in implementation.




Requirements
Functional Requirements
Start Release from Orchestrator UI; select gameId and markets.
Create/Validate Jira release ticket; capture idempotency keys.
Event-driven Assets: trigger Bynder; await AssetUploadCompleted event (no polling).
If Rejected, update Jira (Rejected(Assets), reasons), stop flow; notify GameOps.
Staging Setup (strictly sequential):
CABO: create/enable staging config →
Wallet API: patch wallet (staging).
On any error, update Jira (Error), stop flow; notify.
On success, set Jira to Staging Setup Done.
Tableau Data Checks (staging):
If Error, Jira update; stop; notify.
If Success, proceed.
Manual Approvals (via Workflow UI):
QA gate → Jira “Awaiting QA Approval”; approve/reject;
Director gate → Jira “Awaiting Director Approval”; approve/reject;
Compliance gate → Jira “Awaiting Compliance Approval”; approve/reject;
Any rejection updates Jira to Rejected(stage) with reason; stop; notify.
Compliance Record (UKGC/Legal):
If record Error, Jira Error; stop; notify.
Else Approved → proceed.
Production Promotion (EU/Global only; NA excluded per requirement):
CABO: enable prod config;
Wallet API: patch wallet (prod).
Errors → Jira update; stop; notify.
Success → Jira Production Setup Done.
Finalise: publish/release (live-hidden per policy), update new-games section; Jira → Done with history + auditId; notify GameOps.
Bulk operations up to 100 releases using AWS Lambda + SQS worker-pool.

Jira update rule (strict):

Only when (1) errors/rejections, (2) awaiting manual approvals, (3) staging/production setup done, (4) overall success.

Business Requirements
Reduced cycle time with reliable automation and clear approvals.
Full traceability and compliance-ready audit trail.
Strict separation of duties: GameOps vs. Design/QA/Director/Compliance.
Scale to high throughput (bulk) without sacrificing control or auditability.
Event-driven over polling; deterministic and idempotent automation.
Non-Functional Requirements
Security & RBAC: least privilege for app functions and external integrations; secrets in a vault/parameter store; PII-safe logging.
Resilience: idempotent operations, retries with exponential backoff, dead-letter queue for bulk, compensatory steps only via manual controlled actions.
Observability: structured logs {stage, action, start, success|error(reason), duration, traceId}; correlation IDs across calls; dashboards for stage SLIs.
Performance: bounded latency per stage; concurrency managed by AWS Lambda for bulk; backpressure via SQS.
Cost: serverless-first; minimal idle compute; avoid polling by using webhooks/events.
Dependencies
Contentful (CF Custom App + CF Workflow UI App).
Jira.
Bynder (assets & design workflow, webhooks).
CABO API (game config).
Wallet API (wallet patching).
Tableau (data checks).
UKGC/Legal (compliance record).
Audit Store (S3/CloudWatch/OpenSearch or equivalent).
AWS Lambda + SQS (bulk ops to 100 titles).
Phases / Milestones

Phase 1 — Core Orchestrator (UI + App Functions)

Objectives: Bootstrap React UI, App Action/Event/Filter Functions; wire Jira create/validate; unified audit envelope with traceId.
Deliverables: App scaffold, Jira transitions (Create/Validate + error states), audit schema + dashboard v1.
Entry criteria: Jira project/workflow finalized; service account token ready.
Exit criteria: Start Release → Jira ticket created or deterministically rejected; every happy/error path logged.

Phase 2 — Asset Stage (Event-Driven) & Approvals Wiring

Objectives: Bynder webhook path (no polling); Marketplace Workflow UI configured (QA/Director/Compliance).
Deliverables: Webhook endpoint + signature verification; stage timeline UI; “Awaiting X Approval” transitions.
Exit criteria: Asset rejection halts flow + Jira updated with reason; approvals captured with actor, timestamp, reason.

Phase 3 — Staging Setup & Data Checks

Objectives: Sequential CABO→Wallet staging; Tableau checks.
Deliverables: Idempotent calls with retries/backoff; failure gating; “Staging Setup Done” transition.
Exit criteria: Staging completed or flow stopped with precise error taxonomy; Tableau success required to proceed.

Phase 4 — Manual Gates & Compliance Record

Objectives: QA → Director → Compliance gates; UKGC/Legal record capture.
Deliverables: Role-based gates in Workflow UI; compliance record API/manual capture with audit trail.
Exit criteria: All gates approved and compliance recorded, or stopped with rejection reason pushed to Jira.

Phase 5 — Production Promotion & Publish

Objectives: CABO prod enable → Wallet prod patch → publish (live-hidden policy).
Deliverables: “Production Setup Done” transition; CMS publish + new-games section update.
Exit criteria: Production success audited end-to-end; Jira → Done with attached auditId.

Phase 6 — Bulk Orchestration (≤100 titles)

Objectives: Lambda + SQS worker-pool; chunking, idempotency keys; partial-failure summaries.
Deliverables: Batch console in UI; DLQ + replay; rate-limit guardrails per integration.
Exit criteria: 100-title soak passes; per-title outcomes exported; no dropped audits under sustained load.

Quality gates across all phases

Jira updates only at four moments: errors/rejections, awaiting manual approvals, staging/prod done, final success.
Every step emits {stage, action, success|error(reason), duration, traceId} to Audit Store with dashboards.
Solution Design Diagrams
C4 Context Diagram

C4 Container Diagram

Key Points:

GameOps Team interacts with the Custom React App UI (running in Contentful).
CF Custom App Action Functions handle direct calls to external systems.
CFCustom App Event Functions respond to content events (e.g., asset updated/published).




Sequence Diagram




Wireframes / Mocks for UI/UX (If Necessary)
CF Game Release Orchestrator Custom App UI:
Start Release form: gameId, markets, options.
Stage timeline: “Create/Validate”, “Assets”, “Staging”, “Data Checks”, “Approvals (QA/Director/Compliance)”, “Production”, “Publish”.
Status badges & timestamps; link to Jira ticket and audit IDs.
Manual controls: Retry, Stop, Open Jira, Open Asset in Bynder.
Bulk Console: batch upload gameIds[], show per-title rows, filter by status, export CSV.
CF Workflow UI App (Marketplace):
Stage/gate configuration mapped to the requirement set.
Role-based approval panels (QA/Director/Compliance), rejection reason capture.
Testing Approach

Test pyramid & coverage

Unit: App Functions (Jira/CABO/Wallet/Tableau/Legal) with mocks; idempotency and retry logic.
Contract tests: Provider/consumer contracts (e.g., Pact) for Jira/Bynder/CABO/Wallet/Tableau payloads; run on CI merge gates.
Integration: Sandbox endpoints where available; webhook signature validation; end-to-end audit correlation.
E2E (UX): Orchestrator UI flows (Start → Done) incl. manual gates using headless browser tests; deterministic fixtures for games/markets.
Bulk/soak: 100-title batches with mixed outcomes; verify partial-failure handling, DLQ, replay, and summary export.
Negative/chaos: Inject CABO/Wallet/Tableau/Bynder errors and timeouts; ensure flow stops, Jira is updated at the allowed moments, and alerts fire.
Security/RBAC: Role isolation for GameOps/QA/Director/Compliance; secrets handling; least-priv checks.
Observability & auditability: Assert one audit record per state change with traceId; alert on gaps/missing webhook events.
Performance budgets: Stage latency SLOs; backpressure observed (SQS depth, Lambda concurrency) under load.

Environments & data

Fixture set: Dummy games, markets, wallet states; Bynder sample assets; Tableau staging dataset.
Repeatability: Deterministic ids (idempotency keys) for re-runs; webhook replay harness.
Roll Out Considerations

Release strategy

Feature flags by stage & market (enable Assets, Staging, Approvals, Prod independently; EU/Global only, NA excluded per scope).
Gradual ramp: Single-title canary → cohort (≤10) → scale to ≤100 bulk once dashboards are green.
Dark launch elements: Approvals/UI visible; orchestration writes gated off until readiness checklist passes.

Operational readiness

Runbooks: Start/stop, retry, backfill, webhook replay, DLQ drain; on-call rotations defined.
Dashboards & alerts: Stage SLIs, error taxonomy by integration, SQS depth, Lambda concurrency; alert on missing Bynder events and Jira transition failures.
Training: GameOps & approvers walkthrough; rejection reason taxonomy; “what happens on failure” drills.

Compatibility & migration

In-flight tickets: Map legacy statuses to new four-moment Jira rule; do not auto-transition historical items.
Data retention: Confirm 1-year audit retention (OpenSearch/S3) and snapshot policy.

Risk & backout

Immediate stop: Kill-switch flag disables external writes while keeping UI read-only.
Safe revert: If Prod promotion fails, revert wallet/cabo to last-known good; keep Jira in error with reason and link to auditId.
Incident practice: Post-incident review template; track MTTR and error classes to drive fixes.
Monitoring and Alerting
Dashboards: stage completion times, error rates by integration, queue depth (SQS), Lambda concurrency.
Alerts: on repeated failures per stage; missing webhook events (assets); audit logging gaps; Jira transition failures.
Tracing: distributed tracing IDs across Orchestrator → external dependencies.
Reporting
Periodic release throughput (by market, by game studio).
Approval latency by role (QA/Director/Compliance).
Error taxonomy (CABO staging, Wallet patching, Tableau checks, Compliance record).
Bulk outcomes: success/failure counts, MTTR for retries.
Decision Log
Event-driven assets (Bynder webhooks) instead of polling — reduces latency/cost and increases reliability.
Sequential staging (CABO → Wallet) — avoids race conditions.
Jira update rule limited to 4 critical moments — avoids noise; creates clean, auditable states.
Separate CF Workflow UI App (Marketplace) for approvals — clearer separation of concerns and configurable gating.
Bulk via AWS Lambda instead of only Contentful Functions — scale, cost, observability, retries.
NA-specific flows explicitly excluded per current scope.
Requirements Traceability Matrix (RTM)

The RTM links business and functional requirements to their workflow stages, actors/roles, and system components. It ensures every requirement has an accountable implementation and is fully auditable.

Requirement / User Story	Workflow Stage	Actors / Roles	System Components (Apps/APIs)
As GameOps, I want to start a release from Contentful so that the process is centralized	Start Release	GameOps	Game Release Orchestrator UI (Custom CF App)
As the system, I need to create/validate a Jira ticket for every release	Jira Create/Validate	GameOps (indirect)	CF Game Release Custom App/AppFunctions → Jira API
As Design Team, I must upload assets and approve their readiness	Asset Upload (Bynder)	Design Team	CF Game Release Custom App/AppFunctions → Bynder (event-driven)
The system must stop if assets are rejected and update Jira accordingly	Asset Upload Rejection	Design Team	CF Game Release Custom App/AppFunctions → Jira, Audit Store
As a system, I need to set up staging configs via CABO	Staging Setup (CABO)	GameOps (indirect)	CF Game Release Custom App/AppFunctions → CABO API
As a system, I need to patch wallets in staging	Staging Setup (Wallet)	GameOps (indirect)	CF Game Release Custom App/AppFunctions → Wallet API
As QA, I want a manual gate before production	QA Approval	QA Team	CF Workflow UI App → CF Game Release Custom App/AppFunctions
As Director, I want to approve releases before production	Director Approval	Director	CF Workflow UI App → CF Game Release Custom App/AppFunctions
As Compliance Team, I must approve releases for regulatory reasons	Compliance Approval	Compliance Team	CF Workflow UI App → CF Game Release Custom App/AppFunctions
As a system, I must record compliance decisions in UKGC/Legal system	Compliance Record	Compliance Team (indirect)	CF Game Release Custom App/AppFunctions → LEG API
As a system, I must validate data consistency before go-live	Tableau Data Checks	GameOps (indirect)	CF Game Release Custom App/AppFunctions → Tableau API
As a system, I must enable production configs and wallets	Production Promotion	GameOps (indirect)	CF Game Release Custom App/AppFunctions → CABO API, Wallet API
As a system, I must finalize release and publish game metadata	Publish/Release + Update CMS	GameOps (indirect)	CF Game Release Custom App/AppFunctions → Contentful Entries
As a system, I must log every stage result with traceability	Audit Logging	All (system responsibility)	CF Game Release Custom App/AppFunctions → Audit Store
As GameOps, I want Jira updated at key points only	Jira Updates	GameOps (monitor)	CF Game Release Custom App/AppFunctions → Jira
As Ops, I want to handle up to 100 releases concurrently	Bulk Release	GameOps	CF Game Release Custom App/AppFunctions → AWS Lambda + SQS, Jira, Audit
As Ops, I want partial failures in bulk handled gracefully	Bulk Release Failure Handling	GameOps	AWS Lambda Worker-Pool → Jira Updates + Audit
As Audit/Compliance, I want immutable logs with success/failure reasons	End-to-End Audit Trail	Compliance/Audit Stakeholders	Audit Store (S3/CloudWatch/OpenSearch)
As Security, I want secrets managed and RBAC enforced	Security/Non-Functional	All	CF Game Release Custom App/AppFunctions (secrets store, role checks)
As Product, I want role separation and clear accountability	Approvals + Stage Gates	QA, Director, Compliance Teams	CF Workflow UI App, CF Game Release Custom App/AppFunctions
Key Insights
Coverage: Every requirement from the business vision and functional list maps directly to a stage and actor.
Auditability: All requirements map to the Audit Store, ensuring traceable execution.
Scalability: Bulk handling requirements map explicitly to AWS Lambda + SQS.
Separation of Duties: Approvals are role-bound, enforcing compliance and governance.
Development Kickoff Readiness (Minimal Requirements)
Minimal Go/No-Go Checklist
Jira game release project & roadmap table (issue type/workflow) confirmed.
Jira API token/service account provisioned.
Jira workflow statuses agreed: statuses and allowable transitions that the Orchestrator will set:
Error / Rejected (with reason)
Awaiting Assets
Awaiting QA Approval
Awaiting Director Approval
Awaiting Compliance Approval
Staging Setup Done
Production Setup Done
Done (final success)
The Work Can Be Started with Minimal Requirements
Orchestrator Custom CF App scaffold (React + App Functions).
Jira create/validate & controlled transitions per taxonomy.
Event-driven Bynder integration (notify + webhook) with rejection path to Jira.
Sequential Staging setup (CABO → Wallet) with idempotency and audit logs.
Tableau data checks and failure gating.
Workflow UI gate wiring (QA, Director, Compliance) using the RBAC mapping.
Compliance record integration (UKGC/Legal) following the same audit schema.
Production promotion (CABO + Wallet) honoring approvals.
Later/Last: Bulk (≤100) via AWS Lambda + SQS, extended dashboards/alerts, retention tuning.

Mandatory to start development. All other dependencies are not blockers and can be iterated post-kickoff.

Minimal Requirements During Development (Progressive Enablers)
Bynder Integration Access & Contracts
CABO API Integration Access & Contracts
Wallet API Integration Access & Contracts
Design Team contact assigned for asset workflow alignment.
Asset completion payload/contract documented (Completed / Rejected event).
Sandbox credentials issued.
Test accounts with configurable dummy games.
Tableau Integration Access & Contracts
Tableau Dataset refresh policy documented.
Role mappings integrated with identity provider (Jira groups/Contentful roles).
CF Workflow UI App configured with stages/gates (QA, Director, Compliance).
Alert channels defined (Slack/email). GameOps escalation/notification channels active for failed approvals.
Q & A Resolution
Jira, Roadmap & Release Tickets

Q: What data needs to be migrated from Monday to Jira?

A: Roadmap (game release, game design) and references from Math sheet. Jira becomes single source of truth for release tickets. ✅ Resolved

Q: What is happening to the Math Sheet?

A: Not integrated into automation. Still referenced upstream; Jira drives workflow. ❌ N/A

Q: At what point will the Roadmap in Jira get updated?

A: Must be complete before automation can start. Orchestrator blocks if incomplete. ✅ Defined dependency

Q: How will the release ticket be created?

A: Auto-created/validated by the Orchestrator App in Jira at workflow start. ✅ Resolved

Q: How will bulk upload work?

A: Via AWS Lambda + SQS (not Contentful Functions). Input: Excel/CSV → Orchestrator → Contentful. Supports ≤100 games. ✅ Resolved

Q: Do we need to integrate with WH?

A: No. Explicitly excluded from scope. ✅ Resolved

Assets & External Parties

Q: Should assets from Contentful automatically be assigned to the game?

A: Yes. Bynder webhook → Orchestrator → asset assignment to siteGameV2. ✅ Resolved

Q: Will integrations require work from external parties?

A: Yes. Providers (e.g., L&W, Hasbro, BP) must sign off assets. Orchestrator can automate notifications. ✅ Resolved

Approvals & Compliance

Q: Do QA, Legal and Director all need to approve before release?

A: Yes. Role-based: Spain = Director + Compliance, UK = Director + Legal, QA required in both. ✅ Resolved

Q: Will all approvals be done in Contentful?

A: Yes. CF Workflow UI App captures manual approvals/rejections. ✅ Resolved

Q: Does Live Hidden come after approval?

A: Yes. After Director + Compliance (Spain) or Director + Legal (UK). ✅ Resolved

Q: Do we need to integrate with UKGC?

A: Yes. UK requires Legal approval recorded (API/manual). Spain only requires Compliance + Director. ✅ Resolved

Notifications, UI & Reporting

Q: Who receives error alerts?

A: GameOps + responsible team. Delivered via Jira + Slack/Email. ✅ Resolved

Q: Do we need designs for the UI in Contentful?

A: Yes. Orchestrator App provides UI, CF Workflow UI App defines gates. Keep design simple. ✅ Resolved

Q: Is game removal process unchanged?

A: Yes. Still requires Director approval. ✅ Resolved

Q: Basic reporting frequency?

A: Per release. Triggered automatically. ✅ Resolved

Q: Basic reporting distribution?

A: Trigger in Contentful → Orchestrator → Email/Slack. ✅ Resolved

Q: How long should logs be stored?

A: Proposal = 1 year retention (OpenSearch/S3). Needs final confirmation. ✅ Resolved

Q: Who has access to the app?

A: Role-based: GameOps, Design, QA, Director, Compliance. RBAC mapping enforced. ✅ Resolved