# Search Improvements Product Requirements

---

## Background and strategic fit

This work will apply to Native (iOS and Android) and Web (Desktop and Mobile). It is for EU and NA and for all Ventures.

### WHAT?

- Index and allow players to search across the metadata stored for each game using elasticsearch.
- Enhance the search feature to show Lower  RTP games in the top results.
- Update the search UI using the latest design and UX guidelines.
- Improve the speed which results are returned, retain search history, commercially weight results, add fuzzy logic and stop ‘dead’ ends to always 
show results.
- Add filters using the metadata that allows players to narrow down their search results
- Add collections to provide players with pre-generated groups of content.
- Order results by commercial weighting (from ML personalisation).

### WHY?

- Since 90% of clicks occur on the top three results, promoting Lower RTP games can increase revenue by encouraging more profitable and growth
- We believe there is a lot of opportunity to improve our search product.  We want to leverage this as a tool which encourages players to explore 
our content library or allow them to more quickly find the game they want to play if they don’t know the exact name.
- We will target a reduction the number of searches without game launch and grow the number of game launches from search as players use it 
more.  We aim to ultimately grow the game launches per session and cash actives by reducing sessions without game launch.

### Assumptions

- Product/Gaming Ops will add in the Quick Filters/Filters

## Requirements

- Must Have: Allow players to search using elasticsearch
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am searching for a game
  
  Then I should be able to search 
  across the metadata stored for 
  each game, using elasticsearch
  
  Elasticsearch Logic:
  
  If a customer types 'Blackjack' or 
  '21' it should quickly find all 
  Blackjack games on the website.
  
  
- Must Have: Ability to search for results in the search bar
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I want to search for a game
  
  Then I should be able to type in 
  the search bar
  
  And see games that are relevant 
  to what I have searched for as I 
  am typing (starting from 2 letters)
  
  **Figma**  
  Figma -  
  Typed  
  Search  
  Native
  
  **UI/UX – description**
  
  #### iOS — 375px × 812px
  
  1. **Search tab (idle):** The user is on the Search tab. The screen shows the search bar with placeholder text “Search for Games, Providers or Themes,” quick filters (e.g., Game Filter, Slots, Jackpots, Live Casino, Table), and carousels such as “Game Collections.” The user taps into the search box.
  2. **Keyboard + suggestions:** The keyboard opens and a new view appears listing **Recent Searches** and **Popular Searches** (stacked list items). The search field is focused with a **Cancel** action on the right.
  3. **Typing begins (no results until 2 chars):** The user starts entering a query. The interface indicates that search **does not begin** until at least **two letters** have been typed.
  4. **Results upon second character:** As soon as the second character is entered, a **results grid** of game tiles appears. A note indicates the user can **sort** the search results.
  5. **Final results:** After the user finishes typing, all **relevant search results** are shown.
  
  #### Android — 360px × 780px
  
  1. **Search tab (idle):** The user is on the Search tab with the same search bar, quick filters, and content rows (e.g., Game Collections, Popular Games). The user taps into the search box.
  2. **Keyboard + suggestions:** The keyboard opens; a list of **Recent Searches** and **Popular Searches** is displayed beneath the focused search field.
  3. **Typing begins (no results until 2 chars):** The user begins entering text; the design specifies that results **do not appear** until **two characters** are entered.
  4. **Results upon second character:** After the second character is typed, a **grid of game results** is displayed. A note indicates the user can **sort** these results.
  5. **Final results:** When typing is complete, the screen shows all **relevant search results** for the query.
  
  
  
- Must Have: Implement 'fuzzy logic' to ensure results are always displayed
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am searching for a game
  
  And my search does not match 
  anything
  
  Then I should see results based 
  on proximity to the original search
  
  But if there are no matches, the 
  player should be informed
  
  Example:  
  Toleration of misspellings and 
  typos (e.g. 'blupraint' returns 
  'Blueprint' and 'jakpot' returns 
  'Jackpot') 
  
  **Figma**  
  Figma -  
  Fuzzy  
  Logic  
  Native
  
  **UI/UX – description**
  
  #### iOS — 375px × 812px
  
  1. **Search tab (idle):** User is on the Search tab and taps into the search box.
  2. **Keyboard + suggestions:** The keyboard opens and a new view appears showing **Recent Searches** and **Popular Searches** beneath the focused search field (with **Cancel** on the right).
  3. **Typing begins (no results until 2 chars):** The user starts entering a query; search does **not** begin until at least **two letters** are typed.
  4. **Results on second character:** After the second character is entered, a **results grid** of game tiles is displayed; the user can **sort** results.
  5. **Fuzzy tolerance (up to 4 incorrect characters):** The flow indicates **fuzzy search works for up to four incorrect characters**; users still receive relevant search results within that tolerance.
  6. **Empty state beyond tolerance:** If the user enters **five or more incorrect characters** and no matches are found, an **empty state** appears with “No Search Results.”
  
  #### Android — 360px × 780px
  
  1. **Search tab (idle):** User is on the Search tab and taps into the search box.
  2. **Keyboard + suggestions:** The keyboard opens and a new view appears showing **Recent Searches** and **Popular Searches**.
  3. **Typing begins (no results until 2 chars):** The user begins to type; search **does not** run until **two characters** are entered.
  4. **Results on second character:** After the second character is typed, a **grid of game results** appears; the user can **sort** results.
  5. **Fuzzy tolerance (up to 4 incorrect characters):** **Fuzzy matching** supports **up to four incorrect characters**, still returning results.
  6. **Empty state beyond tolerance:** With **five incorrect characters** and no match, the screen shows an **empty state** labeled **No Search Results**.
  
  
- Must Have: Implement Semantic Search
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am searching for a game
  
  Then semantic search should be 
  available
  
  And I will be able to find games 
  based on my intent, rather than 
  exact keyword rules
  
  **Notes**  
  Semantic search is a technique that goes beyond simple keyword matching to 
  understand the meaning and context of a user's search query, aiming to deliver 
  more relevant results. It uses natural language processing (NLP), machine learning 
  (ML), and other AI techniques to analyse the user's intent and provide results that 
  align with that intent, even if the exact keywords are not present in the results
  
  
- Must Have: Semantic Search uses the games metadata
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am searching for a game
  
  Then semantic search should 
  effectively use the games 
  metadata
  
  Ensure all games are tagged with 
  relevant themes and features for 
  enhanced search accuracy.
  
  Examples:  
  If a customer types 'Big Wins' 
  then semantic search should 
  understand you're looking for 
  games where you can win lots of 
  money, and will show popular 
  jackpot or high-paying games to 
  the player.
  
  “I would like to play games like X” 
  Therefore use recommendations 
  for target game X
  
  “I would like to play Blueprint 
  Jackpot Games” Therefore filter 
  to show only BP Jackpot Games
  
  “I want to play quick games with a 
  chance of a big win” therefore 
  filter to instants with high max 
  multipliers (order by max 
  multiplier)
  
  **Notes**  
  An aggregator will display list for games from all supported studio. E.g. Player 
  selecting Games global filter will display all games through this aggregation. 
  Similarly, with Relax, Light and wonder.
  
  Some of the providers/studio might not be live in certain states.
  
  The system should dynamically display game providers list if they are set to status 
  as Live in Contentful in respective jurisdiction.
  
  
- Must Have: Search Bar should advise customers what they can search for
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am looking at the search 
  bar
  
  Then there should be text in the 
  search bar which says 'Search for 
  Games, Providers or Themes'
  
  And this text should be replaced 
  with my search items when I start 
  to type/have typed
  
  **Figma**  
  Figma -  
  Typed  
  Search  
  Native
  
  **UI/UX – description**  
  - The search page header shows a large title “SEARCH”.  
  - Below, a search field placeholder reads: **“Search for Games, Providers or Themes”** with a magnifying-glass icon on the left.  
  - The field sits within a red-themed native layout with a visible **Deposit** widget at the top-right.  
  
  #### iOS — 375px × 812px
  
  1. **Search tab (idle):** The user is on the Search tab. At the top, the search field displays the **placeholder copy**: **“Search for Games, Providers or Themes.”** Quick-filter chips (e.g., *Game Filter*, *Slots*, *Jackpots*, *Live Casino*, *Table*) and carousels (e.g., **Game Collections**) are visible beneath. The user taps the search field.
  2. **Keyboard + suggestions:** The on-screen keyboard opens. A suggestions panel appears under the focused field (with a **Cancel** action on the right), listing **Recent Searches** and **Popular Searches** entries. The placeholder copy is replaced by the text cursor.
  3. **Typing begins (no results until 2 chars):** The user starts typing. The UI notes that **search does not begin** until the **first two letters** have been entered.
  4. **Results on second character:** When the second character is typed, the screen updates to a **grid of game tiles** showing search results; the user can **sort** the results.
  5. **Final results:** After typing is finished, all **relevant search results** remain displayed.
  
  #### Android — 360px × 780px
  
  1. **Search tab (idle):** The Search screen shows the search field with the **placeholder** text **“Search for Games, Providers or Themes.”** Quick-filter chips and content rows (e.g., **Game Collections**, **Popular Games**) are below. The user taps the field.
  2. **Keyboard + suggestions:** The keyboard opens, and a panel of **Recent Searches** and **Popular Searches** appears under the focused field (with a **Cancel** action on the right). The placeholder copy is replaced by the caret.
  3. **Typing begins (no results until 2 chars):** As the user types, no results are shown until **two characters** have been entered.
  4. **Results on second character:** After the second character, a **results grid** of games is displayed; the user can **sort** these results.
  5. **Final results:** When typing is complete, the screen shows all **relevant search results** for the query.
  
  
- Must Have: Quick Filters to be displayed on the search page
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am on the search page
  
  Then I should have access to 
  Quick Filters
  
  And I should be able to add
  /remove these filters from the 
  Quick Filters bar
  
  **Figma**  
  Figma -  
  Quick  
  Links  
  Native
  
  **UI/UX – description**  
  - The search page shows a horizontal **Quick Filters** chip bar (e.g., *Game Filter*, *Slots*, *Jackpots*, *Live Casino*, *Table*).  
  - Below the quick filters, a **Game Collections** carousel appears with image tiles.  
  - A second image shows the same quick-filter chips with **placeholder result tiles** below.  
  
  #### *SEARCH · QUICK FILTERS — User searches for a slot game through quick filters* (iOS · 375×812)
  
  1. **Search tab with Quick Filters visible**
  
     * Screen shows the Search header, a search field, and a horizontal **Quick Filters** chip bar (e.g., *Game Filter*, *Slots*, *Jackpots*, *Live Casino*, *Table*).
     * Content rows such as **Game Collections** and a standard header are visible below.
     * User taps **Slots** in the Quick Filters.
  
  2. **Chip state: “Free Spins” added**
  
     * Under the search field, **filter chips** are shown (e.g., *Filter*, *Free Spins*, *Inspired*, *3–3 Reels* appear progressively in this flow).
     * A **results grid** of placeholder tiles is displayed; results are scoped to **Slots** + **Free Spins**.
  
  3. **User taps provider “Inspired”**
  
     * The **Inspired** chip is added to the active chip row.
     * Results grid updates again to reflect **Slots** + **Free Spins** + **Inspired**.
  
  4. **User taps reels “3–3 Reels”**
  
     * The **3–3 Reels** chip is added.
     * Results update to **Slots** + **Free Spins** + **Inspired** + **3–3 Reels**.
  
  5. **User clears filters**
  
     * A **Clear** interaction (e.g., “X” on individual chips or a “Clear All” control) is used.
     * The chips are removed, and the grid reverts to the broader results set.
  
  6. **Return to default search view**
  
     * The page returns to the unfiltered Search view (search field + quick-filter chips + content rows).
     * Examples from other products are shown for reference:
  
       * **Amazon-style chips** with a **counter** indicating the number of active filters and a **clear** option.
       * **Spotify-style** where an “X” appears to **clear all** when filters are applied.
  
  
  #### *SEARCH · FILTER MENU — User searches for a bingo game through filter menu* (iOS · 375×812)
  
  > UI should show how the **Game Filter** modal works alongside the quick-filter bar.
  
  1. **Search tab; user taps “Game Filter”**
  
     * The quick-filter bar is visible; the user selects **Game Filter** to open the full-screen modal.
  
  2. **Game Filter menu (main categories)**
  
     * A modal labeled **GAME FILTER** shows category cards: *Slots*, *Jackpots*, *Live Casino*, *Table*, *Slingo*, *Bingo*, *Instant*, *Arcade*.
     * A **SHOW X GAMES** button is pinned at the bottom.
     * User taps **Bingo**.
  
  3. **Bingo games list**
  
     * Because **Bingo** has **no child filters**, the app immediately shows a **results grid** scoped to Bingo games.
     * Active chips (e.g., **Filter**) remain visible under the search field.
  
  4. **Reopening Game Filter (with Bingo active)**
  
     * The **GAME FILTER** modal reopens.
     * The **Active Filters** row shows **Bingo** with an **“X”** (remove).
     * Additional controls (e.g., **Stake Range** slider and **Game Provider** checkboxes) are shown for Bingo context, along with **SHOW X GAMES**.
  
  5. **Back to main categories**
  
     * User returns to the top-level **GAME FILTER** menu of eight categories.
     * **SHOW X GAMES** remains at the bottom.
  
  
  #### *SEARCH · FILTER MENU — All categories* (iOS · 375×812)
  
  > UI should illustrate the **filter facets** that appear when different categories are active in the Game Filter modal.
  
  * **Slots**
  
    * **Stake Range** slider at the top.
    * **Game Provider** list with checkboxes (e.g., *Evolution*, *Scientific Games*, *Light & Wonder*, *PlayTech*, *Pragmatic Play*, *Red Tiger*, *Blueprint Gaming*).
    * **Type of Game** chip group (e.g., *Slingo*, *Instants*, *Jackpot*, *Megaways*, *Table Games*, *Seasonal*, *Fishing*).
    * **SHOW X GAMES** button at the bottom.
  
  * **Jackpot**
  
    * Same **Stake Range** and **Game Provider** sections with checkboxes.
    * **Type of Game** chips relevant to jackpot contexts.
    * **SHOW X GAMES** button.
  
  * **Live Casino**
  
    * **Stake Range** and **Game Provider** checklists tailored to live providers.
    * **SHOW X GAMES** button.
  
  * **Table**
  
    * **Stake Range** and **Game Provider** checklists suited for table games.
    * **SHOW X GAMES** button.
  
  
  #### Summary
  
  * **Quick Filters are always visible** on the Search page as a **horizontal chip bar** supporting fast, incremental filtering.
  * **Tapping chips** (e.g., *Slots*, *Free Spins*, *Inspired*, *3–3 Reels*) **adds active filter chips** beneath the search field and **immediately updates the grid**.
  * **Chips are removable** individually (via **“X”**) and can be **cleared all at once**; patterns mirror familiar products (Amazon’s count/clear and Spotify’s clear-all).
  * The **Game Filter** modal complements Quick Filters by exposing **full facet menus** (categories, providers, reel/lines, themes, stake range, etc.) with a **“SHOW X GAMES”** confirmation at the bottom.
  
  
  
- Must Have: Quick Filters can be added in Contentful
  **Acceptance Criteria**
  
  Given that I am a Bally's 
  Employee using the CMS
  
  When I am configuring the Quick 
  Filters
  
  Then I should be able to add and 
  remove Quick Filters
  
  And the customer should see the 
  filters I have configured
  
  Filters to be added by Product
  /Gaming Ops
  
  
- Must Have: Quick Filters are configurable in Contentful
  **Acceptance Criteria**
  
  Given that I am a Bally's 
  Employee using the CMS
  
  When I am configuring the Quick 
  Filters
  
  Then I should be able to change 
  the order the Quick Filters are 
  presented to customer
  
  And the flow they are presented 
  to the customer
  
  
- Must Have: Quick Filters should follow a flow
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am using Quick Filters
  
  Then the filters should follow a 
  flow e.g. for slots, the flow would 
  be Game Type (slot) > Feature > 
  Provider > Reel
  
  See the Figma board and excel (S
  ) for more detailearch Filters
  
  **Notes**
  
  **Figma**  
  Figma -  
  Quick  
  Links  
  Native
  
  **UI/UX – description**
  
  
  #### Image set 1 — *SEARCH · QUICK FILTERS — User searches for a slot game through quick filters* (iOS · 375×812)
  
  **Flow intent illustrated:** **Game Type → Feature → Provider → Reel** (then clear).
  
  1. **Search tab with Quick Filters**
  
     * The Search header and search field are shown.
     * A horizontal **Quick Filters** chip bar is visible (e.g., *Game Filter*, *Slots*, *Jackpots*, *Live Casino*, *Table*).
     * User starts by tapping **Slots** (the **Game Type**).
  
  2. **Add Feature**
  
     * A chip **Free Spins** is tapped/added, appearing in the active chip row below the search field.
     * The result grid updates to **Slots + Free Spins**.
  
  3. **Add Provider**
  
     * User taps **Inspired**; the **Inspired** chip is added.
     * Results refine to **Slots + Free Spins + Inspired**.
  
  4. **Add Reel format**
  
     * User taps **3–3 Reels**; the **3–3 Reels** chip is added.
     * Results refine again to **Slots + Free Spins + Inspired + 3–3 Reels**.
  
  5. **Clear filters**
  
     * The screen shows an interaction to **clear** applied filters (e.g., “X” on chips or a global **Clear All**).
     * Clearing returns the grid to a broader state.
  
  6. **Return to default Search view**
  
     * Back to unfiltered Search with the quick-filter bar and content rows.
  
  7. **Reference patterns (comparative examples)**
  
     * **Amazon** example: chips with a **counter** indicating the number of active filters and an explicit **Clear** option.
     * **Spotify** example: a **clear-all “X”** appears when any filters are active.
  
  
  #### Image set 2 — *SEARCH · FILTER MENU — User searches for a slot game through filter menu* (iOS · 375×812)
  
  > Supports the same **flow order** but via the full **Game Filter** modal rather than inline chips.
  
  1. **Open Game Filter**
  
     * On the Search screen, user taps **Game Filter** in the quick-filter bar.
  
  2. **Game Filter (main categories)**
  
     * Full-screen **GAME FILTER** modal shows category cards: *Slots*, *Jackpots*, *Live Casino*, *Table*, *Slingo*, *Bingo*, *Instant*, *Arcade*.
     * User taps **Slots** (the **Game Type**).
  
  3. **Select Feature**
  
     * Inside **GAME FILTER**, the **Features** list is shown (e.g., *Free Spins*). User selects **Free Spins**.
  
  4. **Select Provider**
  
     * User scrolls/selects a **Game Provider** (e.g., **Inspired**) via checkbox.
  
  5. **Confirm → results**
  
     * User taps **SHOW X GAMES**.
     * The Search screen returns showing the **quick-filter chips** (**Slots**, **Free Spins**, **Inspired**) above a results grid.
  
  6. **Alternative visual styles**
  
     * Additional mockups present alternate **facet layouts** (e.g., larger pill cards) and a **Google Filters** reference showing chips with **count badges**, **reset/clear**, and **apply** patterns.
  
  
  #### Image set 3 — *SEARCH · FILTER MENU — User searches for a bingo game through filter menu* (iOS · 375×812)
  
  > Demonstrates **special-case flow** when a category has **no child filters** (Bingo).
  
  1. **Open Game Filter**
  
     * User taps **Game Filter** from the Search screen.
  
  2. **Select Bingo (Game Type)**
  
     * In **GAME FILTER**, user taps **Bingo**.
  
  3. **Immediate results (no child filters)**
  
     * Because **Bingo has no child filters**, the app **immediately shows a results grid** of Bingo games (no intermediate Feature/Provider/Reel steps).
  
  4. **Reopen Game Filter while Bingo is active**
  
     * The **Active Filters** row shows **Bingo** with an **“X”** to remove.
     * The panel may show **Stake Range** and **Game Provider** controls to further refine where applicable; **SHOW X GAMES** remains at bottom.
  
  5. **Back to main categories**
  
     * The user can return to the category grid to adjust **Game Type** again.
  
  
  #### Image set 4 — *SEARCH · FILTER MENU — All categories* (iOS · 375×812)
  
  > Shows the **facet consistency** across categories and reinforces the **ordered flow**.
  
  * **Slots** (Game Type)
  
    * **Stake Range** slider → **Game Provider** checklist → **Type of Game** chips (e.g., *Slingo*, *Instants*, *Jackpot*, *Megaways*, *Table Games*, *Seasonal*, *Fishing*).
    * **SHOW X GAMES**.
  
  * **Jackpot** (Game Type)
  
    * **Stake Range** → **Game Provider** checklist → **Type of Game** chips (jackpot-relevant).
    * **SHOW X GAMES**.
  
  * **Live Casino** (Game Type)
  
    * **Stake Range** → **Game Provider** checklist (live providers).
    * **SHOW X GAMES**.
  
  * **Table** (Game Type)
  
    * **Stake Range** → **Game Provider** checklist (table providers).
    * **SHOW X GAMES**.
  
  
  #### Summary
  
  * The **prescribed order** is consistently demonstrated: **Game Type → Feature → Provider → Reel** (with category-specific variants like Stake Range or Type of Game).
  * **Quick Filters** enable fast, inline application of this order via **chips**; the **Game Filter modal** provides the same flow with **full facet menus** and a **SHOW X GAMES** confirmation.
  * Clear, discoverable **removal/clear-all** patterns are showcased (Amazon/Spotify/Google references).
  
  
  
- Must Have: Quick Filters should display relevant games
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I have clicked on a Quick 
  Filter
  
  Then only games relevant to that 
  filter should be displayed
  
  And if I have chosen multiple 
  filters
  
  Then only games relevant to the 
  filters selected should be 
  displayed
  
  **Figma**  
  Figma -  
  Quick  
  Links  
  Native
  
  **UI/UX – description**
  
  
  #### *SEARCH · QUICK FILTERS — User searches for a slot game through quick filters* (iOS · 375×812)
  
  **Goal illustrated:** As the user adds/removes **Quick Filter** chips, the **results grid** immediately updates to show **only games that match the active filters**.
  
  1. **Default Search view.**
  
     * Header “SEARCH”, deposit widget, and a **search field** with placeholder.
     * A **Quick Filters** chip row is visible under the field (e.g., *Game Filter*, *Slots*, *Jackpots*, *Live Casino*, *Table*).
     * Below are content rows like **Game Collections** and a **default grid**.
  
  2. **User taps “Free Spins” (Feature).**
  
     * An **active chip** “Free Spins” appears beneath the search field (in the “applied filters” bar).
     * The **grid switches** to show **only titles with Free Spins**; tiles render as placeholders in the mock.
  
  3. **User taps provider “Inspired.”**
  
     * A second chip “Inspired” is added in the applied-filters bar: `[Free Spins] [Inspired]`.
     * The grid **re-filters** to games that **have Free Spins AND are by Inspired**.
  
  4. **User taps reels “3–3 Reels.”**
  
     * A third chip is added: `[Free Spins] [Inspired] [3–3 Reels]`.
     * The grid **tightens** again to items that **satisfy all three** conditions.
  
  5. **User clears filters.**
  
     * Either the user taps the **“×”** on individual chips or a **Clear all** control.
     * All chips disappear; the grid **returns to the broader state** (unfiltered or previously scoped).
  
  6. **Returned to default Search view.**
  
     * The screen shows the **default Search** with the quick-filter bar and standard content rows.
  
  7. **Comparative UI references (for clarity of patterns).**
  
     * **Amazon** example: chips show a **count** of applied filters and an explicit **Clear** control.
     * **Spotify** example: a **persistent “X”** appears when any filters are active to **clear all**.
     * These references reinforce **visibility of applied filters** and **easy removal**, ensuring grids always reflect **current active filters**.
  
  
  #### *SEARCH · FILTER MENU — User searches for a slot game through filter menu* (iOS · 375×812)
  
  **Why this supports Req 11:** Although entered via **Game Filter** (full-screen modal), once filters are applied and the user returns to Search, the **same promise holds**—the grid shows **only relevant games** that match the active chips.
  
  1. **User taps “Game Filter.”**
  
     * From the Search screen, the user opens the **GAME FILTER** modal.
  
  2. **Category selection (Slots).**
  
     * The modal shows **category tiles** (Slots, Jackpots, Live Casino, Table, Slingo, Bingo, Instant, Arcade).
     * User selects **Slots**.
  
  3. **Facet selection (Feature).**
  
     * In the Slots facet view, the user selects **Free Spins** under **Features**.
  
  4. **Apply via “SHOW X GAMES.”**
  
     * The bottom **sticky button** indicates how many games match.
     * User taps **SHOW X GAMES** to confirm.
  
  5. **Back to Search with applied chips → relevant grid.**
  
     * The user returns to Search; applied chips (e.g., `[Slots] [Free Spins]`) appear under the field.
     * The **results grid** now shows **only games that match those facets**.
     * (Panels titled **Alternative Styles** and **Google Filters** show comparable chip/clear/apply patterns and count badges.)
  
  **Summary:**
  
  * **Every chip selection** narrows the set.
  * **Multiple chips** combine **conjunctively** (AND), so the grid only contains titles that meet **all** current criteria.
  * **Removal/clear** instantly **broadens** the grid.
  * The UI keeps **applied filters visible** at all times so users understand why specific titles are shown.
  
  
- Must Have: Add Game Filter to the search page
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am on the search page
  
  Then I should have access to a 
  Game Filter option
  
  And when it is clicked, it should 
  load up the Game Filter menu 
  where I can see the main 
  categories (game types)
  
  **Figma**  
  Figma -  
  Search  
  Menu  
  Native
  
  **Embedded UI/UX images – textual description**  
  - The search screen shows a **“Game Filter”** chip among quick filters.  
  - Tapping **Game Filter** opens a **full-screen modal** titled **GAME FILTER**.  
  - The modal lists **main categories** as large icon buttons: *Slots*, *Jackpots*, *Live Casino*, *Table*, *Slingo*, *Bingo*, *Instant*, *Arcade*.  
  
  
  #### Image 1 — *SEARCH · FILTER MENU — User searches for a slot game through filter menu* (iOS · 375×812)
  
  **Purpose:** The Search page exposes an explicit **“Game Filter”** entry point that opens a full-screen modal for deep facet selection. Users can select a **category** (e.g., Slots) and then choose **child filters** before applying with a sticky **SHOW X GAMES** button.
  
  1. **Search screen with “Game Filter” entry point**
  
     * Standard Search header and search field at top.
     * Directly beneath is the **Quick Filters** chip row; the **first chip is “Game Filter.”**
     * Below, content rows (e.g., Game Collections and default grids) are visible.
     * **User taps “Game Filter.”**
  
  2. **Game Filter modal — main category grid**
  
     * A full-screen panel titled **GAME FILTER** slides up.
     * It presents **eight large category cards** with icons and labels: **Slots**, **Jackpots**, **Live Casino**, **Table**, **Slingo**, **Bingo**, **Instant**, **Arcade**.
     * A persistent **footer CTA** reads **SHOW X GAMES** (disabled until a selection is actionable).
     * **User taps “Slots.”**
  
  3. **Category → child facet view (Slots)**
  
     * The header remains **GAME FILTER**, with a close **(×)** at top-right.
     * **Facet groups** appear vertically:
  
       * **Features** (e.g., Free Spins, Expanding Wilds, Sticky Wilds…) as multi-select **chips**.
       * **Game Provider** (Evolution, Light & Wonder, Pragmatic Play, etc.) as **checkbox list**.
       * Additional, category-specific groups may follow (e.g., Reels, Themes, Win Lines).
     * Selecting any facet adds a **pill** to an **Active Filters** strip at the top of the modal.
     * **User taps “Free Spins.”** The pill **Free Spins** appears under Active Filters.
  
  4. **Apply selections**
  
     * The **SHOW X GAMES** footer updates to reflect the dynamic count (**X**) of matching titles.
     * **User taps “SHOW X GAMES.”**
  
  5. **Return to Search with applied state**
  
     * Modal dismisses.
     * The Search screen now shows **applied filter chips** beneath the search field (e.g., **\[Slots] \[Free Spins]**).
     * The **results grid** renders **only titles** matching those filters.
     * Additional mockups illustrate alternate **facet visual styles** (e.g., large pill cards) and a **Google-like filters** pattern with count badges, reset/clear, and apply behaviors—reinforcing the same model: obvious entry, visible selections, explicit apply.
  
  
  #### Image 2 — *SEARCH · FILTER MENU — User searches for a bingo game through filter menu* and *All Categories*
  
  **Purpose:** The **Game Filter** entry supports all categories and handles **special cases**. For **Bingo**, there are **no child filters**; selecting the category immediately shows results. A separate “All Categories” panel shows the **facet consistency** for categories like **Slots**, **Jackpot**, **Live Casino**, and **Table**.
  
  1. **Bingo flow — no child filters**
  
     * From Search, user taps **Game Filter** → **GAME FILTER** category grid.
     * **User selects “Bingo.”**
     * Because Bingo has **no child facets**, the app **immediately returns** to Search and displays a **Bingo-scoped results grid** (only Bingo games).
     * If the user reopens Game Filter while Bingo is active, the **Active Filters** strip shows **Bingo** with an **“×”** (remove). Where relevant, the modal can show **Stake Range** and **Game Provider** controls; the bottom retains **SHOW X GAMES** to apply refinements.
  
  2. **All Categories — facet structure by type**
  
     * **Slots:**
  
       * **Stake Range** slider at top.
       * **Game Provider** checklist (Evolution, Scientific Games, Light & Wonder, PlayTech, Pragmatic Play, Red Tiger, Blueprint Gaming).
       * **Type of Game** chips (Slingo, Instants, Jackpot, Megaways, Table Games, Seasonal, Fishing).
       * Sticky **SHOW X GAMES** footer.
     * **Jackpot:**
  
       * **Stake Range** slider.
       * **Game Provider** checklist.
       * **Type of Game** chips tailored to jackpot context.
       * **SHOW X GAMES** footer.
     * **Live Casino:**
  
       * **Stake Range** slider.
       * **Game Provider** checklist focused on live providers.
       * **SHOW X GAMES** footer.
     * **Table:**
  
       * **Stake Range** slider.
       * **Game Provider** checklist for table providers.
       * **SHOW X GAMES** footer.
  
  **Summary:**
  
  * The **Search page includes a dedicated “Game Filter” chip** that opens a **full-screen modal** for comprehensive filtering.
  * Users **pick a category first**, then **refine via child facets** (or immediately see results if the category has no children, like Bingo).
  * **Selections are visible** as **Active Filter pills** and are **applied explicitly** via **SHOW X GAMES**, returning users to Search with an **applied chips bar** and a **filtered results grid**.
  
  
  
- Must Have: Game Filters can be added to the Game Filter Menu using Contentful
  **Acceptance Criteria**
  
  Given that I am a Bally's 
  Employee using the CMS
  
  When I am configuring the Game 
  Filters in the Game Filter Menu
  
  Then I should be able to add and 
  remove Filters
  
  And the customer should see the 
  filters I have configured
  
  Filters to be added by Product
  /Gaming Ops
  
  
- Must Have: Game Filters are configurable in Contentful
  **Acceptance Criteria**
  
  Given that I am a Bally's 
  Employee using the CMS
  
  When I am configuring Game 
  Filters Filters
  
  Then I should be able to change 
  the order the all Game Filters that 
  are presented to customer
  
  
- Must Have: Ability to apply filters in the Game Filter menu
  **Acceptance Criteria**
  
  Given that I am a customer
  
  And I am viewing the Game Filter 
  menu
  
  When I click on one of the main 
  categories e.g. slots
  
  Then I should be able to see all 
  the child filters of the category
  
  And apply these filters
  
  **Figma**  
  Figma -  
  Search  
  Menu  
  Native
  
  **UI/UX – description**  
  - The **GAME FILTER** modal shows **Active Filters** chips at the top.  
  - Under **Features**, chip options include: *Free Spins*, *Expanding Wilds*, *Stacked Wilds*, *Hold & Win*, *Cascading Reels*, *Cash Collect*, *Other Wilds*, *Scatter*, *Mystery Symbols*, *Respins*, *Buy a Bonus*, *Gamble*, *Sticky Wilds*, etc.  
  - **Providers** section lists studios as chips (e.g., *Light & Wonder*, *Playtech*, *Pragmatic Play*, *Bragg*, *Evolution Gaming*, *Eyecon*, *Gaming Realms*, etc.).  
  - **Reel** section offers *Megaways*, *3-3*, *3-5*, *4-4*, *Other*.  
  - **Win Line**: *10*, *20*, *50+*, *Other*.  
  - **Win Line Type**: *Megaways*, *Both*, *All*, *Ways*.  
  - **Themes**: *Animal*, *Mythical*, *Money*, *Historic*, *Sweets*, etc.  
  
  #### Image 1 — GAME FILTER (iOS · 375×812) — Selecting and combining child facets
  
  1. **Entry context**
  
     * User has tapped **Game Filter** on the Search screen.
     * A full-screen modal titled **GAME FILTER** slides up. A **Close (×)** icon sits in the top-right.
     * A **sticky footer CTA** reads **SHOW X GAMES** (X is a dynamic count of matches).
  
  2. **Active Filters strip**
  
     * Directly below the header, an **Active Filters** row appears once the first option is chosen.
     * Each selection is rendered as a **pill** with a small **“×”** affordance to remove that specific filter.
     * Pills wrap or horizontally scroll if they overflow.
  
  3. **Facet groups (vertical stack)**
  
     * **Features** (multi-select **chips**): examples shown include *Free Spins*, *Expanding Wilds*, *Stacked Wilds*, *Hold & Win*, *Cascading Reels*, *Cash Collect*, *Other Wilds*, *Scatter Wilds*, *Mystery Symbols*, *Respins*, *Buy a Bonus*, *Gamble*, *Sticky Wilds*, etc.
  
       * Tapping a chip toggles its selected state.
       * Selected chips immediately appear in **Active Filters** and visually highlight in place.
     * **Providers** (**checkbox list**): examples include *Light & Wonder*, *Playtech*, *Pragmatic Play*, *Bragg*, *Evolution Gaming*, *Eyecon*, *Gaming Realms*, *Greentube*, *IGT*, *Inspired*, etc.
  
       * Multiple providers can be checked at once; each check adds a pill to **Active Filters**.
     * **Reel** (single-select **options**): *Megaways*, *3–3*, *3–5*, *4–4*, *Other*.
  
       * Exactly one value can be active; choosing another replaces the prior selection in **Active Filters**.
     * **Win Line** (single-select options): *10*, *20*, *50+*, *Other*.
     * **Win Line Type** (single-select options): *Megaways*, *Both*, *All*, *Ways*.
     * **Themes** (multi-select **chips**): examples include *Animal*, *Mythical*, *Money*, *Historic*, *Sweets*, etc.
  
  4. **Real-time feedback & validation**
  
     * Every selection updates the **Active Filters** row **immediately**.
     * The footer CTA **SHOW X GAMES** updates the **count (X)** in real time to reflect current selections.
     * CTA is **enabled** when at least one actionable filter/category is applied.
  
  5. **Removal & reset**
  
     * Tapping the **“×”** on any pill removes just that filter; the pill disappears from **Active Filters**, the facet control deselects, and the **X** count in the CTA recomputes.
     * The **Close (×)** in the header dismisses the modal without applying new changes.
  
  6. **Apply**
  
     * Tapping **SHOW X GAMES** confirms the current set of filters and dismisses the modal.
  
  7. **Scrolling & layout**
  
     * The facet list is **scrollable**; header, **Active Filters** row, and footer CTA remain **fixed** to keep context and actions visible at all times.
  
  
  #### Image 2 — GAME FILTER (iOS · 375×812) — Multi-selection state and confirmation
  
  1. **Multi-facet state visible**
  
     * Several **Feature** chips are selected (e.g., *Free Spins*, possibly *Expanding Wilds*), and at least one **Provider** checkbox is ticked (e.g., *Red Tiger*).
     * The top **Active Filters** strip shows **all chosen items** in pill form, confirming exactly what will be applied.
  
  2. **Single-select sections**
  
     * A **Reel** or **Win Line** option appears visually “on” to indicate exclusivity (changing it replaces the current pill rather than adding a new one).
  
  3. **Footer CTA with count**
  
     * **SHOW X GAMES** reflects the **current match count** based on the combined filter set (AND logic).
     * The button remains **sticky**; as the user scrolls, it’s always reachable to apply.
  
  4. **Apply & return**
  
     * On tapping **SHOW X GAMES**, the modal closes and the Search screen reappears with an **applied-filters chip row** (e.g., `[Slots] [Free Spins] [Red Tiger] [3–3 Reels] …`) beneath the search field, and the **results grid** showing **only games matching all active filters**.
  
  5. **Edit loop**
  
     * Reopening **Game Filter** shows the same selections already **persisted**: the **Active Filters** strip is pre-populated, corresponding facet controls remain selected, and the user can add/remove before re-applying.
  
  **Summary**
  
  * Users can **open** the dedicated **Game Filter** modal, **select** across multiple facet groups, **see** their choices summarized as **removable pills**, and **apply** them via a **sticky button** that shows the **exact number of matching games**.
  * Facets support both **multi-select** (chips/checkboxes) and **single-select** (mutually exclusive options).
  * The design emphasizes **immediate, visible feedback**, **easy removal**, and a **clear confirmation** action that returns users to a **filtered Search results** state.
  
  
- Must Have: When filters are applied, relevant games should be shown
  **Acceptance Criteria**
  
  Given that I am a customer
  
  And I have applied filters in the 
  Game Filter menu
  
  When I click the 'Show X Games' 
  button
  
  Then I should see games that are 
  relevant to the filters I have 
  applied
  
  **Figma**  
  Figma -  
  Search  
  Menu  
  Native
  
  **UI/UX – description**  
  
  - The **GAME FILTER** modal shows a red **“SHOW X GAMES”** button at the bottom, indicating how many results will be displayed with the applied filters.
  
  #### Image 1 — *Post-apply state from Quick Filters / Game Filter (iOS · 375×812)*
  
  1. **Return to Search with applied context**
  
     * The screen header remains **SEARCH** with the search field focused/available.
     * Directly beneath the field, an **Applied Filters bar** displays all active pills in order of selection (e.g., `[Slots] [Free Spins] [Inspired] [3–3 Reels]`).
     * Each pill includes an **“×”** affordance for one-tap removal; the bar scrolls horizontally when overflow occurs.
  
  2. **Results grid restricted by active filters**
  
     * The main content area renders a **grid of game tiles** limited to titles that **match all active filters (AND logic)**.
     * Tiles show standard metadata/badges (e.g., NEW/EXCLUSIVE/jackpot labels), indicating these are **real, playable results** rather than placeholders.
     * No unrelated titles appear; the grid is **immediately refreshed** from the previous state.
  
  3. **Visible feedback + discoverability of edits**
  
     * The **Applied Filters** bar keeps user context visible at all times, explaining *why* specific results are shown.
     * Tapping a pill’s **“×”** removes that single constraint; the grid **recomputes instantly** to a broader but still filtered set.
     * If all pills are removed (or a **Clear all** control is used), the page reverts to the **default/unfiltered** Search content.
  
  4. **Refine loop via Game Filter**
  
     * Tapping **Game Filter** again reopens the modal with **Active Filters pre-populated** at the top and the corresponding **facet controls preselected**.
     * Users add/remove facets; the footer **SHOW X GAMES** reflects the **new match count**.
     * Confirming updates the Search screen, pills, and grid again.
  
  5. **Edge/empty state handling (implied by spec patterns)**
  
     * If the current combination yields **no matches**, the results area switches to a **clear empty state** (e.g., “No Search Results”) with guidance to **edit or remove filters**.
  
  
  #### Image 2 — *Applied filters visible in GAME FILTER and reflected on Search (iOS · 375×812)*
  
  1. **GAME FILTER modal with selections made**
  
     * The modal header shows **GAME FILTER**; beneath it sits an **Active Filters strip** listing each current selection as a pill (e.g., `Slots`, `Free Spins`, `Inspired`).
     * Facet groups (Features, Providers, Reels/Lines/Themes, Stake Range, etc.) display the **chosen values** as selected chips/checkboxes or radio options.
  
  2. **Count-based confirmation**
  
     * The sticky footer button reads **SHOW X GAMES**, where **X** updates in real time based on the current selection set.
     * This explicit count primes the user that **only X relevant titles** will be shown after applying.
  
  3. **Apply → filtered Search**
  
     * On tapping **SHOW X GAMES**, the modal closes.
     * Back on the Search screen, the **Applied Filters bar** mirrors the exact selections; the **results grid** now shows **only games that satisfy all of them**.
  
  4. **Subsequent adjustments**
  
     * From the Search screen, users can:
  
       * **Remove an individual pill** to widen results.
       * **Open GAME FILTER** to bulk-edit; previously selected values remain **persisted**, keeping mental load low.
  
  5. **Consistency across entry points**
  
     * Whether the filters were applied via **Quick Filter chips** or via the **GAME FILTER** modal, the resulting behavior is identical:
  
       * **Active pills visible** under the search field.
       * **Grid constrained** to **relevant** matches only.
       * **Immediate recomputation** when filters change or clear.
  
  
  
- Must Have: Direct customers straight to games when Bingo is selected as a filter
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I filter Bingo as the game 
  type
  
  Then I should see a list of games 
  without having the option to 
  choose additional filters
  
  This is because there are no child 
  filters for Bingo
  
  **Figma**  
  Figma -  
  Search  
  Menu  
  Native
  
  **UI/UX – description**
  
  
  #### Image 1 — *SEARCH · FILTER MENU — User searches for a bingo game through filter menu* (iOS · 375×812)
  
  **Intent illustrated:** **Bingo** is a **top-level category with no child facets.** Selecting it should **immediately route** the user to a Bingo-only results view—skipping intermediate filter steps.
  
  1. **Search page (idle) with Game Filter entry**
  
     * Standard **SEARCH** header and search field at the top.
     * **Quick Filters** row is visible; the first chip is **Game Filter**.
     * Content rows (e.g., **Game Collections**, a standard header grid) fill the page.
     * **User taps “Game Filter.”**
  
  2. **GAME FILTER modal — main categories**
  
     * A full-screen modal titled **GAME FILTER** slides up.
     * It shows **eight large category tiles** with icon + label: *Slots, Jackpots, Live Casino, Table, Slingo, Bingo, Instant, Arcade*.
     * A sticky footer CTA reads **SHOW X GAMES** (disabled before a meaningful selection).
     * **User taps “Bingo.”**
  
  3. **Immediate results (no child filters for Bingo)**
  
     * Because **Bingo has no child facets**, there is **no intermediate facet screen**.
     * The modal **dismisses automatically** and the user lands back on the **Search screen**.
     * Beneath the search field, an **Applied Filters bar** now shows the single pill **\[Bingo]**.
     * The primary content area renders a **grid of Bingo games only** (placeholder tiles in the mock).
  
  4. **Optional refinement via re-opening Game Filter**
  
     * If the user taps **Game Filter** again, the modal opens with **Bingo** listed under **Active Filters** at the top (as a removable pill with **“×”**).
     * The facet column may present **Stake Range** and **Game Provider** checkboxes (Evolution, Scientific Games, Light & Wonder, PlayTech, Pragmatic Play, etc.)—these are **optional refinements** specific to Bingo availability.
     * The sticky footer CTA **SHOW X GAMES** reflects the **current match count** as selections are toggled.
  
  5. **Clearing Bingo**
  
     * From the reopened modal, tapping the **“×”** on the **Bingo** pill clears the category; user can pick a new top-level category (e.g., Slots).
     * Alternatively, from the Search screen, removing the **\[Bingo]** pill in the **Applied Filters bar** clears the constraint and broadens results.
  
  
  #### Image 2 — *SEARCH · FILTER MENU — All categories (Bingo behavior contrasted with others)* (iOS · 375×812)
  
  **What the panel shows:** A comparative look at **facet structures** for other categories (Slots, Jackpot, Live Casino, Table) versus **Bingo’s special case**.
  
  1. **Other categories (Slots, Jackpot, Live Casino, Table)**
  
     * Each shows a **Stake Range** slider at top and a **Game Provider** checklist.
     * Some also include **Type of Game** or other facet groups.
     * Users must **select and apply** (via **SHOW X GAMES**) to see filtered results.
  
  2. **Why Bingo is different**
  
     * **No child facets are required** to get to meaningful content; therefore **selecting Bingo immediately displays Bingo games**.
     * Any additional controls (e.g., Stake Range, Provider) are **optional** refinements available **after** the first results view, not prerequisites.
  
  
  #### Summary
  
  * **Single-tap to content:** Choosing **Bingo** from **GAME FILTER** should **bypass** intermediate filtering and **immediately** show **Bingo-only search results**.
  * **Applied state visibility:** The **Applied Filters bar** on Search displays **\[Bingo]** so users understand why the grid is scoped.
  * **Refinement loop (optional):** Users can re-enter **GAME FILTER** to add **Stake Range** or **Providers** for Bingo, with a **dynamic results count** on the **SHOW X GAMES** CTA.
  * **Removal / change of mind:** Clearing the **\[Bingo]** pill (in the modal or on Search) **broadens** results and allows selection of a **different category**—mirroring the pattern used for all other filters.
  
  
  
- Must Have: Ability to remove filters
  **Acceptance Criteria**
  
  Given that I am a customer
  
  And I have applied a filter
  
  When I want to remove a filter
  
  Then I should have the ability to 
  remove 1 or multiple filters
  
  **Figma**  
  Figma -  
  Search  
  Menu  
  Native
  
  **UI/UX – description**  
  - The top of the **GAME FILTER** modal shows **Active Filters** chips (e.g., *Slots*, *Free Spins*) each with an **“x”** icon to remove them.  
  
  
  #### Image 1 — *GAME FILTER modal with Active Filters pills (iOS · 375×812)*
  
  **Intent illustrated:** Users can **see every applied constraint** and **remove one or many** directly inside the **GAME FILTER** modal.
  
  1. **Context & scaffolding**
  
     * A full-screen modal titled **GAME FILTER** is open (invoked from the Search screen).
     * Directly beneath the header, an **Active Filters** strip lists each current selection as a **pill** (e.g., `Slots`, `Free Spins`), each with a small **“×”** control.
     * The main pane shows facet groups (e.g., **Features** as chips, **Game Provider** as checkboxes, **Reel/Win Lines/Themes** as single/multi-selects). Selections here are mirrored in the **Active Filters** strip.
     * A **sticky footer CTA** shows **SHOW X GAMES**; **X** is the live count of matches.
  
  2. **Remove a single filter**
  
     * The user taps the **“×”** on a specific pill (e.g., `Free Spins`).
     * Immediate effects:
  
       * The pill **disappears** from the Active Filters strip.
       * The corresponding control in the facet list **deselects** (chip unhighlights or checkbox unticks).
       * The **X** in **SHOW X GAMES** **recomputes** to reflect the broader result set.
  
  3. **Remove multiple filters rapidly**
  
     * The user may tap **“×”** on multiple pills in succession.
     * Pills vanish in the order tapped; related facet controls deselect in lockstep.
     * The **match count** in the footer updates after each removal.
  
  4. **Optional close without applying**
  
     * If the user taps the modal **Close (×)** in the header, the modal dismisses **without confirming** changes (i.e., the previously applied state remains on the Search screen).
  
  5. **Apply updated set**
  
     * Tapping **SHOW X GAMES** confirms the reduced filter set and returns to Search with the new, broadened results.
  
  
  #### Image 2 — *Search screen with Applied Filters bar (iOS · 375×812)*
  
  **Intent illustrated:** Users can also **remove filters directly from the Search screen** without reopening the modal.
  
  1. **Applied state visible**
  
     * Beneath the search field, an **Applied Filters bar** displays each active filter as a **pill** with an **“×”** (e.g., `[Slots] [Free Spins] [Inspired]`).
     * Pills are **horizontally scrollable** when they overflow.
  
  2. **Remove individual pills in place**
  
     * The user taps the **“×”** on a pill (e.g., removes `Inspired`).
     * Immediate effects:
  
       * The pill **disappears** from the bar.
       * The **results grid** **recomputes instantly** to reflect the remaining constraints (e.g., now `[Slots] [Free Spins]`).
       * If the user reopens **GAME FILTER**, the **Active Filters** strip and facet controls **match** this new state.
  
  3. **Clear all (pattern reference)**
  
     * If a **clear-all** affordance is present (as shown in reference patterns), activating it **removes every pill** at once.
     * The page **reverts** to default/unfiltered Search content.
  
  4. **Empty-state prevention**
  
     * If removals broaden from “no results” to a valid set, the grid **populates** immediately—avoiding dead ends.
  
  
  #### Summary
  
  * **Bidirectional removal:** Filters can be removed **inside the GAME FILTER modal** (via the **Active Filters** pills) or **directly on Search** (via the **Applied Filters** bar).
  * **Immediate feedback:** Each removal synchronizes the **UI controls**, **pills**, and **result count**; Search results update **without extra steps**.
  * **Granular or bulk:** Users can remove filters **one by one** or use a **clear-all** control (where provided).
  * **State persistence:** Whatever remains after removals is **persisted** across both surfaces (Search and modal), keeping the system **predictable** and **transparent**.
  
  
  
- Must Have: Ability to view applied filters
  **Acceptance Criteria**
  
  Given that I am a customer
  
  And I have applied a filter
  
  When I want to view the filters 
  that I have applied
  
  Then I should have the ability to 
  view all of the filters I have applied
  
  **Example (embedded images – textual descriptions)**  
  - **Search Page after Filters have been applied in the filter menu:**  
    - The search results screen shows the **Filters** button and displays selected filter **chips** (e.g., providers and features) above the result grid.  
  - **When the customer clicks 'Filter' they can now see which filters they have applied:**  
    - The **GAME FILTER** modal opens with **Active Filters** chips shown at the top, listing all applied filters.  
    - A **SHOW X GAMES** button is visible at the bottom.  
  
  **Figma**  
  Figma -  
  Search  
  Menu  
  Native
  
  **UI/UX – description**
  
  
  #### Image 1 — *Search page after filters have been applied (iOS · 375×812)*
  
  1. **Applied state surfaced directly on Search**
  
     * The screen header is **SEARCH** with the text field at the top.
     * Immediately beneath the field sits an **Applied Filters bar** showing every active filter as a **pill** (e.g., `Free Spins`, `Inspired`, `Evolution`, `3–3 Reels`).
     * Each pill includes an **“×”** affordance for one-tap removal; the bar supports **horizontal scroll** when there are many pills.
  
  2. **Results reflect the applied set**
  
     * The content area renders a **grid** of titles that **match all active filters**.
     * Users can infer why these specific games are visible because the **entire selection logic is summarized** in the pills directly above the grid.
  
  3. **Entry back to full details of what’s applied**
  
     * A **Filter** control (or re-tapping **Game Filter**) is available; activating it opens the **GAME FILTER** modal so users can **inspect, review, and adjust** the exact list of applied criteria.
  
  4. **Inline management (view + quick edit)**
  
     * Because pills are visible here, users can also **view at a glance** what’s active and **remove** any single pill without leaving the page.
     * The grid **immediately recomputes**; the remaining pills continue to document the active state.
  
  
  #### Image 2 — *GAME FILTER modal showing the applied filters list (iOS · 375×812)*
  
  1. **Complete, centralized view of what’s applied**
  
     * The full-screen **GAME FILTER** modal opens with an **Active Filters strip** directly under the header.
     * This strip lists **every current selection** as a pill (e.g., category, features, provider, reels/lines/themes). This provides a **single, comprehensive view** of the applied set.
  
  2. **Synchronized facet view**
  
     * Down the page, facet groups (e.g., **Features**, **Game Provider**, **Reel**, **Win Line**, **Themes**, or **Stake Range**) display the **same selections pre-checked**.
     * Scrolling lets users **audit all groups** to confirm what’s on without losing sight of the **Active Filters strip**.
  
  3. **Counted confirmation**
  
     * The sticky footer CTA displays **SHOW X GAMES** where **X updates live** based on the current applied set—reinforcing **how many results** the visible filters produce.
  
  4. **Granular removal while viewing**
  
     * From this screen, users can **remove any item** by tapping the pill’s **“×”** in the Active Filters strip. The pill disappears, the corresponding facet **deselects**, and **X** recomputes.
     * This makes the modal both a **viewer** and an **editor** of the applied state.
  
  5. **Apply or close**
  
     * Tapping **SHOW X GAMES** returns to Search with the **updated pill list** under the field and the grid **filtered accordingly**.
     * Dismissing the modal without applying **preserves** the previously applied set on the Search page, keeping the visible pills and results consistent.
  
  
  
- Must Have: Handling of multiple languages
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am on the search page
  
  Then the UI and search logic 
  should support my chosen 
  language/language of the country 
  I am playing in
  
  
- Must Have: Search results should load quickly
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I search for a game by filter 
  or by typing in the search bar
  
  Then I should see my results 
  within 2 seconds
  
  This includes caching and the 
  displaying of the results
  
  
- Must Have: Ordering the games based on Margin
  **Acceptance Criteria**
  
  Given that I am a customer
  
  And I search for a game by filter 
  or by typing in the search bar
  
  When I see the results
  
  Then the games should be 
  ordered highest margin to lowest 
  margin
  
  
- Must Have: Update the search UI to latest designs
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I go to the search page
  
  Then I should see the latest 
  designs and UX guidelines
  
  And it should adjust dependant on 
  device
  
  The designs can be found in 
  Figma
  
  
- Could Have: Retain Player Search History
  **Acceptance Criteria**
  
  Given that I am a logged in 
  customer
  
  And I have previously searched 
  for a game
  
  When I begin to search for a game
  
  Then I should see my last 5 
  searches
  
  **Figma**  
  Figma -  
  Search  
  Native
  
  **UI/UX – description**  
  - The search screen shows a **search field** with a list titled **“Recent Searches”** underneath, displaying up to five prior terms (e.g., “Mega”, “Jungle”, “Mega Moolah”, “Egypt”) each with a clock-like recent icon.
  
  #### iOS — 375×812
  
  1. **User lands on Search and taps the search field**
  
     * The Search page is visible with the standard header and text field.
     * After tapping the field, the keyboard appears.
  
  2. **A new view presents the player’s past queries**
  
     * Directly under the search field a list labeled **Recent Searches** is shown.
     * A second list labeled **Popular Searches** is also available beneath it.
     * Each entry is tappable to reuse that query immediately.
  
  3. **User begins typing**
  
     * Typing starts in the search field.
     * The UI notes that **searching does not begin until at least two characters** are entered.
  
  4. **Two-character threshold reached → live results**
  
     * After the **second character**, the **results grid updates** in real time.
     * The keyboard remains open so the user can continue refining; results keep updating.
  
  5. **User finishes typing → full, relevant results**
  
     * The grid shows games matching the query.
     * (Optional sorting controls are available as in other flows.)
     * The experience demonstrates that previously typed queries are **retained and surfaced** the next time the user enters the search field.
  
  
  #### Android — 360×780
  
  1. **User taps the search field on the Search tab**
  
     * The Search page is visible; tapping the field raises the keyboard.
  
  2. **Recent & popular searches are shown**
  
     * A panel under the field lists the user’s **Recent Searches**.
     * A **Popular Searches** list appears beneath.
     * Items are tappable to re-run that query without retyping.
  
  3. **User begins typing**
  
     * Input starts, but **no search executes until two characters** are entered.
  
  4. **Live results after two characters**
  
     * With the **second character**, the **results grid appears/updates** dynamically while the keyboard stays up.
  
  5. **Completed input → relevant results**
  
     * The user sees the full set of matching results for the entered term.
     * The presence of **Recent Searches** at the start of the flow confirms that the app **retains a short history of prior queries** for quick reuse.
  
  
  
- Could Have: Show Popular Searches
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I click on the search bar
  
  Then I should see a list of popular 
  games
  
  And be able to load the game by 
  clicking on it
  
  **Figma**  
  Figma -  
  Search  
  Native
  
  **UI/UX – description**  
  - Below **Recent Searches**, a section titled **“Popular Searches”** lists popular game keywords (e.g., *Double Bubble*, *Cherry Pop*, *Pipeline*) as selectable items with a search icon.  
  
  #### iOS — 375×812
  
  1. **Search screen → user taps the search field**
  
     * The Search tab is open with the standard header and text field.
     * Below the field are typical modules (e.g., Game Finder, Game Collections).
     * User taps the **search input** to start a query.
  
  2. **Keyboard appears + lists are revealed**
  
     * The on-screen keyboard slides up.
     * A **panel directly beneath the search field** shows two vertically stacked lists:
  
       * **Recent Searches** — the player’s own previous queries (each row tappable).
       * **Popular Searches** — a curated list of commonly searched terms (each row tappable).
     * The user can re-run any item by tapping it; no typing needed.
  
  3. **User begins typing**
  
     * Typed characters appear in the field.
     * **No results are returned until at least two characters** are entered (threshold rule is noted in the caption).
  
  4. **After second character → live results**
  
     * Once the second character is entered, the **results grid updates dynamically** to show matches.
     * Keyboard remains visible so the user can continue refining; results keep updating.
     * Sort controls (where provided) can be used while the keyboard is up.
  
  5. **Finished typing → full results**
  
     * The grid now shows all relevant titles for the term.
     * If instead the user had tapped an item in **Popular Searches**, the app would **immediately populate the field** with that term and **load the corresponding results** without further input.
  
  
  #### Android — 360×780
  
  1. **User taps into the search field on the Search tab**
  
     * Default Search screen visible; user activates the input.
  
  2. **Keyboard + recent & popular lists**
  
     * A **drawer-like panel** appears beneath the field listing:
  
       * **Recent Searches** (user’s own history), and
       * **Popular Searches** (predefined, high-demand terms).
     * Every row is **pressable** to execute that query instantly.
  
  3. **Typing begins**
  
     * Characters appear, but **no search executes until two characters** have been entered.
  
  4. **Live results after two characters**
  
     * With the second character, the **results grid appears/refreshes** in real time while the keyboard stays open.
  
  5. **Completed query**
  
     * The user sees the full set of **relevant results**.
     * Selecting a **Popular Search** item at any time would **auto-fill the field** and **navigate directly to its results**, fulfilling the requirement to surface and use **Popular Searches** from the search UI.
  
  
- Could Have: Ability to configure 'Popular Searches'
  **Acceptance Criteria**
  
  Given that I am a Ballys 
  employee using the CMS
  
  When I am configuring the games 
  that appear under 'Popular 
  Searches'
  
  Then I should be able to choose 
  which games to show based on 
  highest bets, highest GGR, most 
  played etc.
  
  
- Should Have: Ability to configure default content on the Search Page
  **Acceptance Criteria**
  
  Given that I am a Ballys 
  Employee using the CMS
  
  When I am configuring the search 
  page
  
  Then I should be able to add 
  categories of games the customer 
  can choose from, before they 
  have searched for a game (e.g. 
  Game Collections, Popular 
  Games etc.)
  
  Given that I am a customer
  
  When I am on the search page
  
  And I have not searched for a 
  game
  
  Then I will see categories of 
  games that have been configured 
  in the CMS
  
  This is to ensure the Search Page 
  is not blank
  
  Content to be decided by Game
  /Product Ops
  
  
- Could Have: Game Collections to be visible on the search page
  **Acceptance Criteria**
  
  Given that I am a customer
  
  When I am on the search page
  
  Then I should be able to see a 
  carousel of Game Collections
  
  **Notes**  
  Shish to confirm Game Collections before proceeding with this
  
  **UI/UX – description**  
  - The search screen shows a **“Game Collections”** section with a **horizontal carousel** of large, illustrated cards (e.g., *High Roller*, *Risk Taker*, *Lucky Irish*) each displaying art and labels like features or themes.  
  
  
- Could Have: Ability to find games via Game Collections
  **Acceptance Criteria**
  
  Given that I am a customer
  
  And I am on the search page
  
  When I click on one of the game 
  collections
  
  Then I should be taken to games 
  that fall under that collection
  
  **Notes**  
  Shish to confirm Game Collections before proceeding with this
  
  
- Must Have: Update Google Analytics for Effective Monitoring
  **Acceptance Criteria**
  
  Given that I am a Bally's 
  Employee using Google Analytics
  
  Then I should be able to see 
  results on how customer's use 
  search
  
  We already have google analytics 
  tagged for our existing search. 
  Make sure the enhanced search 
  features are captured
  
  
- Must Have: Error Handling
  **Acceptance Criteria**
  
  Given that I am a customer
  
  And I am attempting to search
  
  When there is an error in the data
  
  Then a basic search functionality 
  should be applied
  
  
  ## Questions
  
  Below is a list of questions to be addressed as a result of this requirements document:
  
  | Question | Outcome |
  |---|---|
  | Should logged in and logged out have the same search experience? | Shish to double check |
  | Which filters do we want to include in quick filters? Are we just following what is included in the designs? | Answered in Excel: Search Filters |
  | How do we determine 'Popular Searches'? Most searched or do we want to choose these ourselves? | This is for us to choose and configure e.g. popular games based on highest bets, highest GGR etc |

---
verified:
  last_updated: 2025-12-25
  verified_by: "System Validator Script"
  commit_sha: "41ce5457a7a1202a0f32227929443c032f0d07d9"
  verified_moscow_counts:
    must: 25
    should: 1
    could: 5
    wont: 0
    total: 31
