---
title: "Webhook→Content Type Matrix Config (setup-ready)"
tags: [projects, work-app-orchestration, current]
aliases: []
---
# Webhook→Content Type Matrix Config (setup-ready)

Below is a precise, build-from-scratch reference for **which webhook handles which Contentful entry types**, the **URL & filters**, **topics by environment**, and the **exact payload shape** each webhook posts into OpenSearch write aliases.

> Shared settings used by all hooks
> **Headers:** Basic Auth + `X-Query-Metadata: type, contentType`
> **Refresh policy:** `wait_for` in dev/stg, `true` in prod
> **Topics (typical):** Prod=publish/unpublish; Dev/Stg also save/auto\_save. Archive: special rules for games (see §10).

---

## 1) Games v2 (parent docs)

* **Content types:** `gameV2`
* **Alias:** `games-v2-w`
* **URL template:**
  `https://<osHost>/games-v2-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** `sys.environment == <env>` AND `sys.contentType.sys.id == "gameV2"`
* **Topics:** per env (see shared settings)

### Payload (exact fields)

```json
{
  "game_to_sitegame": { "name": "game" },
  "game": {
    "id": "{/payload/sys/id}",
    "contentType": "{/payload/sys/contentType/sys/id}",
    "entryTitle": "{/payload/fields/entryTitle}",
    "howToPlayContent": "{/payload/fields/howToPlayContent}",
    "imgUrlPattern": "{/payload/fields/imgUrlPattern}",
    "infoImgUrlPattern": "{/payload/fields/infoImgUrlPattern}",
    "infoDetails": "{/payload/fields/infoDetails}",
    "introductionContent": "{/payload/fields/introductionContent}",
    "loggedOutImgUrlPattern": "{/payload/fields/loggedOutImgUrlPattern}",
    "maxBet": "{/payload/fields/maxBet}",
    "minBet": "{/payload/fields/minBet}",
    "progressiveJackpot": "{/payload/fields/progressiveJackpot}",
    "representativeColor": "{/payload/fields/representativeColor}",
    "title": "{/payload/fields/title}",
    "launchCode": "{/payload/fields/launchCode}",
    "gamePlatformConfig": "{/payload/fields/gamePlatformConfig}",
    "funPanelBackgroundImage": "{/payload/fields/funPanelBackgroundImage}",
    "funPanelDefaultCategory": "{/payload/fields/funPanelDefaultCategory}",
    "funPanelEnabled": "{/payload/fields/funPanelEnabled}",
    "operatorBarDisabled": "{/payload/fields/operatorBarDisabled}",
    "rgpEnabled": "{/payload/fields/rgpEnabled}",
    "vendor": "{/payload/fields/vendor}",
    "platformVisibility": "{/payload/fields/platformVisibility}",
    "tags": "{/payload/fields/tags}",
    "meta": "{/payload/fields/meta}",
    "nativeRequirement": "{/payload/fields/nativeRequirement}",
    "videoUrlPattern": "{/payload/fields/videoUrlPattern}",
    "dfgWeeklyImgUrlPattern": "{/payload/fields/dfgWeeklyImgUrlPattern}",
    "webComponentData": "{/payload/fields/webComponentData}",
    "showNetPosition": "{/payload/fields/showNetPosition}",
    "cmsEnv": "{/payload/sys/environment/sys/id}",
    "createdAt": "{/payload/fields/createdAt}",
    "updatedAt": "{/payload/sys/updatedAt}",
    "bynderDFGWeeklyImage": "{/payload/fields/bynderDFGWeeklyImage}",
    "bynderGameInfoGameTile": "{/payload/fields/bynderGameInfoGameTile}",
    "bynderLoggedOutGameTile": "{/payload/fields/bynderLoggedOutGameTile}",
    "bynderLoggedInGameTile": "{/payload/fields/bynderLoggedInGameTile}",
    "bynderVideoGameTile": "{/payload/fields/bynderVideoGameTile}",
    "bynderFunPanelBackgroundImage": "{/payload/fields/bynderFunPanelBackgroundImage}",
    "animationMedia": "{/payload/fields/animationMedia}",
    "loggedOutAnimationMedia": "{/payload/fields/loggedOutAnimationMedia}",
    "foregroundLogoMedia": "{/payload/fields/foregroundLogoMedia}",
    "loggedOutForegroundLogoMedia": "{/payload/fields/loggedOutForegroundLogoMedia}",
    "backgroundMedia": "{/payload/fields/backgroundMedia}",
    "loggedOutBackgroundMedia": "{/payload/fields/loggedOutBackgroundMedia}"
  }
}
```

---

## 2) SiteGame v2 (child docs with routing)

* **Content types:** `siteGameV2`
* **Alias:** `games-v2-w` (same as games)
* **URL template (includes routing to parent):**
  `https://<osHost>/games-v2-w/_doc/{/payload/sys/id}?routing={/payload/fields/game/en-GB/sys/id}&<refresh>`
* **Filters:** `sys.environment == <env>` AND `sys.contentType.sys.id == "siteGameV2"`
* **Topics:** per env (see shared settings)

### Payload (exact fields)

```json
{
  "game_to_sitegame": {
    "name": "sitegame",
    "parent": "{/payload/fields/game/en-GB/sys/id}"
  },
  "siteGame": {
    "id": "{/payload/sys/id}",
    "contentType": "{/payload/sys/contentType/sys/id}",
    "entryTitle": "{/payload/fields/entryTitle}",
    "howToPlayContent": "{/payload/fields/howToPlayContent}",
    "chat": "{/payload/fields/chat}",
    "cmsEnv": "{/payload/sys/environment/sys/id}",
    "sash": "{/payload/fields/sash}",
    "tags": "{/payload/fields/tags}",
    "maxBet": "{/payload/fields/maxBet}",
    "minBet": "{/payload/fields/minBet}",
    "venture": "{/payload/fields/venture}",
    "headlessJackpot": "{/payload/fields/headlessJackpot}",
    "gameId": "{/payload/fields/game/en-GB/sys/id}",
    "createdAt": "{/payload/sys/createdAt}",
    "updatedAt": "{/payload/sys/updatedAt}",
    "showNetPosition": "{/payload/fields/showNetPosition}",
    "platformVisibility": "{/payload/fields/platformVisibility}",
    "environmentVisibility": "{/payload/fields/environmentVisibility}",
    "liveHidden": "{/payload/fields/liveHidden}"
  }
}
```

---

## 3) Game Sections (rails, carousels, jackpots, etc.)

* **Content types (regex):** `igGrid[A–G]Section|igCarouselA|igCarouselB|igJackpotsSection|igJackpotSectionsBlock|igSearchResults|igDfgSection|igGameShuffle`
* **Alias:** `game-sections-w`
* **URL template:** `https://<osHost>/game-sections-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + `regexp(sys.contentType.sys.id, <regex>)`
* **Topics:** per env (see shared settings)

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "platformVisibility": "{/payload/fields/platformVisibility}",
  "sessionVisibility": "{/payload/fields/sessionVisibility}",
  "environmentVisibility": "{/payload/fields/environmentVisibility}",
  "name": "{/payload/fields/name}",
  "venture": "{/payload/fields/venture}",
  "classification": "{/payload/fields/classification}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}",
  "title": "{/payload/fields/title}",
  "slug": "{/payload/fields/slug}",
  "games": "{/payload/fields/games}",
  "game": "{/payload/fields/game}",
  "sectionTruncation": "{/payload/fields/sectionTruncation}",
  "layoutType": "{/payload/fields/layoutType}",
  "viewAllActionText": "{/payload/fields/viewAllActionText}",
  "viewAllType": "{/payload/fields/viewAllType}",
  "viewAllAction": "{/payload/fields/viewAllAction}",
  "expandedSectionLayoutType": "{/payload/fields/expandedSectionLayoutType}",
  "image": "{/payload/fields/image}",
  "mediaLoggedIn": "{/payload/fields/mediaLoggedIn}",
  "mediaLoggedOut": "{/payload/fields/mediaLoggedOut}",
  "jackpotType": "{/payload/fields/jackpotType}",
  "headlessJackpot": "{/payload/fields/headlessJackpot}",
  "headerImage": "{/payload/fields/headerImage}",
  "backgroundImage": "{/payload/fields/backgroundImage}",
  "headerImageBynder": "{/payload/fields/headerImageBynder}",
  "backgroundImageBynder": "{/payload/fields/backgroundImageBynder}",
  "pot1ImageBynder": "{/payload/fields/pot1ImageBynder}",
  "pot2ImageBynder": "{/payload/fields/pot2ImageBynder}",
  "pot3ImageBynder": "{/payload/fields/pot3ImageBynder}",
  "pot1Image": "{/payload/fields/pot1Image}",
  "pot2Image": "{/payload/fields/pot2Image}",
  "pot3Image": "{/payload/fields/pot3Image}",
  "jackpots": "{/payload/fields/jackpots}",
  "media": "{/payload/fields/media}",
  "dynamicBackground": "{/payload/fields/dynamicBackground}",
  "dynamicLogo": "{/payload/fields/dynamicLogo}",
  "bynderMedia": "{/payload/fields/bynderMedia}",
  "bynderDynamicBackground": "{/payload/fields/bynderDynamicBackground}",
  "bynderDynamicLogo": "{/payload/fields/bynderDynamicLogo}",
  "link": "{/payload/fields/link}"
}
```

---

## 4) Views

* **Content types (regex):** `igView|igMiniGames`
* **Alias:** `views-w`
* **URL template:** `https://<osHost>/views-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + regex on contentType id
* **Topics:** per env (see shared settings)

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "name": "{/payload/fields/name}",
  "viewSlug": "{/payload/fields/viewSlug}",
  "platformVisibility": "{/payload/fields/platformVisibility}",
  "sessionVisibility": "{/payload/fields/sessionVisibility}",
  "environmentVisibility": "{/payload/fields/environmentVisibility}",
  "venture": "{/payload/fields/venture}",
  "sections": "{/payload/fields/sections}",
  "topContent": "{/payload/fields/topContent}",
  "primaryContent": "{/payload/fields/primaryContent}",
  "liveHidden": "{/payload/fields/liveHidden}",
  "classification": "{/payload/fields/classification}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}"
}
```

---

## 5) Navigation (trees & links)

* **Content types (regex):** `igNavigation|igLink|igQuickLinks`
* **Alias:** `navigation-w`
* **URL template:** `https://<osHost>/navigation-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + regex on contentType id
* **Topics:** per env (see shared settings)

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "layoutType": "{/payload/fields/layoutType}",
  "links": "{/payload/fields/links}",
  "bottomNavLinks": "{/payload/fields/bottomNavLinks}",
  "label": "{/payload/fields/label}",
  "view": "{/payload/fields/view}",
  "externalUrl": "{/payload/fields/externalUrl}",
  "internalUrl": "{/payload/fields/internalUrl}",
  "image": "{/payload/fields/image}",
  "bynderImage": "{/payload/fields/bynderImage}",
  "subMenu": "{/payload/fields/subMenu}",
  "platformVisibility": "{/payload/fields/platformVisibility}",
  "sessionVisibility": "{/payload/fields/sessionVisibility}",
  "environmentVisibility": "{/payload/fields/environmentVisibility}",
  "venture": "{/payload/fields/venture}",
  "liveHidden": "{/payload/fields/liveHidden}",
  "classification": "{/payload/fields/classification}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}"
}
```

---

## 6) Themes

* **Content types (regex):** `igTheme`
* **Alias:** `themes-w`
* **URL template:** `https://<osHost>/themes-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + regex on contentType id

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "image": "{/payload/fields/image}",
  "primaryColor": "{/payload/fields/primaryColor}",
  "secondaryColor": "{/payload/fields/secondaryColor}",
  "venture": "{/payload/fields/venture}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}"
}
```

---

## 7) Marketing Sections

* **Content types (regex):** `igMarketingSection|igBanner|igBrazePromosSection|igPromotionsGrid`
* **Alias:** `marketing-sections-w`
* **URL template:** `https://<osHost>/marketing-sections-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + regex on contentType id

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "platformVisibility": "{/payload/fields/platformVisibility}",
  "sessionVisibility": "{/payload/fields/sessionVisibility}",
  "environmentVisibility": "{/payload/fields/environmentVisibility}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}",
  "venture": "{/payload/fields/venture}",
  "title": "{/payload/fields/title}",
  "classification": "{/payload/fields/classification}",
  "layoutType": "{/payload/fields/layoutType}",
  "viewAllActionText": "{/payload/fields/viewAllActionText}",
  "viewAllType": "{/payload/fields/viewAllType}",
  "viewAllAction": "{/payload/fields/viewAllAction}",
  "banners": "{/payload/fields/banners}",
  "bynderMedia": "{/payload/fields/bynderMedia}",
  "imageUrl": "{/payload/fields/imageUrl}",
  "videoUrl": "{/payload/fields/videoUrl}",
  "representativeColor": "{/payload/fields/representativeColor}",
  "bannerLink": "{/payload/fields/bannerLink}",
  "displayType": "{/payload/fields/displayType}",
  "displaySize": "{/payload/fields/displaySize}"
}
```

---

## 8) ML Personalised Sections

* **Content types (regex):** `igSimilarityBasedPersonalisedSection|igCollabBasedPersonalisedSection`
* **Alias:** `ml-sections-w`
* **URL template:** `https://<osHost>/ml-sections-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + regex on contentType id

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "platformVisibility": "{/payload/fields/platformVisibility}",
  "sessionVisibility": "{/payload/fields/sessionVisibility}",
  "environmentVisibility": "{/payload/fields/environmentVisibility}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}",
  "venture": "{/payload/fields/venture}",
  "title": "{/payload/fields/title}",
  "classification": "{/payload/fields/classification}",
  "slug": "{/payload/fields/slug}",
  "games": "{/payload/fields/games}",
  "layoutType": "{/payload/fields/layoutType}",
  "type": "{/payload/fields/type}",
  "viewAllActionText": "{/payload/fields/viewAllActionText}",
  "viewAllType": "{/payload/fields/viewAllType}",
  "viewAllAction": "{/payload/fields/viewAllAction}",
  "expandedSectionLayoutType": "{/payload/fields/expandedSectionLayoutType}"
}
```

---

## 9) ML Defaults (fallback suggestions)

* **Content types (regex):** `igSuggestedGames`
* **Alias:** `ml-sections-defaults-w`
* **URL template:** `https://<osHost>/ml-sections-defaults-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + regex on contentType id

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "venture": "{/payload/fields/venture}",
  "games": "{/payload/fields/games}",
  "environmentVisibility": "{/payload/fields/environmentVisibility}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}"
}
```

---

## 10) Ventures

* **Content types:** `venture`
* **Alias:** `ventures-w`
* **URL template:** `https://<osHost>/ventures-w/_doc/{/payload/sys/id}?<refresh>`
* **Filters:** env + equals(`sys.contentType.sys.id`, `venture`)

### Payload (exact fields)

```json
{
  "id": "{/payload/sys/id}",
  "contentType": "{/payload/sys/contentType/sys/id}",
  "entryTitle": "{/payload/fields/entryTitle}",
  "name": "{/payload/fields/name}",
  "jurisdiction": "{/payload/fields/jurisdiction}",
  "cmsEnv": "{/payload/sys/environment/sys/id}",
  "updatedAt": "{/payload/sys/updatedAt}"
}
```

---

## 11) Archived Games (lifecycle topics)

* **Aliases:** `games-archived-w` (write), `games-archived-r` (read)
* **Topics:**

  * **Put into archive:** `Entry.archive` (dev/stg/prod)
  * **Remove from archive:** `Entry.publish` (dev/stg/prod)
* **Notes:** Pair these with standard game hooks; on **archive**, index into `games-archived-w`; on **publish**, delete from archive (and ensure primary `games-v2-w` reflects the latest).

---

### Hook naming & uniqueness

* **Hook names** are derived as `createHookName(nodeEnv, WEBHOOK_SUFFIX)`, e.g., `gamesV3`, `siteGamesV3`, `navigation`, etc. (per-use in each `*HookBodyParams`).
* **Unique id** to identify this integration set in Contentful: `"lobby-openSearch"`.

---

