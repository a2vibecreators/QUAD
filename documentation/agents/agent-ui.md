# UI Developer QUAD Agent

**Version:** 1.0.0
**Type:** Base UI Agent (Extended by iOS, Android, Web agents)
**Created:** December 31, 2025
**Extends:** [agent-base.md](agent-base.md)

---

## Introduction

This is the **base UI agent** for frontend development. It provides common functionality for all UI platforms:

- Design integration (Figma/Sketch)
- Source control workflows
- Project management tracking
- Team communication

**This agent is extended by platform-specific agents:**
- [agent-ios.md](agent-ios.md) - iOS/iPadOS development
- [agent-android.md](agent-android.md) - Android development
- [agent-web.md](agent-web.md) - Web development (React, Next.js, Vue, Angular)

**Do not use this directly** unless you're doing cross-platform UI work. Use a platform-specific agent instead.

---

{{> agent-base}}  <!-- Inherits all base template functionality -->

---

## UI-Specific Configuration

### Tools You'll Use

**Design Tools:**
- **Figma** (primary) - Design handoff, inspect mode, component library
- **Sketch** (secondary) - Legacy designs, plugin ecosystem

**Source Control:**
- **GitHub** (primary) - Pull requests, code reviews
- **GitLab** (secondary) - Self-hosted repos
- **Bitbucket** (secondary) - Atlassian integration

**Project Management:**
- **Jira** (primary) - Sprint planning, story tracking
- **Linear** (secondary) - Modern issue tracking
- **Azure DevOps** (secondary) - Microsoft ecosystem

**Communication:**
- **Slack** (primary) - Team chat, alerts
- **Microsoft Teams** (secondary) - Enterprise chat
- **Discord** (secondary) - Community chat

### Environment Variables (UI Agent)

```bash
# Design Tools
FIGMA_ACCESS_TOKEN={{FIGMA_TOKEN}}
FIGMA_FILE_ID={{FIGMA_FILE_ID}}

# Source Control
GITHUB_TOKEN={{GITHUB_TOKEN}}
GITHUB_ORG={{GITHUB_ORG}}
GITHUB_REPO={{GITHUB_REPO}}

# Project Management
JIRA_API_TOKEN={{JIRA_API_TOKEN}}
JIRA_INSTANCE={{JIRA_INSTANCE}}
JIRA_PROJECT_KEY={{JIRA_PROJECT_KEY}}

# Communication
SLACK_BOT_TOKEN={{SLACK_BOT_TOKEN}}
SLACK_CHANNEL={{SLACK_CHANNEL}}
```

---

## UI Development Workflow

### 1. Design Handoff (Figma → Code)

**Figma Integration:**
```bash
# Agent verifies Figma access
curl -H "X-Figma-Token: $FIGMA_ACCESS_TOKEN" \
  https://api.figma.com/v1/files/$FIGMA_FILE_ID

# Agent can:
- Read design specs (spacing, colors, typography)
- Export assets (icons, images)
- Check component variants
- Validate design tokens
```

**Design-to-Code Translation:**
- Agent reads Figma design
- Suggests component structure
- Generates CSS/styling code
- Validates against design tokens

**Example:**
```
User: "Implement the login screen from Figma"
Agent: [Reads Figma file]
  ↓
  "I see a login form with:
   - Email input (spacing: 16px, font: Inter 14px)
   - Password input
   - Submit button (primary blue #007AFF)
   - Forgot password link

   I'll create a LoginScreen component with these specs."
```

### 2. Version Control Workflow

**GitHub Pull Request Flow:**
```bash
# Agent creates feature branch
git checkout -b feature/login-screen

# Agent implements UI
[writes code]

# Agent commits and pushes
git add .
git commit -m "feat: Implement login screen from Figma design"
git push origin feature/login-screen

# Agent creates PR
gh pr create --title "Add login screen" --body "Implements AUTH-123"
```

**Code Review Assistance:**
- Agent can review PRs for design consistency
- Checks if implementation matches Figma specs
- Validates accessibility (a11y) compliance
- Suggests improvements

### 3. Jira Integration

**Story Tracking:**
```bash
# Agent fetches assigned stories
curl -u email@company.com:$JIRA_API_TOKEN \
  https://{{JIRA_INSTANCE}}.atlassian.net/rest/api/3/search?jql=assignee=currentUser()

# Agent updates story status
# When you start work → "In Progress"
# When PR created → "In Review"
# When merged → "Done"
```

**Story Details:**
- Agent reads acceptance criteria from Jira
- Validates implementation against criteria
- Adds comments to Jira with progress updates

### 4. Team Communication (Slack)

**Automated Notifications:**
```bash
# When PR created
"🚀 New PR: Login Screen (AUTH-123) - Ready for review"

# When design differs from Figma
"⚠️  Design mismatch detected: Button color #007AFF expected, found #0066CC"

# When build fails
"❌ Build failed: 3 TypeScript errors in LoginScreen.tsx"
```

---

## UI Best Practices

### Design Consistency

**Agent enforces:**
- Color palette matches design tokens
- Spacing follows 8px grid system
- Typography uses defined font scales
- Components match Figma variants

**Example Check:**
```typescript
// ❌ BAD - Hardcoded colors
<button style={{ backgroundColor: '#007AFF' }}>

// ✅ GOOD - Design tokens
<button className="bg-primary-blue">
```

### Accessibility (a11y)

**Agent validates:**
- Semantic HTML (`<button>` not `<div onclick>`)
- ARIA labels for screen readers
- Keyboard navigation (tab order)
- Color contrast ratios (WCAG AA)

**Example:**
```typescript
// ❌ BAD - No accessibility
<div onClick={handleClick}>Submit</div>

// ✅ GOOD - Accessible
<button
  type="submit"
  aria-label="Submit login form"
  onClick={handleClick}
>
  Submit
</button>
```

### Responsive Design

**Agent checks:**
- Mobile-first approach
- Breakpoints match design system (sm, md, lg, xl)
- Touch targets ≥44px (iOS HIG, Material Design)
- Text scales with viewport

---

## Common UI Tasks

### Task 1: Implement Screen from Figma

```
User: "Build the profile settings screen"
Agent:
  1. Reads Figma file → Identifies components
  2. Checks if reusable components exist (Avatar, Input, Button)
  3. Creates ProfileSettingsScreen component
  4. Implements layout matching Figma spacing
  5. Adds form validation
  6. Creates PR → Links to Jira story
  7. Notifies team in Slack
```

### Task 2: Fix Design Inconsistency

```
User: "This button doesn't match the design"
Agent:
  1. Reads Figma specs for Button component
  2. Compares with current code
  3. Identifies differences (e.g., wrong padding, color)
  4. Suggests fix with exact values from Figma
  5. Updates code
  6. Verifies visually (screenshot comparison)
```

### Task 3: Add New Component

```
User: "Create a reusable Card component"
Agent:
  1. Checks Figma for Card component variants
  2. Creates component with props for variants
  3. Adds TypeScript types
  4. Writes Storybook stories (if enabled)
  5. Documents usage in README
  6. Adds to component library
```

---

## Platform-Specific Extensions

This base UI agent is extended by platform-specific agents with additional tools:

### iOS Agent (agent-ios.md)
**Inherits:** Figma, GitHub, Jira, Slack
**Adds:**
- Xcode integration
- TestFlight distribution
- Firebase Crashlytics
- SwiftUI-specific helpers
- iOS Human Interface Guidelines compliance

### Android Agent (agent-android.md)
**Inherits:** Figma, GitHub, Jira, Slack
**Adds:**
- Android Studio integration
- Google Play Console
- Firebase Crashlytics
- Jetpack Compose helpers
- Material Design 3 compliance

### Web Agent (agent-web.md)
**Inherits:** Figma, GitHub, Jira, Slack
**Adds:**
- Vercel/Netlify deployment
- Cypress/Playwright testing
- npm package management
- React/Next.js/Vue/Angular frameworks
- Web accessibility tools (Lighthouse, axe)

---

## Troubleshooting

### Issue 1: Figma Access Denied
**Error:** `403 Forbidden` when fetching Figma file

**Solution:**
1. Verify `FIGMA_ACCESS_TOKEN` is valid (check Figma settings)
2. Ensure file ID is correct (from Figma URL)
3. Check if you have access to the file (shared with you)

### Issue 2: GitHub PR Creation Failed
**Error:** `gh: command not found` or `Permission denied`

**Solution:**
```bash
# Install GitHub CLI
brew install gh  # macOS
# or: https://cli.github.com/

# Authenticate
gh auth login

# Retry PR creation
```

### Issue 3: Jira Story Not Found
**Error:** `Issue does not exist` when fetching story

**Solution:**
1. Verify `JIRA_PROJECT_KEY` matches your project (e.g., "AUTH", not "auth")
2. Check story number (AUTH-123, not 123)
3. Confirm you have read access to the story

### Issue 4: Slack Notification Failed
**Error:** `channel_not_found` when posting to Slack

**Solution:**
1. Verify channel name includes `#` (e.g., `#dev-alerts`)
2. Ensure Slack bot is added to the channel
3. Check `SLACK_BOT_TOKEN` has `chat:write` scope

---

## Customization

**For Company-Specific Workflows:**

Edit this template to add:
- Custom design token validation
- Company-specific component naming conventions
- Additional Figma plugins (e.g., Zeplin, Abstract)
- Custom Jira workflows (e.g., custom statuses)

**Example:**
```markdown
## {{COMPANY_NAME}} Design System

Our design tokens:
- Primary: #007AFF (not Material Blue)
- Font: SF Pro (not Inter)
- Spacing: 8px grid (strict)

Component naming:
- Prefix all components with "QC" (QCButton, QCInput)
```

---

## Support

**Questions or Issues?**
- Documentation: https://quadframe.work/docs/agents/ui
- GitHub Issues: https://github.com/a2vibecreators/quadframework/issues
- Email: support@quadframe.work

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
