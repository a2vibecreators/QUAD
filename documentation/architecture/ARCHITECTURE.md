# QUAD Platform - Architecture Documentation

**Date:** January 1, 2026
**Version:** 1.1

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Technology Stack](#technology-stack)
3. [Database Design](#database-design)
4. [API Architecture](#api-architecture)
5. [Frontend Architecture](#frontend-architecture)
6. [Backend Services](#backend-services)
7. [Security Architecture](#security-architecture)
8. [Deployment Architecture](#deployment-architecture)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     User Browser                            │
│  (React/Next.js Frontend + Authentication)                  │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              Caddy Reverse Proxy (Mac Studio)               │
│  dev.quadframe.work → :16001                                │
│  qa.quadframe.work  → :17001                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                 Next.js Application                         │
│  ┌─────────────────┐          ┌──────────────────────────┐ │
│  │   Frontend      │          │   Backend API Routes     │ │
│  │   React/TSX     │          │   /api/**/route.ts       │ │
│  │   Tailwind CSS  │  ←────→  │   TypeScript/Node.js     │ │
│  │   Client-Side   │          │   Server-Side            │ │
│  └─────────────────┘          └──────────┬───────────────┘ │
│                                           │                 │
│  ┌────────────────────────────────────────┴──────────────┐ │
│  │          Backend Services Layer                       │ │
│  │  - GitRepoAnalyzer (clone & analyze repos)            │ │
│  │  - ScreenshotService (Puppeteer screenshots)          │ │
│  │  - MockupGenerator (AI design generation) [TODO]     │ │
│  └────────────────────────────┬──────────────────────────┘ │
└─────────────────────────────────┬──────────────────────────┘
                                  │ pg library
                                  ↓
                  ┌───────────────────────────────┐
                  │   PostgreSQL Database         │
                  │   - QUAD_organizations        │
                  │   - QUAD_users                │
                  │   - QUAD_domains              │
                  │   - QUAD_domain_resources     │
                  │   - QUAD_resource_attributes  │
                  │   - QUAD_*_requirements       │
                  └───────────────────────────────┘
```

### Data Flow Example: Blueprint Upload

```
User uploads Figma URL
        ↓
Next.js Frontend (POST request)
        ↓
API Route: /api/resources/[resourceId]/attributes/blueprint/route.ts
        ↓
Validation & URL Auto-Detection
        ↓
Database Query (INSERT INTO QUAD_resource_attributes)
        ↓
ScreenshotService (if competitor URL)
        ↓
Database Update (blueprint_screenshot_url)
        ↓
Response to Frontend (success + metadata)
```

---

## Technology Stack

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Next.js** | 15.5.x | React framework with SSR |
| **React** | 19.x | UI library |
| **TypeScript** | 5.x | Type safety |
| **Tailwind CSS** | 4.x | Utility-first CSS |
| **shadcn/ui** | Latest | Component library |
| **NextAuth.js** | 4.x | Authentication |

**Why Next.js?**
- ✅ File-based routing (automatic route generation)
- ✅ Server-side rendering (fast initial load)
- ✅ API routes (no separate backend needed)
- ✅ TypeScript support out of the box
- ✅ Optimized production builds

### Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Next.js API Routes** | 15.5.x | RESTful API endpoints |
| **Node.js** | 20.x | Runtime environment |
| **TypeScript** | 5.x | Type safety |
| **Prisma ORM** | 6.x | Database ORM with type safety |
| **Puppeteer** | 21.x | Screenshot capture |

**Why Prisma ORM?**
- Type-safe database queries
- Auto-generated TypeScript types from schema
- Easy migrations and schema management
- Works seamlessly with Next.js

**Why NOT Spring Boot?**
- QUAD has ~15 tables (simple schema)
- Next.js API routes are sufficient
- Reduces deployment complexity
- TypeScript across full stack

### Database

| Technology | Version | Purpose |
|------------|---------|---------|
| **PostgreSQL** | 15.x | Relational database |
| **UUID** | Built-in | Primary keys |
| **JSONB** | Built-in | Flexible attribute storage |

**Database Features Used:**
- UUIDs for distributed-safe IDs
- Foreign keys with CASCADE deletes
- Triggers for `updated_at` timestamps
- Helper functions for validation

### Infrastructure

| Component | Technology | Environment |
|-----------|------------|-------------|
| **Development** | Docker (Mac Studio) | DEV |
| **QA** | Docker (Mac Studio) | QA |
| **Production** | GCP Cloud Run | PROD (future) |
| **Reverse Proxy** | Caddy | All |
| **DNS** | Cloudflare | All |

---

## Database Design

### EAV (Entity-Attribute-Value) Pattern

**Traditional Approach:**
```sql
CREATE TABLE projects (
  id UUID,
  name VARCHAR(255),
  frontend_framework VARCHAR(50),  -- Column for every attribute
  css_framework VARCHAR(50),
  backend_framework VARCHAR(50),
  database_type VARCHAR(50),
  ...  -- 100s of columns for all possible attributes
);
```

**QUAD Approach (EAV):**
```sql
CREATE TABLE QUAD_domain_resources (
  id UUID,
  domain_id UUID,
  resource_type VARCHAR(50),  -- 'web_app_project', 'api_project', etc.
  resource_name VARCHAR(255)
);

CREATE TABLE QUAD_resource_attributes (
  id UUID,
  resource_id UUID REFERENCES QUAD_domain_resources(id),
  attribute_name VARCHAR(50),   -- 'frontend_framework', 'css_framework', etc.
  attribute_value TEXT,          -- 'nextjs', 'tailwind', etc.
  UNIQUE(resource_id, attribute_name)
);
```

**Benefits:**
- ✅ No NULL columns (only store attributes that exist)
- ✅ Add new attributes without schema changes
- ✅ Different resource types have different attributes
- ✅ Query flexibility (JSON aggregation)

### Core Tables

```sql
-- 1. Organizations (top-level organizations)
QUAD_organizations (id, name, admin_email, size)

-- 2. Users (people who log in)
-- Note: company_id column maps to org_id in Prisma for code clarity
QUAD_users (id, company_id, email, password_hash, role, full_name)

-- 3. Domains (organizational units - hierarchical)
QUAD_domains (id, name, parent_domain_id, domain_type, path)
  - parent_domain_id = NULL → root domain
  - parent_domain_id = {uuid} → sub-domain

-- 4. Resources (projects, integrations, repos)
QUAD_domain_resources (id, domain_id, resource_type, resource_name, resource_status)

-- 5. Attributes (EAV pattern)
QUAD_resource_attributes (id, resource_id, attribute_name, attribute_value)
  - Stores: blueprint_url, git_repo_url, frontend_framework, etc.

-- 6. Attribute Requirements (validation rules)
QUAD_resource_attribute_requirements (id, resource_type, attribute_name, is_required, validation_rule, allowed_values)
  - Defines: Which attributes are required for which resource types
```

### Relationships

```
QUAD_organizations
  └─ QUAD_users (one organization has many users)
      └─ QUAD_domain_members (users belong to domains with roles)

QUAD_domains
  ├─ self-reference (parent_domain_id → id for hierarchy)
  └─ QUAD_domain_resources (domains contain resources)
      └─ QUAD_resource_attributes (resources have attributes)

QUAD_resource_attribute_requirements
  └─ Defines rules for resource types (not linked via FK)
```

---

## API Architecture

### Next.js App Router (File-Based Routing)

```
src/app/api/
├── auth/
│   ├── signup/route.ts          → POST /api/auth/signup
│   ├── login/route.ts           → POST /api/auth/login (via NextAuth)
│   └── set-domain/route.ts      → POST /api/auth/set-domain
│
├── resources/
│   └── [resourceId]/            → Dynamic route parameter
│       ├── attributes/
│       │   ├── blueprint/
│       │   │   └── route.ts     → POST/GET /api/resources/{id}/attributes/blueprint
│       │   └── git-repo/
│       │       └── route.ts     → POST/GET/DELETE /api/resources/{id}/attributes/git-repo
│       └── analyze-repo/
│           └── route.ts         → POST/GET /api/resources/{id}/analyze-repo
│
└── blueprint-agent/
    ├── start-interview/
    │   └── route.ts             → POST/GET /api/blueprint-agent/start-interview
    └── submit-answer/
        └── route.ts             → POST/GET /api/blueprint-agent/submit-answer
```

### API Route Structure

**Standard Pattern:**
```typescript
// src/app/api/resources/[resourceId]/attributes/blueprint/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function POST(
  request: NextRequest,
  { params }: { params: { resourceId: string } }
) {
  const { resourceId } = params;  // From URL path
  const body = await request.json();  // From request body

  // Validation
  if (!body.blueprintUrl) {
    return NextResponse.json({ error: '...' }, { status: 400 });
  }

  // Database operation
  const result = await query('INSERT INTO ...', [resourceId, body.blueprintUrl]);

  // Response
  return NextResponse.json({ success: true, data: {...} }, { status: 200 });
}

export async function GET(
  request: NextRequest,
  { params }: { params: { resourceId: string } }
) {
  // Retrieve data logic
}
```

### Database Connection

**IMPORTANT:** QUAD uses a **separate database** (`quad_dev_db`) from NutriNine (`nutrinine_dev_db`).

**Prisma Client:**
```typescript
// src/lib/db.ts
import { PrismaClient } from '@/generated/prisma';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma || new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

**Environment Configuration (.env):**
```env
DATABASE_URL="postgresql://nutrinine_user:nutrinine_dev_pass@localhost:16201/quad_dev_db?schema=public"
```

**Usage:**
```typescript
import { prisma } from '@/lib/db';

// Type-safe queries
const resources = await prisma.qUAD_domain_resources.findMany({
  where: { domain_id: domainId },
  include: { attributes: true }
});
```

---

## Frontend Architecture

### Page Structure

```
src/app/
├── layout.tsx               → Root layout (header, nav)
├── page.tsx                 → Homepage (/)
│
├── auth/
│   ├── login/page.tsx       → /auth/login
│   └── signup/page.tsx      → /auth/signup
│
├── dashboard/page.tsx       → /dashboard
│
├── configure/
│   ├── page.tsx             → /configure
│   ├── domain/
│   │   └── create/page.tsx  → /configure/domain/create
│   ├── prerequisites/page.tsx → /configure/prerequisites
│   └── integrations/page.tsx  → /configure/integrations
│
└── docs/
    └── [...slug]/page.tsx   → /docs/* (catch-all route)
```

### Component Structure

```
src/components/
├── ui/                      → shadcn/ui components (Button, Card, etc.)
├── layout/
│   ├── Header.tsx
│   ├── Sidebar.tsx
│   └── Footer.tsx
├── domain/
│   ├── DomainSelector.tsx
│   └── DomainTree.tsx
├── blueprint/
│   ├── BlueprintUpload.tsx
│   └── BlueprintAgentInterview.tsx
└── shared/
    ├── Loading.tsx
    └── ErrorBoundary.tsx
```

### State Management

**Server Components (Default):**
- Fetch data directly in components
- No client-side state needed

**Client Components (when needed):**
- Use `'use client'` directive
- React hooks (useState, useEffect)
- Context API for global state

**Example:**
```typescript
// Server Component (default)
export default async function DashboardPage() {
  const domains = await getDomains();  // Direct database query
  return <DomainList domains={domains} />;
}

// Client Component (interactive)
'use client';
export function BlueprintUpload() {
  const [file, setFile] = useState<File | null>(null);
  // ... interactive logic
}
```

---

## Backend Services

### Service Architecture

```
src/lib/services/
├── GitRepoAnalyzer.ts       → Clone & analyze Git repositories
├── ScreenshotService.ts     → Puppeteer screenshot capture
└── MockupGenerator.ts       → AI mockup generation [TODO]
```

### GitRepoAnalyzer Flow

```
1. User triggers: POST /api/resources/{id}/analyze-repo
2. API fetches git_repo_url from QUAD_resource_attributes
3. GitRepoAnalyzer.analyzeRepository(url, token, isPrivate)
   ├─ git clone --depth 1 {url} /tmp/quad-repo-analysis/{repo-name}
   ├─ Analyze package.json → detect frontend/backend frameworks
   ├─ Analyze pom.xml → detect Java/Spring Boot
   ├─ Analyze requirements.txt → detect Python frameworks
   ├─ Walk directory tree → count files, find components
   └─ Return analysis result (JSON)
4. Save result to QUAD_resource_attributes.git_repo_analysis_result
5. Cleanup /tmp directory
```

### ScreenshotService Flow

```
1. User uploads competitor URL: POST /api/resources/{id}/attributes/blueprint
2. API detects blueprintType === 'competitor_url'
3. ScreenshotService.captureAndSave(resourceId, url)
   ├─ Launch Puppeteer browser
   ├─ Navigate to URL (wait for networkidle2)
   ├─ Remove unwanted elements (chat widgets, popups)
   ├─ Take full-page screenshot
   ├─ Save to /tmp/quad-screenshots/screenshot-{domain}-{timestamp}.png
   └─ Store path in QUAD_resource_attributes.blueprint_screenshot_url
4. Close browser
```

---

## Security Architecture

### Authentication

**Provider:** NextAuth.js

```typescript
// src/app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';

export const authOptions = {
  providers: [
    CredentialsProvider({
      credentials: { email: {}, password: {} },
      async authorize(credentials) {
        // Verify against QUAD_users table
        const user = await query('SELECT * FROM QUAD_users WHERE email = $1', [credentials.email]);
        if (user && verifyPassword(credentials.password, user.password_hash)) {
          return { id: user.id, email: user.email, role: user.role };
        }
        return null;
      },
    }),
  ],
  session: { strategy: 'jwt' },
};
```

### Authorization

**Role-Based Access Control (RBAC):**

```typescript
// Middleware to check permissions
async function checkPermission(userId: string, domainId: string, requiredRole: string) {
  const result = await query(
    `SELECT role FROM QUAD_domain_members
     WHERE user_id = $1 AND domain_id = $2`,
    [userId, domainId]
  );

  const userRole = result.rows[0]?.role;
  const roleHierarchy = ['VIEWER', 'QA', 'DEVELOPER', 'SUBDOMAIN_ADMIN', 'DOMAIN_ADMIN', 'QUAD_ADMIN'];

  return roleHierarchy.indexOf(userRole) >= roleHierarchy.indexOf(requiredRole);
}
```

### Secrets Management

**Vaultwarden Integration (Planned):**
- Git access tokens stored in Vaultwarden
- Only path stored in database: `/vaultwarden/company/github-token`
- Service fetches token at runtime

**Environment Variables:**
```env
DATABASE_URL=postgresql://user:pass@localhost:16201/db
NEXTAUTH_SECRET=...
GIT_ACCESS_TOKEN=ghp_...  # Fallback if Vaultwarden not configured
```

---

## Deployment Architecture

### Development (Mac Studio)

```
Mac Studio M4 Max (macOS Sequoia 15.6)
├── Docker Containers
│   ├── quadframework-dev (port 18001) → dev.quadframe.work
│   ├── quadframework-qa (port 18101) → qa.quadframe.work
│   └── postgres-dev (port 16201)
│       ├── quad_dev_db (QUAD Framework)
│       └── nutrinine_dev_db (NutriNine - separate)
│
├── Caddy Reverse Proxy
│   ├── dev.quadframe.work → quadframework-dev:3000
│   └── qa.quadframe.work → quadframework-qa:3000
│
└── Cloudflare DNS
    ├── dev.quadframe.work → 96.240.97.243 (Proxied)
    └── qa.quadframe.work → 96.240.97.243 (Proxied)
```

### Production (GCP Cloud Run - Future)

```
GCP Cloud Run (us-east1)
├── quadframe-web (Cloud Run service)
│   └── Auto-scaling (0-10 instances)
├── Cloud SQL PostgreSQL 15
│   └── Private VPC connection
└── Load Balancer
    └── SSL/TLS termination
```

### Deployment Commands

**Deploy to DEV:**
```bash
cd /Users/semostudio/git/a2vibecreators/quadframework
./deploy-studio.sh dev
```

**Deploy to QA:**
```bash
./deploy-studio.sh qa
```

**Deploy to GCP (future):**
```bash
./deploy-gcp.sh prod
```

---

## Performance Considerations

### Database Optimization

✅ **Indexes on Foreign Keys:**
```sql
CREATE INDEX idx_attributes_resource ON QUAD_resource_attributes(resource_id);
CREATE INDEX idx_attributes_name ON QUAD_resource_attributes(attribute_name);
```

✅ **Connection Pooling:**
- Max 20 connections
- Idle timeout: 30 seconds

### Next.js Optimization

✅ **Static Generation (SSG):**
- Marketing pages, documentation

✅ **Server-Side Rendering (SSR):**
- Dashboard, dynamic content

✅ **API Route Optimization:**
- Single database queries where possible
- Parallel queries with Promise.all()

### Puppeteer Optimization

✅ **Headless Mode:**
- No GUI overhead

✅ **Resource Optimization:**
```javascript
args: [
  '--no-sandbox',
  '--disable-setuid-sandbox',
  '--disable-dev-shm-usage',
  '--disable-gpu',
]
```

---

## Scalability

### Current Limits

- **Mac Studio:** ~100 concurrent users
- **Database:** Single PostgreSQL instance
- **File Storage:** Local /tmp (not persistent)

### Future Scaling Strategy

**Horizontal Scaling:**
- Deploy to GCP Cloud Run (auto-scale)
- Cloud SQL with read replicas
- Cloud Storage for screenshots

**Vertical Scaling:**
- Increase database resources
- Add Redis caching layer

---

## Monitoring & Logging

### Application Logs

**Console Logging:**
```typescript
console.log('Database query:', { text, duration, rows });
console.error('Error:', { endpoint, error, stack });
```

**Slow Query Detection:**
```typescript
if (duration > 1000) {
  console.warn('Slow query detected:', { text, duration });
}
```

### Future Monitoring

🔜 **Metrics:**
- Request latency
- Database query performance
- Error rates

🔜 **Tools:**
- Google Cloud Monitoring (GCP)
- Sentry (error tracking)
- Grafana (dashboards)

---

**Next:** Read [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) for complete schema documentation.
