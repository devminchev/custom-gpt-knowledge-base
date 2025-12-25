Practical, up-to-date guide to the Contentful App Framework—and especially **App Functions**—covering what they are, when to use them, how to build, deploy, and operate them, plus limits, examples, and gotchas.

# 1) What the App Framework gives you

**Apps** are installable packages that customize the Contentful web app (UI) and/or automate work in the backend. They’re defined once at the org level and installed per space/environment. Apps can render UI (in iFrames at specific “locations”), subscribe to content lifecycle events, call the CMA with their own identity, and bundle **Functions** (serverless code) that run on Contentful’s platform. ([contentful.com][1])

Key building blocks:

- **App Definition & Bundle**: the app’s metadata and its uploaded build artifacts (hosted by Contentful or externally). ([contentful.com][2])
- **App Locations**: where UI renders (Entry Field, Entry Sidebar, Entry Editor, Dialog, Page, Home, App Config). ([contentful.com][1])
- **App SDK**: client API your UI uses to talk to the host editor and (optionally) the CMA via `sdk.cmaAdapter`. ([contentful.com][3])
- **App Identity**: lets your app act as itself (not a human user) against the CMA using short-lived “app access tokens.” ([contentful.com][4])
- **App Events & App Actions**: event subscriptions and callable actions that wire your app to Contentful and other apps. ([contentful.com][5])
- **App Functions**: serverless, platform-hosted logic you attach to event flows or call from Actions or the GraphQL resolver path. ([contentful.com][6])

# 2) What App Functions are (and why they matter)

**Functions** are sandboxed serverless workloads running on Contentful’s infrastructure. Use them to:

- **Resolve data at delivery time** (GraphQL “external references”) so editors store IDs/URLs and your function fetches full objects into `_data` fields.
- **React to content events** without running your own server—filter, transform, or handle App Events.
- **Expose callable backends** behind App Actions for frontends or other apps. ([contentful.com][6])

Recent highlight: Contentful formally emphasizes **App Event functions** for “intercept, filter, transform, respond” to content lifecycle events, reducing reliance on external webhook consumers. (Announced June 27, 2025.) ([contentful.com][7])

> Availability: Functions are a **Premium plans & Partners** feature. Check your plan’s usage limits. ([contentful.com][8])

# 3) Function types (what you can build)

Within one codebase you can support multiple types; the **“kitchen-sink”** template scaffolds them together. ([contentful.com][6])

1. **Custom / Native External References (GraphQL resolution)**

   - Events your function accepts: `graphql.field.mapping`, `graphql.query`, etc.
   - Used to map a Contentful field to a GraphQL type and fetch the referenced external data into `<field>_data`. ([contentful.com][6])

2. **App Event Functions**

   - **Filter** (decide whether an event proceeds), **Transformation** (mutate headers/body before request signing), **Handler** (replace the HTTP target; run your code directly). ([contentful.com][6])

3. **App Action Functions**

   - A callable endpoint behind an **App Action** used by your UI or other apps. ([contentful.com][6])

# 4) Typical use cases

- **Editorial UI enhancements**: custom field editors, sidebars, dialogs, dashboards (Page/Home). ([contentful.com][1])
- **Workflow automation**: auto-tagging, quality checks, CI/CD triggers, cache invalidation—now easily done with App Event functions. ([contentful.com][5])
- **Integration at delivery time**: show live product/pricing from a commerce API using GraphQL external references. ([contentful.com][6])
- **Cross-app communication**: publish an **App Action** and let other apps call it; back it with an Action Function. ([contentful.com][9])

# 5) Developer workflow (scaffold → code → upload → install → enable)

1. **Scaffold** using `create-contentful-app`:

```bash
# Start a new app with a function template
npx create-contentful-app@latest my-app --function appevent-handler
# Or generate a full example
npx create-contentful-app@latest my-app --example function-appaction
```

Templates/examples include code, the **app manifest**, and scripts. ([contentful.com][10])

2. **Understand the app manifest** (`contentful-app-manifest.json`):

- Each function declares `id`, `entryFile`, `path`, `accepts` (event types it can process), and **`allowNetworks`** (domains/IPs/ports you’re permitted to call). ([contentful.com][10])

3. **Write the handler** (TypeScript shown):

```ts
import { FunctionEventHandler, FunctionTypeEnum } from "@contentful/node-apps-toolkit";

export const handler: FunctionEventHandler<FunctionTypeEnum.AppEventFilter> = async (event, context) => {
  // Decide whether to pass this event through
  const shouldAllow = true; // your logic
  return { result: shouldAllow };
};
```

The **context** includes helpers (e.g., CMA client options) and IDs for the current space/environment. ([contentful.com][10])

4. **Build & upload** (creates an **AppBundle** and registers functions):

```bash
npm run build
npm run upload
```

> Apps **with functions must be uploaded via CLI** (the web UI upload won’t create functions). ([contentful.com][10])

5. **Install** the app in the target space/environment (web app, CLI, or CMA). ([contentful.com][10])

6. **Enable and trigger** your functions depending on type:

- **External references**: enable “Resolve content on delivery” on the field and query `<field>_data` via GraphQL. ([contentful.com][10])
- **App Events**: link Filter/Transformation/Handler functions in the app’s **Events** tab; or via CMA. ([contentful.com][5])
- **App Actions**: create an App Action and connect it to your Action Function. ([contentful.com][6])

# 6) Frontend app essentials

- **Locations & initialization**
  Use the **App SDK** to detect location and interact with entries/fields/dialogs, etc.

  ```ts
  import { init, locations } from "@contentful/app-sdk";
  init((sdk) => {
    if (sdk.location.is(locations.LOCATION_ENTRY_SIDEBAR)) {
      // read/write via sdk.entry / sdk.field, open dialogs, notify, etc.
    }
  });
  ```

  Full list of locations and APIs is in the SDK reference. ([contentful.com][3])

- **CMA from the UI (no token handling)**

  ```ts
  import { createClient } from "contentful-management";
  const cma = createClient(
    { apiAdapter: sdk.cmaAdapter },
    {
      type: "plain",
      defaults: { spaceId: sdk.ids.space, environmentId: sdk.ids.environmentAlias ?? sdk.ids.environment },
    }
  );
  ```

  This uses the app installation’s authorization automatically. ([contentful.com][3])

# 7) Backend options: App Events, Identities, and Functions

- **App Events** let you subscribe to content and settings changes (similar to webhooks but managed per app). Configure in the app definition; you can target your server **or** attach Functions (Filter/Transformation/Handler). ([contentful.com][5])
- **App Identity** provides short-lived app tokens so your backend or function can call the CMA; actions are attributed to the app in UI and APIs. ([contentful.com][4])
- **Functions** let you eliminate hosting for many cases; use them as the App Event target or as App Action backends. ([contentful.com][6])

# 8) Hosting & deployment

- **Hosted by Contentful**: upload static builds as App Bundles; max **10 MB** and **500 files** per upload; promote/rollback versions. ([contentful.com][11])
- **External hosting**: toggle off “Hosted by Contentful” and provide a public URL. ([contentful.com][11])
- **CI/CD**: official GitHub Action `contentful/actions-app-deploy@v1` to upload & promote after building. ([contentful.com][2])

# 9) Limits, usage & runtime notes (2025)

- **Plan availability**: Functions are Premium/Partners only. ([contentful.com][8])
- **Function platform usage**: executions/month subject to **Technical Limits** & **Usage Limits** (Contentful introduced a “soft limits” period in 2025; check current status). ([contentful.com][6])
- **Runtime constraints** (selected):

  - No filesystem access; payload limit \~**32 MB** for incoming events and for the built-in CMA client requests/responses.
  - Limited CPU/memory; exceeding ends execution (no automatic retry).
  - Node/Web APIs support is curated (e.g., Streams, Crypto supported; HTTP/HTTPS built-ins not supported—use **allowNetworks** to reach external services via the platform’s fetch). See the Functions page for the latest table. ([contentful.com][6])

- **App counts / installs**: total apps and installations are plan-limited; orgs can generally create up to **250 app definitions** and install up to **50 apps per environment** (see Technical Limits for your plan). ([contentful.com][12])

# 10) API & GraphQL behaviors to expect with Functions

- **External References in GraphQL**
  When a field is enabled for resolution, your schema exposes `<field>` and `<field>_data`. Your function handles schema mapping and data fetching via the GraphQL events; Contentful triggers mapping & query events (including introspection). ([contentful.com][6])
- **App Events pipeline**
  Filter → Transformation → (Signed) Request/Handler. You can attach any combination; Handler replaces the outgoing request entirely. ([contentful.com][5])

# 11) Code patterns you can reuse

**A) App Event Filter function**

```ts
import { FunctionEventHandler, FunctionTypeEnum } from "@contentful/node-apps-toolkit";

export const handler: FunctionEventHandler<FunctionTypeEnum.AppEventFilter> = async (event) => {
  // Only allow publish events from the "blogPost" content type
  const topic = event.headers["x-contentful-topic"] ?? "";
  const isPublish = topic.endsWith(".publish");
  const isBlogPost = JSON.parse(event.body ?? "{}")?.sys?.contentType?.sys?.id === "blogPost";
  return { result: isPublish && isBlogPost };
};
```

Wire this function to your app’s **Events** tab as a Filter. ([contentful.com][10])

**B) App Action Function + calling it from your UI**

- Create an App Action in your app definition.
- Link it to an **App Action function**; from your UI, trigger it via the App SDK (or call it from another app). ([contentful.com][6])

**C) CMA inside a Function (App Identity)**
The function **context** provides CMA client options & defaults; you can init `contentful-management` and act as the app:

```ts
import * as contentful from "contentful-management";

export const handler = async (event, context) => {
  const cma = contentful.createClient(context.cmaClientOptions, {
    type: "plain",
    defaults: { spaceId: context.spaceId, environmentId: context.environmentId },
  });
  // e.g., add a tag or comment
  await cma.entry.update(
    { entryId: "..." },
    {
      fields: {
        /*...*/
      },
    }
  );
  return { result: "ok" };
};
```

Size note: the pre-initialized client in context is limited to \~32 MB requests/responses. ([contentful.com][6])

**D) External References mapping snippet**
Handle `graphql.field.mapping` to declare what type `<field>_data` exposes, and `graphql.query` to fetch data for the incoming IDs. ([contentful.com][6])

# 12) Operational tips & best practices

- **Prefer Functions over bespoke servers** for event workflows; keep custom servers for long-running workloads or heavy dependencies. ([contentful.com][6])
- **Keep bundles slim** (≤10 MB, ≤500 files) and avoid shipping server-only packages into the UI. ([contentful.com][11])
- **Use installation parameters** for per-environment config (API keys, content type IDs). ([contentful.com][13])
- **Attribute changes**: when using App Identity (backend/functions), the UI shows the app as the actor in “Author/Last edited.” ([contentful.com][4])
- **CI/CD**: automate deploys with the official GitHub Action; promote/rollback bundles like you would releases. ([contentful.com][2])
- **UI integration quality**: use the App SDK’s dialogs, notifier, navigator, etc., instead of custom popups; respect location constraints. ([contentful.com][3])

# 13) When to choose Apps + Functions vs. UI Extensions or Webhooks

- Build **new** extensions as **Apps** (superset of UI Extensions with better packaging, identities, events, hosting). ([contentful.com][14])
- Prefer **App Events + Functions** over plain webhooks for app-scoped, portable automation that’s easy to reuse across environments. ([contentful.com][5])
- Use **webhooks** where a project already relies on external consumers and you don’t want to migrate; Functions can still help as Filters/Transformations. ([contentful.com][5])

# 14) Publishing to the Marketplace (if relevant)

If you intend to list publicly, Contentful outlines requirements (support, security, and—since Jan 2024—open-source hosting in the **Marketplace Partner Apps** repo). Review the publishing guide before you build. ([contentful.com][15])

# 15) Quick checklist to get started

1. **Scaffold**: `npx create-contentful-app@latest my-app --function kitchen-sink`. ([contentful.com][10])
2. **Develop UI** with **App SDK** and add **Functions** via `@contentful/app-scripts generate-function`. ([contentful.com][10])
3. **Upload** with `npm run build && npm run upload`. (CLI upload required for functions.) ([contentful.com][10])
4. **Install** the app in your space/env and **enable** Functions in the Events tab or field settings (for external references). ([contentful.com][5])
5. **Automate deploys** with the official GitHub Action. ([contentful.com][2])

---

If you tell me your use case (e.g., “auto-tag news on publish,” “pull product data into GraphQL,” or “one-click image optimization”), I’ll sketch the **exact app + function type**, the **event wiring**, and sample code to ship it.

[1]: https://www.contentful.com/developers/docs/extensibility/app-framework/ "App Framework | Contentful"
[2]: https://www.contentful.com/developers/docs/extensibility/app-framework/deploy-app/ "Deploy a custom app | Contentful"
[3]: https://www.contentful.com/developers/docs/extensibility/app-framework/sdk/ "App SDK Reference | Contentful"
[4]: https://www.contentful.com/developers/docs/extensibility/app-framework/app-identity/ "App Identity | Contentful"
[5]: https://www.contentful.com/developers/docs/extensibility/app-framework/app-events/ "App Events | Contentful"
[6]: https://www.contentful.com/developers/docs/extensibility/app-framework/functions/ "Functions | Contentful"
[7]: https://www.contentful.com/blog/serverless-functions-code-content/?utm_source=chatgpt.com "Bring your code closer to content with serverless functions ..."
[8]: https://www.contentful.com/help/functions/?utm_source=chatgpt.com "Functions | Contentful Help Center"
[9]: https://www.contentful.com/developers/docs/extensibility/app-framework/app-actions/?utm_source=chatgpt.com "App Actions"
[10]: https://www.contentful.com/developers/docs/extensibility/app-framework/working-with-functions/ "Working with Functions | Contentful"
[11]: https://www.contentful.com/developers/docs/extensibility/app-framework/hosting-an-app/ "Hosting an app | Contentful"
[12]: https://www.contentful.com/faq/extensibility/?utm_source=chatgpt.com "FAQ / Extensibility"
[13]: https://www.contentful.com/developers/docs/extensibility/app-framework/app-parameters/?utm_source=chatgpt.com "App Parameters"
[14]: https://www.contentful.com/help/apps/contentful-app-framework-faq/?utm_source=chatgpt.com "App Framework FAQ"
[15]: https://www.contentful.com/developers/docs/extensibility/app-framework/publishing-an-app/?utm_source=chatgpt.com "Publishing an app"
