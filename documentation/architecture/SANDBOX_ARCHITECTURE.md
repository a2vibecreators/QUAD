# QUAD Framework - Sandbox Architecture

## Table of Contents
1. [Overview](#overview)
2. [Why Sandboxes?](#why-sandboxes)
3. [Architecture](#architecture)
4. [Sandbox Types](#sandbox-types)
5. [Lifecycle Management](#lifecycle-management)
6. [Database Schema](#database-schema)
7. [API Design](#api-design)
8. [Infrastructure Options](#infrastructure-options)
9. [Security Considerations](#security-considerations)
10. [Cost Optimization](#cost-optimization)

---

## Overview

QUAD Framework uses **ephemeral cloud sandboxes** to provide isolated development environments for ticket work. Each sandbox is a containerized environment that can:

- Clone Git repositories
- Run builds (Maven, npm, Gradle)
- Execute tests
- Perform AI-assisted code analysis
- Host browser-based IDEs (future)

**Key Principle:** Sandboxes are **ticket-scoped** - they are created when work starts and destroyed when work completes.

---

## Why Sandboxes?

### Problems We Solve

| Problem | Traditional Approach | QUAD Sandbox Approach |
|---------|---------------------|----------------------|
| "Works on my machine" | Blame game | Standardized containers |
| Environment setup | Hours of configuration | Instant spin-up |
| Conflicting dependencies | Version conflicts | Isolated per-ticket |
| Build verification | Manual CI | Auto-build in sandbox |
| Resource contention | Shared dev servers | Dedicated resources |
| Security | Secrets on dev machines | Ephemeral, auto-cleaned |

### Use Cases

1. **Ticket Development** - Start work on QUAD-123, sandbox auto-provisions
2. **Code Review** - Reviewer gets sandbox with PR branch checked out
3. **Build Verification** - AI verifies code compiles before PR merge
4. **Security Scans** - Run SAST/DAST in isolated environment
5. **Browser IDE** - Access VS Code in browser (Phase 2)

---

## Architecture

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         QUAD Web App                                 │
│                                                                      │
│   User: "Start work on QUAD-123"                                     │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         QUAD API                                     │
│                                                                      │
│   1. Create sandbox request                                          │
│   2. Record in QUAD_sandbox_instances table                          │
│   3. Call Infrastructure Provider                                    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  Infrastructure Provider                             │
│                                                                      │
│   Option A: Google Cloud Run Jobs                                    │
│   Option B: AWS Fargate                                              │
│   Option C: Kubernetes (GKE/EKS)                                     │
│   Option D: Local Docker (development)                               │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Sandbox Container                               │
│                                                                      │
│   Base Image: quad-sandbox:latest                                    │
│   Includes: Git, Maven, npm, Node, Java 21, Python                   │
│                                                                      │
│   Startup Script:                                                    │
│   1. git clone {repo_url} --branch {branch}                          │
│   2. cd {project_dir}                                                │
│   3. Run build command (mvn compile / npm install)                   │
│   4. Report status to QUAD API                                       │
│   5. Wait for commands or timeout                                    │
└─────────────────────────────────────────────────────────────────────┘
```

### Component Diagram

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   QUAD Web App   │────▶│    QUAD API      │────▶│  Sandbox Manager │
└──────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                           │
                         ┌─────────────────────────────────┼──────────┐
                         │                                 ▼          │
                         │  ┌──────────────┐    ┌──────────────────┐  │
                         │  │   Sandbox 1   │    │    Sandbox 2     │  │
                         │  │  QUAD-123     │    │    QUAD-456      │  │
                         │  │  Feature work │    │    Bug fix       │  │
                         │  └──────────────┘    └──────────────────┘  │
                         │                                             │
                         │           Container Orchestrator            │
                         └─────────────────────────────────────────────┘
```

---

## Sandbox Types

### Type 1: Build Sandbox (Default)

**Purpose:** Code checkout, compilation, test execution

```yaml
sandbox_type: BUILD
resources:
  cpu: 2 cores
  memory: 4 GB
  disk: 10 GB
timeout: 30 minutes
capabilities:
  - git_clone
  - maven_build
  - npm_install
  - run_tests
  - ai_analysis
```

### Type 2: IDE Sandbox (Phase 2)

**Purpose:** Browser-based development environment

```yaml
sandbox_type: IDE
resources:
  cpu: 4 cores
  memory: 8 GB
  disk: 20 GB
timeout: 8 hours (extendable)
capabilities:
  - all BUILD capabilities
  - code_server (VS Code)
  - terminal_access
  - live_preview
```

### Type 3: Review Sandbox

**Purpose:** Code review with full environment

```yaml
sandbox_type: REVIEW
resources:
  cpu: 2 cores
  memory: 4 GB
  disk: 10 GB
timeout: 2 hours
capabilities:
  - git_clone (specific PR)
  - build_verification
  - test_verification
  - diff_viewer
```

---

## Lifecycle Management

### Sandbox States

```
REQUESTED → PROVISIONING → READY → ACTIVE → IDLE → TERMINATING → TERMINATED
                                     │
                                     └──→ FAILED
```

| State | Description |
|-------|-------------|
| REQUESTED | Request received, pending provisioning |
| PROVISIONING | Container being created, repo cloning |
| READY | Build complete, waiting for user |
| ACTIVE | User actively working |
| IDLE | No activity for X minutes |
| TERMINATING | Cleanup in progress |
| TERMINATED | Sandbox destroyed |
| FAILED | Error during any phase |

### Auto-Cleanup Rules

```yaml
cleanup_rules:
  # Terminate if idle for 30 minutes
  idle_timeout: 30m

  # Force terminate after 8 hours
  max_lifetime: 8h

  # Warn user 5 minutes before termination
  warning_before_terminate: 5m

  # Keep logs for 7 days after termination
  log_retention: 7d
```

### Scaling Strategy

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Autoscaling Configuration                        │
│                                                                      │
│   Organization Tier Limits:                                          │
│   - FREE:       1 concurrent sandbox,  Build only                    │
│   - BASIC:      3 concurrent sandboxes, Build only                   │
│   - PRO:        10 concurrent sandboxes, Build + IDE                 │
│   - ENTERPRISE: Unlimited, Build + IDE + Custom                      │
│                                                                      │
│   Function: QUAD_sandbox_autoscale()                                 │
│   - Checks org tier limits before provisioning                       │
│   - Queues requests if at capacity                                   │
│   - Prioritizes active tickets over new requests                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Database Schema

### Core Tables

```sql
-- Sandbox configuration per organization
CREATE TABLE QUAD_infrastructure_config (
    id UUID PRIMARY KEY,
    company_id UUID REFERENCES QUAD_organizations(id),
    provider VARCHAR(50),          -- GCP, AWS, K8S, LOCAL
    region VARCHAR(50),
    default_cpu_millicores INT,
    default_memory_mb INT,
    default_disk_gb INT,
    max_sandboxes_per_org INT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Individual sandbox instances
CREATE TABLE QUAD_sandbox_instances (
    id UUID PRIMARY KEY,
    company_id UUID REFERENCES QUAD_organizations(id),
    domain_id UUID REFERENCES QUAD_domains(id),

    -- Type and status
    sandbox_type VARCHAR(20),      -- BUILD, IDE, REVIEW
    status VARCHAR(20),            -- REQUESTED, PROVISIONING, READY, etc.

    -- Infrastructure details
    provider_instance_id VARCHAR(255),  -- Cloud provider's ID
    container_url VARCHAR(500),
    ssh_command VARCHAR(500),

    -- Resource allocation
    cpu_millicores INT,
    memory_mb INT,
    disk_gb INT,

    -- Git context
    repository_url VARCHAR(500),
    branch_name VARCHAR(255),
    commit_sha VARCHAR(40),

    -- Timing
    requested_at TIMESTAMP DEFAULT NOW(),
    provisioned_at TIMESTAMP,
    last_activity_at TIMESTAMP,
    terminated_at TIMESTAMP,
    expires_at TIMESTAMP,

    -- Metadata
    created_by UUID REFERENCES QUAD_users(id),
    error_message TEXT
);

-- Link sandboxes to tickets
CREATE TABLE QUAD_ticket_sandbox_groups (
    id UUID PRIMARY KEY,
    ticket_id UUID REFERENCES QUAD_tickets(id),
    sandbox_id UUID REFERENCES QUAD_sandbox_instances(id),
    role VARCHAR(20),              -- PRIMARY, REVIEWER, AI_ANALYSIS
    created_at TIMESTAMP DEFAULT NOW()
);

-- Usage tracking for billing
CREATE TABLE QUAD_sandbox_usage (
    id UUID PRIMARY KEY,
    sandbox_id UUID REFERENCES QUAD_sandbox_instances(id),
    company_id UUID REFERENCES QUAD_organizations(id),

    -- Usage metrics
    cpu_seconds BIGINT,
    memory_mb_hours DECIMAL(10,2),
    disk_gb_hours DECIMAL(10,2),
    network_egress_mb BIGINT,

    -- Cost calculation
    estimated_cost_usd DECIMAL(10,4),

    -- Period
    usage_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

## API Design

### REST Endpoints

```
POST   /api/sandboxes              Create sandbox
GET    /api/sandboxes              List user's sandboxes
GET    /api/sandboxes/{id}         Get sandbox details
DELETE /api/sandboxes/{id}         Terminate sandbox
POST   /api/sandboxes/{id}/extend  Extend expiration
POST   /api/sandboxes/{id}/exec    Execute command
GET    /api/sandboxes/{id}/logs    Get sandbox logs
```

### Create Sandbox Request

```json
POST /api/sandboxes
{
  "ticket_id": "uuid-of-ticket",
  "sandbox_type": "BUILD",
  "repository": {
    "url": "https://github.com/org/repo.git",
    "branch": "feature/QUAD-123-new-api",
    "commit": "abc123"  // Optional, defaults to HEAD
  },
  "build_command": "mvn clean compile",
  "test_command": "mvn test -DskipTests=false"
}
```

### Create Sandbox Response

```json
{
  "id": "sandbox-uuid",
  "status": "PROVISIONING",
  "estimated_ready_at": "2026-01-04T15:30:00Z",
  "resources": {
    "cpu": "2 cores",
    "memory": "4 GB",
    "disk": "10 GB"
  },
  "expires_at": "2026-01-04T23:30:00Z"
}
```

### Sandbox Ready Webhook

```json
POST {callback_url}
{
  "sandbox_id": "sandbox-uuid",
  "status": "READY",
  "container_url": "https://sandbox-abc123.quad.run",
  "ssh_command": "ssh user@sandbox-abc123.quad.run",
  "build_result": {
    "success": true,
    "duration_seconds": 45,
    "output_lines": 127
  }
}
```

---

## Infrastructure Options

### Option A: Google Cloud Run Jobs (Recommended for QUAD)

**Pros:**
- Serverless, pay-per-use
- Fast cold start (~2 seconds)
- Automatic scaling
- Integrated with GCP ecosystem

**Cons:**
- Max 1 hour execution (jobs)
- No persistent connections for IDE

```yaml
# cloudbuild.yaml for sandbox image
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/quad-sandbox:$TAG', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/quad-sandbox:$TAG']
```

### Option B: AWS Fargate

**Pros:**
- Serverless containers
- Good for long-running tasks
- ECS integration

**Cons:**
- Slower cold start (~30 seconds)
- More complex networking

### Option C: Kubernetes (GKE/EKS)

**Pros:**
- Full control
- Best for IDE sandboxes
- Persistent volumes possible

**Cons:**
- Higher base cost (cluster always running)
- More operational overhead

### Option D: Local Docker (Development)

**Pros:**
- Free
- Fast iteration
- No cloud setup needed

**Cons:**
- Single machine only
- Manual cleanup

```bash
# Development sandbox
docker run -d \
  --name quad-sandbox-123 \
  -e REPO_URL=https://github.com/org/repo.git \
  -e BRANCH=feature/QUAD-123 \
  -v /tmp/quad-sandbox-123:/workspace \
  quad-sandbox:latest
```

---

## Security Considerations

### Network Isolation

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VPC / Network                                 │
│                                                                      │
│   ┌─────────────────┐     ┌─────────────────┐                       │
│   │  Sandbox Subnet  │     │   QUAD API      │                       │
│   │  (Private)       │────▶│   Subnet        │                       │
│   │                  │     │   (Private)     │                       │
│   │  - No internet   │     │                 │                       │
│   │  - NAT for pulls │     │  - Internet via │                       │
│   │  - API only      │     │    Load Balancer│                       │
│   └─────────────────┘     └─────────────────┘                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Secret Management

1. **Never store secrets in sandbox images**
2. **Inject via environment variables at runtime**
3. **Use GCP Secret Manager / AWS Secrets Manager**
4. **Rotate credentials after sandbox termination**

```yaml
# Sandbox secrets injection
env_vars:
  - name: GIT_TOKEN
    source: secret_manager
    key: projects/quad/secrets/git-token
  - name: NPM_TOKEN
    source: secret_manager
    key: projects/quad/secrets/npm-token
```

### Sandboxed Execution

```dockerfile
# Dockerfile for quad-sandbox
FROM ubuntu:22.04

# Non-root user
RUN useradd -m -s /bin/bash quaduser

# Limited capabilities
USER quaduser
WORKDIR /home/quaduser/workspace

# No network except allowed domains
# (enforced via network policies)
```

---

## Cost Optimization

### Pricing Model (Estimated)

| Resource | GCP Cloud Run | AWS Fargate |
|----------|--------------|-------------|
| CPU (per vCPU-second) | $0.00002400 | $0.00001417 |
| Memory (per GB-second) | $0.00000250 | $0.00000156 |
| Disk (per GB-hour) | $0.00014 | $0.000111 |

### Example Costs

| Sandbox Type | Duration | Estimated Cost |
|--------------|----------|----------------|
| BUILD (2 CPU, 4GB) | 30 min | ~$0.05 |
| REVIEW (2 CPU, 4GB) | 2 hours | ~$0.20 |
| IDE (4 CPU, 8GB) | 8 hours | ~$1.60 |

### Cost Controls

1. **Tier limits** - FREE tier gets 5 sandbox-hours/month
2. **Auto-shutdown** - Idle sandboxes terminate after 30 min
3. **Spot instances** - Use preemptible/spot for non-critical builds
4. **Caching** - Cache Maven/npm dependencies to reduce build time

```sql
-- Monthly usage query
SELECT
    o.name as organization,
    SUM(su.cpu_seconds) / 3600 as cpu_hours,
    SUM(su.estimated_cost_usd) as total_cost_usd
FROM QUAD_sandbox_usage su
JOIN QUAD_organizations o ON su.company_id = o.id
WHERE su.usage_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY o.name;
```

---

## Implementation Phases

### Phase 1: Build Sandboxes (Current Focus)

- [ ] Sandbox base image (Docker)
- [ ] GCP Cloud Run Jobs integration
- [ ] Basic API (create, status, terminate)
- [ ] Ticket-sandbox association
- [ ] Build output capture

### Phase 2: IDE Sandboxes

- [ ] Code-server integration
- [ ] Persistent workspace volumes
- [ ] WebSocket for terminal
- [ ] VS Code settings sync

### Phase 3: Advanced Features

- [ ] Multi-sandbox collaboration
- [ ] AI-assisted debugging in sandbox
- [ ] Custom sandbox images
- [ ] Self-hosted runner support

---

## Related Documentation

- [DATABASE_ARCHITECTURE.md](../database/DATABASE_ARCHITECTURE.md) - Schema details
- [BROWSER_IDE_RESEARCH.md](../research/BROWSER_IDE_RESEARCH.md) - Competitor analysis
- [AGENT_RULES.md](../agents/AGENT_RULES.md) - Rule 39 (sandbox association)

---

**Last Updated:** January 4, 2026
**Version:** 1.0
