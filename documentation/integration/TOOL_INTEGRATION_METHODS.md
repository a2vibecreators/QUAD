# QUAD Platform - Tool Integration Methods

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** Complete reference for all tool integrations (API, Webhook, Polling)

---

## Overview

QUAD Platform integrates with 40+ industry-standard tools. This document lists each tool's integration capabilities:

- **API Access** - Can we query data programmatically?
- **Webhook Support** - Can tool push events to us?
- **Polling Strategy** - How often do we poll (if no webhooks)?
- **Authentication** - OAuth, API tokens, etc.
- **QUAD Platform Status** - ✅ Implemented, 🔜 Planned, ❌ Not supported

---

## Integration Strategy

**Self-Hosted Deployment (Our Choice):**
- ✅ Polling (30-second interval, configurable)
- ❌ Webhooks (requires customer to expose our endpoint to their firewall)

**Why Polling?**
- No firewall configuration needed
- Works in air-gapped environments
- Customer controls refresh rate (30s, 1min, 5min)
- Simpler security model (outbound only)

---

## Source Control Tools

### 1. GitHub

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v3, GraphQL v4 |
| **Webhooks** | ✅ Yes (but we use polling instead) |
| **Authentication** | OAuth App, Personal Access Token (PAT), GitHub App |
| **QUAD Uses** | Polling (30s interval) |
| **Data Access** | Repositories, Pull Requests, Issues, Commits, Branches, Reviews |
| **Rate Limits** | 5,000 req/hour (authenticated), 60 req/hour (unauthenticated) |
| **QUAD Status** | ✅ Implemented |

**API Endpoints Used:**
```
GET /repos/{owner}/{repo}/pulls
GET /repos/{owner}/{repo}/issues
GET /repos/{owner}/{repo}/commits
GET /repos/{owner}/{repo}/branches
```

**Polling Strategy:**
- Poll every 30 seconds (configurable)
- Use `If-Modified-Since` header to reduce API calls
- Cache ETags to detect changes

---

### 2. GitLab

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v4, GraphQL |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | OAuth 2.0, Personal Access Token |
| **QUAD Uses** | Polling (30s interval) |
| **Data Access** | Projects, Merge Requests, Issues, Pipelines, Commits |
| **Rate Limits** | 600 req/minute (SaaS), unlimited (self-hosted) |
| **QUAD Status** | ✅ Implemented |

**API Endpoints Used:**
```
GET /projects/{id}/merge_requests
GET /projects/{id}/issues
GET /projects/{id}/repository/commits
GET /projects/{id}/pipelines
```

---

### 3. Bitbucket

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v2.0 |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | OAuth 2.0, App Password |
| **QUAD Uses** | Polling (30s interval) |
| **Data Access** | Repositories, Pull Requests, Issues, Commits, Branches |
| **Rate Limits** | 1,000 req/hour (varies by plan) |
| **QUAD Status** | ✅ Implemented |

---

### 4. Azure Repos (Azure DevOps)

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v6.0 |
| **Webhooks** | ✅ Service Hooks (but we use polling) |
| **Authentication** | PAT (Personal Access Token), OAuth 2.0 |
| **QUAD Uses** | Polling (30s interval) |
| **Data Access** | Repositories, Pull Requests, Commits, Branches, Work Items |
| **Rate Limits** | Rate limit based on Azure DevOps service tier |
| **QUAD Status** | 🔜 Planned (Phase 2) |

---

## Project Management Tools

### 5. Jira (Atlassian)

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v3, Jira Cloud Platform API |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | OAuth 2.0 (3LO), API Token (Basic Auth) |
| **QUAD Uses** | Polling (30s interval) |
| **Data Access** | Issues, Sprints, Boards, Projects, Comments, Workflows |
| **Rate Limits** | 10 req/second (Jira Cloud), unlimited (self-hosted) |
| **QUAD Status** | ✅ Implemented |

**API Endpoints Used:**
```
GET /rest/api/3/search (JQL queries)
GET /rest/api/3/issue/{issueKey}
GET /rest/agile/1.0/board/{boardId}/sprint
GET /rest/agile/1.0/sprint/{sprintId}/issue
```

**JQL Queries:**
```
assignee = currentUser() AND status != Done
project = {{PROJECT_KEY}} AND sprint = activeSprint()
```

---

### 6. Linear

| Aspect | Details |
|--------|---------|
| **API** | ✅ GraphQL API |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | OAuth 2.0, API Key |
| **QUAD Uses** | Polling (30s interval) |
| **Data Access** | Issues, Projects, Cycles, Teams, Comments, Labels |
| **Rate Limits** | 1,500 req/hour (per API key) |
| **QUAD Status** | ✅ Implemented |

**GraphQL Queries:**
```graphql
query {
  issues(filter: { assignee: { id: { eq: "user-id" } } }) {
    nodes {
      id
      title
      state { name }
      assignee { name }
    }
  }
}
```

---

### 7. Azure DevOps (Boards)

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v6.0 |
| **Webhooks** | ✅ Service Hooks |
| **Authentication** | PAT, OAuth 2.0 |
| **QUAD Uses** | Polling (30s interval) |
| **Data Access** | Work Items, Sprints, Queries, Boards |
| **Rate Limits** | Varies by service tier |
| **QUAD Status** | 🔜 Planned (Phase 2) |

---

### 8. Asana

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v1 |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | OAuth 2.0, Personal Access Token |
| **QUAD Uses** | Polling (1min interval - lower priority) |
| **Data Access** | Tasks, Projects, Sections, Comments, Attachments |
| **Rate Limits** | 1,500 req/minute |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 9. Monday.com

| Aspect | Details |
|--------|---------|
| **API** | ✅ GraphQL API |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | API Token |
| **QUAD Uses** | Polling (1min interval - lower priority) |
| **Data Access** | Boards, Items, Updates, Columns |
| **Rate Limits** | 10,000,000 complexity points/minute |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

## Communication Tools

### 10. Slack

| Aspect | Details |
|--------|---------|
| **API** | ✅ Web API, Events API |
| **Webhooks** | ✅ Incoming Webhooks, Outgoing Webhooks |
| **Authentication** | OAuth 2.0, Bot Token |
| **QUAD Uses** | **Send notifications** (not polling) |
| **Data Access** | Channels, Messages, Users, Teams |
| **Rate Limits** | Tier-based (1+ req/minute per method) |
| **QUAD Status** | ✅ Implemented (notifications only) |

**Use Cases:**
- ✅ Send alerts ("PR ready for review")
- ✅ Post build status ("Build failed - 3 errors")
- ❌ Don't poll Slack (not needed)

**API Endpoints Used:**
```
POST /chat.postMessage (send message)
POST /files.upload (attach screenshots, logs)
```

---

### 11. Microsoft Teams

| Aspect | Details |
|--------|---------|
| **API** | ✅ Microsoft Graph API, Bot Framework |
| **Webhooks** | ✅ Incoming Webhooks, Outgoing Webhooks |
| **Authentication** | OAuth 2.0, Bot Token |
| **QUAD Uses** | **Send notifications** (not polling) |
| **Data Access** | Teams, Channels, Messages, Tabs |
| **Rate Limits** | 2,000 req/app/second (Graph API) |
| **QUAD Status** | ✅ Implemented (notifications only) |

---

### 12. Discord

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v10, Gateway API |
| **Webhooks** | ✅ Incoming Webhooks |
| **Authentication** | Bot Token, OAuth 2.0 |
| **QUAD Uses** | **Send notifications** (not polling) |
| **Data Access** | Guilds, Channels, Messages, Roles |
| **Rate Limits** | 50 req/second (global), 5 req/second (per route) |
| **QUAD Status** | ✅ Implemented (notifications only) |

---

## Design Tools

### 13. Figma

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v1 |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | Personal Access Token, OAuth 2.0 |
| **QUAD Uses** | Polling (5min interval - low priority) |
| **Data Access** | Files, Versions, Comments, Components, Styles |
| **Rate Limits** | 200 req/minute |
| **QUAD Status** | ✅ Implemented |

**API Endpoints Used:**
```
GET /v1/files/{file_key}
GET /v1/files/{file_key}/components
GET /v1/images/{file_key}
```

**Use Cases:**
- Read design specs (spacing, colors, typography)
- Export assets (icons, images)
- Detect design changes (new components)

---

### 14. Sketch (via Sketch Cloud)

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API |
| **Webhooks** | ❌ No |
| **Authentication** | API Token |
| **QUAD Uses** | Polling (5min interval) |
| **Data Access** | Documents, Pages, Artboards, Layers |
| **Rate Limits** | Not publicly documented |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 15. Adobe XD (Cloud Documents)

| Aspect | Details |
|--------|---------|
| **API** | ❌ Limited API (Creative Cloud API) |
| **Webhooks** | ❌ No |
| **Authentication** | OAuth 2.0 |
| **QUAD Uses** | ❌ Not supported |
| **Data Access** | Limited |
| **QUAD Status** | ❌ Not supported (use Figma instead) |

---

## Infrastructure & Monitoring Tools

### 16. PagerDuty

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v2 |
| **Webhooks** | ✅ Webhooks v3 (but we use polling) |
| **Authentication** | API Token |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Incidents, Services, Escalation Policies, On-Call Schedules |
| **Rate Limits** | 960 req/minute (aggregated across API keys) |
| **QUAD Status** | ✅ Implemented |

**API Endpoints Used:**
```
GET /incidents (active incidents)
GET /services (service status)
GET /oncalls (who's on call)
```

---

### 17. Datadog

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v1, v2 |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | API Key + App Key |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Metrics, Logs, Traces, Monitors, Dashboards |
| **Rate Limits** | 300 req/hour (free tier), 1,000 req/hour (paid) |
| **QUAD Status** | ✅ Implemented |

---

### 18. New Relic

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API, GraphQL (NerdGraph) |
| **Webhooks** | ✅ Alerts (but we use polling) |
| **Authentication** | API Key |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | APM, Infrastructure, Logs, Alerts, Dashboards |
| **Rate Limits** | 1,000 req/account/minute |
| **QUAD Status** | ✅ Implemented |

---

### 19. Grafana

| Aspect | Details |
|--------|---------|
| **API** | ✅ HTTP API |
| **Webhooks** | ✅ Alert Notifications (but we use polling) |
| **Authentication** | API Key, Basic Auth |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Dashboards, Alerts, Data Sources, Annotations |
| **Rate Limits** | Self-hosted (no limit), Grafana Cloud (varies) |
| **QUAD Status** | ✅ Implemented |

---

### 20. Prometheus

| Aspect | Details |
|--------|---------|
| **API** | ✅ HTTP API |
| **Webhooks** | ✅ Alertmanager webhooks |
| **Authentication** | Basic Auth (optional) |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Metrics, Queries (PromQL), Alerts |
| **Rate Limits** | Self-hosted (no limit) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

## Cloud Providers (Future - Phase 3)

### 21. AWS (Amazon Web Services)

| Aspect | Details |
|--------|---------|
| **API** | ✅ AWS SDK, REST APIs for all services |
| **Webhooks** | ✅ EventBridge, SNS |
| **Authentication** | IAM Access Keys, STS Temporary Credentials |
| **QUAD Uses** | Polling (5min interval) |
| **Data Access** | EC2, RDS, S3, Lambda, CloudWatch, Cost Explorer |
| **Rate Limits** | Service-specific (1,000+ req/second for most) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 22. GCP (Google Cloud Platform)

| Aspect | Details |
|--------|---------|
| **API** | ✅ Cloud APIs (REST, gRPC) |
| **Webhooks** | ✅ Pub/Sub, Cloud Functions |
| **Authentication** | Service Account Keys, OAuth 2.0 |
| **QUAD Uses** | Polling (5min interval) |
| **Data Access** | Compute Engine, Cloud SQL, Cloud Storage, Stackdriver |
| **Rate Limits** | Service-specific (10,000+ req/minute for most) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 23. Azure (Microsoft Azure)

| Aspect | Details |
|--------|---------|
| **API** | ✅ Azure REST API, SDKs |
| **Webhooks** | ✅ Event Grid |
| **Authentication** | Service Principal, OAuth 2.0 |
| **QUAD Uses** | Polling (5min interval) |
| **Data Access** | VMs, SQL Database, Storage, Monitor, Cost Management |
| **Rate Limits** | 12,000 read req/hour, 1,200 write req/hour |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

## Testing Tools (Future - Phase 3)

### 24. Selenium Grid

| Aspect | Details |
|--------|---------|
| **API** | ✅ WebDriver API, Grid API |
| **Webhooks** | ❌ No |
| **Authentication** | None (usually internal network) |
| **QUAD Uses** | Query grid status, browser availability |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 25. BrowserStack

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API |
| **Webhooks** | ❌ No |
| **Authentication** | Username + Access Key (Basic Auth) |
| **QUAD Uses** | Polling (1min interval for test status) |
| **Data Access** | Builds, Sessions, Screenshots, Logs |
| **Rate Limits** | Not publicly documented |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 26. Postman (Postman API)

| Aspect | Details |
|--------|---------|
| **API** | ✅ Postman API |
| **Webhooks** | ✅ Postman Monitors (but we use polling) |
| **Authentication** | API Key |
| **QUAD Uses** | Polling (5min interval - low priority) |
| **Data Access** | Collections, Environments, Monitors, Test Results |
| **Rate Limits** | 60 req/minute (free), 300 req/minute (paid) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

## CI/CD Tools (Future - Phase 3)

### 27. Jenkins

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API |
| **Webhooks** | ✅ Build Triggers |
| **Authentication** | API Token, Basic Auth |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Jobs, Builds, Queue, Nodes |
| **Rate Limits** | Self-hosted (no limit) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 28. GitHub Actions

| Aspect | Details |
|--------|---------|
| **API** | ✅ GitHub REST API v3 |
| **Webhooks** | ✅ Yes (but we use polling) |
| **Authentication** | GitHub PAT, OAuth |
| **QUAD Uses** | Polling (30s interval, same as GitHub repo polling) |
| **Data Access** | Workflows, Runs, Jobs, Artifacts |
| **Rate Limits** | Same as GitHub (5,000 req/hour) |
| **QUAD Status** | 🔜 Planned (Phase 2) |

---

### 29. GitLab CI/CD

| Aspect | Details |
|--------|---------|
| **API** | ✅ GitLab REST API v4 |
| **Webhooks** | ✅ Pipeline hooks |
| **Authentication** | GitLab PAT, OAuth |
| **QUAD Uses** | Polling (30s interval, same as GitLab repo polling) |
| **Data Access** | Pipelines, Jobs, Artifacts |
| **Rate Limits** | Same as GitLab (600 req/minute) |
| **QUAD Status** | 🔜 Planned (Phase 2) |

---

### 30. CircleCI

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v2 |
| **Webhooks** | ✅ Webhooks |
| **Authentication** | API Token |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Pipelines, Workflows, Jobs, Artifacts |
| **Rate Limits** | Not publicly documented |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

## Distribution & Analytics Tools (Mobile)

### 31. TestFlight (App Store Connect API)

| Aspect | Details |
|--------|---------|
| **API** | ✅ App Store Connect API |
| **Webhooks** | ❌ No |
| **Authentication** | JWT (App Store Connect API Key) |
| **QUAD Uses** | Polling (5min interval - low priority) |
| **Data Access** | Builds, Beta Testers, Test Groups, Feedback |
| **Rate Limits** | Not publicly documented |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 32. Google Play Console API

| Aspect | Details |
|--------|---------|
| **API** | ✅ Google Play Developer API |
| **Webhooks** | ✅ Real-time Developer Notifications (Pub/Sub) |
| **Authentication** | OAuth 2.0, Service Account |
| **QUAD Uses** | Polling (5min interval) |
| **Data Access** | Tracks, Releases, Reviews, Statistics |
| **Rate Limits** | 20,000 req/day (adjustable) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 33. Firebase

| Aspect | Details |
|--------|---------|
| **API** | ✅ Firebase Admin SDK, REST APIs |
| **Webhooks** | ✅ Cloud Functions triggers |
| **Authentication** | Service Account Key, OAuth 2.0 |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Crashlytics, Analytics, Remote Config, A/B Testing |
| **Rate Limits** | Service-specific (generous) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 34. Crashlytics (Firebase)

| Aspect | Details |
|--------|---------|
| **API** | ✅ Firebase Admin SDK |
| **Webhooks** | ❌ No (part of Firebase) |
| **Authentication** | Service Account Key |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Crash reports, ANRs, Stack traces |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

## Deployment & Hosting Tools (Future)

### 35. Vercel

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v2 |
| **Webhooks** | ✅ Deployment Hooks |
| **Authentication** | API Token, OAuth |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Deployments, Projects, Domains, Analytics |
| **Rate Limits** | 100 req/minute (varies by plan) |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 36. Netlify

| Aspect | Details |
|--------|---------|
| **API** | ✅ REST API v1 |
| **Webhooks** | ✅ Outgoing Webhooks |
| **Authentication** | Personal Access Token, OAuth |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Sites, Deploys, Forms, Functions |
| **Rate Limits** | 500 req/minute |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

### 37. Heroku

| Aspect | Details |
|--------|---------|
| **API** | ✅ Platform API |
| **Webhooks** | ✅ App Webhooks |
| **Authentication** | API Token, OAuth |
| **QUAD Uses** | Polling (1min interval) |
| **Data Access** | Apps, Dynos, Add-ons, Releases, Pipelines |
| **Rate Limits** | 4,500 req/hour |
| **QUAD Status** | 🔜 Planned (Phase 3) |

---

## Summary Table

| Tool | API | Webhooks | QUAD Uses | Status |
|------|-----|----------|-----------|--------|
| **GitHub** | ✅ REST, GraphQL | ✅ Yes | Polling (30s) | ✅ Implemented |
| **GitLab** | ✅ REST, GraphQL | ✅ Yes | Polling (30s) | ✅ Implemented |
| **Bitbucket** | ✅ REST | ✅ Yes | Polling (30s) | ✅ Implemented |
| **Jira** | ✅ REST | ✅ Yes | Polling (30s) | ✅ Implemented |
| **Linear** | ✅ GraphQL | ✅ Yes | Polling (30s) | ✅ Implemented |
| **Slack** | ✅ Web API | ✅ Yes | Send only | ✅ Implemented |
| **Teams** | ✅ Graph API | ✅ Yes | Send only | ✅ Implemented |
| **Discord** | ✅ REST | ✅ Yes | Send only | ✅ Implemented |
| **Figma** | ✅ REST | ✅ Yes | Polling (5min) | ✅ Implemented |
| **PagerDuty** | ✅ REST | ✅ Yes | Polling (1min) | ✅ Implemented |
| **Datadog** | ✅ REST | ✅ Yes | Polling (1min) | ✅ Implemented |
| **New Relic** | ✅ REST, GraphQL | ✅ Yes | Polling (1min) | ✅ Implemented |
| **Grafana** | ✅ HTTP API | ✅ Yes | Polling (1min) | ✅ Implemented |
| **Azure DevOps** | ✅ REST | ✅ Hooks | Polling (30s) | 🔜 Phase 2 |
| **GitHub Actions** | ✅ REST | ✅ Yes | Polling (30s) | 🔜 Phase 2 |
| **GitLab CI** | ✅ REST | ✅ Yes | Polling (30s) | 🔜 Phase 2 |
| **AWS** | ✅ SDK | ✅ EventBridge | Polling (5min) | 🔜 Phase 3 |
| **GCP** | ✅ APIs | ✅ Pub/Sub | Polling (5min) | 🔜 Phase 3 |
| **Azure** | ✅ REST | ✅ Event Grid | Polling (5min) | 🔜 Phase 3 |
| **TestFlight** | ✅ App Store API | ❌ No | Polling (5min) | 🔜 Phase 3 |
| **Play Console** | ✅ Developer API | ✅ Pub/Sub | Polling (5min) | 🔜 Phase 3 |
| **Firebase** | ✅ Admin SDK | ✅ Functions | Polling (1min) | 🔜 Phase 3 |
| **Vercel** | ✅ REST | ✅ Yes | Polling (1min) | 🔜 Phase 3 |
| **Netlify** | ✅ REST | ✅ Yes | Polling (1min) | 🔜 Phase 3 |

---

## Polling Configuration (QUAD Platform)

**QUAD_ADMIN can configure polling intervals per integration:**

```sql
-- Example: Organization preferences
-- Note: company_id column maps to org_id in Prisma
UPDATE QUAD_org_integrations
SET config = jsonb_set(
  config,
  '{poll_interval}',
  '"30s"'::jsonb
)
WHERE company_id = 'org-uuid' AND integration_id = 'github';

-- Supported intervals:
-- '15s' - Aggressive (expensive, high API usage)
-- '30s' - Default (balanced)
-- '1min' - Conservative (low API usage)
-- '5min' - Very conservative (infrastructure tools)
```

**Default Intervals by Tool Type:**
- Source Control (GitHub, GitLab): 30s
- Project Management (Jira, Linear): 30s
- Communication (Slack, Teams): Send only (no polling)
- Design (Figma): 5min (low priority)
- Monitoring (Datadog, PagerDuty): 1min
- Cloud (AWS, GCP): 5min (low priority)

---

## Authentication Storage

**All API tokens stored in database:**
```sql
-- Example:
-- Note: company_id column maps to org_id in Prisma
SELECT * FROM QUAD_org_integrations
WHERE company_id = 'org-uuid';

-- Result:
{
  "integration_id": "github",
  "config": {
    "org": "acmecorp",
    "poll_interval": "30s",
    "api_token": "ghp_xxxxxxxxxxxx",  -- Encrypted in production
    "default_branch": "main"
  }
}
```

**Security:**
- API tokens encrypted at rest
- Never exposed in logs or UI
- Rotated every 90 days (admin reminder)

---

## Future Enhancements

**Phase 2:**
- Azure DevOps (full integration)
- GitHub Actions (workflow status)
- GitLab CI (pipeline status)

**Phase 3:**
- Cloud providers (AWS, GCP, Azure)
- Testing tools (Selenium, BrowserStack)
- Mobile distribution (TestFlight, Play Console)
- Deployment (Vercel, Netlify)

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
