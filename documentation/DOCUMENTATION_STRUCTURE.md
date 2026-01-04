# QUAD Framework Documentation Structure

**Last Updated:** January 3, 2026

---

## Documentation Folder Organization

```
documentation/
├── README.md                           # Documentation index
├── GETTING_STARTED.md                  # Quick start guide
│
├── methodology/                        # QUAD Methodology (Public)
│   ├── QUAD.md                         # Core concept
│   ├── QUAD_SUMMARY.md                 # Executive summary
│   ├── QUAD_DETAILS.md                 # Deep dive
│   ├── QUAD_FLOW.md                    # Workflow diagrams
│   ├── QUAD_PITCH.md                   # Pitch deck content
│   ├── QUAD_DISCOVERY.md               # Discovery phase
│   ├── QUAD_JARGONS.md                 # Terminology glossary
│   ├── QUAD_CASE_STUDY.md              # Case studies overview
│   ├── QUAD_PLATFORM.md                # Platform description
│   └── quad-workflow/                  # Detailed workflows
│       ├── QUAD_PROJECT_LIFECYCLE.md
│       ├── QUAD_ADOPTION_LEVELS.md
│       ├── QUAD_ADOPTION_JOURNEY.md
│       └── ...
│
├── ai/                                 # AI Strategy & Models (NEW)
│   ├── AI_MODELS_CATALOG.md            # Model reference
│   ├── AI_PLATFORM_COMPARISON.md       # vs Cursor, Antigravity
│   ├── AI_PRICING_TIERS.md             # Turbo/Balanced/Quality
│   ├── AI_PIPELINE_TIERS.md            # Task routing
│   ├── MULTI_PROVIDER_STRATEGY.md      # Claude + Gemini + Groq
│   ├── AI_CONTEXT_MANAGEMENT.md        # Memory & context
│   └── TOKEN_OPTIMIZATION.md           # Cost savings
│
├── architecture/                       # System Architecture
│   ├── ARCHITECTURE.md                 # Overview
│   ├── ARCHITECTURE_ROADMAP.md         # Future plans
│   ├── BROWSER_IDE_RESEARCH.md         # Competitor IDE analysis (Bolt, Replit, etc.)
│   ├── OBJECT_MODEL.md                 # Domain objects
│   ├── SESSION_MANAGEMENT.md           # User sessions
│   └── MULTI_TENANT_SETUP.md           # Domain isolation
│
├── features/                           # Feature Documentation (NEW)
│   ├── PHASE1_WORKFLOW.md              # Phase 1 features
│   ├── PHASE1_CROWD_PULLING.md         # Key differentiators
│   ├── ONBOARDING_FLOW.md              # User onboarding
│   ├── MASTER_FLOWS.md                 # All user flows
│   ├── AUTHENTICATION_FLOW.md          # Login/SSO
│   ├── BLUEPRINT_AGENT.md              # AI project planning
│   └── REPORTS_SYSTEM.md               # Reporting features
│
├── api/                                # API Documentation (NEW)
│   ├── API_REFERENCE.md                # Endpoint reference
│   ├── BLUEPRINT_AGENT_API.md          # Blueprint endpoints
│   ├── BLUEPRINT_AGENT_SERVICES.md     # Service layer
│   └── DATABASE_AGENT_DESIGN.md        # DB operations
│
├── database/                           # Database Documentation (NEW)
│   ├── DATABASE_SCHEMA.md              # Table descriptions
│   ├── CODEBASE_INDEX_SYSTEM.md        # Code indexing
│   └── migrations/                     # Migration notes
│
├── deployment/                         # Deployment & Ops
│   ├── DEPLOYMENT_MODES.md             # SaaS vs Self-hosted
│   ├── GOOGLE_CLOUD_MIGRATION.md       # GCP setup
│   ├── INFRASTRUCTURE_STRATEGY.md      # Infra decisions
│   └── SETUP_INSTRUCTIONS.md           # Local dev setup
│
├── integration/                        # Third-Party Integrations
│   ├── CLOUDFLARE_INTEGRATION.md       # CDN, DNS, tunnels
│   ├── INTEGRATION_REQUEST_WORKFLOW.md # How to add integrations
│   ├── TOOL_INTEGRATION_METHODS.md     # OAuth, webhooks, etc.
│   ├── SSO_SETUP_GUIDE.md              # Google, GitHub SSO
│   └── AGENT_TOOLS_REFERENCE.md        # MCP tools
│
├── case-studies/                       # Industry Examples
│   ├── ecommerce.md
│   ├── hospital.md
│   ├── education.md
│   ├── manufacturing.md
│   └── software-agency.md
│
├── testing/                            # Testing Documentation
│   ├── TEST_JOURNEYS.md                # User journey tests
│   └── journeys/                       # Detailed test cases
│
├── strategy/                           # Business Strategy (NEW)
│   ├── SUCCESS_STORY.md                # Market opportunity
│   ├── COMPETITOR_COMPARISON.md        # vs Linear, Jira, etc.
│   ├── IP_STRATEGY.md                  # Patents, trademarks
│   ├── SERVICE_MODEL_ANALYSIS.md       # Pricing strategy
│   └── DEVELOPMENT_MODEL.md            # 4-4-4 principle
│
├── internal/                           # Internal Dev Notes (NEW)
│   ├── DISCUSSIONS_LOG.md              # Decision log
│   ├── IMPLEMENTATION_SUMMARY.md       # Dev progress
│   ├── GAMIFICATION_RANKING.md         # Scoring system
│   ├── WIREFRAMES.md                   # UI mockups
│   ├── BOOKS.md                        # Reference materials
│   └── PORTAL_ORG_PLAN.md              # Portal org structure
│
└── vscode-plugin/                      # VS Code Extension (NEW)
    ├── PHASE1_SPEC.md
    ├── PHASE2_SPEC.md
    └── ARCHITECTURE.md
```

---

## File Migration Plan

### Files to Move → ai/
| Current | New Location |
|---------|--------------|
| QUAD_AI_MODELS_CATALOG.md | ai/AI_MODELS_CATALOG.md |
| QUAD_AI_PLATFORM_COMPARISON.md | ai/AI_PLATFORM_COMPARISON.md |
| AI_PRICING_TIERS.md | ai/AI_PRICING_TIERS.md |
| AI_PIPELINE_TIERS.md | ai/AI_PIPELINE_TIERS.md |
| MULTI_PROVIDER_AI_STRATEGY.md | ai/MULTI_PROVIDER_STRATEGY.md |
| AI_CONTEXT_MANAGEMENT.md | ai/AI_CONTEXT_MANAGEMENT.md |
| TOKEN_OPTIMIZATION_STRATEGY.md | ai/TOKEN_OPTIMIZATION.md |
| QUAD_AI_ACTIVITIES.md | ai/AI_ACTIVITIES.md |

### Files to Move → features/
| Current | New Location |
|---------|--------------|
| PHASE1_WORKFLOW.md | features/PHASE1_WORKFLOW.md |
| PHASE1_CROWD_PULLING_FEATURES.md | features/PHASE1_CROWD_PULLING.md |
| ONBOARDING_FLOW.md | features/ONBOARDING_FLOW.md |
| QUAD_MASTER_FLOWS.md | features/MASTER_FLOWS.md |
| AUTHENTICATION_FLOW.md | features/AUTHENTICATION_FLOW.md |
| QUAD_REPORTS_SYSTEM.md | features/REPORTS_SYSTEM.md |
| BLUEPRINT_AGENT_IMPLEMENTATION_PLAN.md | features/BLUEPRINT_AGENT.md |
| BLUEPRINT_AGENT_Q4_Q10_COMPLETION.md | features/BLUEPRINT_AGENT_Q4_Q10.md |
| BLUEPRINT_AGENT_IMPLEMENTATION_PLAN_Q3_REVISED.md | features/BLUEPRINT_AGENT_Q3.md |

### Files to Move → api/
| Current | New Location |
|---------|--------------|
| API_REFERENCE.md | api/API_REFERENCE.md |
| BLUEPRINT_AGENT_API_REFERENCE.md | api/BLUEPRINT_AGENT_API.md |
| BLUEPRINT_AGENT_SERVICES.md | api/BLUEPRINT_AGENT_SERVICES.md |
| DATABASE_AGENT_DESIGN.md | api/DATABASE_AGENT_DESIGN.md |

### Files to Move → database/
| Current | New Location |
|---------|--------------|
| DATABASE_SCHEMA.md | database/DATABASE_SCHEMA.md |
| CODEBASE_INDEX_SYSTEM.md | database/CODEBASE_INDEX_SYSTEM.md |

### Files to Move → architecture/
| Current | New Location |
|---------|--------------|
| ARCHITECTURE.md | architecture/ARCHITECTURE.md |
| QUAD_ARCHITECTURE_ROADMAP.md | architecture/ARCHITECTURE_ROADMAP.md |
| QUAD_OBJECT_MODEL.md | architecture/OBJECT_MODEL.md |
| SESSION_MANAGEMENT.md | architecture/SESSION_MANAGEMENT.md |
| MULTI_TENANT_DOMAIN_SETUP.md | architecture/MULTI_TENANT_SETUP.md |

### Files to Move → deployment/
| Current | New Location |
|---------|--------------|
| DEPLOYMENT_MODES.md | deployment/DEPLOYMENT_MODES.md |
| GOOGLE_CLOUD_MIGRATION.md | deployment/GOOGLE_CLOUD_MIGRATION.md |
| QUAD_INFRASTRUCTURE_STRATEGY.md | deployment/INFRASTRUCTURE_STRATEGY.md |

### Files to Move → strategy/
| Current | New Location |
|---------|--------------|
| QUAD_SUCCESS_STORY.md | strategy/SUCCESS_STORY.md |
| COMPETITOR_COMPARISON.md | strategy/COMPETITOR_COMPARISON.md |
| QUAD_IP_STRATEGY.md | strategy/IP_STRATEGY.md |
| SERVICE_MODEL_ANALYSIS.md | strategy/SERVICE_MODEL_ANALYSIS.md |
| QUAD_DEVELOPMENT_MODEL.md | strategy/DEVELOPMENT_MODEL.md |

### Files to Move → internal/
| Current | New Location |
|---------|--------------|
| QUAD_DISCUSSIONS_LOG.md | internal/DISCUSSIONS_LOG.md |
| IMPLEMENTATION_SUMMARY_DEC31_2025.md | internal/IMPLEMENTATION_SUMMARY.md |
| GAMIFICATION_RANKING.md | internal/GAMIFICATION_RANKING.md |
| WIREFRAMES.md | internal/WIREFRAMES.md |
| BOOKS.md | internal/BOOKS.md |
| PORTAL_ORG_PLAN.md | internal/PORTAL_ORG_PLAN.md |
| TECH_STACK.md | internal/TECH_STACK.md |
| DEV_AGENT_WORKFLOW.md | internal/DEV_AGENT_WORKFLOW.md |

---

## Naming Conventions

1. **Remove QUAD_ prefix** from most files (redundant inside QUAD repo)
2. **Use underscores** for multi-word names (not hyphens)
3. **Capitalize** all letters in filename
4. **Group by function**, not by date

---

## Public vs Internal

| Folder | Visibility | Who Reads |
|--------|------------|-----------|
| methodology/ | Public | Users, prospects |
| ai/ | Semi-public | Technical prospects |
| features/ | Public | Users |
| case-studies/ | Public | Prospects |
| architecture/ | Internal | Developers |
| api/ | Internal | Developers |
| database/ | Internal | Developers |
| deployment/ | Internal | DevOps |
| strategy/ | Confidential | Team only |
| internal/ | Confidential | Team only |

---

*This structure will be implemented after user approval.*
