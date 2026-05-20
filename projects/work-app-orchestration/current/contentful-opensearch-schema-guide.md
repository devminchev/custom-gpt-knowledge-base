---
title: "Contentful CMS → OpenSearch Data Schema Guide"
tags: [projects, work-app-orchestration, current]
aliases: []
---
# Contentful CMS → OpenSearch Data Schema Guide

## 1) Content models & OpenSearch docs Map

* **`navigation` index**

  * content types: **IG Navigation**, **IG Quick Links**, **IG Link**.
* **`views` index**

  * content types: **IG View**.
* **`game-sections` index**

  * content types (family of section content types): **IG DFG Section**, **IG Grid A/B/C/D/E/F/G Section**, **IG Carousel A/B**, **IG Jackpots Section**, **IG Jackpot Sections Block**, **IG Game Shuffle**, **IG Search Results**.
* **`games-v2` index**

  * content types: **Game Model V2** and **Site Game V2** (parent/child relationship).
* **`ventures` index**

  * content types: **Venture**.
* **`ml-personalised-sections`**

  * content types: **IG Collab Based Personalised Section**, **IG Similarity Based Personalised Section**.
* **`ml-personalised-sections-defaults`**

  * content types: **IG Suggested Games**.
* **`themes`**

  * content types: **IG Theme**.
* **`marketing-sections`**

  * content types: **IG Banner**, **IG Braze Promos Section**, **IG Promotions Grid**, **IG Marketing Section**.

---

## 2) Index-by-index document structures (from the JSON mappings)

### A. `navigation`

Documents carry navigation link structures and visibility metadata. notable fields:

* **Identity & meta**: `id`, `cmsEnv`, `contentType`, `createdAt`, `updatedAt`, `publishedAt`, `entryTitle`.
* **Scoping/visibility** (localized): `platformVisibility`, `sessionVisibility`, `environmentVisibility`, `liveHidden`.
* **Link modeling**:

  * `layoutType`, `label`, `image`.
  * `links` (array of references with `{ sys: { id, linkType, type } }`).
  * For leaf/link items: `externalUrl`, `internalUrl`, `view` (reference), optional `classification`.
* **Venture reference**: `venture.sys.{ id, linkType, type }`.
* **Localization**: many text fields appear with locale keys (e.g., `en-GB`) and include a `.keyword` subfield for exact matching.

### B. `views`

Represents “view” pages/containers that stitch other entities together.

* **Identity & meta**: `id`, `cmsEnv`, `contentType`, `createdAt`, `updatedAt`, `publishedAt`, `entryTitle`.
* **View attributes**:

  * `name` (localized), `viewSlug` (localized), optional `classification`, `validationStatus` (object).
* **Scoping/visibility** (localized): `platformVisibility`, `sessionVisibility`, `environmentVisibility`, `liveHidden`.
* **Composition** (references):

  * `venture.sys.{ id, linkType, type }`.
  * `topContent[]` and `primaryContent[]` as references (`sys.{ id, linkType, type }`).
  * `sections[]` as references (for section lists on the view).

### C. `game-sections`

A unified index for multiple section types used on views (grids, carousels, jackpots, search results, etc.). It mixes content selection, visuals, and CTA information.

* **Identity & meta**: `id`, `cmsEnv`, `contentType`, `createdAt`, `updatedAt`, `publishedAt`, `entryTitle`.
* **Naming & routing** (localized): `name`, `title`, `slug`.
* **Section configuration** (localized):

  * `layoutType`, `expandedSectionLayoutType`, `sectionTruncation`.
  * “View all” UI: `viewAllAction` (as reference object with `sys`), `viewAllType`, `viewAllActionText`.
  * `validationStatus` sub-keys include `expandedSectionLayoutType`, `slug`, `slug:duplicate`, `viewAllAction`.
* **Scoping/visibility** (localized): `platformVisibility`, `sessionVisibility`, `environmentVisibility`.
* **Content selection**:

  * `games` (array of references via `sys`), optional `game` (single reference), and `gameIds` (text).
  * Jackpots: `jackpots` (array of references via `sys`), `jackpotType` (text), `headlessJackpot` (`{ id: number, name: text }` localized).
  * `venture` (reference via `sys`).
* **Media / assets** (localized) — several Bynder-backed objects with rich metadata:

  * `headerImageBynder`, `backgroundImageBynder`,
  * `mediaLoggedIn` (Bynder object),
  * `bynderDynamicBackground`, `bynderDynamicLogo`, `bynderMedia`,
  * `pot1ImageBynder`, `pot2ImageBynder`, `pot3ImageBynder`,
  * plus simpler text-based `image`, `media`, and `link`.
  * Typical Bynder fields inside these objects: `id`, `name`, `src`, `extension`, `fileSize`, `height/width`, `orientation`, `isPublic`, `limited`, `brandId`, `dateCreated/Modified/Published`, `original`, `thumbnails` (`BlurBackground`, `JPJ_Thumbnail`, `LPhone600x1200`, `mini`, `original`, `thul`, `transformBaseUrl`, `webimage`), `type`, `watermarked`.
* **Localization coverage**: at minimum `en-GB`; some fields also include `en-US` and `es`.

### D. `games-v2`

Holds *two* document shapes and a **join relationship**:

* **Join**: `game_to_sitegame` with relation `"game" -> "sitegame"`.
* **`game` (parent)** — game catalog entry with content, visuals, and configuration:

  * **Media (localized)**: `bynderGameInfoGameTile`, `backgroundMedia`, `foregroundLogoMedia`, `loggedOutBackgroundMedia`, `loggedOutForegroundLogoMedia`, `animationMedia`, `loggedOutAnimationMedia`, and URL patterns: `imgUrlPattern`, `infoImgUrlPattern`, `videoUrlPattern`, `dfgWeeklyImgUrlPattern`. The Bynder objects here carry the same metadata shape noted earlier (id/src/size/dates/tags/thumbnails/etc.).
  * **Copy/content (localized)**: `title`, `introductionContent`, `infoDetails`, `howToPlayContent`, `representativeColor`.
  * **Flags & presentation**: `funPanelEnabled`, `funPanelBackgroundImage`, `funPanelDefaultCategory`, `operatorBarDisabled`, `progressiveJackpot`, `progressiveBackgroundColor`, `showGameName`, `showNetPosition`, `rgpEnabled`.
  * **Taxonomy/tags (localized)**: `tags`, `vendor`, `platform`, `platformVisibility`.
  * **Config**: `gamePlatformConfig` (nested) with provider/aggregator/loader filenames, URLs (demo/real, desktop & mobile), RTP (`rtp`), `taxProductType`, `contractGameType`, `federalGameType`, `gameType` (nested booleans and texts like `isJackpot*`, `features`, `volatility`, `themes`, `winLines`, `winLineType`, etc.), plus mobile overrides.
  * **Misc**: `launchCode`, `nativeRequirement` (object), `webComponentData` (nested attributes like `currency`, `lang`, `partnerId`, `ventureId`, `lockoutTime`, and booleans such as `isEnabled`, `controlMobileChat`).
  * **Identity & meta**: `id`, `cmsEnv`, `contentType`, `publishedAt`, `updatedAt`, `publishedVersion`, `version`.
* **`siteGame` (child)** — site-specific presentation/availability of a game:

  * **Identity & meta**: `id`, `gameId`, `cmsEnv`, `contentType`, `createdAt`, `publishedAt`, `updatedAt`, `publishedVersion`, `version`.
  * **Scoping/visibility** (localized): `environment`, `environmentVisibility`, `platformVisibility`, `liveHidden`.
  * **Site-game settings (localized where applicable)**: `sash`, `tags`, `showNetPosition`, `maxBet`, `minBet`, `howToPlayContent`.
  * **Other**: `venture` (reference via `sys`), `headlessJackpot` (with `activeEnv`, numeric `id`, `name`), optional `chat` block (booleans, ids).

### E. `personalised-sections`

Used for personalized content sections.

* **Identity & meta**: `id`, `cmsEnv`, `contentType`, `publishedAt`, `updatedAt`, `version`, `publishedVersion`, `entryTitle`.
* **Core fields** (localized): `name`, `title`, `type`, `tileSize`, `show`.
* **Targeting/scope**: `environment` (string), `platform` (localized string), `venture` (reference via `sys`).
* **Content selection**: `games` (array of references via `sys`).
* **Priority**: `priorityOverride` (numeric).

### F. `ventures`

Represents ventures/brands and their jurisdiction link.

* **Identity & meta**: `id`, `cmsEnv`, `contentType`, `publishedAt`, `updatedAt`, `publishedVersion`, `version`.
* **Fields**:

  * `name` (localized), `entryTitle` (localized).
  * `environment` (string).
  * `jurisdiction` (reference via `sys`).

---

## 3) Cross-entity relationships

* **Navigation model**

  * **IG Quick Links** holds **Links\[]** (references to **IG Link**).
  * **IG Link** can point to either an external URL, an internal URL, or a referenced **View**. It also contains optional image fields and localized label.
* **Views → Sections**

  * **IG View** references one **Venture**, and composes content via **Top Content** / **Primary Content** lists and **Sections\[]**.
* **Sections → Games/Jackpots/Venture**

  * Section entries may reference **Games**, **Jackpots**, and a **Venture**; they also carry their own layout & “view all” config and a set of media fields.
* **Games model**

  * **Game Model V2** (parent) and **Site Game V2** (child) are related via a join in the `games-v2` index.
* **Ventures**

  * A **Venture** is referenced from **Views**, **Sections**, and **Site Game V2** (in the index these are represented uniformly as `sys` references).

---

## 4) Localization pattern (as modeled in the mappings)

* Localized fields are nested under locale codes (e.g., `en-GB`, `en-US`, `es`, `en-CA`, `sv`) for both text and boolean types (where present).
* Many localized text fields include a multi-field: `fields.keyword` to support exact matching alongside full-text analysis.
* Bynder asset objects are also localized (e.g., `backgroundImageBynder.en-GB.{ ... }`), each holding a full set of metadata.

---

## 5) Reference/Link representation

Across indices, references are consistently modeled with a `sys` object containing:

* `id`: the referenced entry ID,
* `linkType`: the Contentful link type,
* `type`: the Contentful system type.

This structure appears for references such as `games[]`, `jackpots[]`, `venture`, `view`, and `topContent`/`primaryContent`/`sections`.

---

## 6) Visibility & publication metadata

* **Visibility controls** (commonly localized): `platformVisibility`, `sessionVisibility`, `environmentVisibility`, and `liveHidden`.
* **Publication & audit**: `createdAt`, `updatedAt`, `publishedAt`, plus `version` / `publishedVersion` where present.
* **Classification / validation**: some indices include `classification` and a `validationStatus` object (e.g., in `views` and `game-sections`) with named keys tied to slugs and layout.

---

## 7) Media (Bynder) metadata shape (repeated across fields)

For any Bynder-backed media field (e.g., headers, backgrounds, logos, tiles), the inner object includes the following repeated schema elements:

* **Identity & dates**: `id`, `brandId`, `dateCreated`, `dateModified`, `datePublished`.
* **Dimensions & file**: `extension`, `fileSize`, `height`, `width`, `orientation`, `type`, `watermarked`.
* **Access flags**: `isPublic`, `limited`, `archive`.
* **Paths**: `src`, `original`, sometimes `description` or `tags`.
* **Thumbnails**: keys like `BlurBackground`, `JPJ_Thumbnail`, `LPhone600x1200`, `mini`, `original`, `thul`, `transformBaseUrl`, `webimage`.

---
