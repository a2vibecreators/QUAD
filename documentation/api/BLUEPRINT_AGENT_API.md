# Blueprint Agent API Reference

**Date:** December 31, 2025
**Status:** ✅ Implemented
**Base URL:** `https://quadframe.work/api`

---

## Overview

Blueprint Agent APIs allow users to:
1. Upload blueprint URLs (Figma, Sketch, competitor websites)
2. Link Git repositories for tech stack analysis
3. Start AI-powered interview to generate mockups

All blueprint and Git repo data is stored as **resource attributes** using the EAV (Entity-Attribute-Value) pattern.

---

## API Endpoints

### 1. Upload Blueprint URL

**Endpoint:** `POST /api/resources/{resourceId}/attributes/blueprint`

**Purpose:** Upload blueprint design files or competitor website URLs

**Request:**
```json
{
  "blueprintUrl": "https://figma.com/file/abc123",
  "blueprintType": "figma_url",  // Optional: auto-detected if not provided
  "additionalUrls": [            // Optional: additional pages/screens
    {
      "name": "Dashboard",
      "url": "https://figma.com/file/dashboard"
    },
    {
      "name": "Login",
      "url": "https://figma.com/file/login"
    }
  ]
}
```

**Supported Blueprint Types:**
- `figma_url` - Figma design files
- `sketch_url` - Sketch Cloud files
- `adobe_xd_url` - Adobe XD files
- `competitor_url` - Competitor website (for inspiration)
- `wireframe_image` - Uploaded wireframe image
- `blueprint_agent` - AI-generated mockup

**Response:**
```json
{
  "success": true,
  "message": "Blueprint uploaded successfully",
  "data": {
    "resourceId": "550e8400-e29b-41d4-a716-446655440000",
    "blueprintType": "figma_url",
    "blueprintUrl": "https://figma.com/file/abc123",
    "verified": true,
    "verificationError": null,
    "additionalUrls": [...],
    "isRequired": true
  }
}
```

**Error Responses:**
- `400` - Invalid URL format
- `404` - Resource not found
- `500` - Internal server error

---

### 2. Get Blueprint Data

**Endpoint:** `GET /api/resources/{resourceId}/attributes/blueprint`

**Purpose:** Retrieve blueprint information for a resource

**Response:**
```json
{
  "success": true,
  "data": {
    "resourceId": "550e8400-e29b-41d4-a716-446655440000",
    "blueprint": {
      "type": "figma_url",
      "url": "https://figma.com/file/abc123",
      "verified": true,
      "verification_date": "2025-12-31T10:30:00Z",
      "additional_urls": [
        { "name": "Dashboard", "url": "..." }
      ]
    }
  }
}
```

---

### 3. Link Git Repository

**Endpoint:** `POST /api/resources/{resourceId}/attributes/git-repo`

**Purpose:** Link Git repository for tech stack analysis and style matching

**Request:**
```json
{
  "gitRepoUrl": "https://github.com/company/project",
  "gitRepoType": "github",      // Optional: auto-detected
  "gitRepoPrivate": false,       // true = private repo
  "gitAccessTokenVaultPath": "/vaultwarden/company/github-token",  // Required if private
  "triggerAnalysis": true        // Queue immediate repo analysis
}
```

**Supported Git Providers:**
- `github` - GitHub.com
- `gitlab` - GitLab.com
- `bitbucket` - Bitbucket.org
- `azure_devops` - Azure DevOps / Visual Studio

**Response:**
```json
{
  "success": true,
  "message": "Git repo linked. Analysis queued (not implemented yet).",
  "data": {
    "resourceId": "550e8400-...",
    "gitRepoUrl": "https://github.com/company/project",
    "gitRepoType": "github",
    "gitRepoPrivate": false,
    "analysisStatus": "queued"
  }
}
```

**Private Repository Security:**
- Access tokens stored in **Vaultwarden** (not in database)
- Only the Vaultwarden path is stored: `/vaultwarden/company/github-token`
- GitRepoAnalyzer service fetches token from Vaultwarden at runtime

---

### 4. Get Git Repository Data

**Endpoint:** `GET /api/resources/{resourceId}/attributes/git-repo`

**Purpose:** Retrieve Git repository information

**Response:**
```json
{
  "success": true,
  "data": {
    "resourceId": "550e8400-...",
    "gitRepo": {
      "url": "https://github.com/company/project",
      "type": "github",
      "private": false,
      "analyzed": false,
      "analysis_result": null  // Will contain JSON after analysis
    }
  }
}
```

---

### 5. Unlink Git Repository

**Endpoint:** `DELETE /api/resources/{resourceId}/attributes/git-repo`

**Purpose:** Remove Git repository link from resource

**Response:**
```json
{
  "success": true,
  "message": "Git repository unlinked successfully",
  "data": {
    "resourceId": "550e8400-...",
    "deletedAttributes": 5
  }
}
```

---

### 6. Start Blueprint Agent Interview

**Endpoint:** `POST /api/blueprint-agent/start-interview`

**Purpose:** Start AI-powered interview to generate mockups (10 questions)

**Request:**
```json
{
  "resourceId": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "user-123"  // Optional
}
```

**Response:**
```json
{
  "success": true,
  "message": "Blueprint Agent interview started",
  "data": {
    "sessionId": "a1b2c3d4-...",
    "resourceId": "550e8400-...",
    "resourceName": "Claims Dashboard",
    "resourceType": "web_app_project",
    "currentQuestion": 1,
    "totalQuestions": 10,
    "question": {
      "id": "q1",
      "question": "What type of application are you building?",
      "type": "single_choice",
      "options": [
        { "value": "web_app_internal", "label": "Web App (Internal Dashboard/Tool)" },
        { "value": "web_app_external", "label": "Web App (Customer-Facing)" },
        ...
      ],
      "required": true
    },
    "progress": {
      "current": 1,
      "total": 10,
      "percentage": 10
    }
  }
}
```

---

### 7. Submit Answer to Interview

**Endpoint:** `POST /api/blueprint-agent/submit-answer`

**Purpose:** Submit answer to current question, get next question

**Request:**
```json
{
  "sessionId": "a1b2c3d4-...",
  "resourceId": "550e8400-...",
  "questionId": "q1",
  "answer": "web_app_internal"  // Or text/array depending on question type
}
```

**Response (Next Question):**
```json
{
  "success": true,
  "message": "Answer saved",
  "data": {
    "sessionId": "a1b2c3d4-...",
    "resourceId": "550e8400-...",
    "status": "in_progress",
    "currentQuestion": 2,
    "totalQuestions": 10,
    "answeredQuestions": 1,
    "nextQuestionId": "q2",
    "progress": {
      "current": 2,
      "total": 10,
      "percentage": 20
    }
  }
}
```

**Response (Interview Complete):**
```json
{
  "success": true,
  "message": "Interview completed! Mockup generation queued.",
  "data": {
    "sessionId": "a1b2c3d4-...",
    "resourceId": "550e8400-...",
    "status": "completed",
    "totalQuestions": 10,
    "answeredQuestions": 10,
    "answers": {
      "q1": "web_app_internal",
      "q2": "Claims processing dashboard",
      "q3": "Insurance claims adjusters, ages 30-55",
      ...
    },
    "nextStep": "mockup_generation"
  }
}
```

---

### 8. Get Interview Progress

**Endpoint:** `GET /api/blueprint-agent/submit-answer?sessionId={id}&resourceId={id}`

**Purpose:** Check interview progress and retrieve answers

**Response:**
```json
{
  "success": true,
  "data": {
    "sessionId": "a1b2c3d4-...",
    "resourceId": "550e8400-...",
    "status": "in_progress",  // or "completed"
    "totalQuestions": 10,
    "answeredQuestions": 5,
    "answers": {
      "q1": "web_app_internal",
      "q2": "Claims processing",
      ...
    },
    "progress": {
      "current": 5,
      "total": 10,
      "percentage": 50
    }
  }
}
```

---

### 9. Get All Interview Questions

**Endpoint:** `GET /api/blueprint-agent/start-interview`

**Purpose:** Preview all 10 interview questions (for testing/documentation)

**Response:**
```json
{
  "success": true,
  "data": {
    "questions": [
      {
        "id": "q1",
        "question": "What type of application are you building?",
        "type": "single_choice",
        "options": [...],
        "required": true
      },
      ...
    ],
    "totalQuestions": 10,
    "estimatedTime": "5-7 minutes"
  }
}
```

---

## Database Storage (EAV Pattern)

All blueprint and Git repo data is stored as **resource attributes** (rows, not columns):

```sql
-- Blueprint attributes
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('550e8400-...', 'blueprint_type', 'figma_url'),
  ('550e8400-...', 'blueprint_url', 'https://figma.com/...'),
  ('550e8400-...', 'blueprint_verified', 'true'),
  ('550e8400-...', 'blueprint_verification_date', '2025-12-31T10:30:00Z'),
  ('550e8400-...', 'blueprint_additional_urls', '[{"name":"Dashboard","url":"..."}]');

-- Git repo attributes
  ('550e8400-...', 'git_repo_url', 'https://github.com/...'),
  ('550e8400-...', 'git_repo_type', 'github'),
  ('550e8400-...', 'git_repo_private', 'false'),
  ('550e8400-...', 'git_repo_analyzed', 'false'),
  ('550e8400-...', 'git_access_token_vault_path', '/vaultwarden/company/token');

-- Blueprint Agent session
  ('550e8400-...', 'blueprint_agent_session_id', 'a1b2c3d4-...'),
  ('550e8400-...', 'blueprint_agent_answers', '{"q1":"web_app_internal",...}'),
  ('550e8400-...', 'blueprint_agent_status', 'completed');
```

---

## Testing Examples

### cURL Examples

**Upload Figma Blueprint:**
```bash
curl -X POST https://quadframe.work/api/resources/550e8400-e29b-41d4-a716-446655440000/attributes/blueprint \
  -H "Content-Type: application/json" \
  -d '{
    "blueprintUrl": "https://figma.com/file/abc123",
    "additionalUrls": [
      {"name": "Dashboard", "url": "https://figma.com/file/dashboard"}
    ]
  }'
```

**Link GitHub Repo:**
```bash
curl -X POST https://quadframe.work/api/resources/550e8400-e29b-41d4-a716-446655440000/attributes/git-repo \
  -H "Content-Type: application/json" \
  -d '{
    "gitRepoUrl": "https://github.com/company/project",
    "gitRepoPrivate": false,
    "triggerAnalysis": true
  }'
```

**Start Blueprint Agent Interview:**
```bash
curl -X POST https://quadframe.work/api/blueprint-agent/start-interview \
  -H "Content-Type: application/json" \
  -d '{
    "resourceId": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**Submit Answer:**
```bash
curl -X POST https://quadframe.work/api/blueprint-agent/submit-answer \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "a1b2c3d4-...",
    "resourceId": "550e8400-...",
    "questionId": "q1",
    "answer": "web_app_internal"
  }'
```

---

## Next Steps (TODO)

**Backend Services to Implement:**
1. **GitRepoAnalyzer Service** - Clone repo, extract tech stack, patterns, components
2. **Blueprint Screenshot Service** - Auto-capture screenshots of competitor URLs
3. **AI Mockup Generator** - Use interview answers to generate mockups with Claude/Gemini

**Frontend Pages to Build:**
1. `/configure/domain/create` - Domain creation wizard with blueprint upload
2. `/configure/prerequisites` - Prerequisites upload page
3. `/blueprint-agent/interview` - Blueprint Agent interview UI

---

## Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Database Migration** | ✅ Complete | `001_create_resource_attribute_model.sql` |
| **Blueprint Upload API** | ✅ Complete | POST/GET `/api/resources/{id}/attributes/blueprint` |
| **Git Repo Link API** | ✅ Complete | POST/GET/DELETE `/api/resources/{id}/attributes/git-repo` |
| **Blueprint Agent Start** | ✅ Complete | POST/GET `/api/blueprint-agent/start-interview` |
| **Blueprint Agent Submit** | ✅ Complete | POST/GET `/api/blueprint-agent/submit-answer` |
| **GitRepoAnalyzer Service** | 🔜 Pending | Clone, analyze, extract patterns |
| **Screenshot Service** | 🔜 Pending | Puppeteer screenshot capture |
| **AI Mockup Generator** | 🔜 Pending | Claude/Gemini mockup generation |
| **Frontend UI** | 🔜 Pending | Domain wizard, interview UI |

---

**Author:** Claude Sonnet 4.5
**Date Created:** December 31, 2025
**Last Updated:** December 31, 2025
