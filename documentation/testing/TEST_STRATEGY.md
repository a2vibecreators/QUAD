# QUAD Framework - Test Strategy

**Version:** 1.0
**Last Updated:** January 2026

---

## Test Categories

| Category | Purpose | Count | Scripts |
|----------|---------|-------|---------|
| **Startup** | Verify services are running | 12 checks | `test-startup.sh` |
| **Feature** | Test individual APIs | ~50 tests | `test-feature-*.sh` |
| **Journey** | End-to-end user flows | 4 journeys | `test-user-journey-e2e.sh` |
| **Load** | Performance testing | TBD | Future |

---

## Feature Test Coverage

### Core Tables (15 tables)

| Table | API Routes | Test Script | Status |
|-------|------------|-------------|--------|
| QUAD_organizations | /api/organizations | test-feature-01.sh | TODO |
| QUAD_org_members | /api/organizations/[id]/members | test-feature-01.sh | TODO |
| QUAD_domains | /api/domains | test-feature-02.sh | TODO |
| QUAD_domain_members | /api/domains/[id]/members | test-feature-02.sh | TODO |
| QUAD_circles | /api/circles | test-feature-03.sh | TODO |
| QUAD_circle_members | /api/circles/[id]/members | test-feature-03.sh | TODO |
| QUAD_users | /api/auth/* | test-feature-04.sh | TODO |
| QUAD_roles | /api/roles | test-feature-05.sh | TODO |
| QUAD_core_roles | /api/core-roles | test-feature-05.sh | TODO |
| QUAD_role_assignments | /api/roles/assign | test-feature-05.sh | TODO |

### Work Management (10 tables)

| Table | API Routes | Test Script | Status |
|-------|------------|-------------|--------|
| QUAD_cycles | /api/cycles | test-feature-10.sh | TODO |
| QUAD_tickets | /api/tickets | test-feature-11.sh | TODO |
| QUAD_ticket_comments | /api/tickets/[id]/comments | test-feature-11.sh | TODO |
| QUAD_ticket_time_logs | /api/tickets/[id]/time-logs | test-feature-11.sh | TODO |
| QUAD_flows | /api/flows | test-feature-12.sh | TODO |
| QUAD_flow_transitions | /api/flows/[id]/transitions | test-feature-12.sh | TODO |

### AI & Memory (8 tables)

| Table | API Routes | Test Script | Status |
|-------|------------|-------------|--------|
| QUAD_ai_configs | /api/ai-config | test-feature-20.sh | TODO |
| QUAD_ai_usage | /api/ai/usage | test-feature-20.sh | TODO |
| QUAD_memory_contexts | /api/memory/context | test-feature-21.sh | TODO |
| QUAD_memory_documents | /api/memory/documents | test-feature-21.sh | TODO |
| QUAD_memory_templates | /api/memory/templates | test-feature-21.sh | TODO |

### Integrations (6 tables)

| Table | API Routes | Test Script | Status |
|-------|------------|-------------|--------|
| QUAD_git_integrations | /api/integrations/git | test-feature-30.sh | TODO |
| QUAD_meeting_integrations | /api/integrations/meeting | test-feature-31.sh | TODO |
| QUAD_meetings | /api/meetings | test-feature-31.sh | TODO |
| QUAD_pull_requests | /api/pull-requests | test-feature-32.sh | TODO |

---

## User Journey Tests

### Journey 1: Onboarding
```
Register → Verify Email → Create Organization → Create Domain → Invite Team
```

### Journey 2: Team Setup
```
Accept Invite → Create Circle → Assign Roles → Configure AI Tier
```

### Journey 3: Work Cycle
```
Create Cycle → Create Tickets → Assign Tickets → Track Progress → Complete Cycle
```

### Journey 4: AI-Assisted Flow
```
Create Flow → AI Analyze → Branch Creation → PR Review → Merge
```

---

## How to Find Stuck Processes

### Local Development

```bash
# Check CPU usage of all services
ps aux | grep -E "next|java|postgres" | grep -v grep

# Find processes using specific ports
lsof -i :3000   # Next.js
lsof -i :14101  # Java
lsof -i :14201  # PostgreSQL

# Kill stuck process
kill $(lsof -t -i:3000)

# Check what a process is doing
sample <PID> 5  # macOS: sample process for 5 seconds
```

### GCP Cloud Run

Cloud Run automatically handles stuck containers:

1. **Liveness Probe**: Cloud Run checks `/api/_health` every 10s
2. **Startup Probe**: Allows up to 300s for container to start
3. **Auto-Restart**: If liveness fails 3x, container is replaced
4. **Memory Limit**: Container killed if exceeds memory limit

**Configuration (in Dockerfile):**
```yaml
# Cloud Run will use these automatically
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/_health || exit 1
```

**Monitor in GCP Console:**
```bash
# View logs
gcloud run services logs read quadframework-web --limit=100

# Check health
gcloud run services describe quadframework-web --format='value(status.conditions)'

# View metrics
# Console: Cloud Run → quadframework-web → Metrics → CPU, Memory, Request latency
```

---

## Test Execution Order

### Daily (Startup Check)
```bash
cd test/scripts
./test-startup.sh
```

### After Feature Changes
```bash
./test-feature-XX.sh  # Run relevant feature test
```

### Before Deployment
```bash
./test-all.sh         # Run all tests
./test-user-journey-e2e.sh  # Run E2E journeys
```

---

## Success Criteria

A test passes when:
- ✅ API returns expected HTTP status codes
- ✅ Response body matches expected structure
- ✅ Database state is correct after operations
- ✅ Error cases return proper error messages
- ✅ Authentication/authorization works correctly

---

**See Also:**
- [test-startup.sh](../scripts/test-startup.sh) - Startup health checks
- [test-user-journey-e2e.sh](../scripts/test-user-journey-e2e.sh) - E2E user flows
