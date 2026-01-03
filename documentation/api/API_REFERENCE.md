# QUAD Platform - Complete API Reference

**Version:** 2.0
**Last Updated:** January 3, 2026
**Total Routes:** 115+
**Base URL:** `/api`

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Organizations](#organizations)
4. [Users](#users)
5. [Roles](#roles)
6. [Domains](#domains)
7. [Circles](#circles)
8. [Flows](#flows)
9. [Cycles](#cycles)
10. [Requirements](#requirements)
11. [Tickets](#tickets)
12. [Resources](#resources)
13. [AI & Chat](#ai--chat)
14. [Memory & Context](#memory--context)
15. [Git Integration](#git-integration)
16. [Meeting Integration](#meeting-integration)
17. [Pull Requests](#pull-requests)
18. [Dashboard & Analytics](#dashboard--analytics)
19. [Gamification](#gamification)
20. [Rankings](#rankings)
21. [Kudos](#kudos)
22. [Training](#training)
23. [Skills](#skills)
24. [User Skills](#user-skills)
25. [Skill Feedback](#skill-feedback)
26. [Risks](#risks)
27. [Database Operations](#database-operations)
28. [Adoption Matrix](#adoption-matrix)
29. [Workload](#workload)
30. [Work Sessions](#work-sessions)
31. [Blueprint Agent](#blueprint-agent)
32. [Book Generation](#book-generation)
33. [Admin & BYOK](#admin--byok)
34. [Setup](#setup)
35. [Codebase](#codebase)
36. [Meetings](#meetings)
37. [Tools](#tools)
38. [Error Responses](#error-responses)
39. [Rate Limiting](#rate-limiting)

---

## Overview

QUAD Platform provides a comprehensive RESTful API with **115+ endpoints** across **37 categories**. Built on Next.js 14 App Router with Prisma ORM connecting to PostgreSQL.

### Architecture

```
Client Request → Next.js API Route → Prisma ORM → PostgreSQL
                     ↓
              JWT Authentication
                     ↓
              Business Logic
                     ↓
              JSON Response
```

### Authentication Header

All endpoints (except `/auth/*` public routes) require:

```
Authorization: Bearer <jwt_token>
```

### Response Format

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
  "details": { ... }
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

### POST /api/auth/signup

Create a new user account with SSO (Google OAuth).

**Request Body:**
```json
{
  "email": "user@company.com",
  "name": "John Doe",
  "companyName": "Acme Corp"
}
```

**Response (201):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@company.com",
    "full_name": "John Doe"
  },
  "company": {
    "id": "uuid",
    "name": "Acme Corp"
  }
}
```

---

### POST /api/auth/register

Legacy registration with email/password.

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
  "user": { "id": "uuid", "email": "admin@company.com" },
  "company": { "id": "uuid", "name": "Acme Corp" },
  "token": "jwt_token_here"
}
```

---

### POST /api/auth/login

Authenticate with email/password.

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
    "company_id": "uuid"
  }
}
```

---

### POST /api/auth/send-code

Send verification code to email.

**Request Body:**
```json
{
  "email": "user@company.com"
}
```

**Response (200):**
```json
{
  "message": "Verification code sent"
}
```

---

### POST /api/auth/verify-code

Verify email code.

**Request Body:**
```json
{
  "email": "user@company.com",
  "code": "123456"
}
```

**Response (200):**
```json
{
  "verified": true,
  "token": "jwt_token_here"
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

### GET /api/auth/sso-config

Get SSO configuration for organization.

**Query Parameters:**
- `domain=company.com` - Email domain

**Response (200):**
```json
{
  "provider": "google",
  "enabled": true,
  "clientId": "google_client_id"
}
```

---

### GET /api/auth/user-domains

Get domains accessible by current user.

**Response (200):**
```json
{
  "domains": [
    { "id": "uuid", "name": "Engineering", "path": "/engineering" }
  ]
}
```

---

### POST /api/auth/set-domain

Set active domain for user session.

**Request Body:**
```json
{
  "domainId": "uuid"
}
```

---

### POST /api/auth/request-access

Request access to a domain.

**Request Body:**
```json
{
  "domainId": "uuid",
  "message": "I need access for project X"
}
```

---

### GET /api/auth/[...nextauth]

NextAuth.js handler for OAuth flows (Google, GitHub, etc.).

---

## Organizations

### GET /api/organizations

List all organizations (admin only).

**Response (200):**
```json
{
  "organizations": [
    {
      "id": "uuid",
      "name": "Acme Corp",
      "admin_email": "admin@acme.com",
      "is_active": true,
      "_count": { "users": 25 }
    }
  ]
}
```

---

### POST /api/organizations

Create a new organization.

**Request Body:**
```json
{
  "name": "New Company",
  "admin_email": "admin@newcompany.com",
  "size": "medium"
}
```

---

### GET /api/organizations/[id]/invite

List pending invitations for organization.

---

### POST /api/organizations/[id]/invite

Invite user to organization.

**Request Body:**
```json
{
  "email": "newuser@company.com",
  "role_id": "uuid"
}
```

---

### GET /api/companies

List companies (legacy endpoint, maps to organizations).

---

### GET /api/companies/[id]

Get company details.

---

### PUT /api/companies/[id]

Update company.

---

## Users

### GET /api/users

List all users in organization.

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

Create a new user (admin only).

**Request Body:**
```json
{
  "email": "newuser@company.com",
  "password": "password123",
  "full_name": "New User",
  "role_id": "uuid"
}
```

---

### GET /api/users/[id]

Get user by ID.

---

### PUT /api/users/[id]

Update user.

**Request Body:**
```json
{
  "full_name": "Updated Name",
  "role_id": "uuid",
  "is_active": true
}
```

---

### DELETE /api/users/[id]

Delete user (admin only).

---

## Roles

### GET /api/roles

List all roles in organization.

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
      "hierarchy_level": 40
    }
  ]
}
```

---

### POST /api/roles

Create a new role.

**Request Body:**
```json
{
  "role_code": "SCRUM_MASTER",
  "role_name": "Scrum Master",
  "description": "Facilitates agile ceremonies",
  "can_manage_users": false,
  "can_manage_domains": true,
  "q_participation": "PRIMARY",
  "hierarchy_level": 70
}
```

**Participation Values:** `PRIMARY`, `SUPPORT`, `REVIEW`, `INFORM`, `null`

---

### GET /api/roles/[id]

Get role by ID with assigned users.

---

### PUT /api/roles/[id]

Update role (admin only).

---

### DELETE /api/roles/[id]

Delete role (cannot delete system roles or roles with users).

---

### GET /api/core-roles

List master role templates (18 predefined roles).

**Response (200):**
```json
{
  "coreRoles": [
    {
      "id": "uuid",
      "role_code": "SUPER_ADMIN",
      "role_name": "Super Admin",
      "category": "ADMIN",
      "hierarchy_level": 100
    }
  ]
}
```

---

## Domains

### GET /api/domains

List all domains in organization (hierarchical).

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
        { "id": "uuid", "name": "Frontend", "path": "/engineering/frontend" }
      ]
    }
  ]
}
```

---

### GET /api/domains/list

Simple flat list of domains.

---

### POST /api/domains

Create a new domain.

**Request Body:**
```json
{
  "name": "Backend",
  "parent_domain_id": "uuid",
  "domain_type": "team"
}
```

**Note:** Creates 4 default circles (Management, Development, QA, Infrastructure).

---

### POST /api/domains/create

Alternative domain creation endpoint.

---

### GET /api/domains/[id]

Get domain with members, resources, and circles.

---

### PUT /api/domains/[id]

Update domain.

---

### PATCH /api/domains/[id]

Partial update/restore deleted domain.

---

### DELETE /api/domains/[id]

Soft-delete domain.

**Query Parameters:**
- `cascade=true` - Also delete sub-domains

---

### GET /api/domains/[id]/members

List domain members.

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

### POST /api/domains/[id]/members

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

### DELETE /api/domains/[id]/members

Remove member from domain.

**Query Parameters:**
- `userId=uuid` - User to remove

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

### GET /api/circles/[id]

Get circle with members.

---

### PUT /api/circles/[id]

Update circle.

---

### DELETE /api/circles/[id]

Delete circle and memberships.

---

### GET /api/circles/[id]/members

List circle members.

---

### POST /api/circles/[id]/members

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

### DELETE /api/circles/[id]/members

Remove member from circle.

---

## Flows

### GET /api/flows

List flows (optionally filtered).

**Query Parameters:**
- `domain_id=uuid` - Filter by domain
- `quad_stage=Q|U|A|D` - Filter by stage
- `assigned_to=uuid` - Filter by assignee
- `cycle_id=uuid` - Filter by cycle

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

### GET /api/flows/[id]

Get flow with stage history.

---

### PUT /api/flows/[id]

Update flow. Stage transitions are logged.

**Request Body:**
```json
{
  "quad_stage": "U",
  "stage_status": "completed",
  "change_reason": "Requirements clarified"
}
```

---

### DELETE /api/flows/[id]

Delete flow and history.

---

### POST /api/flows/[id]/branch

Create Git branch for flow.

**Request Body:**
```json
{
  "repository_id": "uuid",
  "branch_name": "feature/FLOW-123-auth"
}
```

---

### GET /api/flows/[id]/branch

Get branch info for flow.

---

### POST /api/flows/[id]/pull-request

Create pull request for flow.

**Request Body:**
```json
{
  "title": "Add authentication feature",
  "description": "Implements login/logout",
  "base_branch": "main"
}
```

---

### GET /api/flows/[id]/pull-request

Get pull request info for flow.

---

## Cycles

### GET /api/cycles

List cycles (sprints).

**Query Parameters:**
- `domain_id=uuid` - Filter by domain
- `status=active|completed|planned`

**Response (200):**
```json
{
  "cycles": [
    {
      "id": "uuid",
      "name": "Sprint 23",
      "start_date": "2026-01-06",
      "end_date": "2026-01-20",
      "status": "active",
      "goal": "Complete authentication module",
      "_count": { "flows": 8, "tickets": 24 }
    }
  ]
}
```

---

### POST /api/cycles

Create a new cycle.

**Request Body:**
```json
{
  "domain_id": "uuid",
  "name": "Sprint 24",
  "start_date": "2026-01-20",
  "end_date": "2026-02-03",
  "goal": "Payment integration"
}
```

---

### GET /api/cycles/[id]

Get cycle with flows and metrics.

---

### PUT /api/cycles/[id]

Update cycle.

---

### DELETE /api/cycles/[id]

Delete cycle (moves flows to backlog).

---

## Requirements

### GET /api/requirements

List requirements.

**Query Parameters:**
- `domain_id=uuid` - Filter by domain
- `status=draft|approved|in_progress|completed`

**Response (200):**
```json
{
  "requirements": [
    {
      "id": "uuid",
      "title": "User Authentication",
      "description": "System shall support SSO login",
      "type": "functional",
      "priority": "high",
      "status": "approved"
    }
  ]
}
```

---

### POST /api/requirements

Create a new requirement.

**Request Body:**
```json
{
  "domain_id": "uuid",
  "title": "Payment Processing",
  "description": "System shall process credit card payments",
  "type": "functional",
  "priority": "high"
}
```

---

### GET /api/requirements/[id]

Get requirement with linked flows.

---

### PUT /api/requirements/[id]

Update requirement.

---

### DELETE /api/requirements/[id]

Delete requirement.

---

### POST /api/requirements/[id]/analyze

AI-analyze requirement for completeness and ambiguity.

**Response (200):**
```json
{
  "analysis": {
    "completeness_score": 85,
    "ambiguity_issues": ["Define 'fast' in concrete terms"],
    "suggested_acceptance_criteria": ["..."],
    "estimated_complexity": "medium"
  }
}
```

---

### POST /api/requirements/[id]/generate-tickets

AI-generate tickets from requirement.

**Request Body:**
```json
{
  "ticket_count": 5,
  "include_subtasks": true
}
```

---

## Tickets

### GET /api/tickets

List tickets.

**Query Parameters:**
- `flow_id=uuid` - Filter by flow
- `cycle_id=uuid` - Filter by cycle
- `assigned_to=uuid` - Filter by assignee
- `status=open|in_progress|review|done`

**Response (200):**
```json
{
  "tickets": [
    {
      "id": "uuid",
      "ticket_number": "TKT-001",
      "title": "Create login form",
      "status": "in_progress",
      "priority": "high",
      "story_points": 3,
      "assignee": { "full_name": "Jane Doe" }
    }
  ]
}
```

---

### POST /api/tickets

Create a new ticket.

**Request Body:**
```json
{
  "flow_id": "uuid",
  "title": "Create login form",
  "description": "Build React login component",
  "ticket_type": "task",
  "priority": "high",
  "story_points": 3
}
```

---

### GET /api/tickets/[id]

Get ticket with comments and time logs.

---

### PUT /api/tickets/[id]

Update ticket.

---

### DELETE /api/tickets/[id]

Delete ticket.

---

### POST /api/tickets/[id]/analyze

AI-analyze ticket for implementation suggestions.

---

### GET /api/tickets/[id]/comments

List ticket comments.

---

### POST /api/tickets/[id]/comments

Add comment to ticket.

**Request Body:**
```json
{
  "content": "Started working on this",
  "type": "comment"
}
```

---

### GET /api/tickets/[id]/time-logs

List time logs for ticket.

---

### POST /api/tickets/[id]/time-logs

Log time on ticket.

**Request Body:**
```json
{
  "hours": 2.5,
  "description": "Implemented form validation",
  "log_date": "2026-01-03"
}
```

---

## Resources

### GET /api/resources

List resources.

**Query Parameters:**
- `domain_id=uuid` - Filter by domain
- `resource_type=web_app_project|mobile_app|api_service`

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

### GET /api/resources/[resourceId]

Get resource with all attributes.

---

### PUT /api/resources/[resourceId]

Update resource.

---

### DELETE /api/resources/[resourceId]

Delete resource.

---

### POST /api/resources/[resourceId]/analyze-repo

Analyze connected Git repository.

---

### GET /api/resources/[resourceId]/analyze-repo

Get repository analysis results.

---

### GET /api/resources/[resourceId]/attributes/git-repo

Get Git repository attribute.

---

### POST /api/resources/[resourceId]/attributes/git-repo

Set Git repository attribute.

---

### DELETE /api/resources/[resourceId]/attributes/git-repo

Remove Git repository link.

---

### GET /api/resources/[resourceId]/attributes/blueprint

Get project blueprint.

---

### POST /api/resources/[resourceId]/attributes/blueprint

Generate/save project blueprint.

---

## AI & Chat

### POST /api/ai/chat

Send message to AI assistant.

**Request Body:**
```json
{
  "messages": [
    { "role": "user", "content": "How do I implement authentication?" }
  ],
  "context": {
    "domain_id": "uuid",
    "resource_id": "uuid"
  }
}
```

**Response (200):**
```json
{
  "response": "To implement authentication, you should...",
  "usage": { "prompt_tokens": 50, "completion_tokens": 200 }
}
```

---

### POST /api/ai/chat/stream

Stream AI response.

**Request Body:** Same as `/api/ai/chat`

**Response:** Server-Sent Events stream

---

### GET /api/ai/credits

Get AI credit balance and usage.

**Response (200):**
```json
{
  "balance": {
    "total_credits": 10000,
    "used_credits": 2500,
    "remaining_credits": 7500
  },
  "tier": "growth",
  "reset_date": "2026-02-01"
}
```

---

### POST /api/ai/credits

Purchase/add AI credits.

---

### GET /api/ai/usage

Get AI usage statistics.

**Query Parameters:**
- `period=day|week|month`

---

### GET /api/ai/ticket-chat

Get ticket-specific chat history.

---

### POST /api/ai/ticket-chat

Send message about specific ticket.

---

### POST /api/ai/ticket-chat/stream

Stream ticket chat response.

---

### GET /api/ai/settings

Get AI configuration settings.

---

### PATCH /api/ai/settings

Update AI settings.

---

### GET /api/ai

Get AI service status.

---

### POST /api/ai

Generic AI completion endpoint.

---

### GET /api/ai-config

Get organization AI configuration.

---

### PUT /api/ai-config

Update organization AI configuration.

---

## Memory & Context

### POST /api/memory/context

Create new conversation context session.

**Request Body:**
```json
{
  "resource_id": "uuid",
  "session_type": "planning",
  "initial_context": { "goal": "Design auth system" }
}
```

---

### GET /api/memory/context/[sessionId]

Get conversation context.

---

### POST /api/memory/context/[sessionId]

Add to conversation context.

---

### PATCH /api/memory/context/[sessionId]

Update context metadata.

---

### GET /api/memory/documents

List memory documents (vector store).

---

### POST /api/memory/documents

Add document to memory.

**Request Body:**
```json
{
  "content": "Document content for RAG",
  "metadata": { "source": "confluence", "page": "auth-design" }
}
```

---

### GET /api/memory/templates

List prompt templates.

---

### POST /api/memory/templates

Create prompt template.

---

### GET /api/memory/analytics

Get memory usage analytics.

---

## Git Integration

### GET /api/integrations/git/providers

List available Git providers.

**Response (200):**
```json
{
  "providers": [
    { "id": "github", "name": "GitHub", "icon": "github" },
    { "id": "gitlab", "name": "GitLab", "icon": "gitlab" },
    { "id": "bitbucket", "name": "Bitbucket", "icon": "bitbucket" }
  ]
}
```

---

### POST /api/integrations/git/[provider]/connect

Start OAuth flow for Git provider.

---

### GET /api/integrations/git/[provider]/callback

OAuth callback handler.

---

### POST /api/integrations/git/[provider]/disconnect

Disconnect Git provider.

---

### GET /api/integrations/git/status

Get Git integration status for organization.

---

### GET /api/integrations/git/repositories

List connected repositories.

---

### POST /api/integrations/git/repositories

Add repository to organization.

---

## Meeting Integration

### GET /api/integrations/meeting/providers

List available meeting providers.

**Response (200):**
```json
{
  "providers": [
    {
      "id": "google_calendar",
      "name": "Google Calendar",
      "features": ["Calendar sync", "Google Meet"]
    },
    {
      "id": "cal_com",
      "name": "Cal.com",
      "features": ["Webhook events", "API integration"]
    }
  ]
}
```

---

### POST /api/integrations/meeting/[provider]/connect

Start OAuth flow for meeting provider.

---

### GET /api/integrations/meeting/[provider]/callback

OAuth callback handler.

---

### POST /api/integrations/meeting/[provider]/disconnect

Disconnect meeting provider.

---

### POST /api/integrations/meeting/[provider]/webhook

Webhook endpoint for meeting events.

---

### GET /api/integrations/meeting/status

Get meeting integration status.

---

## Pull Requests

### GET /api/pull-requests/[prId]/approvals

List PR approvals.

---

### POST /api/pull-requests/[prId]/approvals

Approve pull request.

---

### DELETE /api/pull-requests/[prId]/approvals

Remove approval.

---

### GET /api/pull-requests/[prId]/reviewers

List PR reviewers.

---

### POST /api/pull-requests/[prId]/reviewers

Add reviewer.

---

### DELETE /api/pull-requests/[prId]/reviewers

Remove reviewer.

---

### PATCH /api/pull-requests/[prId]/reviewers

Update reviewer status.

---

## Dashboard & Analytics

### GET /api/dashboard

Get dashboard overview metrics.

**Response (200):**
```json
{
  "metrics": {
    "active_flows": 12,
    "completed_this_week": 8,
    "upcoming_deadlines": 3,
    "team_velocity": 45
  }
}
```

---

### GET /api/dashboard/velocity

Get velocity metrics over time.

**Query Parameters:**
- `cycles=5` - Number of cycles to include

---

### GET /api/dashboard/team

Get team performance metrics.

---

### GET /api/dashboard/cycles/[id]/burndown

Get burndown chart data for cycle.

---

## Gamification

### GET /api/gamification

Get gamification data for user.

**Response (200):**
```json
{
  "points": {
    "total": 1250,
    "this_week": 150,
    "rank": 3
  },
  "badges": [
    { "id": "uuid", "name": "First Flow", "earned_at": "2026-01-01" }
  ],
  "streak": {
    "current": 5,
    "longest": 12
  }
}
```

---

## Rankings

### GET /api/rankings

Get leaderboard rankings.

**Query Parameters:**
- `period=week|month|all_time`
- `domain_id=uuid`

---

### POST /api/rankings

Update ranking configuration.

---

### GET /api/rankings/config

Get ranking configuration.

---

### PUT /api/rankings/config

Update ranking rules.

---

## Kudos

### GET /api/kudos

List kudos (peer recognition).

**Query Parameters:**
- `received_by=uuid` - Filter by recipient
- `given_by=uuid` - Filter by sender

---

### POST /api/kudos

Give kudos to colleague.

**Request Body:**
```json
{
  "to_user_id": "uuid",
  "message": "Great work on the auth feature!",
  "category": "collaboration"
}
```

---

## Training

### GET /api/training

List training modules.

---

### POST /api/training

Create training module (admin).

---

### PUT /api/training/[id]/progress

Update training progress.

**Request Body:**
```json
{
  "progress_percentage": 75,
  "completed_sections": ["intro", "basics", "advanced"]
}
```

---

## Skills

### GET /api/skills

List skill definitions.

---

### POST /api/skills

Create skill (admin).

---

### PUT /api/skills/[id]

Update skill.

---

### DELETE /api/skills/[id]

Delete skill.

---

## User Skills

### GET /api/user-skills

Get current user's skills.

---

### POST /api/user-skills

Add skill to profile.

**Request Body:**
```json
{
  "skill_id": "uuid",
  "proficiency_level": 3,
  "years_experience": 2
}
```

---

### GET /api/user-skills/interests

Get user's skill interests.

---

### PUT /api/user-skills/interests

Set skill interests.

---

### PATCH /api/user-skills/interests

Update skill interests.

---

## Skill Feedback

### GET /api/skill-feedback

Get feedback on skills.

---

### POST /api/skill-feedback

Give skill feedback.

**Request Body:**
```json
{
  "user_id": "uuid",
  "skill_id": "uuid",
  "rating": 4,
  "feedback": "Strong understanding of React hooks"
}
```

---

### PATCH /api/skill-feedback

Update feedback.

---

## Risks

### GET /api/risks

List project risks.

**Query Parameters:**
- `domain_id=uuid`
- `status=open|mitigated|closed`

---

### POST /api/risks

Create risk entry.

**Request Body:**
```json
{
  "title": "API Rate Limiting",
  "description": "Third-party API may throttle requests",
  "probability": "medium",
  "impact": "high",
  "mitigation_plan": "Implement caching layer"
}
```

---

### GET /api/risks/[id]

Get risk details.

---

### PUT /api/risks/[id]

Update risk.

---

### DELETE /api/risks/[id]

Delete risk.

---

## Database Operations

### GET /api/database-operations

List database operations (A-stage).

**Query Parameters:**
- `status=pending|approved|completed|rejected`

---

### POST /api/database-operations

Create database operation request.

**Request Body:**
```json
{
  "operation_type": "schema_migration",
  "description": "Add user preferences table",
  "sql_script": "CREATE TABLE user_preferences (...)",
  "target_environment": "production"
}
```

---

### GET /api/database-operations/[id]

Get operation details.

---

### PATCH /api/database-operations/[id]

Update operation (approve/reject).

---

### DELETE /api/database-operations/[id]

Delete operation.

---

## Adoption Matrix

### GET /api/adoption-matrix

List all adoption matrices.

---

### PUT /api/adoption-matrix

Bulk update adoption levels.

---

### GET /api/adoption-matrix/[userId]

Get adoption matrix for user.

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

## Workload

### GET /api/workload

Get workload metrics.

**Query Parameters:**
- `user_id=uuid`
- `domain_id=uuid`
- `period_type=week|month|quarter`

---

### POST /api/workload

Create workload entry.

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
  "root_cause": "blocked_dependency"
}
```

**Root Cause Values:** `blocked_dependency`, `scope_creep`, `technical_debt`, `understaffed`, `overcommitted`, `null`

---

## Work Sessions

### GET /api/work-sessions

List work sessions.

**Query Parameters:**
- `user_id=uuid`
- `start_date=2026-01-01`
- `end_date=2026-01-31`

---

### POST /api/work-sessions

Log work session.

**Request Body:**
```json
{
  "session_date": "2026-01-03",
  "hours_worked": 8,
  "is_workday": true,
  "start_time": "09:00",
  "end_time": "17:00",
  "deep_work_pct": 60,
  "meeting_hours": 2
}
```

---

## Blueprint Agent

### POST /api/blueprint-agent/start-interview

Start blueprint discovery interview.

**Request Body:**
```json
{
  "resource_id": "uuid",
  "interview_type": "new_project"
}
```

---

### POST /api/blueprint-agent/submit-answer

Submit answer to interview question.

**Request Body:**
```json
{
  "session_id": "uuid",
  "question_id": "uuid",
  "answer": "We want to use Next.js with TypeScript"
}
```

---

## Book Generation

### GET /api/book/database

Get database documentation book.

---

### POST /api/book/database

Generate database documentation.

---

### GET /api/book/nextjs

Get Next.js documentation book.

---

### POST /api/book/nextjs

Generate Next.js documentation.

---

### GET /api/book/download

Download generated book.

**Query Parameters:**
- `format=pdf|markdown|html`

---

### POST /api/book/download

Generate downloadable book.

---

## Admin & BYOK

### GET /api/admin/byok

Get BYOK (Bring Your Own Key) configuration overview.

**Response (200):**
```json
{
  "categories": [
    { "id": "ai", "name": "AI Providers", "configured": true },
    { "id": "git", "name": "Git Providers", "configured": true },
    { "id": "meeting", "name": "Meeting Providers", "configured": false }
  ]
}
```

---

### GET /api/admin/byok/[category]

Get providers for category.

---

### PATCH /api/admin/byok/[category]

Update category settings.

---

### GET /api/admin/byok/[category]/[provider]

Get provider configuration.

---

### POST /api/admin/byok/[category]/[provider]

Configure provider credentials.

**Request Body:**
```json
{
  "api_key": "sk-...",
  "model": "gpt-4",
  "endpoint": "https://api.openai.com/v1"
}
```

---

### DELETE /api/admin/byok/[category]/[provider]

Remove provider configuration.

---

### GET /api/admin/ai-pool

Get AI credit pool status.

---

## Setup

### GET /api/setup/status

Get organization setup status.

**Response (200):**
```json
{
  "setup": {
    "meeting_provider_configured": true,
    "calendar_connected": true,
    "ai_tier_selected": true,
    "first_domain_created": true,
    "setup_completed_at": "2026-01-01"
  }
}
```

---

### GET /api/setup/check

Quick check if setup is complete (for middleware).

**Response (200):**
```json
{
  "complete": true
}
```

---

## Codebase

### GET /api/codebase/search

Search codebase index.

**Query Parameters:**
- `q=authentication` - Search query
- `file_type=ts|tsx|js`

---

### POST /api/codebase/search

Advanced codebase search.

---

### GET /api/codebase-index

Get codebase index status.

---

## Meetings

### GET /api/meetings/[id]/mom

Get meeting minutes (MoM).

---

### POST /api/meetings/[id]/mom

Generate meeting minutes from transcript.

---

### PATCH /api/meetings/[id]/mom

Update meeting minutes.

---

## Tools

### POST /api/tools/request

Execute tool request (internal).

---

## Error Responses

### 400 Bad Request

```json
{
  "error": "Validation failed",
  "details": {
    "email": "Invalid email format",
    "name": "Name is required"
  }
}
```

### 401 Unauthorized

```json
{
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

### 403 Forbidden

```json
{
  "error": "Forbidden",
  "message": "Admin access required"
}
```

### 404 Not Found

```json
{
  "error": "Not found",
  "message": "Resource with ID xxx not found"
}
```

### 409 Conflict

```json
{
  "error": "Conflict",
  "message": "Email already exists"
}
```

### 500 Internal Server Error

```json
{
  "error": "Internal server error",
  "message": "An unexpected error occurred"
}
```

---

## Rate Limiting

| Mode | Requests/Minute | Description |
|------|-----------------|-------------|
| O(1) Seed | 100 | Starter tier |
| O(n) Growth | 1000 | Growth tier |
| O(n²) Scale | Unlimited | Enterprise |

Rate limit headers included in responses:
- `X-RateLimit-Limit`: Max requests per window
- `X-RateLimit-Remaining`: Requests remaining
- `X-RateLimit-Reset`: Window reset timestamp

---

**API Routes Summary:**

| Category | Routes | Status |
|----------|--------|--------|
| Authentication | 11 | ✅ Implemented |
| Organizations | 7 | ✅ Implemented |
| Users | 5 | ✅ Implemented |
| Roles | 6 | ✅ Implemented |
| Domains | 10 | ✅ Implemented |
| Circles | 7 | ✅ Implemented |
| Flows | 8 | ✅ Implemented |
| Cycles | 5 | ✅ Implemented |
| Requirements | 6 | ✅ Implemented |
| Tickets | 9 | ✅ Implemented |
| Resources | 10 | ✅ Implemented |
| AI & Chat | 12 | ✅ Implemented |
| Memory & Context | 7 | ✅ Implemented |
| Git Integration | 7 | ✅ Implemented |
| Meeting Integration | 6 | ✅ Implemented |
| Pull Requests | 7 | ✅ Implemented |
| Dashboard | 4 | ✅ Implemented |
| Gamification | 1 | ✅ Implemented |
| Rankings | 4 | ✅ Implemented |
| Kudos | 2 | ✅ Implemented |
| Training | 3 | ✅ Implemented |
| Skills | 4 | ✅ Implemented |
| User Skills | 5 | ✅ Implemented |
| Skill Feedback | 3 | ✅ Implemented |
| Risks | 5 | ✅ Implemented |
| Database Operations | 5 | ✅ Implemented |
| Adoption Matrix | 3 | ✅ Implemented |
| Workload | 2 | ✅ Implemented |
| Work Sessions | 2 | ✅ Implemented |
| Blueprint Agent | 2 | ✅ Implemented |
| Book Generation | 6 | ✅ Implemented |
| Admin & BYOK | 6 | ✅ Implemented |
| Setup | 2 | ✅ Implemented |
| Codebase | 3 | ✅ Implemented |
| Meetings | 3 | ✅ Implemented |
| Tools | 1 | ✅ Implemented |
| **Total** | **~175 methods** | |

---

**Last Updated:** January 3, 2026
**Version:** 2.0
