---
title: "Game Ops Process Review — Excel Workbook Documentation"
tags: [projects, game-release-automation, current]
aliases: []
---
````markdown
# Game Ops Process Review — Excel Workbook Documentation

This document captures the **full logic, structure, and intent** of the `Game ops process review.xlsx` workbook.

It is written for **technical architects** who need to understand the current **manual game-release process** end-to-end so they can design automated, scalable flows (Contentful apps, Lambdas, Jira integrations, etc.) that replace these steps.

---

## 1. Workbook Overview

- **File name:** `Game ops process review.xlsx`
- **Sheets:** 1 (`Sheet1`)
- **Rows:** ~70
- **Columns:** 26 (0–25), of which the model uses 0–10 consistently and 11+ for extra metrics/notes.

The sheet is essentially a **process inventory and time study** for Game Ops:

- Each **row group** describes a **task** in the game lifecycle.
- The **first row in a group** holds the main task.
- Any **subsequent rows with an empty Task cell** are **sub-steps or notes** for that task.
- Several rows also capture **volumes, regions, and time-per-week** numbers to quantify the workload.

---

## 2. Column Model

Row 0 defines the conceptual headers for the main columns:

| Column | Header text in sheet                                  | Interpreted meaning                                                            |
| ------ | ----------------------------------------------------- | ------------------------------------------------------------------------------ |
| 0      | `Task`                                                | Name of the task or activity                                                   |
| 1      | `MH`                                                  | Context / extra notes (often narrative description)                            |
| 2      | `What do Game Ops Do`                                 | Concrete actions performed by Game Ops                                         |
| 3      | `Time for Game Ops to Complete`                       | Time for Game Ops to execute the step (per game / per batch)                   |
| 4      | `Does it require work from another team`              | External team(s) involved, or `No`                                             |
| 5      | `ETA for External Team to Complete Task`              | Typical turnaround time for the external team                                  |
| 6      | `Improvements Already Made Since Last Year`           | Changes already implemented vs older process                                   |
| 7      | `Improvements we Easily Make With Our current Set Up` | Low-hanging automation / process improvements                                  |
| 8      | `Dream Scenario`                                      | Ideal end-state if constraints were removed                                    |
| 9      | `Craigs Comments`                                     | Comments, concerns, or ideas from Craig                                        |
| 10     | `Savings`                                             | Indicators like `x`, `time saving`, or similar flags to mark potential benefit |

Columns **11+** do not have a formal header row. They are used for **quantification and time studies**, e.g.:

- **11** – extra qualitative note (e.g. “need workshop to work out how long this can save”).
- **12** – aggregate time estimate (e.g. “10–12 hours per month”, “20mins per game”).
- **13** – numeric volume (e.g. `300` games).
- **14** – time per week (e.g. `5hours per week`).
- **16** – further aggregate (e.g. “maybe up to 25hours per month”).
- **18 / 21** – numeric counts (games, tiles, etc.).
- **19** – region/scope (`eu (uk & es)`, `eu and na`, etc.).
- **23** – time per item in minutes.
- **25** – time impact summarised as “X hours per week”.

For automation design, treat 0–10 as the **canonical process schema**, and 11+ as **attached metrics** that help prioritise which tasks deliver most benefit when automated.

---

## 3. Roles Identified

Across the sheet, column 4 (“Does it require work from another team”) reveals the **actors**:

- **Game Ops** (implicit main actor for column 2)
- **Prod Ops**  
- **Design**
- **Design & Compliance**
- **Copywriters**
- **Game Providers / Game provider (Light & Wonder)**
- **Spanish Compliance (Alberto)**
- **Directors** (Gibraltar / Malta – decision authority)
- **Release Managers**
- **Game Providers / external platforms**
- **Site editors**
- Internal specialist teams like **“Data Toad”** for data issues.

These map cleanly to future **swimlanes** (Contentful, Jira, CABO, Providers, Legal, Director, etc.) in an automated orchestration design.

---

## 4. Process Walkthrough — As-Is Game Ops Flow

Below, each **main task** (Task column) is listed with its key attributes and notable metrics.  
Sub-steps from the same group are included underneath.

### 4.1 Roadmap & Preparation

#### 4.1.1 Games added to Prod Ops roadmap (row 1)

- Game Ops rely on **Prod Ops roadmaps** (currently in Monday) being up to date.
- Actions:
  - Game Ops ask whether the roadmap is ready.
- Time:
  - ~**2 minutes** for Game Ops to check.
- External:
  - **Prod Ops** maintain the roadmap.
  - They’re usually ahead, so Game Ops rarely wait.
- Improvements:
  - Warning: if Monday is removed, current **automations are lost**.
  - Dream scenario: roadmap **stays in Monday** and continues with existing automations.
- Comments:
  - Suggestion to move from **Excel to Jira** in future.
- Savings: flagged with `x` (likely meaning “potential saving”).

#### 4.1.2 Confirming games into Game Ops roadmap (rows 2–3)

- Context:
  - Games require **manual approval** to appear on the Game Ops roadmap.
- Game Ops actions:
  - Confirm the games in Monday.
  - Sub-step: **“Check the automations ran”** to ensure things pulled through correctly.
- time:
  - ~**10 minutes** per batch (“once a day depending”).
- External:
  - No other teams involved at this stage.
- Improvements:
  - Already improved by **moving games from the “Add” section into Grouping**.
  - The board structure is now better grouped.

#### 4.1.3 Game Ops Create Math Sheet (rows 4–6)

- Context:
  - Math sheet is **triggered** when games are added to the Prod Ops board.
- Game Ops actions:
  - Export the Monday board.
  - Sub-steps:
    - Tidy up the exported Excel.
    - Add data into the Math sheet.
- Time:
  - ~**5 minutes** to export; extra time to clean.
- External:
  - Dependent on **Prod Ops** updates throughout the month.
- Improvements / ideas:
  - If game isn’t ready with provider, it’s dropped from the roadmap.
  - Dream scenario: **suppliers ready earlier**.
  - Comment: question whether a separate Math sheet is needed or if this could be pushed directly into **CMS** as a single source of truth.

#### 4.1.4 Release Ticket is created (rows 7–8)

- Context:
  - When Prod Ops add a line on the board, a **REL ticket** is auto-created.
- Game Ops actions:
  - Monday automatically creates the ticket; Game Ops:
    - Add **game code & game ID** to the ticket.
- Time:
  - ~**1 minute per game** (12–15 games per week).
- External:
  - Marked as **No** – this is internal.
- Improvements:
  - Existing: ticket creation automation in Monday.
  - Improved by **merging Patching Ticket and Game Ticket** into one.
- Dream scenario:
  - Marked as **“Already living the dream”** (this part is in decent shape).
- Savings:
  - Flagged as `x`.

---

### 4.2 Game Tile Design & Approval

#### 4.2.1 Game Tiles Added to Design Board (rows 9–10)

- Context:
  - Design tickets are created for **game tiles** (visuals).
- Game Ops actions:
  - Use the ticket to request tiles, with info such as:
    - Game name, venture, rating, etc.
  - Sub-step:
    - Ability to create tiles manually for **late additions** or **new supplier launches**.
- Key concerns:
  - Desire to **automate tile asset retrieval** (via Bynder or provider assets).

#### 4.2.2 Tile Ticket filled out and tile made (rows 11–13)

- Game Ops actions:
  - Add more info to the Jira ticket.
  - Log out tiles if needed for **Gold & Platinum rated games**.
  - Update statuses on Design tickets.
  - Get assets from providers when Design is not doing it (involves copying, renaming, uploading, updating Contentful).
- Time & metrics:
  - **1 minute per game for the designer (Emyrey)**.
  - Quantification:
    - Approx **15** items (Volume Metric 1).
    - **Region:** `eu (uk & es)`.
    - **Volume Metric 2:** `300` (likely tiles).
    - **Time per Unit:** `5` minutes.
    - **Time impact:** **~7 hours per week**.
- External:
  - **Design** team.
- Improvements:
  - Aim to have tiles done **3 weeks before launch**.
  - Improved by getting the designer onboard and downloading assets centrally.
  - Potential improvement: **Designers independently prepare tickets and assets** without Game Ops having to chase.
- Dream:
  - If another team owned tile creation entirely, this process could be removed from Game Ops.

#### 4.2.3 Game tile Approval (rows 14–17)

- Context:
  - Tiles are reviewed by **Compliance** and **Design**.
- Game Ops actions:
  - Ensure all games that are due have tiles.
  - Chase or track approvals.
- Time & metrics:
  - ~**1 minute to chase** per tile.
  - Sign-off frequency: **Compliance review every Friday**.
  - Quantification:
    - Volume Metric 1: `25`.
    - Region: `eu and na`.
    - Volume Metric 2: `500`.
    - Time per Unit: `8.33` minutes.
    - Time impact: **~10 hours per week**.
- Improvements already made:
  - Tile review moved from a separate Excel sheet to **Monday board**.
- Further improvements:
  - Easier tile creation process to reduce dependence on other teams (possible Bynder integration).
  - Extra note: **workshop needed** to fully quantify the savings.
- Dream:
  - Again, if another team fully owned tile creation, Game Ops could drop this step.

#### 4.2.4 Game tile Upload – GitHub (rows 18–20)

- Game Ops actions:
  - Final review and **upload of tiles to GitHub**.
  - Download all created tiles and push them.
- Time & metrics:
  - ~**2 hours per week** (based on 10 games on average).
- External:
  - No external team – internal work.
- Improvements:
  - Use **automation scripts** (e.g. terminal scripts) to rename files.
  - Merge separate repos (JPJ and VGN) into **one repo**.
  - Dream: **Design team or site editors** upload images and update Contentful links directly.
- Comments:
  - Product design workshop suggested to streamline this and **save time for everyone**.

---

### 4.3 Regulatory & Configuration Steps

#### 4.3.1 Request Hasbro Approval (rows 21–22)

- Game Ops actions:
  - Send list of **game names and countries** to Hasbro.
  - Export Monday data for Monopoly venture games.
- Time:
  - ~**15 minutes** to prepare and send.
- External:
  - **Game provider (Light & Wonder)** plus Hasbro brand approvals.
  - ETA: usually **a few weeks**.
- Improvements:
  - Prod Ops could send this to Hasbro **when they build the roadmap**, not later.
- Dream:
  - In pure dream scenario this step would **not exist**, but Hasbro approvals are brand requirement.
- Metric:
  - Note on **“1 game = 5 hours”** of end-to-end impact.

#### 4.3.2 Send off Bet Configs (rows 23–26)

- Game Ops actions:
  - Send requests to each **provider** for bet configs.
  - Chase once providers confirm updates.
- External:
  - Game providers.
- Key point:
  - This is **email/communication heavy**, and a strong candidate for automation via **integrated provider APIs** and templates.

#### 4.3.3 Set up games in Cabo Stage (rows 27–28)

- Game Ops actions:
  - Use **software ID and RTP** from patch and config.
  - Create or configure games in **Cabo Stage**.
- Sub-steps:
  - Ensure software ID and RTP exist in Jira so Game Ops aren’t guessing.
- Improvements:
  - Better **data flow from Jira / Prod Ops** into Cabo, reducing manual re-entry.

#### 4.3.4 Patch Games Staging (rows 29–30)

- Game Ops actions:
  - Use **Cabo ID, software ID, RTP** to create stage patches.
  - Fill patch form in Contentful for staging.
- External:
  - Internal patching model; no outside teams named.
- Improvements:
  - Game Cashier Config is used to patch games to wallet and map to **Jackpot** and **wallet places**.
  - There is a note that this step is better integrated once Contentful and Cabo are tied together more tightly.

#### 4.3.5 Spanish Regulatory Name & Form (rows 31–33)

- Tasks:
  - Request **Spanish Reg name** for forms.
  - Fill **Spanish Reg form** in Contentful for staging.
- External:
  - **Spanish Compliance (Alberto)**.
- Time:
  - Extra compliance flow that adds latency but is essential for Spain.
- Approvals:
  - One-level approvals mentioned for these regulatory forms.

---

### 4.4 Contentful Build, Copy, and Metadata

#### 4.4.1 Game Built in Contentful (rows 34–36)

- Context:
  - Once games have been approved by **regulators** and providers, they are built in Contentful.
- Game Ops actions:
  - Set up **game model and site game (soon V3)**.
  - Build **Site Game v2** entry.
  - Clone site games to other ventures.
- Improvements:
  - Built once and then cloned, but there is still manual decision on **which ventures** to clone to.
- Dream:
  - Many of these fields could be **auto-loaded from Cabo / providers** to minimise manual entry.
- Comments:
  - Marked as **time saving** activity already: centralised modelling in Contentful reduces duplication.

#### 4.4.2 Copywriting & Content Updates (rows 37–40)

- Intro & copy:
  - Requests sent to **copywriters** (via Jira).
  - Game Ops email list of games that need copy, including links.
- Game Ops actions:
  - Add game info into Contentful.
  - Copy-paste HTML from Prod Ops / copywriters into Contentful fields.
- Improvements:
  - Removing the need for separate Excel lists; **Contentful** should be the single source.
  - Idea: Prod Ops could add this directly to Jira; Game Ops only copy/paste into Contentful or eventually automate.

#### 4.4.3 Staging Testing & Compliance Checks (rows 41–43)

- Tasks:
  - **Staging testing by Game Ops**.
  - Follow **TestRail** to ensure compliance.
  - Check RTP and configs vs spec.
- Improvements:
  - Some testing tasks are already integrated; some can be removed once Contentful becomes a better single source.

#### 4.4.4 Metadata Added (row 44)

- Game Ops actions:
  - Add **theme and feature tags** while testing the game.
- Time:
  - ~**10 minutes per game**.
- External:
  - No external team; however:
    - Improvement: Prod Ops providing metadata info upfront so Game Ops **don’t have to research**.
- Dream:
  - Prod Ops handle metadata because they are more knowledgeable.
- Key note:
  - **“Automate to one single entry point for data input that flows to all systems”** — this is critical architectural guidance.

---

### 4.5 Issues, Approvals, and Live Hidden

#### 4.5.1 Reporting issues to providers (row 45)

- Game Ops actions:
  - Email/portal/Skype issues to providers and push for resolution.
- Time:
  - **5–10 minutes** to raise an issue.
  - Aggregate: **10–12 hours per month**.
- External:
  - Game providers; response time **varies by provider** (up to weeks).
- Improvements:
  - Centralised provider channel (single portal/API) instead of scattered email/Skype.
- Dream:
  - Games **always work flawlessly**.
- Comments:
  - Mix of both testing and live issues.

#### 4.5.2 Director approval for live hidden (row 46)

- Game Ops actions:
  - Directors review **Jira dashboard** and provide approval.
  - Jira ticket updated to show director sign-off.
- Time & metrics:
  - **1 minute per game** operationally.
  - Aggregate:
    - `20mins per game` (extra overhead).
    - `300` games.
    - ~`5 hours per week`.
    - Up to **25 hours per month**.
- External:
  - **Directors** (UK & Spain).
  - Usually a **few days** for approval; often require direct requests.
- Improvements:
  - Already improved by centralising approvals in **Jira**.
  - Further improvement: **single director approval** rather than separate approvals for live hidden vs live.
- Dream:
  - No approvals needed; Jira ticket auto-signs off once checklist is complete.

#### 4.5.3 Add Patch and Reg Form to production (row 48)

- Game Ops actions:
  - Promote **patch** and **reg form** from staging to production.
  - Ensure that cashiers have everything needed in their back office.
- Comments:
  - Some parts are more Spain-specific and can’t be fully removed.

#### 4.5.4 Release Managers progress tickets (rows 49–50)

- Context:
  - Release Managers move tickets through **final stages**.
- Game Ops actions:
  - Reliant on Release Managers to progress items for go-live.
- Approvals:
  - **One level of approval** specified.

#### 4.5.5 Game Ops add games to live hidden (rows 51–54)

- Actions:
  - Add games to **live hidden** configuration.
  - Tick correct flags in Contentful.
- Time:
  - ~**1 minute per game**.
- Comments:
  - Considered “not a big job”.
- Other linked step:
  - **Update URL document**, add new URLs to Jira ticket and documentation.
  - If data in the data sheet is wrong:
    - Republish the patch.
    - Raise with **Data Toad** if still incorrect.

#### 4.5.6 Game Ops test live hidden (rows 55–57)

- Actions:
  - Tick production flags in Contentful.
  - Perform **smoke tests**:
    - Spins.
    - Compliance aspects.
    - RTP and configs.
- External:
  - No external team; Game Ops own most live hidden testing.

---

### 4.6 Production Issues, UKGC, Release & Removal

#### 4.6.1 Production issues raised with providers (row 58)

- Actions:
  - Similar to earlier “reporting issues” but specific to live production issues.
  - Channels: email, portals, Skype.
- Dream:
  - Games working reliably without issues.
- Ownership:
  - Game Ops own raising and tracking issues.

#### 4.6.2 Add UKGC ref (rows 59–60)

- Actions:
  - Log into **UKGC website**.
  - Retrieve and add UKGC reference numbers.
  - Add games to the UKGC website as needed.
- Dependency:
  - Games cannot go live until UKGC registration is done.
- Dream:
  - Ideally the register would not require manual input, or it could be automated.

#### 4.6.3 Release Games (rows 61–63)

- Actions:
  - Add games to **new games carousel** and relevant tabs.
  - Ensure games appear correctly based on rating and venture.
  - Update **jackpot pages** or exclusive sections if applicable.
- Time:
  - ~**6 hours a week** total.
- Improvements:
  - Batch removal when migrating.
- Ownership:
  - Game Ops initiate; some actions can “go back to Prod Ops” (e.g., Freddie Watford).

#### 4.6.4 Requesting Removals (rows 64–66)

- Actions:
  - Raise **Jira REL tickets** for removals.
  - Director approval via ticket.
- Improvements:
  - Email approvals no longer needed; approval tracked in Jira ticket.
- Approvals:
  - Again, **one level of approval**.

#### 4.6.5 Removing Games (rows 67–68)

- Game Ops actions:
  - Remove game from each section and **untick production**.
- Tools:
  - When working, a **Contentful removal tool** removes all instances in one go.
- Time & metrics:
  - With a working tool: **5 minutes for all sites**.
  - Aggregate savings: moving to Prod Ops and/or FW could save **6–8 hours per week**.
- Issues:
  - Tool is not always reliable.
- Dream:
  - Reliable removal tool; site editors may remove games themselves.
- Comments:
  - One-off problems; often coordination between Game Ops and other teams.

#### 4.6.6 Confirming Games are Gone (row 69)

- Actions:
  - Manually verify on desktop and mobile that games are fully removed from the site.
- Dream:
  - Site editors remove games, and removal is **fully traceable and automated**.
- Comments:
  - Game Ops currently own the verification.

---

## 5. Quantitative Insights (Where Automation Saves the Most)

From the metric columns (11–25), the workbook gives explicit time/volume signals:

- **Tile creation & approval**  
  - ~**7 hours per week** (tile ticket fill + creation) for EU (UK & ES).  
  - ~**10 hours per week** for tile review/approval across EU and NA.
- **GitHub tile upload**  
  - ~**2 hours per week**.
- **Director approvals**  
  - Up to **25 hours per month**.
- **Reporting issues**  
  - **10–12 hours per month** across providers.
- **Removing games**  
  - Potential saving of **6–8 hours per week** if removal tooling and ownership are improved.
- **Release games (front-end placement)**  
  - ~**6 hours per week** for carousels & tabs.

From an architecture perspective, these numbers point to **high-ROI automation targets**:

1. Tile lifecycle (creation, approval, upload).
2. Director/approval flows centralised in Jira/Contentful with clear state.
3. Metadata entry as a **single source of truth**.
4. Provider communication (issues, bet configs) via **APIs rather than ad-hoc email/Skype**.
5. Game removal tooling (Contentful + OpenSearch + front-end) made reliable and possibly shifted to other teams.

---

## 6. Conceptual Flow Diagrams

### 6.1 High-Level End-to-End Flow

```mermaid
flowchart TD
  A[Prod Ops roadmap ready] --> B[Game Ops confirm roadmap]
  B --> C[Math sheet maintained]
  C --> D[Release ticket created in Jira]
  D --> E[Game tiles design board]
  E --> F[Tile ticket filled and assets prepared]
  F --> G[Tile approval by design and compliance]
  G --> H[Tile upload to GitHub]
  H --> I[Regulatory approvals Hasbro and Spanish compliance]
  I --> J[Bet configs requested and confirmed]
  J --> K[Games set up in Cabo stage]
  K --> L[Patch configuration for staging]
  L --> M[Game entries built in Contentful]
  M --> N[Copy and metadata added]
  N --> O[Staging testing and compliance checks]
  O --> P[Director and release manager approvals]
  P --> Q[Games added to live hidden]
  Q --> R[Live hidden testing and fixes]
  R --> S[UKGC registration]
  S --> T[Games released to production views]
  T --> U[Monitoring, issues to providers, removals, verification]
````

### 6.2 Roles vs Tasks (Conceptual Swimlane)

```mermaid
flowchart TD
  subgraph ProdOps
    PO1[Maintain roadmap in Monday or Jira]
    PO2[Trigger release ticket]
    PO3[Provide math sheet inputs and metadata]
  end

  subgraph GameOps
    GO1[Confirm roadmap items]
    GO2[Maintain math sheet]
    GO3[Enrich Jira tickets game id and codes]
    GO4[Coordinate tile creation and approvals]
    GO5[Configure Cabo and staging patches]
    GO6[Build and clone Contentful game entries]
    GO7[Run staging and live hidden testing]
    GO8[Raise issues and coordinate fixes]
    GO9[Manage releases and removals]
  end

  subgraph Design
    DE1[Design game tiles]
    DE2[Upload or deliver assets]
  end

  subgraph Compliance
    CO1[Review tiles]
    CO2[Handle Spanish regulatory forms]
    CO3[UKGC registration]
  end

  subgraph Providers
    PR1[Provide bet configs]
    PR2[Resolve game issues]
  end

  subgraph Directors
    DI1[Approve live hidden and release]
  end

  PO1 --> GO1
  GO1 --> GO2 --> PO2 --> GO3
  GO3 --> DE1 --> CO1 --> GO4
  GO4 --> GO5 --> GO6 --> GO7
  GO7 --> PR1 --> GO5
  GO7 --> CO2 --> GO6
  GO7 --> DI1 --> GO8 --> GO9
  GO9 --> CO3
  GO9 --> PR2
```

These diagrams align directly with the steps in the Excel sheet and can be used as starting points for a **future automated architecture** (Contentful apps, event functions, Jira integrations, CABO writers, OpenSearch update functions, etc.).

---

## 7. How Architects Can Use This Documentation

* **Model the as-is workflow** in your architecture diagrams using the task groups above.
* **Identify automation hotspots** using the quantitative time metrics.
* Use the column mapping (especially 2, 3, 4, 5, 7, 8) to design:

  * **Action functions** (what Game Ops do → what a Lambda should do).
  * **Approvals and roles** (who triggers what, with which permissions).
  * **External connectors** (Prod Ops, providers, compliance).
* Use the **dream scenario** and **improvements we can easily make** columns as direct input into:

  * Backlog items.
  * MVP scope for the orchestrator.
  * Long-term simplification roadmap (e.g., single metadata entry, reliable removal tool, provider integrations).
