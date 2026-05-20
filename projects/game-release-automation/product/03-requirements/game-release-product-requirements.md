---
title: "Game Release Automation - MoSCoW Requirements"
tags: [projects, game-release-automation, product, requirements]
aliases: []
---
# Game Release Automation - MoSCoW Requirements

## Background and strategic fit

### **What?**

- We want automate and centralise the Game Release tasks carried out by the Gaming Ops Team
- We want to create a single, User-Friendly App within Contentful to do this
- This app will handle the end-to-end flow, from validating roadmap entries (on JIRA) and retrieving assets from Bynder, to patching wallet configurations and triggering final approval steps

### **Why?**

- The Gaming Ops Team currently releases games through a series of manual steps across multiple tools
- This process is prone to error and requires constant switching between platforms
- This process takes up a lot of resource, and can cause delays when it comes to releasing new games
- The new automated release process will allow for better visibility, as we will have a single dashboard for game status, logs, and pending approvals

## Assumptions

- Bulk upload - Currently unsure what this will look like. This must be in place before we roll out to more territories
- Migrate all tasks away from Monday
- Math Sheet is no longer being used

## Teams Involved

- Thunderbird
- Gaming Ops
- Legal (Boguslaw)
- Design

## System Integrations

- Contentful
- Jira
- Bynder
- CABO
- Wallet Platform API
- Test Rail
- Tableau

# **Requirements**

## Requirements
  
- Must Have: Migration of Data - Monday to Jira
  - User story:
    As a member of Gaming Ops
    I want the Game Release Roadmap, Game Design Roadmap, Released Games Board and Math Sheet Info to be migrated from Monday to Jira
    So that I don't lose access to this information
  - Acceptance criteria:
    Given that I am a member of Gaming Ops
    When we move from Monday to Jira
    Then I want to migrate the Game Release Roadmap, Game Design Roadmap and Math Sheet Info
  - Notes:
    Game Release Roadmap: A roadmap of upcoming game releases
    Game Design Roadmap: A roadmap showing where design are at with the assets for game tiles
    Released Games Board: A board which shows which games have been released and the date they were released
  
    Ideally, if we complete the Jira work first, Gaming Ops can begin to populate upcoming/new releases in Jira, rather than Monday, so less needs to be migrated
  
- Must Have: Centralised Interface within Contentful
  - User story:
    As a member of Gaming Ops
    I want an interface within Contentful that can be used to initiate, monitor and complete game releases
    So that I can manage the entire release process from one place
  - Acceptance criteria:
    Given that I am a member of Gaming Ops
    When I am managing the release of games
    Then I should have a centralised interface within Contentful that allows me to initiate, monitor and complete game releases
  
    Need designs for this interface
  - Notes:
    **Release Process:**
    1. Initiate Release: GameOps triggers a release event in Contentful.
    2. Validation: The system checks roadmap and release ticket status in Jira.
    3. Asset Preparation: Notifies Bynder.
    4. Staging Setup in CABO.
    5. QA + Legal approvals.
    6. Data Checks.
    7. Live Hidden Testing.
    8. Test Rail.
    9. Production Launch.
    10. All logs + metrics stored.
  
- Must Have: Release Process - Step 1 - Initiate Release
  - User story:
    As a member of Gaming Ops
    I want to trigger a release within Contentful
    So that the release process can begin
  - Acceptance criteria:
    Given that I am a member of Gaming Ops
    When I initiate a release in Contentful
    Then the release flow should be started
    And the system should log this event
  
    Only Gaming Ops should be able to trigger a release
  
    I need to be able to choose which territory/venture the release is for at this stage.
  
- Must Have: Release Process - Step 2 - Validation
  - User story:
    As a Game Release system
    I want to check the Gaming Ops roadmap and release tickets statuses in Jira
    So that only ready games can proceed
  - Acceptance criteria:
    Given that a release has been initiated
    When the validation step has been reached
    Then the Gaming Ops roadmap and release ticket statuses in Jira should be checked
    And release proceeds only if tickets exist + fields are filled
  - Notes:
    Jira ticket must have all required info
  
- Must Have: Release Process - Step 3 (Part 1) - Asset Preparation
  - User story:
    As a Game Release system
    I want to notify Bynder to prepare or confirm asset availability
    So that assets are ready for release
  - Acceptance criteria:
    Given validation is successful
    When asset preparation begins
    Then Bynder should be notified
    Assets may be added anytime after validation
  
- Must Have: Release Process - Step 3 (Part 2) - Asset Approval
  - User story:
    As an asset approver
    I want to approve game tiles
    So that I can confirm they are compliant
  - Acceptance criteria:
    Given assets are ready
    When approved
    Then they proceed
    Only approved assets move on
    Approvals logged
    Bulk approval supported
  
- Must Have: Release Process - Step 3 (Part 3) - Asset Approval (Providers)
  - User story:
    Given I am a provider (L&W, Hasbro, BP)
    I want to approve assets
    So I can confirm they are acceptable
  - Acceptance criteria:
    Provider approvals required for branded games.
    Bulk approvals supported.
  - Notes:
    Providers list here: Branded Content Approval Contacts
    Monopoly requires Hasbro + Boguslaw
  
- Must Have: Step 4 (Part 1) - Staging Setup - Game Config
  - User story:
    As a Game Release system
    I want staging config created in CABO
    So game can be tested
  - Notes:
    Requires RTP + software ID
  
- Must Have: Step 4 (Part 2) - Patch Wallet
  - User story:
    As a Game Release system
    I want to patch staging wallet
    So game can be tested
  - Notes:
    Requires RTP + software ID
  
- Must Have: Step 5 - QA Approval - New Integrations
  - User story:
    As QA
    I want to review new integrations
    So integration is validated
  
- Must Have: Step 5 - Director Approval - UK
  - User story:
    As Director
    I want to approve releases
    So only compliant + tested games go live
  - Notes:
    Requires Legal + Director
  
- Must Have: Step 5 - Spain Approval
  - User story:
    As Director/Compliance
    I want to approve Spanish releases
  - Notes:
    Requires Legal + Director + Compliance
  
- Must Have: Step 6 - Data Checks
  - User story:
    As Gaming Ops
    I want to ensure games have been data checked
  - Notes:
    Tableau integration = Should Have
  
- Must Have: Step 7 - Live Hidden
  - User story:
    As release system
    I want games in Live Hidden for testing
  - Notes:
    Wallet patch occurs
  
- Must Have: Step 8 - Test Rail
  - User story:
    As Gaming Ops
    I want to ensure games are tested
    Before going live
  - Notes:
    Test Rail integration = Should Have
  
- Must Have: Step 9 - Production Launch
  - User story:
    As Gaming Ops
    I want to put games into production
  - Notes:
    Ready for Release used to trigger publish
  
- Must Have: Bulk Upload Games
  - User story:
    As Gaming/Product Ops
    I want to bulk upload games
    So games not on roadmap can be released
  - Notes:
    Excel upload ideal
  
- Must Have: Jira Integration
  - User story:
    As the release system
    I want Jira integrated for roadmap + tickets
  
- Must Have: Wallet API Integration
  - User story:
    As release system
    I want to patch wallet config
  
- Must Have: Bynder Integration
  - User story:
    As release system
    I want asset management
  
- Must Have: CABO Integration
  - User story:
    As release system
    I want staging + production configs
  
- Should Have: Test Rail Integration
  - User story:
    As release system
    I want to see test status
  
- Should Have: Tableau Integration
  - User story:
    As Gaming Ops
    I want to see Tableau data in UI
  
- Must Have: Auto Jira Ticket Creation
  - User story:
    As Gaming Ops
    I want auto-generated tickets
  
- Must Have: Auto Jira Validation
  - User story:
    As Gaming Ops
    Automate validation
  
- Must Have: Auto Asset Management
  - User story:
    As Gaming Ops
    Automate Bynder asset flow
  - Notes:
    Notify design if assets missing
  
- Must Have: Auto Game Configs
  - User story:
    As Gaming Ops
    Automate Game Configs
  
- Must Have: Auto Wallet Patch
  - User story:
    As Gaming Ops
    Automate wallet patching
  
- Must Have: Auto Approvals Notifications
  - User story:
    As QA/Legal/Director
    Notify when approval needed
  - Notes:
    Automated email to providers preferred
  
- Must Have: Auto Publish to Live Hidden
  - User story:
    As Gaming Ops
    Auto-update Jira + Live Hidden
  
- Must Have: Auto Publish Live to Players
  - User story:
    As Gaming Ops
    Auto-update Jira + roadmap
  
- Should Have: Auto Test Rail Plan
  - User story:
    As Gaming Ops
    Auto-generate Test Rail plans
  
- Should Have: Auto Test Rail Confirmation
  - User story:
    As Gaming Ops
    Block release if not tested
  
- Should Have: Auto Tableau Checks
  - User story:
    As Gaming Ops
    Auto-verify data checks
  
- Should Have: Auto Release Updates
  - User story:
    As stakeholder
    Notify released games
  - Notes:
    Teams notification
  
- Must Have: In-App Logging (Critical Steps)
  - User story:
    As auditor
    I want all critical steps logged
  - Notes:
    Retention period TBD
  
- Must Have: Timestamp Logging
  - User story:
    As auditor
    I want timestamps + filters
  
- Must Have: Role-Based Approvals
  - User story:
    As stakeholder
    I want approvals in UI
  - Notes:
    May require off-Contentful approvals
  
- Must Have: Remove Games - Trigger
  - User story:
    As Gaming Ops
    I want to remove games
  - Notes:
    Director notified
  
- Must Have: Remove Games - Approval
  - User story:
    As Director
    I want to approve removal
  - Notes:
    Logged
  
- Must Have: Remove Games - Auditing
  - User story:
    As Gaming Ops
    I want to see removed games
  
- Should Have: Prevent Restricted Games
  - User story:
    As Gaming Ops
    Block restricted games
  - Notes:
    Only restricted blocked
  
- Should Have: Error Alerts
  - User story:
    As Dev/Ops
    I want error alerts
  - Notes:
    Email + Teams
  
- Should Have: Basic Reporting
  - User story:
    As Gaming Ops
    I want reporting
  - Notes:
    Email summary
  
- Could Have: Advanced Reporting
  - User story:
    As Gaming Ops
    I want dashboard
  
- Could Have: Upstream Event Triggers
  - User story:
    As Gaming Ops
    I want auto triggers
  
- Must Have: Scalability
  - User story:
    As Gaming Ops
    Support multiple parallel releases
  
- Must Have: Reliability
  - User story:
    As stakeholder
    Retries + graceful fail
  
- Must Have: Security
  - User story:
    As stakeholder
    Secure APIs + RBAC
  
- Should Have: Maintainability
  - User story:
    As developer
    Modular, decoupled code
  
---

## Questions

Below is a list of questions to be addressed as a result of this requirements document:

| What data needs to be migrated from Monday to Jira? Is it just the roadmap? | Game release roadmap, game design roadmap, Math sheet info - depending on when Jira work is done, ideally this gets done first | Yes |
| --- | --- | --- |
| What is happening to the Math Sheet? Is this being replaced somewhere and does it need referencing in the requirements? | N/A | N/A |
| At what point will the Roadmap in Jira get updated? | N/A - automation will not kick off without a complete roadmap | N/A |
| How will the release ticket be created? | Release ticket should be automatically generated in Jira | Yes |
| How will the bulk upload work? Where are bulk we uploading to? Assume it will be Contentful? | Ask Oktay - Excel sheet with games and info - upload to contentful - just ignores roadmap step | Yes |
| Do we need to integrate with WH? | One for KK - No | Yes |
| Should assets from Contentful automatically be assigned to the game? | Yes ideally | Yes |
| Will any of the integrations require work from external parties? | L&W, Hasbro and BP need provider sign off (2 assets sign-off) - potentially automate an email to providers? | Yes |
| Do all 3 of QA, Legal and Director need to have approved before a release can occur? | Spain and UK - Director and Legal, Spain - Director and Compliance, QA - New integrations | Yes |
| Will all approvals be done in Contentful? | Ideally yes | Yes |
| Does Live Hidden come after approval? | Comes after Director and Compliance approval (Spain), UK just director | Yes |
| Do we need to integrate with UKGC for approvals? It is mentioned in some places but is left out of others | One for Oktay | Yes |
| Who do we want error alerts to be sent to? | Game Ops in all instances, Team who is responsible for the fix | Yes |
| Do we have/need designs for the UI in Contentful? | Needs to be looked at - simple as possible | N/A |
| Is the process of removing games to stay as is? | Needs automated director approval - rest stays as is |  |
| For Basic Reporting, how often should this automated report be distributed? Weekly or Monthly? | Day of release - manual trigger | Yes |
| For Basic Reporting, how do we want this distributed? Or is it just to be found within Contentful? | trigger in contentful, goes out via email | Yes |
| How long do we want logs to be stored for? | One for Kris Apap | Not Yet |
| Who should have access to the app? Will we need functionality to add and remove members? | Anyone can access, but different roles will be assigned and only people with the relevant roles can do their parts | Yes |

## Not Doing

- We will not be using Monday for the Game Ops workflow as the tool is being retired.
- We will not be fully automating End-End releases without any Manual Approval as this would not be compliant.

---
verified:
  last_updated: 2025-12-25
  verified_by: "System Validator Script"
  commit_sha: "41ce5457a7a1202a0f32227929443c032f0d07d9"
  verified_moscow_counts:
    must: 38
    should: 10
    could: 2
    wont: 0
    total: 50
