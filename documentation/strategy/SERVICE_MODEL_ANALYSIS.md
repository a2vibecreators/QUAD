# QUAD Framework - Service Model Analysis

## QUAD-Provided vs BYOK (Bring Your Own Key)

**Date:** January 2, 2026
**Author:** Claude (AI Assistant)

---

## Executive Summary

This document analyzes whether QUAD can provide fully-managed services (API keys, accounts, infrastructure) to customers, or if customers must bring their own credentials (BYOK).

**Recommendation:** Hybrid approach - QUAD provides some services, customers provide others based on security and cost requirements.

---

## Service Categories

### Category 1: QUAD CAN Fully Provide

These services allow organizational/reseller accounts where QUAD can create sub-accounts for customers:

| Service | Model | QUAD Cost | Customer Experience |
|---------|-------|-----------|---------------------|
| **Anthropic AI (Claude)** | API Key per org | ~$0.003/1K tokens | Seamless, no setup |
| **Google Calendar (OAuth)** | OAuth per user | Free | Redirect to Google login |
| **Cal.com** | Self-hosted | ~$50/month (VPS) | Fully managed |
| **SendGrid/Postmark** | Sub-accounts | ~$15/month base | No email setup needed |
| **Twilio SMS** | Sub-accounts | ~$0.0075/SMS | No phone setup needed |

**Why these work:**
- OAuth-based (Google) - Users authorize QUAD, no API key needed
- Sub-account APIs (Twilio, SendGrid) - We can create accounts programmatically
- Self-hosted options (Cal.com) - We control the infrastructure

### Category 2: Customer MUST Provide (BYOK Required)

These services don't support programmatic sub-account creation or require customer's own billing:

| Service | Why BYOK? | Customer Must Provide |
|---------|-----------|----------------------|
| **GitHub/GitLab** | OAuth tied to user's repos | OAuth authorization |
| **Slack** | Workspace-specific app install | Slack App credentials |
| **Jira/Azure DevOps** | Enterprise security policies | OAuth or PAT |
| **Otter.ai/Fireflies** | No sub-account API | Individual subscription |
| **Zoom** | Account-level API | OAuth or JWT |
| **AWS/GCP (Customer's)** | Customer's cloud billing | Service account keys |

**Why these require BYOK:**
- Repository access requires customer authorization (GitHub)
- Workspace/team integrations need customer's app install (Slack)
- No programmatic account creation API (Otter.ai)
- Enterprise security policies require customer-controlled credentials

### Category 3: Hybrid (Either Mode)

| Service | QUAD-Provided Mode | BYOK Mode |
|---------|-------------------|-----------|
| **Google Calendar** | OAuth (free) | Customer's service account |
| **Microsoft 365** | OAuth (free) | Enterprise Azure AD app |
| **AI Models** | QUAD pays (tiered pricing) | Customer's Anthropic/OpenAI key |

---

## Implementation Recommendation

### Tier 1: Free/Starter (QUAD-Provided)

```
✅ Anthropic Claude API (Turbo tier - limited tokens)
✅ Google Calendar OAuth
✅ Email notifications (SendGrid)
✅ Cal.com self-hosted
❌ No GitHub integration
❌ No Slack integration
❌ No meeting transcription
```

**Monthly Cost to QUAD:** ~$50 base + ~$0.25/user

### Tier 2: Professional (Hybrid)

```
✅ Anthropic Claude API (Balanced tier)
✅ Google/Outlook Calendar OAuth
✅ Cal.com managed
⚡ GitHub integration (customer OAuth)
⚡ Slack integration (customer app)
❌ No meeting transcription
```

**Monthly Cost to QUAD:** ~$100 base + ~$3/user

### Tier 3: Enterprise (BYOK Optional)

```
✅ All Professional features
⚡ Otter.ai/Fireflies (customer account)
⚡ Jira/Azure DevOps (customer OAuth)
⚡ Custom AI model (customer's key)
⚡ Self-hosted option available
```

**Monthly Cost to QUAD:** ~$200 base (or customer self-hosts)

---

## Specific Service Analysis

### 1. GitHub/GitLab - Can QUAD Create Repos?

**Answer:** NO - Not recommended

- GitHub doesn't allow creating organizations/repos for other users
- We CAN create repos under a QUAD-owned org, BUT:
  - Customer loses ownership
  - Compliance/audit issues
  - Vendor lock-in concerns

**Recommendation:**
- Use OAuth flow - customer authorizes QUAD to access THEIR repos
- QUAD gets read/write access to selected repos only
- Customer retains ownership and control

### 2. Otter.ai/Fireflies - Can QUAD Create Accounts?

**Answer:** NO - No sub-account API

- Both require individual subscriptions
- No API to provision accounts programmatically
- Pricing is per-seat, not usage-based

**Alternatives:**
1. **AssemblyAI** - API-based transcription (~$0.006/minute)
2. **Deepgram** - Real-time transcription (~$0.0043/minute)
3. **Whisper (Self-hosted)** - Free but requires GPU
4. **Rev.ai** - API-based (~$0.05/minute)

**Recommendation:**
- Use AssemblyAI or Deepgram for QUAD-provided tier
- Allow BYOK for Otter.ai/Fireflies enterprise customers

### 3. Slack - Can QUAD Send Messages?

**Answer:** YES - But requires customer app install

- Customer must install QUAD Slack app in their workspace
- Once installed, QUAD can send messages via bot
- No way to bypass workspace installation

**Recommendation:**
- Provide QUAD Slack app for customers to install
- Guide them through 5-minute installation process
- Store bot token per organization

### 4. Meeting Transcription - Can QUAD Record?

**Answer:** PARTIAL - Depends on provider

| Method | QUAD Can Provide? | Notes |
|--------|-------------------|-------|
| Google Meet transcription | YES | Via Calendar API |
| Zoom cloud recording | NO | Requires customer's Zoom account |
| AssemblyAI transcription | YES | Upload audio file |
| Real-time transcription | YES | Via WebSocket API |

**Recommendation:**
- Use AssemblyAI for async transcription (QUAD-provided)
- Deepgram for real-time (QUAD-provided)
- Support Otter.ai/Fireflies import (BYOK)

---

## Cost Model for QUAD-Provided Services

### Base Infrastructure (Fixed Monthly)

| Item | Cost | Notes |
|------|------|-------|
| Cal.com VPS | $50 | Self-hosted scheduling |
| SendGrid Base | $15 | 40K emails/month |
| Monitoring | $20 | Error tracking |
| **Total Base** | **$85/month** | |

### Per-Customer Usage (Variable)

| Service | Cost/Unit | Typical Usage | Monthly/Customer |
|---------|-----------|---------------|------------------|
| Anthropic Turbo | $0.25/1M tokens | 500K tokens | $0.13 |
| Anthropic Balanced | $3/1M tokens | 200K tokens | $0.60 |
| AssemblyAI | $0.006/min | 60 min | $0.36 |
| SendGrid | $0.0003/email | 100 emails | $0.03 |
| **Total** | | | **~$1.12/customer** |

### Pricing Recommendation

| Tier | Price | QUAD Cost | Margin |
|------|-------|-----------|--------|
| Starter | $0 (free) | $0.50/user | Loss leader |
| Professional | $15/user | $3/user | ~80% |
| Enterprise | $50/user | $10/user | ~80% |

---

## Implementation Roadmap

### Phase 1 (Current Sprint)
- [x] Google Calendar OAuth (QUAD-provided)
- [x] Cal.com API integration (BYOK ready)
- [x] AI tier selection (Turbo/Balanced/Quality/BYOK)

### Phase 2 (Next Sprint)
- [ ] GitHub OAuth (customer authorization)
- [ ] Slack app installation flow
- [ ] AssemblyAI transcription (QUAD-provided)

### Phase 3 (Future)
- [ ] Self-hosted Cal.com option
- [ ] Otter.ai import (BYOK)
- [ ] Custom AI model support (BYOK)

---

## Database Schema for Service Modes

Already implemented in `QUAD_meeting_integrations`:

```prisma
model QUAD_meeting_integrations {
  // ...
  is_quad_provided  Boolean  @default(false)  // Add this field
  // ...
}
```

This field tracks whether QUAD pays for the service or customer provides credentials.

---

## Conclusion

**QUAD CAN provide:**
- AI processing (with tiered pricing)
- Calendar OAuth (free for QUAD)
- Email/SMS notifications
- Meeting scheduling (Cal.com self-hosted)
- Meeting transcription (AssemblyAI)

**Customers MUST provide:**
- Git repository access (OAuth authorization)
- Slack workspace access (app installation)
- Otter.ai/Fireflies (if preferred over AssemblyAI)
- Enterprise SSO/compliance requirements

**Hybrid approach maximizes:**
- Customer experience (less setup)
- QUAD revenue (margin on services)
- Flexibility (BYOK for enterprise)

---

*Document created: January 2, 2026*
