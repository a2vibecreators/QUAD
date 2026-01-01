# QUAD Platform - Enforced Deployment Workflows

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** How companies can enforce exact deployment steps via agent MD

---

## Overview

**Use Case:** Company requires EXACT deployment steps (not flexible, not "plain English").

**Example:** Mass Mutual requires these 5 exact steps to deploy to DEV:
1. `mvn clean package`
2. `docker build -t massmutual/insurance-api:v1.2.3 .`
3. `docker push massmutual/insurance-api:v1.2.3`
4. `kubectl apply -f k8s/dev/deployment.yaml`
5. `kubectl rollout status deployment/insurance-api -n dev`

**Solution:** Agent MD contains exact commands. Agent MUST follow them in order. No deviation allowed.

---

## How It Works

### Admin Creates Enforcement Rules in Agent MD

**Agent MD (Mass Mutual Backend Developer):**
```markdown
# Mass Mutual Backend Developer Agent

## ENFORCED WORKFLOWS (CRITICAL - DO NOT DEVIATE)

### Deploy to DEV (5 Steps - EXACT ORDER REQUIRED)

**When user says:** "Deploy to DEV" OR "Deploy to development"

**Agent MUST execute these exact commands in this exact order:**

```bash
# Step 1: Build
mvn clean package

# Step 2: Docker Build
docker build -t massmutual/insurance-api:{{VERSION}} .

# Step 3: Docker Push
docker push massmutual/insurance-api:{{VERSION}}

# Step 4: Deploy to Kubernetes
kubectl apply -f k8s/dev/deployment.yaml

# Step 5: Verify Deployment
kubectl rollout status deployment/insurance-api -n dev
```

**Variables to substitute:**
- `{{VERSION}}` - Get from pom.xml <version> tag

**Validation before running:**
- ✅ Check: pom.xml exists
- ✅ Check: Docker is running (`docker ps`)
- ✅ Check: kubectl is connected to dev cluster (`kubectl config current-context` == `dev-cluster`)

**If any step fails:**
- ❌ STOP immediately
- ❌ DO NOT continue to next step
- ❌ Show user exact error and which step failed

**Agent is NOT allowed to:**
- ❌ Skip any steps
- ❌ Change command order
- ❌ Add extra steps (unless user explicitly requests)
- ❌ Use different commands (e.g., `gradle` instead of `mvn`)
```

---

## Example: User Triggers Deployment

### Scenario 1: Plain English (Agent Converts to Exact Commands)

**User Input:**
```
User: "Deploy this to DEV"
```

**Agent Process:**
1. Reads MD: "Deploy to DEV" → ENFORCED WORKFLOW detected
2. Reads MD: 5 exact steps required
3. Validates environment (pom.xml exists, Docker running, kubectl connected)
4. Asks user for confirmation (optional, based on MD setting)

**Agent Response:**
```
I'll deploy to DEV using Mass Mutual's standard 5-step process:

Step 1: mvn clean package
Step 2: docker build -t massmutual/insurance-api:v1.2.3 .
Step 3: docker push massmutual/insurance-api:v1.2.3
Step 4: kubectl apply -f k8s/dev/deployment.yaml
Step 5: kubectl rollout status deployment/insurance-api -n dev

Proceed with deployment?
  [Yes, deploy]  [No, cancel]
```

**If user clicks "Yes, deploy":**
```bash
# Agent executes exactly as written in MD

[Step 1/5] Running: mvn clean package
[INFO] BUILD SUCCESS
✅ Step 1 complete

[Step 2/5] Running: docker build -t massmutual/insurance-api:v1.2.3 .
Successfully built abc123def456
✅ Step 2 complete

[Step 3/5] Running: docker push massmutual/insurance-api:v1.2.3
Pushed to registry
✅ Step 3 complete

[Step 4/5] Running: kubectl apply -f k8s/dev/deployment.yaml
deployment.apps/insurance-api configured
✅ Step 4 complete

[Step 5/5] Running: kubectl rollout status deployment/insurance-api -n dev
deployment "insurance-api" successfully rolled out
✅ Step 5 complete

🎉 Deployment to DEV successful!
```

---

### Scenario 2: User Tries to Skip Steps (Agent Refuses)

**User Input:**
```
User: "Just build the Docker image, skip Maven build"
```

**Agent Response (Based on MD Enforcement):**
```
❌ I cannot skip steps in the deployment workflow.

Mass Mutual's standard deployment process requires all 5 steps in order:
1. mvn clean package (cannot skip)
2. docker build
3. docker push
4. kubectl apply
5. kubectl rollout status

If you need to run steps individually for debugging, use:
  - "Run step 2 only" (for testing)
  - "Run steps 2-5" (if Maven already ran)

Would you like to run steps 2-5 (skipping Maven)?
  [Yes]  [No, run all 5 steps]
```

---

### Scenario 3: Step Fails (Agent Stops Immediately)

**User Input:**
```
User: "Deploy to DEV"
```

**Agent Execution:**
```bash
[Step 1/5] Running: mvn clean package
[INFO] BUILD SUCCESS
✅ Step 1 complete

[Step 2/5] Running: docker build -t massmutual/insurance-api:v1.2.3 .
ERROR: Cannot connect to Docker daemon
❌ Step 2 FAILED

🛑 Deployment stopped at Step 2/5

Error: Cannot connect to Docker daemon. Is Docker running?

Next steps:
1. Start Docker: systemctl start docker
2. Verify: docker ps
3. Retry: "Deploy to DEV"

I did NOT continue to steps 3-5 because step 2 failed.
```

---

## Variable Substitution

**Agent MD can define variables to substitute at runtime:**

**Example MD:**
```markdown
### Deploy to DEV

```bash
# Step 2: Docker Build
docker build -t massmutual/{{SERVICE_NAME}}:{{VERSION}} .

# Step 3: Docker Push
docker push massmutual/{{SERVICE_NAME}}:{{VERSION}}
```

**Variables:**
- `{{SERVICE_NAME}}` - Get from pom.xml <artifactId>
- `{{VERSION}}` - Get from pom.xml <version>
- `{{ENVIRONMENT}}` - "dev" (hardcoded for this workflow)
```

**Agent Process:**
1. Read pom.xml: `<artifactId>insurance-api</artifactId>`
2. Read pom.xml: `<version>1.2.3</version>`
3. Substitute: `massmutual/{{SERVICE_NAME}}:{{VERSION}}` → `massmutual/insurance-api:v1.2.3`

---

## Conditional Steps

**Agent MD can define conditions:**

**Example MD:**
```markdown
### Deploy to DEV

```bash
# Step 1: Build
mvn clean package

# Step 2 (conditional): Database Migration
# ONLY run if migrations/ folder has new files since last deploy
if [ "$(git diff HEAD~1 --name-only | grep 'src/main/resources/db/migration/')" ]; then
  mvn flyway:migrate
fi

# Step 3: Docker Build
docker build -t massmutual/insurance-api:{{VERSION}} .
```

**Conditions:**
- If new migration files exist → Run `mvn flyway:migrate`
- If no new migrations → Skip
```

**Agent Execution:**
```bash
[Step 1/5] Running: mvn clean package
✅ Complete

[Step 2/5] Checking: New database migrations?
Found: V3__create_policies.sql (new since last deploy)
Running: mvn flyway:migrate
✅ Migration complete

[Step 3/5] Running: docker build...
```

---

## Multi-Environment Workflows

**Company can define different workflows per environment:**

**Agent MD:**
```markdown
### Deploy to DEV (5 steps)
```bash
mvn clean package
docker build -t massmutual/insurance-api:{{VERSION}} .
docker push massmutual/insurance-api:{{VERSION}}
kubectl apply -f k8s/dev/deployment.yaml
kubectl rollout status deployment/insurance-api -n dev
```

### Deploy to STAGING (7 steps - requires approval)
```bash
mvn clean package
mvn test  # Run full test suite (required for staging)
docker build -t massmutual/insurance-api:{{VERSION}} .
docker push massmutual/insurance-api:{{VERSION}}
kubectl apply -f k8s/staging/deployment.yaml
kubectl rollout status deployment/insurance-api -n staging
# Step 7: Run smoke tests
curl https://staging.massmutual.com/health
```

**Approval required:** Cloud team lead must approve before step 5
**Slack notification:** Post to #staging-deploys when complete

### Deploy to PROD (10 steps - requires 2 approvals)
```bash
# ... (more rigorous steps)
```

**Approval required:**
- Approval 1: Cloud team lead
- Approval 2: VP of Engineering

**Slack notifications:**
- #prod-deploys (when started)
- #prod-deploys (when complete)
- #engineering (summary)
```

---

## Approval Workflows

**Agent MD can require approvals:**

**Example MD:**
```markdown
### Deploy to PROD

**Approval Requirements:**
- Cloud Team Lead: @john.doe
- VP Engineering: @jane.smith

**Agent MUST:**
1. Send Slack message to @john.doe: "Approve PROD deployment?"
2. Wait for response (timeout: 30 minutes)
3. If approved by John, send Slack to @jane.smith
4. Wait for response (timeout: 30 minutes)
5. If both approved, proceed with deployment
6. If either rejects, STOP and notify user

**Deployment cannot proceed without both approvals.**
```

**Agent Execution:**
```
User: "Deploy to PROD"

Agent:
  ✅ Pre-checks passed (tests passed, staging verified)
  📤 Requesting approval from @john.doe (Cloud Team Lead)

  Slack message sent:
    "🚀 PROD Deployment Request
     Service: insurance-api v1.2.3
     Requested by: developer@massmutual.com
     React with ✅ to approve or ❌ to reject"

  ⏳ Waiting for approval (timeout: 30 minutes)...

[10 minutes later]
  ✅ Approved by @john.doe
  📤 Requesting approval from @jane.smith (VP Engineering)

  ⏳ Waiting for approval (timeout: 30 minutes)...

[5 minutes later]
  ✅ Approved by @jane.smith

  🚀 Both approvals received. Starting deployment...

  [Step 1/10] Running: mvn clean package
  ...
```

---

## Rollback Workflows

**Agent MD can define rollback procedures:**

**Example MD:**
```markdown
### Rollback DEV Deployment

**When user says:** "Rollback DEV" OR "Undo DEV deployment"

**Agent MUST execute:**
```bash
# Step 1: Get previous version
PREV_VERSION=$(kubectl get deployment insurance-api -n dev -o jsonpath='{.metadata.annotations.previous-version}')

# Step 2: Rollback Kubernetes
kubectl rollout undo deployment/insurance-api -n dev

# Step 3: Verify
kubectl rollout status deployment/insurance-api -n dev

# Step 4: Notify Slack
# Post to #dev-deploys: "insurance-api rolled back to $PREV_VERSION"
```

**No approval required for DEV rollback**
**Approval required for STAGING/PROD rollback** (Cloud Team Lead)
```

---

## Safety Checks

**Agent MD can enforce safety checks:**

**Example MD:**
```markdown
### Deploy to PROD

**Safety Checks (MUST pass before deployment):**

```bash
# Check 1: Tests must pass
if ! mvn test; then
  echo "❌ Tests failed. Fix tests before deploying to PROD."
  exit 1
fi

# Check 2: Staging must be healthy
STAGING_HEALTH=$(curl -s https://staging.massmutual.com/health | jq -r '.status')
if [ "$STAGING_HEALTH" != "healthy" ]; then
  echo "❌ Staging is not healthy. Cannot deploy to PROD."
  exit 1
fi

# Check 3: No critical Jira tickets open
CRITICAL_TICKETS=$(jira issue list --jql "project=INSURANCE AND priority=Critical AND status!=Done")
if [ -n "$CRITICAL_TICKETS" ]; then
  echo "❌ Critical Jira tickets still open. Resolve before deploying."
  exit 1
fi

# Check 4: Code review approvals
PR_APPROVALS=$(gh pr view --json reviewDecision -q '.reviewDecision')
if [ "$PR_APPROVALS" != "APPROVED" ]; then
  echo "❌ PR not approved by 2 reviewers."
  exit 1
fi
```

**If ANY check fails → STOP deployment**
```

---

## Example: Complete Mass Mutual Agent MD

**File:** `agent-massmutual-backend-developer.md`

```markdown
# Mass Mutual Backend Developer Agent
**Generated:** December 31, 2025
**Customized for:** Massachusetts Mutual Life Insurance

---

## ENFORCED WORKFLOWS

### Deploy to DEV (5 steps)

**When user says:** "Deploy to DEV"

**Pre-checks:**
- ✅ pom.xml exists
- ✅ Docker is running
- ✅ kubectl connected to dev-cluster

**Steps:**
```bash
# 1. Build
mvn clean package

# 2. Docker Build
docker build -t massmutual/{{SERVICE_NAME}}:{{VERSION}} .

# 3. Docker Push
docker push massmutual/{{SERVICE_NAME}}:{{VERSION}}

# 4. Deploy
kubectl apply -f k8s/dev/deployment.yaml

# 5. Verify
kubectl rollout status deployment/{{SERVICE_NAME}} -n dev
```

**Variables:**
- `{{SERVICE_NAME}}` - from pom.xml <artifactId>
- `{{VERSION}}` - from pom.xml <version>

**On success:**
- Post to #engineering: "✅ Deployed {{SERVICE_NAME}} v{{VERSION}} to DEV"

**On failure:**
- Stop immediately
- Post to #engineering: "❌ DEV deployment failed at step X"

---

### Deploy to PROD (10 steps)

**Approvals required:**
- Cloud Team Lead (@john.doe)
- VP Engineering (@jane.smith)

**Safety checks:**
- Tests must pass (mvn test)
- Staging must be healthy
- No critical Jira tickets
- PR approved by 2 reviewers

**Steps:**
```bash
# ... (10 steps for PROD)
```

---

### Rollback

**When user says:** "Rollback [environment]"

**DEV/STAGING:**
```bash
kubectl rollout undo deployment/{{SERVICE_NAME}} -n {{ENVIRONMENT}}
```
No approval required.

**PROD:**
```bash
# Requires Cloud Team Lead approval first
```

---

## DO's and DON'Ts

✅ **ALWAYS** use these exact deployment steps
✅ **ALWAYS** wait for approvals (STAGING/PROD)
✅ **ALWAYS** run safety checks before PROD

❌ **NEVER** skip steps
❌ **NEVER** deploy to PROD without approvals
❌ **NEVER** use different commands (e.g., gradle instead of mvn)
```

---

## Summary

**Yes, companies can enforce EXACT commands in agent MD:**

✅ **Exact commands** - Not guidelines, literal commands
✅ **Exact order** - Step 1, 2, 3, 4, 5 (no skipping)
✅ **Variable substitution** - `{{VERSION}}` from pom.xml
✅ **Conditional steps** - Run if condition met
✅ **Approval workflows** - Require Slack approvals
✅ **Safety checks** - Tests, health checks, Jira tickets
✅ **Rollback procedures** - Exact rollback commands
✅ **Environment-specific** - Different rules for DEV/STAGING/PROD

**Agent behavior:**
- Plain English ("Deploy to DEV") → Agent converts to exact commands
- Exact commands shown to user for confirmation
- Agent executes exactly as written in MD (no deviation)
- If step fails, agent stops immediately
- If user tries to skip steps, agent refuses (unless MD allows)

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
