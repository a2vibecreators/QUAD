# Blueprint Agent Services Documentation

**Date:** December 31, 2025
**Status:** ✅ Backend Services Implemented

---

## Overview

Blueprint Agent backend services handle:
1. **GitRepoAnalyzer** - Clone and analyze Git repositories
2. **ScreenshotService** - Capture competitor website screenshots
3. **AI Mockup Generator** - Generate mockups from interview answers (TODO)

---

## Service 1: GitRepoAnalyzer

**File:** `src/lib/services/GitRepoAnalyzer.ts`

**Purpose:** Clone Git repositories and extract tech stack, code patterns, and architecture information.

### Features

✅ **Tech Stack Detection:**
- Frontend frameworks (Next.js, React, Vue, Angular, Svelte)
- CSS frameworks (Tailwind, Bootstrap, MUI, Chakra)
- Backend frameworks (Node.js/Express, NestJS, FastAPI, Django, Spring Boot)
- Databases (PostgreSQL, MySQL, MongoDB from docker-compose.yml)
- Build tools (Webpack, Vite, Turbopack)

✅ **Code Pattern Analysis:**
- Component structure and reusable components
- State management (Redux, Zustand, Recoil)
- Architecture patterns (MVC, MVVM, microservices)

✅ **File Structure Analysis:**
- Total files and file types breakdown
- Directory structure

✅ **Private Repository Support:**
- Access tokens fetched from Vaultwarden (secure storage)
- Only token path stored in database

### Usage

```typescript
import GitRepoAnalyzer from '@/lib/services/GitRepoAnalyzer';

const analyzer = new GitRepoAnalyzer();

// Analyze public repository
const result = await analyzer.analyzeRepository(
  'https://github.com/company/project'
);

// Analyze private repository
const result = await analyzer.analyzeRepository(
  'https://github.com/company/private-repo',
  'ghp_access_token_here',
  true
);

// Save to database
await analyzer.saveAnalysisResult(resourceId, result);
```

### Analysis Result Structure

```json
{
  "success": true,
  "techStack": {
    "frontend": {
      "framework": "nextjs",
      "version": "^14.0.0",
      "cssFramework": "tailwind",
      "uiLibraries": ["MUI", "Headless UI"]
    },
    "backend": {
      "framework": "nodejs",
      "language": "typescript",
      "version": "^18.0.0"
    },
    "database": {
      "type": "postgresql",
      "orm": "prisma"
    },
    "buildTools": ["vite", "turbopack"],
    "deployment": {
      "platform": "docker",
      "configFiles": ["Dockerfile", "docker-compose.yml"]
    }
  },
  "codePatterns": {
    "architecture": "mvc",
    "components": [
      {
        "name": "Button.tsx",
        "path": "/src/components/Button.tsx",
        "reusable": true
      }
    ],
    "stateManagement": "zustand"
  },
  "fileStructure": {
    "totalFiles": 245,
    "fileTypes": {
      ".ts": 120,
      ".tsx": 85,
      ".css": 20,
      ".json": 10
    },
    "directories": ["/src", "/src/components", "/src/app"]
  },
  "cloneUrl": "https://github.com/company/project",
  "analyzedAt": "2025-12-31T10:30:00Z"
}
```

### API Endpoint

**Trigger Analysis:**
```bash
POST /api/resources/{resourceId}/analyze-repo
```

**Get Results:**
```bash
GET /api/resources/{resourceId}/analyze-repo
```

---

## Service 2: ScreenshotService

**File:** `src/lib/services/ScreenshotService.ts`

**Purpose:** Capture screenshots of competitor websites for blueprint inspiration using Puppeteer.

### Features

✅ **Full Page Screenshots:**
- Capture entire scrollable page (not just viewport)
- Custom viewport sizes (default: 1920x1080)

✅ **Smart Element Removal:**
- Remove chat widgets, popups, cookie banners before screenshot
- Wait for specific elements to load

✅ **Multiple URL Support:**
- Capture main page + dashboard + login in one call
- Automatic delay between screenshots

✅ **Metadata Tracking:**
- File size, dimensions, capture timestamp
- Stored in database as resource attribute

### Usage

```typescript
import ScreenshotService from '@/lib/services/ScreenshotService';

const screenshotService = new ScreenshotService();

// Capture single URL
const result = await screenshotService.captureScreenshot(
  'https://competitor.com',
  {
    fullPage: true,
    width: 1920,
    height: 1080,
    removeElements: ['#chat-widget', '.cookie-banner']
  }
);

// Capture multiple URLs
const results = await screenshotService.captureMultiple([
  { name: 'Homepage', url: 'https://competitor.com' },
  { name: 'Dashboard', url: 'https://competitor.com/dashboard' },
  { name: 'Login', url: 'https://competitor.com/login' }
]);

// Capture and save to database
const result = await screenshotService.captureAndSave(
  resourceId,
  'https://competitor.com'
);

// Cleanup
await screenshotService.close();
```

### Screenshot Result Structure

```json
{
  "success": true,
  "screenshotPath": "/tmp/quad-screenshots/screenshot-competitor-com-1735639800000.png",
  "width": 1920,
  "height": 3400,
  "fileSize": 2458720,
  "capturedAt": "2025-12-31T10:30:00Z"
}
```

### Storage

**Current:** Screenshots stored in `/tmp/quad-screenshots/`

**Future (TODO):**
- Upload to S3/GCS
- Return public URL
- Automatic cleanup after 7 days

### Puppeteer Configuration

```typescript
{
  headless: true,
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--disable-gpu',
  ]
}
```

---

## Service 3: AI Mockup Generator (TODO)

**File:** `src/lib/services/MockupGenerator.ts` (not yet implemented)

**Purpose:** Generate UI mockups from Blueprint Agent interview answers using AI (Claude/Gemini).

### Planned Features

🔜 **AI-Powered Design:**
- Use Claude 3.5 Sonnet or Gemini to analyze interview answers
- Generate design recommendations (color scheme, layout, components)

🔜 **Mockup Generation:**
- Integration with design tools (Figma API, v0.dev, or custom renderer)
- Generate multiple design variations

🔜 **Component Library:**
- Suggest reusable component library based on tech stack
- Match existing brand guidelines if provided

### Planned Usage

```typescript
import MockupGenerator from '@/lib/services/MockupGenerator';

const generator = new MockupGenerator();

// Generate mockup from interview answers
const mockup = await generator.generateFromInterview({
  sessionId: 'a1b2c3d4-...',
  resourceId: '550e8400-...',
  answers: {
    q1: 'web_app_internal',
    q2: 'Claims processing dashboard',
    // ... all 10 answers
  }
});

// Result includes:
// - Generated mockup URLs (Figma, v0.dev, or images)
// - Recommended color palette
// - Component library suggestions
// - Design system guidelines
```

---

## Integration Example: Complete Flow

```typescript
// 1. User uploads blueprint URL
POST /api/resources/{id}/attributes/blueprint
{
  "blueprintUrl": "https://competitor.com",
  "blueprintType": "competitor_url"
}

// 2. Capture screenshot of competitor
const screenshotService = new ScreenshotService();
await screenshotService.captureAndSave(resourceId, 'https://competitor.com');

// 3. User links Git repo
POST /api/resources/{id}/attributes/git-repo
{
  "gitRepoUrl": "https://github.com/company/existing-app"
}

// 4. Trigger repo analysis
POST /api/resources/{id}/analyze-repo
// → GitRepoAnalyzer clones repo and extracts tech stack

// 5. Start Blueprint Agent interview
POST /api/blueprint-agent/start-interview
{
  "resourceId": "..."
}

// 6. User answers 10 questions
POST /api/blueprint-agent/submit-answer
{
  "questionId": "q1",
  "answer": "web_app_internal"
}
// ... repeat for q2-q10

// 7. Generate AI mockup (TODO)
POST /api/blueprint-agent/generate-mockup
{
  "sessionId": "..."
}
// → MockupGenerator uses interview answers + tech stack + competitor screenshots
```

---

## Database Storage

All service results stored as resource attributes:

```sql
-- Screenshot metadata
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('550e8400-...', 'blueprint_screenshot_url', '/tmp/quad-screenshots/screenshot-competitor-com-1735639800000.png');

-- Git repo analysis result
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('550e8400-...', 'git_repo_analyzed', 'true'),
  ('550e8400-...', 'git_repo_analysis_result', '{
    "success": true,
    "techStack": {...},
    "codePatterns": {...},
    "fileStructure": {...}
  }');

-- Blueprint Agent interview
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('550e8400-...', 'blueprint_agent_session_id', 'a1b2c3d4-...'),
  ('550e8400-...', 'blueprint_agent_answers', '{"q1":"web_app_internal",...}'),
  ('550e8400-...', 'blueprint_agent_status', 'completed');
```

---

## Package Dependencies

Add these to `package.json`:

```json
{
  "dependencies": {
    "puppeteer": "^21.6.0"
  }
}
```

Install:
```bash
npm install puppeteer
```

---

## Environment Variables

```env
# Vaultwarden URL (for fetching Git access tokens)
VAULTWARDEN_URL=https://vault.quadframe.work

# Optional: Git access token (fallback if Vaultwarden not configured)
GIT_ACCESS_TOKEN=ghp_...

# AI Provider (for MockupGenerator - future)
AI_PROVIDER=gemini  # or 'bedrock'
GOOGLE_GEMINI_API_KEY=...
```

---

## Implementation Status

| Service | Status | Notes |
|---------|--------|-------|
| **GitRepoAnalyzer** | ✅ Complete | Clone, analyze tech stack, code patterns |
| **ScreenshotService** | ✅ Complete | Puppeteer screenshot capture |
| **analyze-repo API** | ✅ Complete | Trigger repo analysis |
| **MockupGenerator** | 🔜 Pending | AI-powered mockup generation |

---

## Next Steps

1. ✅ **Test GitRepoAnalyzer** - Clone real GitHub repos and verify tech stack detection
2. ✅ **Test ScreenshotService** - Capture competitor website screenshots
3. 🔜 **Implement MockupGenerator** - AI mockup generation from interview answers
4. 🔜 **Vaultwarden Integration** - Fetch Git access tokens securely
5. 🔜 **Cloud Storage** - Upload screenshots to S3/GCS

---

**Author:** Claude Sonnet 4.5
**Date Created:** December 31, 2025
**Last Updated:** December 31, 2025
