# QUAD Framework

**Quick Unified Agentic Development** - A modern software development methodology for the AI era.

---

## 📚 Table of Contents

1. [🎯 What is QUAD?](#-what-is-quad) - Two products, one methodology
2. [🏗️ Architecture Overview](#️-architecture-overview) - How components fit together
3. [🚀 Quick Start (Sharath Start Here!)](#-quick-start-sharath-start-here) - Get up and running
4. [📦 Repository Structure](#-repository-structure) - Git submodules
5. [🔧 Tech Stack](#-tech-stack) - Technologies used
6. [🌐 Environments](#-environments) - DEV, QA, PROD
7. [📖 Documentation](#-documentation) - Deep dive into details

---

## 🎯 What is QUAD?

QUAD is **two products**:

### 1. quadframe.work (Static Marketing Site)
- **Live:** https://quadframe.work
- **Purpose:** Learn about QUAD methodology, read docs, watch videos
- **Stack:** Next.js static site (free forever)
- **Hosted:** GCP Cloud Run

### 2. QUAD Platform (Self-Hosted Product)
- **Purpose:** AI-powered development environment for teams
- **Stack:** Next.js + Java Spring Boot + PostgreSQL + Docker
- **Deployment:** Customer's own infrastructure (Mac Studio, AWS, Azure, GCP)
- **Pricing:** Free tier (5 users) → Pro ($99/month) → Enterprise ($499/month)

**This repo:** Source code for BOTH products (shared codebase).

---

## 📜 Patent Notice

**QUAD Platform is Patent Pending**

[![Patent Pending](https://img.shields.io/badge/Patent-Pending-blue?style=for-the-badge)](documentation/patent/)

- **U.S. Provisional Patent Application No. 63/956,810**
- **Filing Date:** January 9, 2026
- **Status:** Patent Pending (12-month protection)

**Protected Innovations:**
- ✅ Pre-generation compliance enforcement for AI code generation
- ✅ Meta-AI architecture with restricted context (zero hallucination)
- ✅ Progressive enforcement levels (alpha/beta/production)
- ✅ Multi-agent cost-optimized code generation
- ✅ QUAD Language domain-specific programming language

**Full patent documentation:** [documentation/patent/](documentation/patent/)

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        QUAD Platform Architecture                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  External Clients                                                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ VS Code Extension │ Mobile Apps │ Browser UI │ CLI Tools    │  │
│  └───────┬──────────────────┬─────────────┬──────────┬──────────┘  │
│          │                  │             │          │              │
│          │ HTTPS            │ HTTPS       │ HTTPS    │ HTTPS        │
│          │                  │             │          │              │
│          └──────────────────┴─────────────┴──────────┘              │
│                             │                                        │
│                   ┌─────────▼──────────┐                            │
│                   │   quad-api (3100)  │ ← API Gateway              │
│                   │  [Rate Limiting]   │   (External clients)       │
│                   │  [API Key Auth]    │                            │
│                   │  [Whitelist]       │                            │
│                   └─────────┬──────────┘                            │
│                             │                                        │
│  ┌──────────────────────────┼──────────────────────────────────┐   │
│  │ Internal Docker Network  │                                   │   │
│  │                          │                                   │   │
│  │  ┌──────────────┐  ┌─────▼────────────┐  ┌────────────────┐ │   │
│  │  │  quad-web    │  │ quad-services    │  │ postgres-quad  │ │   │
│  │  │  (Next.js)   ├──►  (Java Spring)   ├──► (PostgreSQL)   │ │   │
│  │  │  Port: 3000  │  │  Port: 8080      │  │ Port: 5432     │ │   │
│  │  └──────────────┘  └──────────────────┘  └────────────────┘ │   │
│  │                                                               │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                             │                                        │
│                   ┌─────────▼──────────┐                            │
│                   │   Caddy (80/443)   │ ← Reverse Proxy            │
│                   │   [SSL/HTTPS]      │   (dev/qa.quadframe.work)  │
│                   └────────────────────┘                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Purpose | Technology |
|-----------|---------|------------|
| **quad-web** | Web UI (marketing + dashboard) | Next.js 15 + TypeScript + Tailwind |
| **quad-services** | Business logic, REST APIs, OAuth | Java Spring Boot 3.2.1 + JPA |
| **quad-database** | Schema, migrations, SQL files | PostgreSQL 15 + SQL |
| **quad-api** | API gateway for external clients | Node.js Express + rate limiting |
| **Caddy** | SSL/HTTPS termination | Caddy 2 reverse proxy |

**Data Flow:**
1. User visits https://dev.quadframe.work → Caddy → quad-web (Next.js)
2. quad-web calls quad-services (Java backend) via HTTP
3. quad-services queries PostgreSQL database
4. VS Code extension/Mobile apps → quad-api (gateway) → quad-services

---

## 🚀 Quick Start (Sharath Start Here!)

### Step 1: Check Prerequisites

```bash
# Clone repo
git clone --recurse-submodules git@github.com:a2Vibes/QUAD.git
cd QUAD

# Check if you have everything installed
./deployment/scripts/check-prerequisites.sh
```

**What gets checked:**
- ✅ Docker Desktop (required)
- ✅ Node.js 18+ (required)
- ✅ Java 17+ (required)
- ✅ Maven (required)
- ✅ Git (required)
- ✅ Bitwarden CLI (required - for Vaultwarden secrets)
- ⚠️ jq (optional - JSON processor)
- ⚠️ migra (optional - database schema migrations)

### Step 2: Run Interactive Setup

| Platform | Command |
|----------|---------|
| **Mac/Linux** | `./deployment/scripts/setup.sh` |
| **Windows (PowerShell)** | `powershell -ExecutionPolicy Bypass -File .\deployment\scripts\setup.ps1` |
| **Windows (CMD)** | `.\deployment\scripts\setup.bat` |

**What the setup script does:**
1. ✅ Checks prerequisites
2. ✅ Fetches OAuth secrets from Vaultwarden
3. ✅ Sets up Caddy reverse proxy
4. ✅ Creates Docker networks
5. ✅ Asks if you want to deploy now

### Step 3: Access Your Deployment

| Environment | URL | Purpose |
|-------------|-----|---------|
| **DEV** | https://dev.quadframe.work | Development environment |
| **QA** | https://qa.quadframe.work | QA/Testing environment |
| **PROD** | https://quadframe.work | Production (GCP Cloud Run) |

### Step 4: Read Project Rules

Before making any code changes:

1. **[CLAUDE.md](CLAUDE.md)** - Complete project documentation
   - Tech stack, architecture, deployment
   - OAuth configuration, secrets management
   - Container names, DNS configuration

2. **[.claude/rules/AGENT_RULES.md](.claude/rules/AGENT_RULES.md)** - 11 core development rules
   - Session management, todo tracking
   - Database tables (QUAD_ prefix)
   - Git commit conventions

3. **[deployment/README.md](quad-web/deployment/README.md)** - Deployment guide
   - Environment files (.env)
   - Container troubleshooting
   - Caddy configuration

### Need Help?

- **Architecture:** [documentation/architecture/](documentation/architecture/)
- **Database:** [documentation/database/](documentation/database/)
- **API Reference:** [documentation/api/](documentation/api/)
- **Slack:** #quad-dev channel
- **Ask:** Suman or Sharath

---

## 📦 Repository Structure

**Git Organization:** Parent repo with submodules (microservices pattern)

```
a2Vibes/QUAD/                            # Parent repo (THIS REPO)
├── quad-web/                             # Git Submodule → Next.js frontend
├── quad-services/                        # Git Submodule → Java backend
├── quad-database/                        # Git Submodule → SQL schema
├── quad-api/                             # Git Submodule → API Gateway
├── quad-vscode/                          # Git Submodule → VS Code extension
├── quad-ios/                             # Git Submodule → iOS app (future)
├── quad-android/                         # Git Submodule → Android app (future)
├── deployment/                           # Deployment scripts + Caddy config
│   ├── scripts/
│   │   ├── check-prerequisites.sh       # Prerequisites checker
│   │   ├── setup.sh                      # Interactive setup (Mac/Linux)
│   │   ├── setup.bat                     # Interactive setup (Windows CMD)
│   │   ├── setup.ps1                     # Interactive setup (PowerShell)
│   │   ├── fetch-secrets.sh              # Vaultwarden secret fetcher
│   │   └── deploy.sh                     # Main deployment script
│   ├── caddy/
│   │   ├── Caddyfile.dev                # Caddy config for DEV
│   │   └── Caddyfile.qa                 # Caddy config for QA
│   └── README.md                         # Deployment documentation
├── documentation/                        # Comprehensive docs
│   ├── architecture/                    # Architecture docs
│   ├── database/                        # Database schema docs
│   ├── api/                             # API reference
│   ├── deployment/                      # Deployment guides
│   └── guides/                          # How-to guides
├── .claude/                              # Claude Code agent rules
│   ├── commands/                        # Slash commands (/quad-init)
│   └── rules/                           # Agent behavior rules
├── CLAUDE.md                             # Project overview (start here!)
└── README.md                             # This file
```

### Submodule Workflow

```bash
# Pull latest changes (parent + all submodules)
git pull --recurse-submodules

# Update submodules to latest
git submodule update --remote --merge

# Make changes in a submodule
cd quad-web
git add .
git commit -m "feat: Add new feature"
git push

# Update parent repo to point to new commit
cd ..
git add quad-web
git commit -m "Update quad-web submodule"
git push
```

---

## 🔧 Tech Stack

### Frontend (quad-web)
- **Framework:** Next.js 15.5 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Auth:** NextAuth.js (OAuth 2.0)
- **State:** React Context

### Backend (quad-services)
- **Framework:** Spring Boot 3.2.1
- **Language:** Java 17
- **ORM:** JPA/Hibernate
- **Build:** Maven 3.9+
- **Auth:** JWT + BCrypt

### Database (quad-database)
- **Database:** PostgreSQL 15
- **Schema:** Raw SQL files (source of truth)
- **Migrations:** migra (PostgreSQL schema diff tool)
- **Philosophy:** Pure separation - database operations independent from Java/Spring Boot

### Infrastructure
- **Containers:** Docker + Docker Compose
- **Reverse Proxy:** Caddy 2 (automatic SSL)
- **Secrets:** Vaultwarden @ vault.a2vibes.tech (GCP-hosted, shared across all A2Vibe projects)
- **DEV/QA:** Mac Studio (local Docker)
- **PROD:** GCP Cloud Run

---

## 🌐 Environments

### DEV (Development)

| Service | Container | Port | URL |
|---------|-----------|------|-----|
| Web | `quad-web-dev` | 14001 | https://dev.quadframe.work |
| Java API | `quad-services-dev` | 14101 | http://quad-services-dev:8080 |
| API Gateway | `quad-api-dev` | 14301 | https://dev-api.quadframe.work |
| Database | `quad-db-dev` | 14201 | localhost:14201 |

### QA (Quality Assurance)

| Service | Container | Port | URL |
|---------|-----------|------|-----|
| Web | `quad-web-qa` | 15001 | https://qa.quadframe.work |
| Java API | `quad-services-qa` | 15101 | http://quad-services-qa:8080 |
| API Gateway | `quad-api-qa` | 15301 | https://qa-api.quadframe.work |
| Database | `quad-db-qa` | 15201 | localhost:15201 |

### PROD (Production)

| Service | Platform | URL |
|---------|----------|-----|
| Web | GCP Cloud Run | https://quadframe.work |
| API Gateway | GCP Cloud Run | https://api.quadframe.work |
| Database | GCP Cloud SQL | Private IP |

---

## 📖 Documentation

### Essential Reading

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [CLAUDE.md](CLAUDE.md) | Complete project guide | Before any work |
| [.claude/rules/AGENT_RULES.md](.claude/rules/AGENT_RULES.md) | 11 development rules | Before coding |
| [deployment/README.md](quad-web/deployment/README.md) | Deployment guide | Before deploying |

### Deep Dive Documentation

**📚 Complete documentation with 144+ markdown files organized by topic:**

➡️ **[documentation/sitemap/sitemap_documentation.md](documentation/sitemap/sitemap_documentation.md)** - Complete documentation index (all 144 files)

**Essential Guides:**
| Document | Description |
|----------|-------------|
| [Getting Started](documentation/getting-started/GETTING_STARTED.md) | Quick start guide for QUAD Platform |
| [Team Access](documentation/getting-started/TEAM_ACCESS.md) | Vaultwarden setup and team collaboration |
| [Vaultwarden Setup](documentation/security/VAULTWARDEN_SETUP.md) | Centralized secrets management (vault.a2vibes.tech) |
| [QUAD Methodology](documentation/methodology/QUAD.md) | Core QUAD methodology (Q-U-A-D stages) |
| [Agent Rules](documentation/agents/AGENT_RULES.md) | 40 rules for AI agent development |
| [Architecture](documentation/architecture/ARCHITECTURE.md) | System architecture overview |
| [Database Schema](documentation/database/DATABASE_SCHEMA.md) | Complete database schema (15 tables) |
| [API Reference](documentation/api/API_REFERENCE.md) | REST API endpoints |
| [Token Optimization](documentation/ai/TOKEN_OPTIMIZATION.md) | AI cost reduction strategies |
| [OAuth Implementation](documentation/auth/OAUTH_IMPLEMENTATION.md) | OAuth SSO setup guide |
| [Deployment Modes](documentation/deployment/DEPLOYMENT_MODES.md) | SaaS vs self-hosted vs hybrid |

**Website Sitemaps:**
| Sitemap | Description |
|---------|-------------|
| [sitemap_static.md](documentation/sitemap/sitemap_static.md) | Public marketing pages (/, /concept, /pitch) |
| [sitemap_login.md](documentation/sitemap/sitemap_login.md) | Authenticated pages (/dashboard, /domains, /tickets) |
| [sitemap_documentation.md](documentation/sitemap/sitemap_documentation.md) | Complete documentation index (this sitemap) |

**Browse by Topic:**
- 📁 [Getting Started](documentation/getting-started/) - Setup and onboarding
- 📁 [Methodology](documentation/methodology/) - QUAD methodology docs
- 📁 [Architecture](documentation/architecture/) - System design
- 📁 [Features](documentation/features/) - Product features
- 📁 [Authentication](documentation/auth/) - OAuth and security
- 📁 [Security](documentation/security/) - Secrets management (Vaultwarden)
- 📁 [Agents](documentation/agents/) - AI agent templates
- 📁 [AI & Optimization](documentation/ai/) - AI models and token costs
- 📁 [API](documentation/api/) - API reference
- 📁 [Database](documentation/database/) - Database schema
- 📁 [Deployment](documentation/deployment/) - Deployment guides
- 📁 [Integration](documentation/integration/) - Third-party integrations
- 📁 [Testing](documentation/testing/) - Test strategies
- 📁 [Strategy](documentation/strategy/) - Business strategy
- 📁 [Case Studies](documentation/case-studies/) - Real-world examples
- 📁 [Internal](documentation/internal/) - Team documentation

---

## 🤝 Contributing

### Git Workflow

1. **Clone with submodules:**
   ```bash
   git clone --recurse-submodules git@github.com:a2Vibes/QUAD.git
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes, commit, push:**
   ```bash
   git add .
   git commit -m "feat: Your feature description"
   git push origin feature/your-feature-name
   ```

4. **Create pull request** on GitHub

### Branch Strategy

| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Stable production code | ✅ Protected |
| `sumanMain` | Suman's working branch | ⚠️ Push freely |
| `SharuMain` | Sharath's working branch | ⚠️ Push freely |

**Never push directly to `main`** - always use pull requests.

---

## 📝 License

Copyright 2026 A2 Vibe Creators LLC. All rights reserved.

QUAD™ is a trademark of A2 Vibe Creators LLC.

---

## 🎉 You're All Set!

**Next Steps:**
1. Run `./deployment/scripts/setup.sh` (interactive setup)
2. Access https://dev.quadframe.work
3. Read [CLAUDE.md](CLAUDE.md) (project rules)
4. Join #quad-dev on Slack

**Happy coding, macha! 🚀**
