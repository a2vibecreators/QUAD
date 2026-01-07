# Customer Pitch Site - Sitemap

**URL:** https://customer.quadframe.work
**Created:** January 7, 2026
**Status:** v1.1 (In Progress)

---

## Site Structure

```
customer.quadframe.work/
│
├── /customer                     ← Landing Page (Overview)
│   │
│   ├── /customer/pitch           ← Pitch Deck (6 slides)
│   │
│   ├── /customer/demo            ← Platform Demo (Password Protected)
│   │   └── Unlock popup asks for organization name
│   │   └── Pre-configured demo data:
│   │       ├── UI Project (Customer Portal)
│   │       ├── Backend API (Claims API)
│   │       └── B2B Webservice (Partner Gateway)
│   │
│   ├── /customer/roi             ← ROI Calculator
│   │
│   ├── /customer/about           ← About Us / Team
│   │
│   ├── /customer/settings        ← Feature Toggle Settings
│   │   └── Presets: FULL MATRIX, PILOT VECTOR, GROWTH PLANE, CUSTOM PATH
│   │
│   └── /customer/contact         ← Schedule Demo / Contact
│
└── Shared Pages (QUAD Framework)
    ├── /concept                  ← The Problem (Optional reference)
    ├── /flow                     ← Q → U → A → D Flow
    └── /details                  ← AI Agents in Action
```

---

## Page Details

### 1. Landing Page (`/customer`)

**Purpose:** Hero page introducing QUAD value proposition

**Content:**
- Problem statement: "Why does 1 paragraph take 6 weeks?"
- QUAD solution overview
- Timeline comparison (Traditional vs QUAD)
- Enterprise features grid (6 features)
- CTA to demo and contact

**No Duplicates (v1.1):**
- Problem section is the PRIMARY location
- Other pages should NOT duplicate this content

---

### 2. Pitch Deck (`/customer/pitch`)

**Purpose:** 6-slide presentation for executives

**Slides:**
1. Executive Summary (Problem vs Solution stats)
2. Channelized AI Energy (Electricity analogy)
3. The QUAD Model (Q-U-A-D steps)
4. Why QUAD vs Competitors (comparison table)
5. Partnership Proposal (Pilot → Rollout → Strategic)
6. The Ask (4 weeks, 1 team, $0 commitment)

**No Duplicates (v1.1):**
- Removed redundant Problem section (covered in Overview)
- Removed redundant QUAD Model (covered in Overview)

---

### 3. Platform Demo (`/customer/demo`)

**Purpose:** Interactive dashboard demonstration

**Password Protected:** Yes (password: "Ashrith")

**Unlock Flow (v1.1):**
1. User clicks "Unlock Demo"
2. Popup asks for organization name
3. Demo loads with personalized org name

**Demo Screens:**
| Screen | Purpose |
|--------|---------|
| Dashboard | Overview metrics and health scores |
| Domains | Project list with 3 project types |
| Roles | Team member role assignments |
| Adoption | QUAD methodology adoption matrix |
| Reporting | Analytics and metrics |

**Pre-configured Demo Data:**
```
[Organization Name] (entered by user)
├── Digital Experience (Sub-Org)
│   └── Customer Portal (UI Project)
│       ├── Tech: Next.js 15 + Tailwind
│       ├── 4 Circles (Mgmt, Dev, QA, Infra)
│       └── Sample tickets at Q/U/A/D stages
│
├── Data Engineering (Sub-Org)
│   └── Claims API (Backend Project)
│       ├── Tech: Spring Boot 3.2 + PostgreSQL
│       ├── 4 Circles (Mgmt, Dev, QA, Infra)
│       └── Sample tickets at Q/U/A/D stages
│
└── Partner Integration (Sub-Org)
    └── B2B Gateway (Webservice Project)
        ├── Tech: Node.js + REST/GraphQL
        ├── 4 Circles (Mgmt, Dev, QA, Infra)
        └── Sample tickets at Q/U/A/D stages
```

---

### 4. ROI Calculator (`/customer/roi`)

**Purpose:** Show financial impact of QUAD

**Inputs:**
- Number of developers
- Average developer salary
- Current sprint velocity
- Feature delivery time

**Outputs:**
- Time savings (hours/week)
- Cost savings ($/year)
- Productivity improvement %

---

### 5. About Us (`/customer/about`)

**Purpose:** Company and team information

**Content:**
- Company mission/vision
- Team members with bios
- Company values

**Team:**
| Name | Role | Location |
|------|------|----------|
| Madhuri | Founder & CEO | USA |
| Mahesh | VP Sales | Canada |
| Sharath | VP Engineering | India |
| Lokesh | VP Product | India |
| Pradeep | Architecture | India |
| Supriya | Human Resources | India |

---

### 6. Feature Settings (`/customer/settings`)

**Purpose:** Configure which features to show in demo

**Presets:**
| Preset | Features | Use Case |
|--------|----------|----------|
| FULL MATRIX | All 103 features | Show everything |
| PILOT VECTOR | ~40 features | Minimal pilot demo |
| GROWTH PLANE | ~70 features | Mid-tier demo |
| CUSTOM PATH | User-defined | Custom selection |

---

### 7. Contact (`/customer/contact`)

**Purpose:** Schedule personalized demo

**Content:**
- Email contact (suman.addanki@gmail.com)
- Calendar booking (coming soon)
- Team list (matches About page)
- What to expect (4-step process)

---

## Content Consolidation (v1.1)

### Removed Duplicates

| Content | Primary Location | Removed From |
|---------|------------------|--------------|
| Problem (4 issues) | `/customer` (Overview) | Demo, Pitch |
| QUAD Model (Q-U-A-D) | `/customer` (Overview) | Demo, Pitch |
| Channelized AI Energy | `/customer/pitch` | Demo |
| Team list | `/customer/about` | (synced with Contact) |

### Content Ownership

| Section | Owner Page | Can Reference |
|---------|------------|---------------|
| Problem statement | Overview | None (primary) |
| QUAD Model | Overview | Pitch (brief) |
| AI Energy analogy | Pitch | None |
| Team info | About | Contact (synced) |
| Demo data | Demo | None |

---

## Navigation Flow

```
┌─────────────────────────────────────────────────────────┐
│                    Customer Journey                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Overview (/customer)                                │
│     │  • See the problem                               │
│     │  • See the QUAD solution                         │
│     │  • See enterprise features                       │
│     ↓                                                   │
│  2. Pitch (/customer/pitch)                            │
│     │  • 6-slide executive presentation                │
│     │  • Competitive comparison                        │
│     │  • Partnership proposal                          │
│     ↓                                                   │
│  3. Demo (/customer/demo) [Password Protected]         │
│     │  • Enter organization name                       │
│     │  • See live dashboard                            │
│     │  • Explore 3 project types                       │
│     ↓                                                   │
│  4. ROI (/customer/roi)                                │
│     │  • Calculate savings                             │
│     │  • See financial impact                          │
│     ↓                                                   │
│  5. Contact (/customer/contact)                        │
│        • Schedule demo call                             │
│        • Start pilot program                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Validation Checklist (v1.1)

| Page | Duplicates Removed | Approved |
|------|--------------------|----------|
| Overview | ✅ Primary location | Pending |
| Pitch | ⏳ Pending | Pending |
| Demo | ⏳ Pending | Pending |
| ROI | N/A | Pending |
| About | N/A | Pending |
| Settings | N/A | Pending |
| Contact | ✅ Pradeep added | Pending |

---

**Last Updated:** January 7, 2026
**Maintained By:** Suman Addanki
