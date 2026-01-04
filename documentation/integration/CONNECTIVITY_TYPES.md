# QUAD Framework - Integration Connectivity Types

## Table of Contents
1. [Overview](#overview)
2. [Connectivity Types Matrix](#connectivity-types-matrix)
3. [Type 1: API Keys & Tokens](#type-1-api-keys--tokens)
4. [Type 2: OAuth 2.0](#type-2-oauth-20)
5. [Type 3: SSH Keys](#type-3-ssh-keys)
6. [Type 4: App Passwords](#type-4-app-passwords)
7. [Type 5: MCP Agents](#type-5-mcp-agents)
8. [Type 6: Webhooks](#type-6-webhooks)
9. [Database Schema](#database-schema)
10. [Hierarchical Configuration](#hierarchical-configuration)
11. [Phase 1 Required Integrations](#phase-1-required-integrations)

---

## Overview

QUAD integrates with external tools using **6 connectivity types**. Each type has different security models, setup complexity, and use cases.

**Key Insight:** MCP Agents are NOT a replacement for other connectivity types - they are a **wrapper/orchestration layer** that can USE any of the other types internally.

```
┌─────────────────────────────────────────────────────────────────────┐
│                      QUAD Integration Layer                          │
│                                                                      │
│   ┌──────────────────────────────────────────────────────────────┐  │
│   │                    MCP Agent (Orchestrator)                   │  │
│   │                                                               │  │
│   │   Provides: Tools via JSON-RPC                                │  │
│   │   Can use internally: API Keys, OAuth, SSH, Webhooks          │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                              │                                       │
│         ┌────────────────────┼────────────────────┐                 │
│         ▼                    ▼                    ▼                 │
│   ┌──────────┐         ┌──────────┐         ┌──────────┐           │
│   │ GitHub   │         │  Jira    │         │Confluence│           │
│   │ (OAuth)  │         │ (Token)  │         │ (Token)  │           │
│   └──────────┘         └──────────┘         └──────────┘           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Connectivity Types Matrix

| Type | Auth Method | Setup Complexity | Rotation | Multi-User | Best For |
|------|-------------|------------------|----------|------------|----------|
| **API Token** | Bearer token | Low | Manual | Per-user or shared | REST APIs (Jira, Confluence) |
| **OAuth 2.0** | Authorization code | Medium | Auto (refresh) | Per-user | GitHub, Google, Slack |
| **SSH Key** | Public/Private key | Medium | Manual | Per-user | Git operations |
| **App Password** | Username + app-specific password | Low | Manual | Per-user | Bitbucket, Atlassian |
| **MCP Agent** | Depends on underlying | High | Varies | Shared service | AI tool orchestration |
| **Webhook** | Secret + URL | Low | Manual | Shared | Event notifications |

---

## Type 1: API Keys & Tokens

### Description
Simple bearer tokens passed in HTTP headers. Most common for REST APIs.

### Examples
- **Jira Cloud**: API token + email
- **Confluence Cloud**: API token + email
- **OpenAI**: API key
- **Anthropic**: API key

### Configuration
```json
{
  "connectivity_type": "API_TOKEN",
  "provider": "jira",
  "credentials": {
    "email": "user@company.com",
    "api_token": "vault://secrets/jira-token"
  },
  "base_url": "https://company.atlassian.net"
}
```

### Pros/Cons
| Pros | Cons |
|------|------|
| Simple to implement | No auto-refresh |
| Works everywhere | Must rotate manually |
| Easy to revoke | Often per-user |

---

## Type 2: OAuth 2.0

### Description
Industry standard for delegated authorization. User grants access without sharing credentials.

### Examples
- **GitHub**: OAuth App or GitHub App
- **Google Workspace**: OAuth 2.0
- **Slack**: OAuth 2.0
- **Microsoft 365**: Azure AD OAuth

### Flow
```
User clicks "Connect GitHub"
        │
        ▼
QUAD redirects to GitHub OAuth
        │
        ▼
User authorizes QUAD
        │
        ▼
GitHub redirects back with code
        │
        ▼
QUAD exchanges code for tokens
        │
        ▼
Store access_token + refresh_token
```

### Configuration
```json
{
  "connectivity_type": "OAUTH2",
  "provider": "github",
  "credentials": {
    "client_id": "vault://secrets/github-client-id",
    "client_secret": "vault://secrets/github-client-secret",
    "access_token": "vault://secrets/github-access-{user_id}",
    "refresh_token": "vault://secrets/github-refresh-{user_id}",
    "token_expires_at": "2026-01-04T12:00:00Z"
  },
  "scopes": ["repo", "read:user", "read:org"]
}
```

### Pros/Cons
| Pros | Cons |
|------|------|
| Auto-refresh tokens | Complex setup |
| User-controlled permissions | Requires redirect handling |
| Industry standard | Provider-specific quirks |

---

## Type 3: SSH Keys

### Description
Asymmetric key pairs for secure authentication. Common for Git operations.

### Examples
- **GitHub**: Deploy keys or user SSH keys
- **GitLab**: SSH keys
- **Bitbucket**: SSH keys
- **Server access**: SSH to sandboxes

### Configuration
```json
{
  "connectivity_type": "SSH_KEY",
  "provider": "github",
  "credentials": {
    "private_key": "vault://secrets/github-ssh-key",
    "public_key": "ssh-ed25519 AAAA... quad-deploy",
    "passphrase": "vault://secrets/ssh-passphrase"
  },
  "key_type": "ed25519"
}
```

### Pros/Cons
| Pros | Cons |
|------|------|
| Very secure | Key management overhead |
| No expiration by default | Per-user setup |
| Works without browser | Harder to rotate |

---

## Type 4: App Passwords

### Description
Application-specific passwords that don't require OAuth dance. Simpler than OAuth but less secure.

### Examples
- **Bitbucket**: App passwords
- **Atlassian (Server)**: App passwords
- **Email (SMTP)**: App-specific passwords

### Configuration
```json
{
  "connectivity_type": "APP_PASSWORD",
  "provider": "bitbucket",
  "credentials": {
    "username": "quad-service",
    "app_password": "vault://secrets/bitbucket-app-password"
  },
  "permissions": ["repository:read", "repository:write"]
}
```

### Pros/Cons
| Pros | Cons |
|------|------|
| Simple like API tokens | Per-user |
| Scoped permissions | Manual rotation |
| No OAuth complexity | Less standardized |

---

## Type 5: MCP Agents

### Description
Model Context Protocol servers that expose tools via JSON-RPC. Can use ANY of the above connectivity types internally.

### Key Distinction
MCP is **NOT** a replacement for other auth methods - it's an **orchestration layer**:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         MCP Agent Server                             │
│                                                                      │
│   Exposes Tools:                                                     │
│   - jira_create_issue()                                              │
│   - github_create_pr()                                               │
│   - confluence_update_page()                                         │
│                                                                      │
│   Internally Uses:                                                   │
│   - Jira API Token (Type 1)                                          │
│   - GitHub OAuth (Type 2)                                            │
│   - Confluence Token (Type 1)                                        │
└─────────────────────────────────────────────────────────────────────┘
```

### Configuration
```json
{
  "connectivity_type": "MCP_AGENT",
  "provider": "quad-integrations",
  "mcp_config": {
    "server_command": "node",
    "server_args": ["/path/to/quad-mcp-server/index.js"],
    "transport": "stdio"
  },
  "internal_connections": [
    {"ref": "jira-connection-uuid"},
    {"ref": "github-connection-uuid"},
    {"ref": "confluence-connection-uuid"}
  ],
  "tools_exposed": [
    "jira_create_issue",
    "jira_update_issue",
    "github_create_pr",
    "confluence_update_page"
  ]
}
```

### When to Use MCP vs Direct Connection

| Scenario | Use Direct Connection | Use MCP Agent |
|----------|----------------------|---------------|
| Simple API call | ✅ | ❌ |
| AI needs to use tool | ❌ | ✅ |
| Batch operations | ✅ | ❌ |
| Cross-tool orchestration | ❌ | ✅ |
| Webhooks receiving | ✅ | ❌ |
| Browser IDE tool calls | ❌ | ✅ |

### Pros/Cons
| Pros | Cons |
|------|------|
| AI-native interface | Additional server to manage |
| Unified tool discovery | Complexity layer |
| Multi-provider abstraction | Debugging harder |
| Scales to team (shared server) | Requires deployment |

---

## Type 6: Webhooks

### Description
Callback URLs that receive event notifications. Used for real-time updates.

### Examples
- **GitHub Webhooks**: Push, PR, Issue events
- **Jira Webhooks**: Issue created/updated
- **Slack Events API**: Messages, reactions

### Configuration
```json
{
  "connectivity_type": "WEBHOOK",
  "provider": "github",
  "webhook_config": {
    "callback_url": "https://api.quadframe.work/webhooks/github",
    "secret": "vault://secrets/github-webhook-secret",
    "events": ["push", "pull_request", "issue_comment"]
  }
}
```

### Pros/Cons
| Pros | Cons |
|------|------|
| Real-time events | Need public endpoint |
| No polling | Must validate signatures |
| Efficient | Can miss events if down |

---

## Database Schema

### Core Tables

```sql
-- Master table for all integration types
CREATE TABLE QUAD_integration_configs (
    id UUID PRIMARY KEY,
    company_id UUID REFERENCES QUAD_organizations(id),
    domain_id UUID REFERENCES QUAD_domains(id),  -- NULL = org-level

    -- Integration identity
    provider VARCHAR(50) NOT NULL,               -- github, jira, confluence, etc.
    connectivity_type VARCHAR(20) NOT NULL,      -- API_TOKEN, OAUTH2, SSH_KEY, APP_PASSWORD, MCP_AGENT, WEBHOOK
    display_name VARCHAR(100),

    -- Configuration (JSONB for flexibility)
    config JSONB NOT NULL,                       -- Provider-specific config

    -- Credentials (paths to vault, not actual secrets!)
    credentials_vault_path VARCHAR(255),

    -- Status
    status VARCHAR(20) DEFAULT 'pending',        -- pending, active, error, disabled
    last_health_check TIMESTAMP,
    health_status VARCHAR(20),
    error_message TEXT,

    -- Hierarchy
    is_org_default BOOLEAN DEFAULT false,        -- Can be overridden at domain level
    inherits_from UUID REFERENCES QUAD_integration_configs(id),

    -- Audit
    created_by UUID REFERENCES QUAD_users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- MCP Agent specific configuration
CREATE TABLE QUAD_mcp_agent_configs (
    id UUID PRIMARY KEY,
    integration_id UUID REFERENCES QUAD_integration_configs(id),

    -- Server configuration
    server_type VARCHAR(20),                     -- stdio, http, websocket
    server_command VARCHAR(255),
    server_args JSONB,
    environment_vars JSONB,

    -- Tool discovery
    tools_available JSONB,                       -- Cached from tools/list
    tools_enabled JSONB,                         -- Which tools are enabled for this org

    -- Dependencies on other integrations
    required_integrations UUID[],                -- Other integration_configs this MCP uses

    -- Resource limits
    max_concurrent_calls INT DEFAULT 10,
    timeout_seconds INT DEFAULT 30,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- User-level integration overrides
CREATE TABLE QUAD_user_integration_configs (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES QUAD_users(id),
    base_integration_id UUID REFERENCES QUAD_integration_configs(id),

    -- User-specific credentials (e.g., their own GitHub OAuth)
    credentials_vault_path VARCHAR(255),

    -- User preferences
    is_enabled BOOLEAN DEFAULT true,
    preferences JSONB,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(user_id, base_integration_id)
);

-- Integration health checks history
CREATE TABLE QUAD_integration_health_checks (
    id UUID PRIMARY KEY,
    integration_id UUID REFERENCES QUAD_integration_configs(id),

    check_timestamp TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20),                          -- healthy, degraded, unhealthy
    response_time_ms INT,
    error_message TEXT,
    details JSONB
);
```

---

## Hierarchical Configuration

### Override Hierarchy

```
Platform Defaults (QUAD provides)
        │
        ▼
Organization Level (Org admin configures)
        │
        ▼
Domain Level (Domain lead overrides)
        │
        ▼
Circle Level (Team-specific) [Optional]
        │
        ▼
User Level (Personal credentials)
```

### Example: GitHub Integration

```
Platform: No GitHub config (not our job)
    │
    ▼
Org "Acme Corp": GitHub OAuth App configured
    │             Client ID/Secret at org level
    │
    ├── Domain "Backend": Inherits org config
    │       │
    │       └── User "Alice": Her own OAuth token stored
    │
    └── Domain "Mobile": Uses different GitHub org
            │           Override with separate OAuth App
            │
            └── User "Bob": His own OAuth token stored
```

### Configuration Resolution

```sql
-- Function to resolve effective integration config for a user
CREATE FUNCTION QUAD_resolve_integration(
    p_user_id UUID,
    p_domain_id UUID,
    p_provider VARCHAR(50),
    p_connectivity_type VARCHAR(20)
) RETURNS JSONB AS $$
DECLARE
    v_config JSONB;
    v_user_override JSONB;
BEGIN
    -- Start with domain config (or org if domain has none)
    SELECT config INTO v_config
    FROM QUAD_integration_configs
    WHERE (domain_id = p_domain_id OR (domain_id IS NULL AND company_id = (
        SELECT company_id FROM QUAD_domains WHERE id = p_domain_id
    )))
    AND provider = p_provider
    AND connectivity_type = p_connectivity_type
    AND status = 'active'
    ORDER BY domain_id NULLS LAST  -- Prefer domain-specific
    LIMIT 1;

    -- Check for user-level override
    SELECT jsonb_build_object(
        'credentials_vault_path', uic.credentials_vault_path,
        'preferences', uic.preferences
    ) INTO v_user_override
    FROM QUAD_user_integration_configs uic
    JOIN QUAD_integration_configs ic ON uic.base_integration_id = ic.id
    WHERE uic.user_id = p_user_id
    AND ic.provider = p_provider
    AND uic.is_enabled = true;

    -- Merge user overrides
    IF v_user_override IS NOT NULL THEN
        v_config := v_config || v_user_override;
    END IF;

    RETURN v_config;
END;
$$ LANGUAGE plpgsql;
```

---

## Phase 1 Required Integrations

### Mandatory (Must Have for MVP)

| Integration | Connectivity Type | Purpose | MCP Agent? |
|-------------|-------------------|---------|------------|
| **GitHub** | OAuth 2.0 | Code repos, PRs | ✅ Yes |
| **AI Provider** | API Token | Claude/Gemini/OpenAI | ❌ No (direct) |
| **Email (SMTP)** | App Password | Notifications | ❌ No |

### Recommended (High Value)

| Integration | Connectivity Type | Purpose | MCP Agent? |
|-------------|-------------------|---------|------------|
| **Jira** | API Token | Ticket sync | ✅ Yes |
| **Slack** | OAuth 2.0 | Notifications, bot | ✅ Yes |
| **Google Calendar** | OAuth 2.0 | Meeting integration | ❌ No |

### Optional (Phase 2+)

| Integration | Connectivity Type | Purpose | MCP Agent? |
|-------------|-------------------|---------|------------|
| **Confluence** | API Token | Documentation | ✅ Yes |
| **GitLab** | OAuth 2.0 | Alternative Git | ✅ Yes |
| **Bitbucket** | App Password | Alternative Git | ✅ Yes |
| **Azure DevOps** | OAuth 2.0 | Enterprise Git | ✅ Yes |
| **Linear** | API Token | Ticket alternative | ✅ Yes |
| **Notion** | API Token | Documentation | ❌ No |

### MCP Agent Architecture for Phase 1

```
┌─────────────────────────────────────────────────────────────────────┐
│                     QUAD MCP Server (Phase 1)                        │
│                                                                      │
│   Transport: HTTP/WebSocket (for Browser IDE)                        │
│   Deployment: GCP Cloud Run                                          │
│                                                                      │
│   Tools Provided:                                                    │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │ GitHub Module                                                │   │
│   │ - github_clone_repo()                                        │   │
│   │ - github_create_branch()                                     │   │
│   │ - github_create_pr()                                         │   │
│   │ - github_get_pr_status()                                     │   │
│   └─────────────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │ QUAD Tickets Module                                          │   │
│   │ - quad_get_ticket()                                          │   │
│   │ - quad_update_status()                                       │   │
│   │ - quad_get_dependencies() -- Returns IN-DEGREE/OUT-DEGREE    │   │
│   └─────────────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │ Sandbox Module                                               │   │
│   │ - sandbox_create()                                           │   │
│   │ - sandbox_status()                                           │   │
│   │ - sandbox_execute()                                          │   │
│   │ - sandbox_destroy()                                          │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   Internal Connections:                                              │
│   - GitHub: OAuth (org-level, user tokens)                           │
│   - QUAD API: Internal service account                               │
│   - GCP: Service account for sandbox provisioning                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Comparison: Direct vs MCP

| Question | Direct Connection | MCP Agent |
|----------|-------------------|-----------|
| Who manages credentials? | Each service | MCP server |
| How does AI use it? | Can't directly | Native tool calls |
| How does browser IDE use it? | REST calls | WebSocket + tools |
| Multi-provider orchestration? | Manual | Automatic |
| Team sharing? | Per-user setup | Shared server |
| Debugging? | Simple | Need MCP logs |

---

**Last Updated:** January 4, 2026
**Version:** 1.0
