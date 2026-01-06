---
title: "Contentful CMS Custom Apps Architecture"
tags: [contentful-models]
aliases: []
---
# Contentful CMS Custom Apps Architecture

## High level architecture – External → Contentful → AWS → Monitoring
```mermaid

flowchart LR
  subgraph External
    WH[Whitehat backoffice]
    CIS[Contentful integration scripts]
  end

  subgraph Contentful
    CFBO[Contentful backoffice models and data]
    CFEU[Contentful editor UI]
    CA[Custom apps suite]
    ADM[Contentful admin dashboard app]
    WHK[Webhooks DEV STG PROD]
  end

  subgraph AWS
    API[API gateway]
    LBL[Lobby lambdas]
    OS[OpenSearch clusters DEV STG PROD]
    CW[Cloudwatch and dashboards]
  end

  subgraph Monitoring
    WM[Webhooks monitor cron]
    SP[Splunk instance]
  end

  WH -->|Game catalogue data| CIS
  CIS -->|Create update Game V2 and SiteGame V2| CFBO

  CFEU -->|Editors manage entries| CFBO
  CA -->|Enhance editor UX and validations| CFEU

  ADM -->|Admin views and actions| CFBO

  CFBO -->|Publish events| WHK
  WHK -->|Index and sync| OS

  API --> LBL
  LBL -->|Read denormalised docs| OS
  LBL --> CW

  WHK -->|Webhook logs| WM
  WM -->|Push logs and metrics| SP
  CW -->|Selected logs| SP
```

## Contentful internals – models, custom apps, and webhooks
```mermaid
flowchart TB
  subgraph Contentful backoffice
    GV[Game V2 model]
    SG[SiteGame V2 model]
    IV[IG view model]
    SEC[IG grid and carousel sections]
    JP[IG jackpot section models]
    ML1[Similarity based personalised section]
    ML2[Collab based personalised section]
    MKT[IG marketing section models]
  end

  subgraph Editor tooling
    CFEU[Contentful editor UI]
    PCMA[Platform config metadata app]
    GMSB[Game metadata sync bot]
    HJ[Headless jackpot app]
    CFF[Conditional flexible fields app]
    RG[Recommended games app]
    ADM[Contentful admin dashboard app]
  end

  subgraph Integration
    WHK[Webhooks DEV STG PROD]
  end

  %% Editors and apps over models
  CFEU --> GV
  CFEU --> SG
  CFEU --> IV
  CFEU --> SEC
  CFEU --> JP
  CFEU --> ML1
  CFEU --> ML2
  CFEU --> MKT

  PCMA --> CFEU
  GMSB --> CFEU
  HJ --> CFEU
  CFF --> CFEU
  RG --> CFEU

  ADM --> GV
  ADM --> SG
  ADM --> SEC

  %% Webhooks on key models
  GV -->|Publish events| WHK
  SG -->|Publish events| WHK
  IV -->|Publish events| WHK
  SEC -->|Publish events| WHK
  JP -->|Publish events| WHK
  ML1 -->|Publish events| WHK
  ML2 -->|Publish events| WHK
  MKT -->|Publish events| WHK

```

## Runtime side – webhooks, indexing and lobby API

```mermaid
flowchart LR
  subgraph Contentful
    WHK[Webhooks DEV STG PROD]
  end

  subgraph Indexing lambdas
    WHL[Webhook handler lambdas]
  end

  subgraph OpenSearch
    GIDX[game sections index]
    MLIDX[ml personalised sections indexes]
    MKTIDX[marketing sections index]
    VIDX[views index]
    NIDX[navigation index]
    GMIDX[games v2 index]
    VXIDX[ventures index]
  end

  subgraph Lobby api
    API[API gateway]
    LBL[Lobby lambdas]
    CW[Cloudwatch dashboards]
  end

  WHK -->|Entry change payload| WHL
  WHL -->|Upsert section docs| GIDX
  WHL -->|Upsert ml docs| MLIDX
  WHL -->|Upsert marketing docs| MKTIDX
  WHL -->|Upsert view docs| VIDX
  WHL -->|Upsert nav docs| NIDX
  WHL -->|Upsert game docs| GMIDX
  WHL -->|Upsert venture docs| VXIDX

  API --> LBL
  LBL -->|Query indexes| GIDX
  LBL --> MLIDX
  LBL --> MKTIDX
  LBL --> VIDX
  LBL --> NIDX
  LBL --> GMIDX
  LBL --> VXIDX
  LBL --> CW
```

## End to end sequence – from external game change to lobby response

```
sequenceDiagram
  participant WH as Whitehat backoffice
  participant CIS as Integration scripts
  participant CF as Contentful
  participant APP as Custom apps and editor
  participant WHK as Webhook endpoint
  participant IDX as Indexer lambda
  participant OS as OpenSearch
  participant API as API gateway
  participant LBL as Lobby lambda
  participant CL as Client app

  WH->>CIS: Game change or new game
  CIS->>CF: Create update Game V2 and SiteGame V2
  APP->>CF: Editor adjusts IG views and sections
  CF-->>WHK: Webhook call on publish or update

  WHK->>IDX: Normalised event payload
  IDX->>CF: Fetch full entry and links
  IDX->>OS: Upsert documents in modelling indexes
  OS-->>IDX: Acknowledge write

  CL->>API: Request lobby view for venture and context
  API->>LBL: Forward request
  LBL->>OS: Query views and sections for venture
  OS-->>LBL: Denormalised section docs
  LBL-->>CL: Response with lobby layout and games
```

## System context — External → Contentful → AWS
flowchart LR
  subgraph External
    WH[Whitehat backoffice]
    CIS[Contentful integration scripts]
  end

  subgraph Contentful
    CB[Contentful backoffice models and data]
    CE[Contentful editor UI]
    CA[Custom apps]
    CAD[Contentful admin dashboard app]
    WHK[Webhooks DEV STG PROD]
    WM[Webhooks monitor cron]
  end

  subgraph AWS[AWS STG PROD]
    API[API gateway]
    LAM[Lobby lambdas]
    OS[OpenSearch domain]
    CW[Cloudwatch dashboards]
  end

  subgraph Observability
    SPL[Splunk instance]
  end

  WH -->|Game data| CIS
  CIS -->|Create and update GameV2 and SiteGameV2| CB

  CE -->|Editors manage entries| CB
  CA -->|Enhance validation and UI| CE
  CAD -->|Read data from environments| CB

  CB -->|Emit content change webhooks| WHK
  WHK -->|Index documents| OS

  WM -->|Read webhook logs| WHK
  WM -->|Send aggregated events| SPL

  API -->|Invoke lobby endpoints| LAM
  LAM -->|Query game and section indexes| OS
  LAM -->|Send runtime metrics| CW

  CW -->|Forward selected logs| SPL
```

## Contentful apps and models landscape

```mermaid
graph TD
  subgraph Contentful_Backoffice
    CB[Contentful backoffice]
    GV[Game V2 entries]
    SG[SiteGame V2 entries]
    IV[IG view entries]
    SECT[IG grid and section entries]
  end

  subgraph Custom_Apps
    PCM[Platform config metadata app]
    GMS[Game metadata sync bot]
    HJ[Headless jackpot app]
    CFF[Conditional flexible fields app]
    RG[Recommended games app]
  end

  subgraph Editor
    CE[Contentful editor UI]
  end

  CE --> CB

  PCM --> CE
  GMS --> CB
  HJ --> CE
  CFF --> CE
  RG --> CE

  CB --> GV
  CB --> SG
  CB --> IV
  CB --> SECT
```

## Game ingestion flow — Whitehat → Contentful → OpenSearch
```
sequenceDiagram
  participant WH as Whitehat backoffice
  participant CIS as Integration scripts
  participant CB as Contentful backoffice
  participant WHK as Contentful webhooks
  participant WHH as Webhook handler lambda
  participant OS as OpenSearch

  WH->>CIS: Export game metadata
  CIS->>CIS: Transform to GameV2 and SiteGameV2 schema
  CIS->>CB: Create or update GameV2 entry
  CIS->>CB: Create or update SiteGameV2 entry

  CB->>WHK: Publish events for GameV2 and SiteGameV2
  WHK->>WHH: Deliver webhook payload
  WHH->>CB: Fetch latest entry data if required
  WHH->>OS: Upsert game document into games v2 index
```

## Content change flow — Editor publish → Webhook → OS → Lobby API

```mermaid
sequenceDiagram
  participant Editor as Editor
  participant CE as Contentful editor UI
  participant App as Custom app
  participant CB as Contentful backoffice
  participant WHK as Contentful webhooks
  participant WHH as Webhook handler lambda
  participant OS as OpenSearch
  participant API as Lobby lambda API
  participant Client as Client app

  Editor->>CE: Edit IG view or section
  CE->>App: Run client side validations
  App-->>CE: Validation result and warnings
  CE->>CB: Save and publish entry

  CB->>WHK: Emit publish webhook
  WHK->>WHH: Send webhook payload
  WHH->>CB: Optionally fetch linked entries
  WHH->>OS: Upsert denormalised document

  Client->>API: Request lobby view for venture
  API->>OS: Query views and sections indexes via read aliases
  OS-->>API: Matched view and section documents
  API-->>Client: Assembled lobby response
```

## Deployment pipeline — GitHub → SAM → CloudFormation → AWS

### High level flow
```mermaid
flowchart LR
  Dev[Developer] --> GH[GitHub repo]
  GH --> CI[CI pipeline]
  CI --> SAM[SAM CLI build and package]
  SAM --> CFN[CloudFormation stack change set]
  CFN --> AWSDEV[AWS NA Dev account]
  CFN --> AWSSTG[AWS STG account]
  CFN --> AWSPROD[AWS Prod account]
```

### Detailed sequence for a change

```mermaid
sequenceDiagram
  participant Dev as Developer
  participant GH as GitHub
  participant CI as CI pipeline
  participant SAM as SAM CLI
  participant CFN as CloudFormation
  participant AWS as AWS environments

  Dev->>GH: Push code for lambdas or webhooks
  GH->>CI: Trigger pipeline run
  CI->>SAM: Build and package application
  SAM->>CFN: Generate and upload stack template
  CFN->>AWS: Apply stack in target account and stage
  AWS-->>CFN: Stack creation or update result
  CFN-->>CI: Deployment status
  CI-->>Dev: Notify success or failure
```