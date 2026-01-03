# QUAD Framework - Tech Stack

## Overview

QUAD Framework is a full-stack Next.js application with PostgreSQL database.

---

## Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Next.js** | 15.x | React framework with App Router |
| **React** | 19.x | UI component library |
| **TypeScript** | 5.x | Type-safe JavaScript |
| **Tailwind CSS** | 3.x | Utility-first CSS framework |
| **Lucide React** | 0.460+ | Icon library |
| **Recharts** | 2.x | Interactive charts (pie, bar, line) |
| **NextAuth.js** | 4.x | Authentication library |

### Key Frontend Patterns
- **App Router** (Next.js 14) - File-based routing in `src/app/`
- **Server Components** - Default for static pages
- **Client Components** - `"use client"` for interactive forms
- **Responsive Design** - Mobile-first with Tailwind breakpoints

---

## Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Next.js API Routes** | 14.x | REST API endpoints in `src/app/api/` |
| **Prisma** | 5.x | TypeScript ORM for PostgreSQL |
| **PostgreSQL** | 15+ | Primary database |
| **bcrypt** | - | Password hashing |
| **jose** | - | JWT token handling |

### Database Connection
- **ORM**: Prisma (TypeScript types auto-generated from schema)
- **Connection**: Direct to PostgreSQL (shared with NutriNine)
- **Tables**: Prefixed with `QUAD_` for isolation

---

## Database Schema

All tables use `QUAD_` prefix to distinguish from NutriNine tables in shared database.

### Core Tables
| Table | Purpose |
|-------|---------|
| `QUAD_organizations` | Top-level customer organizations |
| `QUAD_users` | User accounts with roles (company_id column maps to org_id in Prisma) |
| `QUAD_domains` | Hierarchical project/team structure |
| `QUAD_domain_members` | User membership with allocation % |
| `QUAD_user_sessions` | Active login sessions |

### Resource Tables
| Table | Purpose |
|-------|---------|
| `QUAD_domain_resources` | Projects, integrations, repos |
| `QUAD_resource_attributes` | EAV pattern for flexible config |
| `QUAD_resource_attribute_requirements` | Validation rules per resource type |

### Feature Tables (New)
| Table | Purpose |
|-------|---------|
| `QUAD_adoption_matrix` | User Skill × Trust positioning |
| `QUAD_workload_metrics` | Assignments vs Completes vs Output |
| `QUAD_flows` | Q-U-A-D workflow items |
| `QUAD_flow_stage_history` | Stage transition audit trail |
| `QUAD_work_sessions` | Daily hours for 4-4-4 tracking |
| `QUAD_circles` | 4 functional circles per domain |
| `QUAD_circle_members` | User membership in circles |

### SSO & Multi-Tenant
| Table | Purpose |
|-------|---------|
| `company_domains` | Custom domains per company |
| `company_sso_configs` | Per-company SSO providers |
| `domain_verification_log` | DNS verification audit |

---

## Authentication

| Method | Status | Notes |
|--------|--------|-------|
| **Email/Password** | Active | Default for all users |
| **SSO (Okta/Azure AD)** | Planned | Per-company configuration |
| **Magic Links** | Planned | Passwordless option |

### Session Management
- **JWT Tokens** - Stored in httpOnly cookies
- **Session Duration** - 24 hours (configurable)
- **Refresh Tokens** - Planned for remember-me

---

## DevOps & Infrastructure

| Technology | Purpose |
|------------|---------|
| **Docker** | Containerization |
| **Docker Compose** | Local development orchestration |
| **Caddy** | Reverse proxy with auto SSL |
| **Mac Studio** | Primary hosting (development) |
| **GCP Cloud Run** | Production hosting (planned) |

### Environment Structure
| Environment | URL | Database |
|-------------|-----|----------|
| DEV | dev.quadframe.work | Local PostgreSQL |
| QA | qa.quadframe.work | Mac Studio PostgreSQL |
| PROD | quadframe.work | GCP Cloud SQL |

---

## AI Integration

| Provider | Purpose | Status |
|----------|---------|--------|
| **Claude (Anthropic)** | Code generation, estimation | Recommended |
| **OpenAI GPT-4** | Fallback AI provider | Supported |
| **Gemini (Google)** | Free tier development | Supported |
| **Ollama** | Self-hosted local models | Supported |

### AI Features
- **Estimation Agent** - Generates time estimates with safety buffers
- **Blueprint Agent** - Creates UI mockups from descriptions
- **Code Generation** - Generates boilerplate code

---

## External Integrations

| Integration | Purpose | Status |
|-------------|---------|--------|
| **Jira** | Issue tracking sync | Planned |
| **GitHub** | Repository integration | Planned |
| **Slack** | Notifications | Planned |
| **MS Teams** | Notifications | Planned |
| **Vaultwarden** | Secrets management | Active |

---

## Development Tools

| Tool | Purpose |
|------|---------|
| **VS Code** | Primary IDE |
| **Claude Code** | AI-assisted development |
| **ESLint** | Code linting |
| **Prettier** | Code formatting |
| **TypeScript** | Static type checking |

---

## File Structure

```
quadframework/
├── src/
│   ├── app/                    # Next.js App Router pages
│   │   ├── api/                # API routes (to be added)
│   │   ├── (pages)/            # Static pages
│   │   └── layout.tsx          # Root layout
│   ├── components/             # Reusable React components
│   └── lib/                    # Utility functions
├── database/
│   ├── sql/                    # SQL schema files
│   └── seed/                   # Seed data
├── prisma/
│   └── schema.prisma           # Prisma schema (to be added)
├── documentation/              # Project documentation
└── public/                     # Static assets
```

---

## Key Concepts

### 4-4-4 Principle
- **4 hours/day** - Focused work sessions
- **4 days/week** - Sustainable pace
- **4X efficiency** - AI amplification

### Q-U-A-D Methodology
- **Q**uestion - Capture requirements
- **U**nderstand - Analyze and break down
- **A**llocate - Assign resources
- **D**eliver - Build, test, deploy

### Adoption Matrix
- 3×3 grid: Skill Level × Trust Level
- Determines safety buffer for AI estimates
- From "AI Skeptic" (80% buffer) to "AI Champion" (10% buffer)

---

## Version History

| Date | Change |
|------|--------|
| Dec 30, 2025 | Initial Next.js setup |
| Dec 31, 2025 | Database schema created |
| Jan 1, 2026 | Adoption Matrix & Workload tables added |
| Jan 1, 2026 | Tech Stack document created |

---

*Last Updated: January 1, 2026*
