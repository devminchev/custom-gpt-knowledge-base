# New Project Initiative - GAME RELEASE AUTOMATION

---

## Current Situation

* Highly manual workflows across multiple territories (EU, NA)
* Retirement of monday.com
* Tool fragmentation (Excel, Google Docs, Infinity, Contentful, Monday.com, Jira, Confluence, GitHub, etc.)
* Resource constraints with the Game Ops team at capacity and no headcount increases approved
* Competitive disadvantage, particularly in the US market where we have fallen behind competitors
* Revenue opportunities missed due to limited capacity for new games and integrations
* Compliance risks from lack of automated verification of live content
* Dependencies on third parties (WhiteHat) for configuration in North America
* Delayed value realization for strategic initiatives like

---

## Opportunity

* Opportunity to be more competitive with our offerings when we launch new sites
* Deliver more content from supplier portfolio on day one to reduce customer attrition
* Ability to react in a timely fashion when suppliers have offers
* Improvement to data reliability as reduction of manual data entry requirement and better compliance posture
* No additional head count required to support new suppliers, new sites, new territories
* Reduction of manual data entry leads to more games being released.
* Better Visibility - Single dashboard for game status, logs, and pending approvals.
* Ability to experiment with markets that we are not 100% sure about

---

## High Level Scope

* **Centralized Release Flow**
  Users initiate, monitor, and complete game releases directly from Contentful.
* **External System Integrations**
  Monday.com (roadmap data), Jira (release tickets), Bynder (asset management), CABO Platform (game config), Wallet Platform (wallet patch), UKGC (legal approval).
* **Automated Steps**

  * Validate release readiness (roadmap status, Bynder asset availability).
  * Game code generation for Whitehat (NA) and CABO (EU)
  * Create game entries in staging and production (gameV2, siteGameV2, CashierGameConfig).
  * Patch wallet configuration.
  * Submit for QA and legal approvals.
  * Final production push and “go-live” steps.
* **Migration of Monday.com (roadmap data) to Jira**
* **In-App Logging and Auditing**

  * Each step of the workflow is logged for debugging and compliance.
  * Provide UI logs in real time (e.g., success, errors, or partial failures).
* **Role-Based Approvals**
  QA, legal, or director can sign off in a simplified UI that triggers final publish.

---

## Initiative Primary Domain

iGaming

---

## Interactive Theme

**1.3 - Third Party Content & Integrations**

---

## Interactive Objective

**#1 Best-in-Class iGaming**

---

## Lead Department

Technology

---

## Description
Automating end-to-end game releases from Contentful CMS (integrating Jira (ex-Monday), Bynder, CABO, Wallet, and UKGC) to accelerate go-production with role-based approvals, compliance validation, and real-time auditability.
