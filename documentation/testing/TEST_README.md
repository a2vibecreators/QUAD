# QUAD Framework Test Suite

**Purpose:** Centralized testing infrastructure for QUAD Framework backend API

---

## Folder Structure

```
test/
├── README.md                     # This file
├── scripts/                      # Test scripts
│   ├── test-startup.sh           # Startup health check (run first!)
│   ├── test-user-journey-e2e.sh  # End-to-end user journey tests
│   └── test-feature-*.sh         # Individual feature tests
└── documentation/                # Testing guides
    ├── TEST_STRATEGY.md          # Testing approach
    └── TEST_RESULTS.md           # Test execution results
```

---

## Quick Start

### 1. Run Startup Check (Always First!)

```bash
cd test/scripts
./test-startup.sh
```

This verifies:
- Next.js (port 3000)
- Java Backend (port 14101)
- PostgreSQL (port 14201)
- Basic API endpoints

### 2. Run Journey Tests

```bash
./test-user-journey-e2e.sh
```

---

## Service URLs

| Service | DEV URL | QA URL |
|---------|---------|--------|
| Next.js Web | http://localhost:3000 | https://dev.quadframe.work |
| Java API | http://localhost:14101/api | https://dev-api.quadframe.work |
| PostgreSQL | localhost:14201 | localhost:15201 |

---

## Test Categories

### 1. Startup Tests
- Service health checks
- Port availability
- Database connectivity
- Basic endpoint responses

### 2. Journey Tests (E2E)
- **Journey 1:** Onboarding (Register → Create Org → Create Domain)
- **Journey 2:** Team Setup (Invite → Create Circles → Assign Roles)
- **Journey 3:** Work Management (Create Cycle → Create Tickets → Track Flow)

### 3. Feature Tests
- Individual API endpoint tests
- CRUD operations
- Authentication/Authorization
- Error handling

---

## Environment Configuration

```bash
# Override default URLs
NEXTJS_URL=https://dev.quadframe.work ./test-startup.sh
JAVA_API_URL=https://dev-api.quadframe.work/api ./test-startup.sh
```

---

## Prerequisites

Before running tests:

1. **Start Services:**
   ```bash
   # Terminal 1: Next.js
   cd /Users/semostudio/git/a2vibecreators/quadframework
   npm run dev

   # Terminal 2: Java Backend
   cd quad-services
   JAVA_HOME=/opt/homebrew/opt/openjdk@21 mvn spring-boot:run

   # Database should already be running
   docker ps | grep postgres-dev
   ```

2. **Verify Database:**
   ```bash
   docker exec postgres-dev psql -U quad_user -d quad_dev_db -c "\dt QUAD_*"
   ```

---

## Test Results Format

```
╔════════════════════════════════════════════════════════════╗
║          QUAD Framework - Startup Health Check             ║
╚════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. Next.js Web App (Port 3000)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TEST: Checking if Next.js is running...
  ✓ PASSED: Next.js is running on port 3000
  TEST: Checking Next.js health endpoint...
  ✓ PASSED: Next.js homepage returned HTTP 200

[... more tests ...]

╔════════════════════════════════════════════════════════════╗
║         ALL SERVICES HEALTHY - READY FOR TESTING!          ║
╚════════════════════════════════════════════════════════════╝
```

---

## Troubleshooting

### Services Not Running
```bash
# Start all services
cd /Users/semostudio/git/a2vibecreators/quadframework
npm run dev &
cd quad-services && JAVA_HOME=/opt/homebrew/opt/openjdk@21 mvn spring-boot:run &
docker start postgres-dev
```

### Database Connection Issues
```bash
# Check database container
docker ps | grep postgres-dev
docker logs postgres-dev --tail 20

# Restart if needed
docker restart postgres-dev
```

### Port Conflicts
```bash
# Check what's using ports
lsof -i :3000
lsof -i :14101
lsof -i :14201
```

---

**Last Updated:** January 2026
