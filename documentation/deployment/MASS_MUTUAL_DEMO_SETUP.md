# QUAD Platform - Mass Mutual Demo Setup

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** Configuration and demo script for Mass Mutual presentation

---

## Mass Mutual Profile

**Company:** Massachusetts Mutual Life Insurance Company (Mass Mutual)
**Industry:** Financial Services / Life Insurance
**Size:** Large Enterprise (5,000+ employees)
**Tech Stack:** Enterprise-grade tools, separate cloud/ML teams

**Known Tools Used:**
- **SSO:** Okta (confirmed)
- **Chat:** Slack
- **Meetings:** Zoom
- **Email:** Outlook (Microsoft 365)
- **Source Control:** GitHub
- **Infrastructure:** Terraform
- **Cloud:** Likely AWS or Azure (need to confirm)

**Team Structure:**
- Separate cloud team
- Separate ML team
- Development teams
- QA teams
- DevOps/SRE teams

---

## Demo Configuration

### QUAD Platform Setup for Mass Mutual Demo

**Company Profile:**
```sql
-- Note: company_id column maps to org_id in Prisma code
INSERT INTO QUAD_organizations (name, admin_email, size, adoption_level, estimation_preset)
VALUES (
  'Massachusetts Mutual Life Insurance',
  'demo@massmutual.com',
  'enterprise',
  'hyperspace',
  'platonic'
);
```

**Enabled Integrations (Demo):**
```sql
-- Note: company_id column maps to org_id in Prisma code
INSERT INTO QUAD_org_integrations (company_id, integration_id, config)
VALUES
  -- SSO (Okta)
  ('mass-mutual-uuid', 'okta', '{
    "issuer": "https://massmutual.okta.com",
    "client_id": "DEMO_CLIENT_ID"
  }'),

  -- Source Control (GitHub)
  ('mass-mutual-uuid', 'github', '{
    "org": "massmutual",
    "default_branch": "main"
  }'),

  -- Project Management (Jira - assumed)
  ('mass-mutual-uuid', 'jira', '{
    "instance": "massmutual.atlassian.net",
    "project_key": "DEMO"
  }'),

  -- Communication (Slack)
  ('mass-mutual-uuid', 'slack', '{
    "workspace": "massmutual",
    "channels": {
      "dev": "#engineering",
      "qa": "#qa-team",
      "cloud": "#cloud-team"
    }
  }'),

  -- Meetings (Zoom - future)
  ('mass-mutual-uuid', 'zoom', '{
    "account_id": "DEMO_ACCOUNT_ID"
  }'),

  -- Email (Outlook - future)
  ('mass-mutual-uuid', 'outlook', '{
    "domain": "massmutual.com",
    "tenant_id": "DEMO_TENANT_ID"
  }');
```

---

## Two Demo Scenarios

### Scenario A: Existing Project (Read & Adapt)

**Use Case:** Mass Mutual has existing codebases, deployment strategies, and team workflows.

**QUAD Platform Workflow:**
1. User provides Git repo URL (e.g., `https://github.com/massmutual/insurance-api`)
2. QUAD Platform clones repo (read-only)
3. Agent analyzes project structure
4. Agent generates custom agent MD with company-specific do's/don'ts
5. Agent respects existing Terraform, Docker, CI/CD setup

**Example:**
```bash
# User provides repo URL in QUAD Platform UI
Repository: https://github.com/massmutual/insurance-api
Branch: main

# QUAD Platform analyzes
[Agent analyzing repository...]

Detected:
  ✅ Language: Java (Spring Boot 3.2.0)
  ✅ Build: Maven
  ✅ Infrastructure: Terraform (AWS)
  ✅ CI/CD: GitHub Actions
  ✅ Containerization: Docker
  ✅ Database: PostgreSQL (RDS)

Generated Custom Agent:
  → agent-massmutual-backend-developer.md
  → Contains Mass Mutual-specific do's/don'ts
```

---

### Scenario B: Fresh Start (We Provide Structure)

**Use Case:** Mass Mutual wants to start a new project with QUAD Platform's recommended structure.

**QUAD Platform Workflow:**
1. User selects "Start Fresh Project"
2. QUAD Platform provides complete project template
3. Includes best practices, folder structure, Terraform scripts
4. Customized for Mass Mutual's tech stack

**Example:**
```bash
# User selects "Start Fresh Project"
Project Type: Backend API
Language: Java (Spring Boot)
Cloud: AWS
Infrastructure: Terraform

# QUAD Platform generates
[Creating project structure...]

Generated:
  ✅ Folder structure
  ✅ Spring Boot boilerplate
  ✅ Terraform scripts (AWS)
  ✅ GitHub Actions CI/CD
  ✅ Docker configuration
  ✅ Custom agent MD
```

---

## Agent Structure Analysis Feature

### How It Works

**When user provides Git repo URL:**

**Step 1: Clone & Scan**
```bash
# QUAD Platform clones repo (read-only)
git clone --depth 1 https://github.com/massmutual/insurance-api /tmp/analysis

# Agent scans structure
tree -L 3 /tmp/analysis
```

**Step 2: Detect Tech Stack**
```bash
# Language detection
if [ -f "pom.xml" ]; then
  LANGUAGE="Java (Maven)"
elif [ -f "build.gradle" ]; then
  LANGUAGE="Java (Gradle)"
elif [ -f "package.json" ]; then
  LANGUAGE="Node.js"
elif [ -f "requirements.txt" ]; then
  LANGUAGE="Python"
fi

# Framework detection
if grep -q "spring-boot" pom.xml; then
  FRAMEWORK="Spring Boot $(mvn help:evaluate -Dexpression=project.parent.version -q -DforceStdout)"
fi

# Infrastructure detection
if [ -d "terraform/" ]; then
  INFRA="Terraform"
  CLOUD=$(grep -r "aws_" terraform/ && echo "AWS" || echo "Unknown")
fi

# CI/CD detection
if [ -d ".github/workflows" ]; then
  CI_CD="GitHub Actions"
elif [ -f ".gitlab-ci.yml" ]; then
  CI_CD="GitLab CI"
elif [ -f "Jenkinsfile" ]; then
  CI_CD="Jenkins"
fi

# Containerization
if [ -f "Dockerfile" ]; then
  CONTAINERIZATION="Docker"
fi

# Database
if grep -q "postgresql" pom.xml; then
  DATABASE="PostgreSQL"
elif grep -q "mysql" pom.xml; then
  DATABASE="MySQL"
fi
```

**Step 3: Generate Custom Agent MD**
```markdown
# Mass Mutual Backend Developer Agent
**Generated:** December 31, 2025
**Repository:** github.com/massmutual/insurance-api
**Customized for:** Massachusetts Mutual Life Insurance

---

## Your Tech Stack (Detected)

**Language:** Java 17 (Spring Boot 3.2.0)
**Build Tool:** Maven 3.9.0
**Infrastructure:** Terraform (AWS)
**CI/CD:** GitHub Actions
**Containerization:** Docker
**Database:** PostgreSQL (AWS RDS)
**Cloud:** AWS (us-east-1)

---

## Mass Mutual-Specific Do's and Don'ts

### ✅ Do's

**1. Follow Existing Terraform Structure**
```bash
# Your current structure:
terraform/
├── modules/
│   ├── api/
│   ├── database/
│   └── networking/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── main.tf

# ALWAYS use this structure for new services
# DON'T create separate Terraform repos
```

**2. Use GitHub Actions Workflow Template**
```yaml
# Your current workflow pattern (detected in .github/workflows/deploy.yml):
name: Deploy to AWS
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build with Maven
        run: mvn clean package
      - name: Deploy to AWS
        run: terraform apply -auto-approve

# ALWAYS use this pattern for new services
```

**3. Docker Image Naming Convention**
```bash
# Detected pattern:
massmutual/insurance-api:v1.2.3
massmutual/customer-service:v2.0.1

# Format: massmutual/<service-name>:<version>
# ALWAYS follow this naming convention
```

**4. Database Migration Strategy**
```bash
# Detected: Flyway migrations in src/main/resources/db/migration/
# Pattern: V1__create_tables.sql, V2__add_indexes.sql

# ALWAYS use Flyway for database migrations
# NEVER use Liquibase or manual SQL scripts
```

**5. Spring Boot Version**
```xml
<!-- Detected version: 3.2.0 -->
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>3.2.0</version>
</parent>

<!-- ALWAYS use Spring Boot 3.2.0 for consistency -->
<!-- DON'T upgrade without consulting cloud team -->
```

### ❌ Don'ts

**1. DON'T Change Cloud Region**
```bash
# Your current setup: us-east-1
# All services deployed to us-east-1

# DON'T deploy to other regions without cloud team approval
# Cloud team manages multi-region strategy
```

**2. DON'T Use Different Database**
```bash
# Standard: PostgreSQL on AWS RDS

# DON'T use:
- MySQL (not approved)
- MongoDB (ML team only)
- Local SQLite (dev only)
```

**3. DON'T Skip Code Reviews**
```bash
# Detected: All PRs require 2 approvals

# ALWAYS get 2 approvals before merging
# DON'T merge your own PRs
```

**4. DON'T Hardcode Secrets**
```bash
# Detected: AWS Secrets Manager used

# ALWAYS use AWS Secrets Manager
# DON'T use environment variables for secrets
# DON'T commit .env files
```

**5. DON'T Deploy to Production Without Terraform**
```bash
# ALWAYS use Terraform for infrastructure changes
# DON'T use AWS Console manually
# DON'T use CloudFormation (Terraform is standard)
```

---

## Mass Mutual Team Structure (Agent Access)

### Cloud Team
**Responsibilities:** Terraform, AWS infrastructure, VPCs, security groups
**Agent Access:** Infrastructure agent, Terraform agent
**Slack Channel:** #cloud-team

### ML Team
**Responsibilities:** Machine learning models, data pipelines
**Agent Access:** ML agent (future), Python agent
**Slack Channel:** #ml-team
**Database:** MongoDB (exception to PostgreSQL rule)

### Development Team
**Responsibilities:** Backend APIs, microservices
**Agent Access:** Backend developer agent, database agent
**Slack Channel:** #engineering

### QA Team
**Responsibilities:** Testing, quality assurance
**Agent Access:** QA agent, Selenium agent (future)
**Slack Channel:** #qa-team

---

## Integration with Existing Tools

### Okta SSO
**Already configured:** Yes
**Login URL:** https://massmutual.okta.com
**Agent behavior:** Auto-login via Okta

### GitHub
**Organization:** massmutual
**Agent behavior:**
- Read existing repos
- Suggest improvements
- Create PRs following company standards

### Slack
**Workspace:** massmutual.slack.com
**Agent behavior:**
- Post to #engineering for deployments
- Post to #cloud-team for infrastructure changes
- Post to #qa-team for test results

### Terraform
**Standard:** AWS provider, us-east-1
**Agent behavior:**
- Generate Terraform modules following existing structure
- Validate before applying
- Never modify cloud team's core infrastructure

---

## Sample Generated Agent Content

**Based on analysis of insurance-api repo:**

```markdown
## Mass Mutual Best Practices (Auto-Detected)

### API Design
- REST endpoints follow pattern: /api/v1/{resource}
- Use DTOs for all external communication
- Always return standard error response:
  {
    "error": "...",
    "message": "...",
    "timestamp": "..."
  }

### Error Handling
- Use @ControllerAdvice for global exception handling
- Custom exceptions: InsuranceNotFoundException, PolicyValidationException
- Always log errors with correlation ID

### Testing
- Minimum 80% code coverage (detected in pom.xml)
- Use JUnit 5 + Mockito
- Integration tests with Testcontainers

### Logging
- Use SLF4J + Logback
- JSON format for log output (AWS CloudWatch)
- Include correlation ID in all logs

### Security
- JWT tokens via Spring Security
- Role-based access control (ADMIN, USER, MANAGER)
- Rate limiting: 100 requests/minute per user
```

---

## Demo Script for Mass Mutual

### Part 1: Show Existing Project Analysis (5 minutes)

**Presenter:**
"Let me show you how QUAD Platform adapts to your existing infrastructure."

**Steps:**
1. Open QUAD Platform → Settings → Integrations
2. Show pre-configured Okta, GitHub, Slack
3. Navigate to "Configure Agent"
4. Enter: `https://github.com/massmutual/insurance-api`
5. Click "Analyze Repository"
6. Show generated agent MD with Mass Mutual-specific do's/don'ts

**Key Points:**
- "Notice it detected your Terraform setup"
- "It found your GitHub Actions workflow"
- "It respects your existing database migrations (Flyway)"
- "All do's/don'ts are based on YOUR codebase, not generic rules"

---

### Part 2: Show Fresh Project Generation (5 minutes)

**Presenter:**
"Now let's say you want to start a new microservice."

**Steps:**
1. Navigate to "New Project"
2. Select:
   - Template: Backend API (Spring Boot)
   - Cloud: AWS
   - Infrastructure: Terraform
   - Database: PostgreSQL
3. Click "Generate Project"
4. Show generated structure matching their existing pattern

**Key Points:**
- "This follows your existing folder structure"
- "Same Terraform module pattern as your current services"
- "Same GitHub Actions workflow"
- "Ready to deploy to your AWS us-east-1 region"

---

### Part 3: Show Team-Specific Agents (5 minutes)

**Presenter:**
"QUAD Platform supports your multi-team structure."

**Steps:**
1. Show agent list:
   - Backend Developer Agent (for dev team)
   - Infrastructure Agent (for cloud team)
   - ML Agent (for ML team)
   - QA Agent (for QA team)
2. Show how each agent has different tool access
3. Show Slack integration (#engineering, #cloud-team, #ml-team)

**Key Points:**
- "Cloud team only sees infrastructure tools"
- "ML team has MongoDB access (exception to PostgreSQL rule)"
- "Agents post to correct Slack channels automatically"

---

### Part 4: Show Integration Request (3 minutes)

**Presenter:**
"If you need a tool we don't support yet..."

**Steps:**
1. Navigate to Integrations
2. Scroll to bottom: "Don't see what you need?"
3. Click "Request Integration"
4. Enter: "Zoom" (meetings)
5. Show tracking page with 2-4 week timeline

**Key Points:**
- "We build custom integrations for enterprise customers"
- "Beta testing in your environment"
- "Then production patch deployed to your self-hosted instance"

---

## Questions to Ask Mass Mutual

**During Demo:**
1. "What cloud provider do you use?" (AWS, Azure, GCP?)
2. "Do you have a dedicated cloud team?" (Yes - confirmed)
3. "Do you have an ML team?" (Yes - confirmed)
4. "What's your current deployment strategy?" (Terraform - confirmed)
5. "What tools do you want integrated first?" (Okta, GitHub, Slack - confirmed)

**Post-Demo:**
1. "Can we access a sample repo to analyze?" (Get specific repo URL)
2. "What's your timeline for deployment?" (Q1 2025?)
3. "How many developers would use this?" (5 users free, then Pro/Enterprise)
4. "Who would be the QUAD_ADMIN?" (Get contact for setup)

---

## Follow-Up Materials

**Send to Mass Mutual After Demo:**
1. **Setup Guide:** How to self-host QUAD Platform on their AWS
2. **Terraform Scripts:** Pre-configured for AWS deployment
3. **Agent Templates:** Customized for Mass Mutual tech stack
4. **Integration List:** All 14 current integrations + roadmap
5. **Pricing Sheet:** Free (5 users), Pro ($99/mo), Enterprise ($499/mo)

---

## Success Criteria

**Demo is successful if:**
- ✅ Mass Mutual sees value in existing project analysis
- ✅ Mass Mutual understands multi-team agent structure
- ✅ Mass Mutual agrees to pilot with 5 users (free tier)
- ✅ Mass Mutual provides sample repo for customization
- ✅ Follow-up meeting scheduled for deployment discussion

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
