# Game Ops Release Process and Jira Analysis

Based on Columns A, B & C, below is a summary of the Game ops Release Process, whilst also referencing what will be needed for the Jira Migration and what parts we could automate in the overall Game Ops Release Process

Jira process must be fluid enough so we are not blocked from progressing tickets. For example we are not blocked from moving the ticket to live hidden testing because there is a delay on content. The only real blockers for a ticket should be the director approval and getting the game into Prod.

### **1. Add Games to Prod Ops Roadmap**

1.1 Jira must provide a Prod Ops Roadmap board or issue type where Product Operations can add a new game for future release.

1.2 Game Ops must be able to view the Prod Ops roadmap and indicate when a roadmap is ready for Game Ops review (e.g. via issue status or comment).

---

### **2. Confirm Games in Game Ops Roadmap**

2.1 Game Ops must be able to manually approve games on the Game Ops roadmap in Jira.

2.2 Approved games must be reflected on the Game Ops roadmap for each relevant venture (one issue per venture, if needed).

---

### **3. Add and Share Game Maths**

3.1 Product Operations must be able to upload or associate “Math” documents/files with each game in Jira.

3.2 Linked or uploaded Maths must auto-populate or sync to the related Game Ops roadmap issues for the game.

---

### **4. Release Ticket Creation & Details**

4.1 On Game Ops approval of a game, Jira must automatically generate a Release (REL) issue, linked to the game record and pre-filled with relevant fields (game name, date, etc).

4.2 Game Ops must be able to manually enter Game Code and Game ID in the REL ticket.

---

### **5. Design Board/Game Tile Entry Management**

5.1 Jira must auto-create a Design Board entry (Design issue) for each game, 6 weeks before scheduled release, linked to the correct game roadmap item.

5.2 For late additions or new suppliers, Game Ops must be able to create Design Board tickets manually in Jira.

---

### **6. Game Tile Ticket Completion & Asset Process**

6.1 Game Ops must be able to add further requirements or details to the Game Tile Design issue (including flag for “logged out tile image” for Gold/Platinum games, request legal lines, attach or link required assets).

6.2 Game Ops must be able to update the status of the Design ticket.

6.3 Game Ops must be able to request assets if not generated internally, upload from provider, and add Dropbox or Bynder links for designers as required.

---

### **7. Game Tile Approval Workflow**

7.1 Jira must include a status or checklist to track whether all required game tile images are created for each game by due date.

7.2 Game Ops must be able to notify Compliance and, if needed, Providers (Blueprint, Light & Wonder, IGT, Roxor) for review, and record those reviews or requests for change on the Jira ticket.

7.3 Game Ops must be able to record and track any required changes and final approvals on the ticket.

---

### **8. Upload Game Tiles for Distribution (Transitioning)**

8.1 Game Ops must be able to download completed game tiles, rename as needed, and upload to designated shared storage (initially Github, moving to Bynder).

8.2 Jira must support tracking or linking to uploaded files across the relevant repositories/locations.

---

### **9. Request Hasbro Approval (Monopoly Venture Only)**

9.1 Game Ops/Jira must support exporting a list of Monopoly games and emailing it to Light & Wonder for Hasbro review; alternatively, Jira should integrate with email notification.

---

### **10. Send Bet Configs to Provider**

10.1 Math sheets/configs must be accessible from Jira. Game Ops must be able to trigger config requests to the provider (email, portal, or other method from Jira when criteria are met).

10.2 (Enhancement) Jira should support automating this step when certain criteria are met.

---

### **11. Set Up Games in Cabo Stage**

11.1 Jira must allow Game Ops to generate or auto-fill Cabo form fields (software ID, RTP, etc) based on game details in Jira upon readiness.

11.2 Cabo IDs must be tracked and linked with the Game ID doc (unique per game).

---

### **12. Patch Games Staging**

12.1 Game Ops must be able to fill out or trigger the patch form in Contentful using info from Jira, including Games Cashier Config and Cabo ID.

---

### **13. Game Built in Contentful**

13.1 Once patched, Game Ops must be able to (or Contentful automation must) create Game Model V2 and Site Game V2 entries.

13.2 Site games must have a cloning workflow to other ventures, with metadata (theme/tags) added during testing as determined by Jira status or fields.

---

### **14. Request Game Intros from Copywriting**

14.1 Game Ops must be able to request (via Jira ticket) intros/copy for games, including providing a list of games and relevant provider portal links to the Copywriting team.

---

### **15. Add Game Info to Contentful**

15.1 Game Info (provided by Prod Ops) must be entered or delivered via Jira, and then passed into Contentful either manually or via integration/automation.

15.2 Jira must support feed of game info into Contentful for UK and Spain (accounting for region differences).

---

### **16. Staging Testing by Game Ops**

16.1 Game Ops must test each game in staging via Contentful, following a Jira-linked Testrail test plan for compliance, RTP, and configuration checks.

16.2 If changes are needed, Jira must facilitate updating the tickets and documenting the changes.

---

### **17. Add Metadata (Theme/Feature Tags)**

17.1 Game Ops must add theme and feature tags (metadata) during the testing process, input via Jira or pushed to Contentful.

---

### **18. Report Issues to Providers**

18.1 Jira must provide a method to log and track issues reported to providers via email, portal, or Skype, and track status and resolution.

---

### **19. Director Approval (for Live Hidden)**

19.1 The REL ticket must be reviewed and approved by a Director (Gibraltar or Malta) in Jira before release.

19.2 Jira must track Director Approval status.

19.3 Jira must support what happens if approval is not granted (e.g. block release, add comment).

---

### **20. Add Patch to Production**

20.1 Game Ops must update or trigger Patch forms in Contentful for Production environment, ideally via Jira.

20.2 (Future) Approving the REL ticket in Jira should auto-update Contentful production patch.

---

### **21. Add Games to Live Hidden**

21.1 Game Ops must update Site Game to “Production” tick-box in Contentful (or equivalent), for each venture/post-release.

---

### **22. Add URL to Jira Ticket**

22.1 For each game released to production per venture, the public/live URL must be added to the relevant Jira ticket.

---

### **23. Data Sheet Confirmation**

23.1 Game Ops must review Tableau/Vitruvian to confirm game data is correct post-release.

23.2 If data is incorrect, a patch must be republished and, if still defective, the issue escalated in Jira to the Data team.

---

### **24. Live Hidden Game Testing**

24.1 Game Ops must do smoke and compliance testing on the live-hidden game, launching it via direct URL and ticking “Prod” in Contentful.

24.2 Game performance, RTP, and config must be validated before full launch.

---

### **25. Production Issue Reporting**

25.1 Jira must allow Game Ops to log and track any production issues with providers post-release.

---

### **26. UKGC Reference Handling**

26.1 Game Ops must log a UKGC reference for each game in Jira, using provider info and confirming it’s entered on the UKGC site.

26.2 Jira must block public release until UKGC reference is entered for relevant games.

---

### **27. Game Release and Handover**

27.1 Games must be added by Game Ops to the “New Games” carousel/site list for each venture.

27.2 Once released, Game Ops must hand over to Product Ops, who then distribute/publish the game everywhere else as required, tracked in Jira.

Fields in the Game Ops Status Board, that will be required in Jira:

https://ballys.monday.com/boards/970054495/views/15796667

1. **Game Name / Title**
2. **Game Code / Internal Reference**
3. **Game ID**
4. **Venture / Brand / Site**
5. **Provider / Supplier**
6. **Region / Market (e.g. UK, Spain, etc.)**
7. **Release Status**
    - (e.g. Planning, Approved, In Design, In QA, Awaiting Compliance, Ready for Launch, Live, Blocked)
8. **Release Date (Planned / Actual)**
9. **Game Type (Slot, Table, Bingo, etc.)**
10. **Maths/Math Model (file/link/reference)**
11. **RTP %**
12. **Software ID**
13. **Hasbro/Compliance/Regulatory Status**
14. **Design Status / Game Tile Status**
15. **Assets Status (uploaded/to be uploaded/approved)**
16. **Copywriting Status**
17. **Patch/Contentful Status**
18. **Staging URL / Production URL**
19. **UKGC Reference No.**
20. **Game Intro/Description**
21. **Notes / Comments**
22. **Stake Limits**
23. **Patch Status (Staging/Production)**
24. **Assigned To / Owner / Responsible Person**
25. **Last Updated**
26. **Director Approval Status**
27. **Game Live Hidden Status**
28. **Testing Status (QA/Validated/Failed/Passed etc.)**
29. **Metadata (Theme, Features, Tags)**
30. **Issue/Blocker Flag**
31. **Game Launch Carousel Status**
32. **Game Model Version**
33. **Site Game Version**
34. **Cabo ID**
35. **Math Sheet Link**
36. **Provider Portal Link**
37. **Patch Form Link**
38. **Smoke Test Status**
39. **Game Info (HTML/field for manual entry)**
40. **Tableau/Vitruvian Data Validation**

Fields in the Prod Ops Status Board, that will be required in Jira:

https://ballys.monday.com/boards/1142271905/views/186438423

1. Name
2. Subitems
3. Product Type
4. Supplier
5. Aggregator
6. Launch Date
7. Release Type
8. Ventures
9. Branded
10. Software ID
11. Software ID - (Mobile, if applicable)
12. Secondary Code
13. Secondary Code - Mobile (if applicable)
14. Jackpot Blast
15. RTP Requested
16. Default Bet
17. Min Bet
18. Max Bet
19. Bonus Buy
20. Jackpot Cont.
21. Bonus Buy Max

Fields shared across both boards

1. **Name**
2. **Subitems**
3. **Aggregator**
4. **Supplier / Provider**
    - "Supplier" in Prod Ops corresponds to "Provider" in Game Ops.
5. **Software ID**
    - "Software ID" in both.
    - Also, "Software ID - (Mobile, if applicable)" in Prod Ops and "Software ID (Mobile)" in Game Ops.
6. **Jackpot Blast**
7. **Bonus Buy**
8. **Min Bet**
9. **Max Bet**
10. **RTP Requested**
11. **Jackpot Cont. / Jackpot Contribution**
- "Jackpot Cont." (Prod Ops) and "Requested Jackpot Contribution"/"Actual JP Contribution" (Game Ops).
1. **Venture / Ventures**
    - "Venture" in Game Ops, "Ventures" in Prod Ops.
2. **Branded**