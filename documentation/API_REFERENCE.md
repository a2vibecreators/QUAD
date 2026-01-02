# QUAD Platform - API Reference

**Date:** January 1, 2026
**Version:** 1.0
**Base URL:** `/api`

---

## Overview

QUAD Platform provides a RESTful API with 24 endpoints across 12 categories. All endpoints (except auth) require JWT authentication via Bearer token.

### Authentication Header

```
Authorization: Bearer <jwt_token>
```

### Response Format

All responses are JSON with consistent structure:

**Success:**
```json
{
  "data": { ... },
  "message": "Operation successful"
}
```

**Error:**
```json
{
  "error": "Error description",
  "details": { ... }  // Optional
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (missing/invalid token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 409 | Conflict (duplicate entry) |
| 500 | Internal Server Error |

---

## Authentication

### POST /api/auth/register

Create a new user and company.

**Request Body:**
```json
{
  "email": "admin@company.com",
  "password": "securePassword123",
  "full_name": "John Doe",
  "company_name": "Acme Corp"
}
```

**Response (201):**
```json
{
  "user": {
    "id": "uuid",
    "email": "admin@company.com",
    "full_name": "John Doe",
    "company_id": "uuid"
  },
  "company": {
    "id": "uuid",
    "name": "Acme Corp"
  },
  "token": "jwt_token_here"
}
```

**Notes:**
- Creates organization with default 6 roles (ADMIN, MANAGER, TECH_LEAD, DEVELOPER, QA, OBSERVER)
- User is assigned ADMIN role automatically
- Creates adoption matrix entry for user

---

### POST /api/auth/login

Authenticate and get JWT token.

**Request Body:**
```json
{
  "email": "admin@company.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "uuid",
    "email": "admin@company.com",
    "full_name": "John Doe",
    "company_id": "uuid",
    "role": "ADMIN"
  }
}
```

---

### POST /api/auth/logout

End user session.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

## Organizations (Companies API)

> **Note:** The database table was renamed from `QUAD_companies` to `QUAD_organizations`. The API endpoints remain as `/api/companies` for backward compatibility. The `company_id` field in API responses maps to `org_id` in Prisma/code.

### GET /api/companies

List all organizations (ADMIN only).

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "companies": [
    {
      "id": "uuid",
      "name": "Acme Corp",
      "admin_email": "admin@acme.com",
      "size": "medium",
      "is_active": true,
      "_count": { "users": 5 }
    }
  ]
}
```

---

### GET /api/companies/{id}

Get organization by ID.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "id": "uuid",
  "name": "Acme Corp",
  "admin_email": "admin@acme.com",
  "size": "medium",
  "is_active": true,
  "users": [...],
  "domains": [...],
  "roles": [...]
}
```

---

### PUT /api/companies/{id}

Update organization details (ADMIN only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Acme Corporation",
  "size": "large"
}
```

**Response (200):**
```json
{
  "id": "uuid",
  "name": "Acme Corporation",
  "size": "large"
}
```

---

## Users

### GET /api/users

List all users in organization.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `include_inactive=true` - Include deactivated users

**Response (200):**
```json
{
  "users": [
    {
      "id": "uuid",
      "email": "user@company.com",
      "full_name": "Jane Doe",
      "role_id": "uuid",
      "is_active": true,
      "user_role": { "role_code": "DEVELOPER", "role_name": "Developer" }
    }
  ]
}
```

---

### POST /api/users

Create a new user (ADMIN only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "email": "newuser@company.com",
  "password": "password123",
  "full_name": "New User",
  "role_id": "uuid"
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "email": "newuser@company.com",
  "full_name": "New User",
  "role_id": "uuid"
}
```

---

### GET /api/users/{id}

Get user by ID.

**Headers:** `Authorization: Bearer <token>`

---

### PUT /api/users/{id}

Update user (ADMIN or self).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "full_name": "Updated Name",
  "role_id": "uuid",
  "is_active": true
}
```

---

### DELETE /api/users/{id}

Delete user (ADMIN only).

**Headers:** `Authorization: Bearer <token>`

---

## Roles

### GET /api/roles

List all roles in organization.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `include_inactive=true` - Include deactivated roles

**Response (200):**
```json
{
  "roles": [
    {
      "id": "uuid",
      "role_code": "DEVELOPER",
      "role_name": "Developer",
      "q_participation": "INFORM",
      "u_participation": "SUPPORT",
      "a_participation": "INFORM",
      "d_participation": "PRIMARY",
      "hierarchy_level": 40,
      "_count": { "users": 3 }
    }
  ]
}
```

---

### POST /api/roles

Create a new role (ADMIN only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "role_code": "SCRUM_MASTER",
  "role_name": "Scrum Master",
  "description": "Facilitates agile ceremonies",
  "can_manage_users": false,
  "can_manage_domains": true,
  "can_manage_flows": true,
  "q_participation": "PRIMARY",
  "u_participation": "PRIMARY",
  "a_participation": "SUPPORT",
  "d_participation": "REVIEW",
  "hierarchy_level": 70
}
```

**Participation Values:** `PRIMARY`, `SUPPORT`, `REVIEW`, `INFORM`, `null`

**Response (201):**
```json
{
  "id": "uuid",
  "role_code": "SCRUM_MASTER",
  "role_name": "Scrum Master"
}
```

---

### GET /api/roles/{id}

Get role by ID with assigned users.

---

### PUT /api/roles/{id}

Update role (ADMIN only). Cannot change `role_code`.

---

### DELETE /api/roles/{id}

Delete role (ADMIN only). Cannot delete system roles or roles with users.

---

## Domains

### GET /api/domains

List all domains in organization (hierarchical).

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "domains": [
    {
      "id": "uuid",
      "name": "Engineering",
      "parent_domain_id": null,
      "domain_type": "division",
      "path": "/engineering",
      "sub_domains": [
        {
          "id": "uuid",
          "name": "Frontend",
          "parent_domain_id": "parent_uuid",
          "path": "/engineering/frontend"
        }
      ]
    }
  ]
}
```

---

### POST /api/domains

Create a new domain.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Backend",
  "parent_domain_id": "parent_uuid",  // Optional
  "domain_type": "team"
}
```

**Notes:**
- Creates 4 default circles (Management, Development, QA, Infrastructure)

---

### GET /api/domains/{id}

Get domain with members, resources, and circles.

---

### PUT /api/domains/{id}

Update domain.

---

### DELETE /api/domains/{id}

Delete domain and all sub-domains (cascading).

---

## Domain Members

### GET /api/domains/{id}/members

List members of a domain.

**Response (200):**
```json
{
  "members": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "role": "DEVELOPER",
      "allocation_percentage": 100,
      "user": { "email": "user@company.com", "full_name": "Jane Doe" }
    }
  ]
}
```

---

### POST /api/domains/{id}/members

Add member to domain.

**Request Body:**
```json
{
  "user_id": "uuid",
  "role": "DEVELOPER",
  "allocation_percentage": 50
}
```

---

### DELETE /api/domains/{id}/members/{userId}

Remove member from domain.

---

## Resources

### GET /api/resources

List resources (optionally filtered by domain).

**Query Parameters:**
- `domain_id=uuid` - Filter by domain

**Response (200):**
```json
{
  "resources": [
    {
      "id": "uuid",
      "resource_type": "web_app_project",
      "resource_name": "Customer Portal",
      "resource_status": "active",
      "attributes": [
        { "attribute_name": "frontend_framework", "attribute_value": "nextjs" }
      ]
    }
  ]
}
```

---

### POST /api/resources

Create a new resource.

**Request Body:**
```json
{
  "domain_id": "uuid",
  "resource_type": "web_app_project",
  "resource_name": "Customer Portal",
  "attributes": {
    "frontend_framework": "nextjs",
    "css_framework": "tailwind",
    "git_repo_url": "https://github.com/..."
  }
}
```

---

### GET /api/resources/{id}

Get resource with all attributes.

---

### PUT /api/resources/{id}

Update resource and attributes.

---

### DELETE /api/resources/{id}

Delete resource and all attributes.

---

## Flows

### GET /api/flows

List flows (optionally filtered by domain or stage).

**Query Parameters:**
- `domain_id=uuid` - Filter by domain
- `quad_stage=Q|U|A|D` - Filter by stage
- `assigned_to=uuid` - Filter by assignee

**Response (200):**
```json
{
  "flows": [
    {
      "id": "uuid",
      "title": "Implement user authentication",
      "quad_stage": "D",
      "stage_status": "in_progress",
      "priority": "high",
      "assigned_to": "uuid",
      "assignee": { "full_name": "Jane Doe" }
    }
  ]
}
```

---

### POST /api/flows

Create a new flow.

**Request Body:**
```json
{
  "domain_id": "uuid",
  "title": "Implement user authentication",
  "description": "Add login/logout functionality",
  "flow_type": "feature",
  "priority": "high",
  "assigned_to": "uuid"
}
```

---

### GET /api/flows/{id}

Get flow with stage history.

---

### PUT /api/flows/{id}

Update flow. Stage transitions are logged to history.

**Request Body:**
```json
{
  "quad_stage": "U",
  "stage_status": "completed",
  "change_reason": "Requirements clarified"
}
```

---

### DELETE /api/flows/{id}

Delete flow and history.

---

## Circles

### GET /api/circles

List circles (optionally filtered by domain).

**Query Parameters:**
- `domain_id=uuid` - Filter by domain

---

### POST /api/circles

Create a new circle.

**Request Body:**
```json
{
  "domain_id": "uuid",
  "circle_number": 5,
  "circle_name": "Security",
  "lead_user_id": "uuid"
}
```

---

### GET /api/circles/{id}

Get circle with members.

---

### PUT /api/circles/{id}

Update circle.

---

### DELETE /api/circles/{id}

Delete circle and memberships.

---

## Circle Members

### GET /api/circles/{id}/members

List members of a circle.

---

### POST /api/circles/{id}/members

Add member to circle.

**Request Body:**
```json
{
  "user_id": "uuid",
  "role": "member",
  "allocation_pct": 100
}
```

---

### DELETE /api/circles/{id}/members/{userId}

Remove member from circle.

---

## Adoption Matrix

### GET /api/adoption-matrix

List all adoption matrices in organization.

---

### GET /api/adoption-matrix/{userId}

Get adoption matrix for specific user.

**Response (200):**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "skill_level": 2,
  "trust_level": 2,
  "previous_skill_level": 1,
  "previous_trust_level": 1,
  "level_changed_at": "2026-01-01T00:00:00Z"
}
```

**Levels:** 1 (Low), 2 (Medium), 3 (High)

---

### PUT /api/adoption-matrix/{userId}

Update adoption matrix levels.

**Request Body:**
```json
{
  "skill_level": 3,
  "trust_level": 2,
  "notes": "Completed AI training course"
}
```

---

## Work Sessions

### GET /api/work-sessions

List work sessions (filtered by user and date range).

**Query Parameters:**
- `user_id=uuid` - Filter by user
- `start_date=2026-01-01` - Start of date range
- `end_date=2026-01-31` - End of date range

---

### POST /api/work-sessions

Log a work session.

**Request Body:**
```json
{
  "session_date": "2026-01-01",
  "hours_worked": 8,
  "is_workday": true,
  "start_time": "09:00",
  "end_time": "17:00",
  "deep_work_pct": 60,
  "meeting_hours": 2
}
```

---

## Workload Metrics

### GET /api/workload

List workload metrics (filtered by user and period).

**Query Parameters:**
- `user_id=uuid` - Filter by user
- `domain_id=uuid` - Filter by domain
- `period_type=week|month|quarter`

---

### POST /api/workload

Create workload metric entry.

**Request Body:**
```json
{
  "user_id": "uuid",
  "domain_id": "uuid",
  "period_start": "2026-01-01",
  "period_end": "2026-01-07",
  "period_type": "week",
  "assignments": 5,
  "completes": 4,
  "hours_worked": 40,
  "root_cause": "blocked_dependency",
  "root_cause_notes": "Waiting on API team"
}
```

**Root Cause Values:**
- `blocked_dependency` - Waiting on external team
- `scope_creep` - Requirements expanded
- `technical_debt` - Legacy code issues
- `understaffed` - Not enough developers
- `overcommitted` - Too many assignments
- `null` - No issues

---

## Error Responses

### 400 Bad Request

```json
{
  "error": "role_code and role_name are required"
}
```

### 401 Unauthorized

```json
{
  "error": "Unauthorized"
}
```

### 403 Forbidden

```json
{
  "error": "Forbidden - Admin access required"
}
```

### 404 Not Found

```json
{
  "error": "Role not found"
}
```

### 409 Conflict

```json
{
  "error": "Role code 'DEVELOPER' already exists"
}
```

---

## Rate Limiting

Currently no rate limiting. Planned for O(n) and O(n²) modes:
- O(1) Seed: 100 requests/minute
- O(n) Growth: 1000 requests/minute
- O(n²) Scale: Unlimited (client infrastructure)

---

## Webhooks (Planned)

Future endpoint for integrations:
- `POST /api/webhooks` - Register webhook
- `GET /api/webhooks` - List webhooks
- `DELETE /api/webhooks/{id}` - Remove webhook

**Events:**
- `flow.stage_changed`
- `user.adoption_updated`
- `domain.created`

---

**Last Updated:** January 1, 2026
