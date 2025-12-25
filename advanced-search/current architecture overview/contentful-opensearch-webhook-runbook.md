# Contentful - OpenSearch Webhook Runbook (per environment)

## TL;DR

* **Write aliases** only (`*-w`), **Basic Auth** to OpenSearch, add `X-Query-Metadata` for traceability. &#x20;
* **Refresh policy:** dev/stg `wait_for`; prod `true`.&#x20;
* **Topics:** Prod = `publish|unpublish`; Dev/Stg also `save|auto_save`. Games have **archive rules**. &#x20;
* **Join:** `gameV2` (parent) ↔ `siteGameV2` (child) with **routing=<gameId>**. &#x20;

---

## 0) Pre-reqs (once)

1. **Indices & write aliases exist:**
   `games-v2-w`, `game-sections-w`, `views-w`, `navigation-w`, `themes-w`, `marketing-sections-w`, `ml-sections-w`, `ml-sections-defaults-w`, `ventures-w`, `games-archived-w`.&#x20;
2. `games-v2` mapping has **join field** `game_to_sitegame: game→sitegame`.&#x20;
3. OpenSearch endpoint reachable from Contentful; **Basic Auth** credentials available.&#x20;

---

## 1) Per-Environment Settings

### Dev / Staging

* **Refresh:** `wait_for` (cheaper, still read-after-write for tests).&#x20;
* **Topics:** `Entry.save`, `Entry.auto_save`, `Entry.publish`, `Entry.unpublish`.&#x20;
* **Use when:** rapid iteration; expect noisy saves.

### Production

* **Refresh:** `true` (immediate visibility in search).&#x20;
* **Topics:** `Entry.publish`, `Entry.unpublish` (+ **archive/publish** rules for games). &#x20;
* **Use when:** live traffic; minimize event noise.

---

## 2) Webhook Matrix (create one hook per row)

| Family            | Content types (filter)          | OpenSearch write alias   | URL pattern (append `?refresh=<per-env>`)  | Notes                                                                        |
| ----------------- | ------------------------------- | ------------------------ | ------------------------------------------ | ---------------------------------------------------------------------------- |
| Games (parent)    | `gameV2`                        | `games-v2-w`             | `/{alias}/_doc/{entryId}`                  | Sets join root: `game_to_sitegame: { name: "game" }`.                        |
| SiteGames (child) | `siteGameV2`                    | `games-v2-w`             | `/{alias}/_doc/{entryId}?routing={gameId}` | Child doc: `{ name: "sitegame", parent: "{gameId}" }`. **Routing required.** |
| Sections          | See `SECTIONS_REGEX` (below)    | `game-sections-w`        | `/{alias}/_doc/{entryId}`                  | Lobby rails, jackpots, search results, shuffles.                             |
| Views             | See `VIEWS_REGEX` (below)       | `views-w`                | `/{alias}/_doc/{entryId}`                  | Page & mini-view models.                                                     |
| Navigation        | See `NAV_REGEX` (below)         | `navigation-w`           | `/{alias}/_doc/{entryId}`                  | Trees and leaf links.                                                        |
| Themes            | `igTheme`                       | `themes-w`               | `/{alias}/_doc/{entryId}`                  | Brand/skin configuration.                                                    |
| Marketing         | See `MARKETING_REGEX` (below)   | `marketing-sections-w`   | `/{alias}/_doc/{entryId}`                  | Promo rails, banners, Braze promos.                                          |
| ML Sections       | See `ML_SECTIONS_REGEX` (below) | `ml-sections-w`          | `/{alias}/_doc/{entryId}`                  | Personalised sections.                                                       |
| ML Defaults       | `igSuggestedGames`              | `ml-sections-defaults-w` | `/{alias}/_doc/{entryId}`                  | Fallback suggestions.                                                        |
| Ventures          | `venture`                       | `ventures-w`             | `/{alias}/_doc/{entryId}`                  | Brand/jurisdiction metadata.                                                 |

### Regex filters (reference)

```text
SECTIONS_REGEX:
  igGrid[A-G]Section|igCarouselA|igCarouselB|igJackpotsSection|igJackpotSectionsBlock|igSearchResults|igDfgSection|igGameShuffle

VIEWS_REGEX:
  igView|igMiniGames

NAV_REGEX:
  igNavigation|igLink|igQuickLinks

MARKETING_REGEX:
  igMarketingSection|igBanner|igBrazePromosSection|igPromotionsGrid

ML_SECTIONS_REGEX:
  igSimilarityBasedPersonalisedSection|igCollabBasedPersonalisedSection
```

**Shared filters on every hook**

* Match the target **Contentful environment** (e.g., `sys.environment.sys.id == "prod"`).
* Apply the **content type** filter from the table (equals or the regex above).

**Shared topics by environment**

* **Dev/Stg:** `Entry.save`, `Entry.auto_save`, `Entry.publish`, `Entry.unpublish`
* **Prod:** `Entry.publish`, `Entry.unpublish` (plus archive/publish rules for games)

## 3) Payloads (what each hook sends)

* **Games:** rich game metadata + join root. &#x20;
* **SiteGames:** site-level flags (venture, visibility, tags, jackpot), `{parent, routing}` set to `gameId`. &#x20;
* **Sections/Views/Navigation/Themes/Marketing/ML/Ventures:** denormalised fields exactly as modeled in CMS (ids, slugs, visibility triplet, layout, media, links, classification, venture, updatedAt, cmsEnv).    &#x20;

> Tip: Keep OpenSearch mappings aligned to avoid dynamic mapping bloat.

---

## 4) Special Lifecycle: Archived Games (all envs)

* **On `Entry.archive` (game):** index doc into `games-archived-w`.
* **On `Entry.publish`:** remove from archive (and index fresh to `games-v2-w`).
* **Aliases:** `games-archived-w` (write), `games-archived-r` (read). &#x20;

---

## 5) Create/Update Hooks (checklist)

1. **Name & uniqueness:** use consistent suffixes; unique id `"lobby-openSearch"`.&#x20;
2. **URL:** `https://<osHost>/{alias}/_doc/{id}[?routing=<gameId>]&refresh=<per-env>` (routing only for **siteGameV2**).&#x20;
3. **Headers:** Basic Auth + `X-Query-Metadata` (`type`, `contentType`).&#x20;
4. **Filters:** `env == <targetEnv>` AND content type equals/regex per matrix.&#x20;
5. **Topics:** set per **Dev/Stg** or **Prod** (see §1).&#x20;

---

## 6) Validate (per deployment)

* **Smoke (each family):** publish a tiny change → confirm doc in correct `*-w` alias within expected refresh window.&#x20;
* **Parent/child:** publish `gameV2`, then `siteGameV2`; check `_explain` shows same shard via `routing`.&#x20;
* **Archive:** archive a `gameV2` → doc appears in `games-archived-w`; re-publish → removed.&#x20;
* **Observability:** verify `X-Query-Metadata` shows `type` & `contentType` in logs/ingest metrics.&#x20;

---

## 7) Rollback & Troubleshooting

* **Bad mapping / ingestion errors:** point write alias to previous index version; re-queue by re-publishing entries.&#x20;
* **Missing siteGame children:** ensure `routing` and `parent` are set (child writes will otherwise scatter). &#x20;
* **Too many events in non-prod:** temporarily remove `save`/`auto_save` topics.&#x20;
* **Security:** if Basic Auth from the public Internet is a concern, front OS with API Gateway + WAF (keep URL/query semantics identical).&#x20;

---
