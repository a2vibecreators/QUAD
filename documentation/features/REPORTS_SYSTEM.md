# QUAD Platform - Reports & Analytics System

**Date:** December 31, 2025
**Purpose:** Downloadable status reports for presentations, townhalls, and governance

---

## Overview

The QUAD Reports System allows users to generate and download professional status reports in PDF and PowerPoint formats. These reports are designed for:
- Executive presentations at townhalls
- Board meetings and stakeholder updates
- Weekly/monthly governance reviews
- Domain health monitoring
- Capacity planning and resource allocation

---

## Report Types

### 1. Governance Dashboard Report
**Purpose:** Weekly/monthly governance health check
**Audience:** QUAD_ADMIN, executives
**Sections:**
- Orphaned domains (domains with no members)
- Over-allocated users (>100% allocation)
- Under-allocated users (<100%, wasted capacity)
- Single point of failure (domains with only 1 admin)
- Role distribution imbalance
- Multi-root access security risks

**Export Formats:** PDF, PowerPoint
**Frequency:** Weekly, Monthly, On-Demand

---

### 2. Domain Health Report
**Purpose:** Status of a specific domain and its subdomains
**Audience:** DOMAIN_ADMIN, SUBDOMAIN_ADMIN
**Sections:**
- Domain hierarchy tree
- Member count and role distribution
- Active resources (projects, integrations)
- Completion status (resources with all required attributes)
- Recent activity timeline
- Sub-domain health scores

**Export Formats:** PDF, PowerPoint
**Frequency:** On-Demand

---

### 3. User Allocation Report
**Purpose:** Team capacity and workload optimization
**Audience:** QUAD_ADMIN, HR
**Sections:**
- User allocation breakdown (table + donut chart)
- Over/under-allocated users
- Users with multiple domains
- Suggested rebalancing actions
- Historical allocation trends

**Export Formats:** PDF, PowerPoint
**Frequency:** Monthly, On-Demand

---

### 4. Security Audit Report
**Purpose:** Access control and security compliance
**Audience:** Security team, compliance officers
**Sections:**
- Users with access to multiple root domains
- Recent role changes (last 30 days)
- Domains with inadequate admin coverage
- Audit log summary
- Recommended security actions

**Export Formats:** PDF
**Frequency:** Quarterly, On-Demand

---

### 5. Resource Completion Report
**Purpose:** Track which resources have all required attributes configured
**Audience:** DOMAIN_ADMIN, project managers
**Sections:**
- Resources missing required attributes
- Blueprint URL completion rate (for UI projects)
- Integration method completion rate
- Git repository linkage status
- Incomplete resources by domain

**Export Formats:** PDF, PowerPoint
**Frequency:** On-Demand

---

### 6. Executive Summary (All Domains)
**Purpose:** High-level overview for C-suite and board
**Audience:** Executives, board members
**Sections:**
- Total domains, subdomains, resources
- Total active users by role
- Top 5 domains by resource count
- Governance health score (0-100)
- Key recommendations
- Month-over-month trends

**Export Formats:** PDF, PowerPoint
**Frequency:** Monthly, Quarterly

---

## Technical Architecture

### Open Source Libraries

#### For PDF Generation

| Library | Language | Pros | Cons | Recommendation |
|---------|----------|------|------|----------------|
| **jsPDF** | JavaScript | Client/server, charts via plugins | Limited layouts | ✅ Good for simple reports |
| **PDFKit** | Node.js | Server-side, rich formatting | No built-in charts | ✅ Best for complex layouts |
| **Puppeteer** | Node.js | HTML → PDF, full CSS support | Heavy (Chromium) | ✅ Best for branded reports |
| **Apache PDFBox** | Java | Spring Boot native | Complex API | ⚪ Spring Boot option |

**Recommended Stack:** **Puppeteer + HTML Templates**
- Design reports as HTML/CSS templates
- Render to PDF via Puppeteer
- Full control over branding, charts, layouts
- Same templates can generate PowerPoint (see below)

#### For PowerPoint Generation

| Library | Language | Pros | Cons | Recommendation |
|---------|----------|------|------|----------------|
| **PptxGenJS** | JavaScript | Client/server, rich API | Manual slide building | ✅ Best JavaScript option |
| **python-pptx** | Python | Powerful, mature | Requires Python service | ⚪ If adding Python microservice |
| **Apache POI** | Java | Spring Boot native | Complex API | ⚪ Spring Boot option |
| **officegen** | Node.js | Simple API | Less maintained | ❌ Not recommended |

**Recommended Stack:** **PptxGenJS**
- Node.js native (works with Spring Boot via REST)
- Supports charts, tables, images
- Template-based slide generation

---

## System Architecture

### Option 1: Spring Boot + Node.js Microservice (Recommended)

```
┌─────────────────────────────────────────────────────────────┐
│ QUAD Web App (Next.js/React)                                │
│   └─ /reports page with filters & download buttons          │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP POST /api/reports/generate
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Spring Boot API (quadframework-services)                     │
│   ├─ ReportsController.java                                 │
│   ├─ ReportsService.java (runs governance queries)          │
│   └─ Calls Node.js Report Generator via HTTP                │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP POST to Node.js service
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Node.js Report Generator Service (Port 16601)               │
│   ├─ Puppeteer (PDF generation from HTML templates)         │
│   ├─ PptxGenJS (PowerPoint generation)                      │
│   ├─ Chart.js (charts in reports)                           │
│   └─ Returns file URL or base64 blob                        │
└────────────────────────┬────────────────────────────────────┘
                         │ File saved to
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Storage (AWS S3 or local /reports folder)                   │
│   └─ reports/{user_id}/{report_id}.{pdf|pptx}               │
└─────────────────────────────────────────────────────────────┘
```

**Benefits:**
- Separation of concerns (Java for business logic, Node.js for document generation)
- Best-in-class libraries for each format
- Can scale report generation independently

---

### Option 2: Pure Spring Boot (Apache POI + PDFBox)

```
┌─────────────────────────────────────────────────────────────┐
│ Spring Boot API (quadframework-services)                     │
│   ├─ ReportsController.java                                 │
│   ├─ ReportsService.java                                    │
│   ├─ PDFGeneratorService.java (Apache PDFBox)               │
│   └─ PowerPointGeneratorService.java (Apache POI)           │
└────────────────────────┬────────────────────────────────────┘
                         │ File saved to
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Storage (AWS S3 or local /reports folder)                   │
└─────────────────────────────────────────────────────────────┘
```

**Benefits:**
- Single codebase (Java only)
- No additional service to manage

**Drawbacks:**
- Apache POI/PDFBox APIs are more complex
- Less flexibility for modern layouts (no HTML/CSS)

---

## Database Schema for Reports

```sql
-- Track generated reports
CREATE TABLE QUAD_generated_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID REFERENCES QUAD_users(id),
  domain_id UUID REFERENCES QUAD_domains(id), -- NULL = all domains

  report_type VARCHAR(50) NOT NULL,
  -- 'GOVERNANCE_DASHBOARD', 'DOMAIN_HEALTH', 'USER_ALLOCATION',
  -- 'SECURITY_AUDIT', 'RESOURCE_COMPLETION', 'EXECUTIVE_SUMMARY'

  report_format VARCHAR(10) NOT NULL, -- 'PDF', 'PPTX'

  filters JSONB, -- {"date_range": "2025-12", "domain_ids": [...], "user_ids": [...]}

  file_url TEXT, -- S3 URL or local path
  file_size_bytes BIGINT,

  generated_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP, -- Auto-delete after 7 days

  status VARCHAR(20) DEFAULT 'pending',
  -- 'pending', 'generating', 'completed', 'failed'

  error_message TEXT
);

CREATE INDEX idx_generated_reports_user ON QUAD_generated_reports(user_id);
CREATE INDEX idx_generated_reports_expires ON QUAD_generated_reports(expires_at);

-- Report templates (for customization)
CREATE TABLE QUAD_report_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  report_type VARCHAR(50) NOT NULL,
  template_name VARCHAR(100),

  -- HTML template for PDF (Puppeteer)
  html_template TEXT,

  -- JSON config for PowerPoint (PptxGenJS)
  pptx_config JSONB,

  -- Branding
  logo_url TEXT,
  color_scheme JSONB, -- {"primary": "#3B82F6", "secondary": "#10B981"}

  is_default BOOLEAN DEFAULT false,

  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## API Endpoints

### Generate Report

**Endpoint:** `POST /api/reports/generate`

**Request Body:**
```json
{
  "reportType": "GOVERNANCE_DASHBOARD",
  "format": "PDF",
  "filters": {
    "dateRange": "2025-12",
    "domainIds": ["domain-uuid-1", "domain-uuid-2"],
    "includeSubdomains": true
  },
  "templateId": "template-uuid" // Optional, uses default if not specified
}
```

**Response:**
```json
{
  "reportId": "report-uuid",
  "status": "generating",
  "estimatedCompletionSeconds": 10,
  "downloadUrl": null // Will be populated when status = 'completed'
}
```

---

### Check Report Status

**Endpoint:** `GET /api/reports/{reportId}/status`

**Response:**
```json
{
  "reportId": "report-uuid",
  "status": "completed",
  "downloadUrl": "https://s3.amazonaws.com/quad-reports/user-123/report-uuid.pdf",
  "expiresAt": "2026-01-07T10:30:00Z"
}
```

---

### Download Report

**Endpoint:** `GET /api/reports/{reportId}/download`

**Response:** Binary file with appropriate Content-Type headers

---

### List User's Reports

**Endpoint:** `GET /api/reports?page=0&size=20`

**Response:**
```json
{
  "reports": [
    {
      "reportId": "report-uuid",
      "reportType": "GOVERNANCE_DASHBOARD",
      "format": "PDF",
      "generatedAt": "2025-12-31T10:30:00Z",
      "downloadUrl": "...",
      "fileSizeMB": 1.2
    }
  ],
  "totalPages": 3,
  "totalReports": 47
}
```

---

## UI Design (Reports Page)

### Route: `/configure/reports`

```
┌───────────────────────────────────────────────────────────────┐
│ 📊 Reports & Analytics                                        │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│ ┌─────────────────────────────────────────────────────────┐  │
│ │ GENERATE NEW REPORT                                     │  │
│ ├─────────────────────────────────────────────────────────┤  │
│ │                                                          │  │
│ │ Report Type: *                                           │  │
│ │ ┌──────────────────────────────────────────────────┐    │  │
│ │ │ ◉ Governance Dashboard                           │    │  │
│ │ │   Weekly health check of domains and allocations│    │  │
│ │ │                                                   │    │  │
│ │ │ ○ Domain Health Report                           │    │  │
│ │ │   Detailed status for a specific domain          │    │  │
│ │ │                                                   │    │  │
│ │ │ ○ User Allocation Report                         │    │  │
│ │ │   Team capacity and workload optimization        │    │  │
│ │ │                                                   │    │  │
│ │ │ ○ Security Audit Report                          │    │  │
│ │ │   Access control and compliance review           │    │  │
│ │ │                                                   │    │  │
│ │ │ ○ Resource Completion Report                     │    │  │
│ │ │   Track incomplete resource configurations       │    │  │
│ │ │                                                   │    │  │
│ │ │ ○ Executive Summary                              │    │  │
│ │ │   High-level overview for C-suite/board          │    │  │
│ │ └──────────────────────────────────────────────────┘    │  │
│ │                                                          │  │
│ │ Format: *                                                │  │
│ │ ◉ PDF (recommended for sharing)                         │  │
│ │ ○ PowerPoint (editable for presentations)               │  │
│ │                                                          │  │
│ │ [IF Domain Health Report selected:]                     │  │
│ │ Domain: *                                                │  │
│ │ [Dropdown: MassMutual / Insurance Division / Claims]    │  │
│ │ ☑ Include all subdomains                                │  │
│ │                                                          │  │
│ │ Date Range: *                                            │  │
│ │ ◉ Last 30 days   ○ Last 90 days   ○ Custom              │  │
│ │                                                          │  │
│ │                    [Generate Report →]                   │  │
│ └─────────────────────────────────────────────────────────┘  │
│                                                                │
│ ┌─────────────────────────────────────────────────────────┐  │
│ │ RECENT REPORTS                                          │  │
│ ├─────────────────────────────────────────────────────────┤  │
│ │                                                          │  │
│ │ ┌──────────────────────────────────────────────────┐    │  │
│ │ │ 📄 Governance Dashboard - December 2025          │    │  │
│ │ │ PDF • 1.2 MB • Generated Dec 31, 2025 10:30 AM  │    │  │
│ │ │ [Download] [Delete]                               │    │  │
│ │ └──────────────────────────────────────────────────┘    │  │
│ │                                                          │  │
│ │ ┌──────────────────────────────────────────────────┐    │  │
│ │ │ 📊 User Allocation Report - Q4 2025              │    │  │
│ │ │ PPTX • 2.8 MB • Generated Dec 28, 2025 3:15 PM  │    │  │
│ │ │ [Download] [Delete]                               │    │  │
│ │ └──────────────────────────────────────────────────┘    │  │
│ │                                                          │  │
│ │                          [View All Reports →]            │  │
│ └─────────────────────────────────────────────────────────┘  │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

---

## Sample Report Templates

### 1. Governance Dashboard Report (PDF)

**Page 1 - Cover:**
```
┌─────────────────────────────────────────────┐
│                                              │
│              QUAD Platform                   │
│        Governance Health Report              │
│                                              │
│           December 2025                      │
│                                              │
│      Generated: Dec 31, 2025 10:30 AM       │
│                                              │
└─────────────────────────────────────────────┘
```

**Page 2 - Executive Summary:**
```
┌─────────────────────────────────────────────┐
│ EXECUTIVE SUMMARY                            │
├─────────────────────────────────────────────┤
│                                              │
│ Overall Health Score: 78/100 ⚠️              │
│                                              │
│ ✅ HEALTHY                                   │
│   • 45 domains properly staffed              │
│   • 89% of users within allocation limits    │
│                                              │
│ ⚠️ NEEDS ATTENTION                           │
│   • 3 orphaned subdomains                    │
│   • 5 users over-allocated (>100%)           │
│   • 2 domains with single admin (SPOF risk)  │
│                                              │
│ 🔴 CRITICAL                                  │
│   • 1 root domain with no admin              │
│                                              │
└─────────────────────────────────────────────┘
```

**Page 3 - Orphaned Domains:**
```
┌─────────────────────────────────────────────┐
│ ORPHANED DOMAINS (No Members Assigned)       │
├─────────────────────────────────────────────┤
│                                              │
│ Domain Path                    | Type        │
│ ────────────────────────────────────────── │
│ /massmutual/new-division       | Subdomain  │
│ /healthcare-co/pilot-program   | Subdomain  │
│ /fintech-startup/mobile-team   | Subdomain  │
│                                              │
│ 📌 RECOMMENDATION:                           │
│ Assign at least 1 DOMAIN_ADMIN to each      │
│ subdomain or archive if no longer needed.    │
│                                              │
└─────────────────────────────────────────────┘
```

**Page 4 - Over-Allocated Users:**
```
┌─────────────────────────────────────────────┐
│ OVER-ALLOCATED USERS (>100% Allocation)      │
├─────────────────────────────────────────────┤
│                                              │
│ Name          | Total Allocation | Domains  │
│ ────────────────────────────────────────── │
│ Alice Smith   | 150%             | 3        │
│   • Domain A: 60% (DOMAIN_ADMIN)            │
│   • Domain B: 50% (DEVELOPER)               │
│   • Domain C: 40% (QA)                      │
│                                              │
│ Bob Johnson   | 120%             | 2        │
│   • Domain X: 80% (DOMAIN_ADMIN)            │
│   • Domain Y: 40% (DEVELOPER)               │
│                                              │
│ 📌 RECOMMENDATION:                           │
│ Reduce allocations or hire additional staff.│
│                                              │
└─────────────────────────────────────────────┘
```

---

### 2. PowerPoint Template (Governance Dashboard)

**Slide 1 - Title Slide:**
```
─────────────────────────────────────────
         QUAD Platform
   Governance Health Report

       December 2025

  Generated: Dec 31, 2025 10:30 AM
─────────────────────────────────────────
```

**Slide 2 - Health Score with Donut Chart:**
```
─────────────────────────────────────────
OVERALL HEALTH SCORE

        ╭─────────╮
        │  78%    │  ⚠️ Needs Attention
        │ ●●●●●○○ │
        ╰─────────╯

[Donut Chart showing:]
- Healthy: 78% (green)
- Warnings: 15% (yellow)
- Critical: 7% (red)
─────────────────────────────────────────
```

**Slide 3 - Key Issues (Bullet Points):**
```
─────────────────────────────────────────
KEY ISSUES REQUIRING ACTION

⚠️ WARNINGS (5 issues)
  • 3 orphaned subdomains
  • 5 over-allocated users

🔴 CRITICAL (3 issues)
  • 2 domains with single admin
  • 1 root domain with no admin

✅ RECOMMENDATIONS
  • Assign admins to orphaned domains
  • Rebalance user allocations
  • Add backup admins to SPOF domains
─────────────────────────────────────────
```

**Slide 4 - Table with Data:**
```
─────────────────────────────────────────
ORPHANED DOMAINS

Domain Path              | Type      | Action Needed
──────────────────────────────────────────────────
/massmutual/new-division | Subdomain | Assign admin
/healthcare-co/pilot     | Subdomain | Assign admin
/fintech-startup/mobile  | Subdomain | Assign admin
─────────────────────────────────────────
```

---

## Implementation Plan

### Phase 1: Core Infrastructure (Week 1-2)
- [ ] Set up Node.js report generator service
- [ ] Install Puppeteer + PptxGenJS
- [ ] Create database tables (QUAD_generated_reports, QUAD_report_templates)
- [ ] Create Spring Boot ReportsController and ReportsService
- [ ] Implement governance queries as SQL views or repository methods

### Phase 2: PDF Generation (Week 3)
- [ ] Create HTML templates for each report type
- [ ] Implement Puppeteer PDF generation
- [ ] Add Chart.js for charts in PDF
- [ ] Test PDF generation with sample data

### Phase 3: PowerPoint Generation (Week 4)
- [ ] Create PptxGenJS templates for each report type
- [ ] Implement slide generation with tables and charts
- [ ] Test PowerPoint generation with sample data

### Phase 4: UI Implementation (Week 5)
- [ ] Create `/configure/reports` page in Next.js
- [ ] Implement report type selector with filters
- [ ] Add download and status polling
- [ ] Display recent reports list

### Phase 5: Testing & Deployment (Week 6)
- [ ] End-to-end testing with real data
- [ ] Performance testing (large reports)
- [ ] Deploy Node.js service to Mac Studio
- [ ] Add Caddy reverse proxy rules

---

## Deployment Configuration

### Node.js Report Generator Service

**Directory:** `/Users/semostudio/services/quad-report-generator`

**Docker Container:**
```yaml
services:
  quad-report-generator:
    image: node:20
    container_name: quad-report-generator
    ports:
      - "16601:3000"
    volumes:
      - ./quad-report-generator:/app
      - ./reports:/app/output
    environment:
      - NODE_ENV=production
      - SPRING_BOOT_API_URL=http://quadframework-api:8080
    command: npm start
    networks:
      - quad-network
```

**Caddyfile:**
```
reports.quadframe.work {
  reverse_proxy quad-report-generator:3000
}
```

---

## Security Considerations

1. **Access Control:**
   - Users can only generate reports for domains they have access to
   - QUAD_ADMIN can generate all reports
   - DOMAIN_ADMIN can only generate reports for their domain + subdomains

2. **File Expiration:**
   - Reports auto-delete after 7 days (configurable)
   - Cron job runs daily to clean up expired reports

3. **Rate Limiting:**
   - Max 10 reports per user per day
   - Prevent abuse of resource-intensive report generation

4. **Sensitive Data:**
   - Reports should NOT include passwords, tokens, or PII beyond names/emails
   - Security audit reports available to QUAD_ADMIN only

---

## Summary

The QUAD Reports System provides executive-level insights into domain governance, user allocation, and resource completion. With PDF and PowerPoint export options, stakeholders can easily incorporate QUAD Platform metrics into presentations and strategic planning sessions.

**Next Steps:**
1. User approval of report types and design
2. Set up Node.js report generator service
3. Implement governance SQL queries
4. Create HTML/PPTX templates
5. Build `/configure/reports` UI

---

**Author:** Claude (AI Assistant)
**Date:** December 31, 2025
**Status:** 🔜 Awaiting user approval
