# QUAD Framework - Gamification Ranking System

## Overview

The QUAD Gamification Ranking System evaluates team members across multiple performance dimensions to create a holistic view of contribution, reliability, and growth. Rankings are configurable per organization.

---

## Ranking Factors (Default Weights)

### 1. Delivery Performance (35% default)

| Factor | Weight within Category | Description |
|--------|----------------------|-------------|
| **Ticket Completion Rate** | 40% | % of assigned tickets completed on time |
| **Story Points Delivered** | 30% | Total story points completed in period |
| **On-Time Delivery** | 30% | % delivered by estimated due date |

**Metrics Calculated:**
- `completion_rate = completed_tickets / assigned_tickets`
- `velocity = story_points_completed / cycles_worked`
- `on_time_rate = on_time_tickets / completed_tickets`

### 2. Quality (25% default)

| Factor | Weight within Category | Description |
|--------|----------------------|-------------|
| **Defect Rate** | 40% | Bugs found in completed work |
| **Rework Rate** | 30% | Tickets reopened after completion |
| **Code Review Score** | 30% | Average PR review ratings |

**Metrics Calculated:**
- `defect_rate = 1 - (bugs_created / tickets_completed)`
- `rework_rate = 1 - (reopened_tickets / completed_tickets)`
- `review_score = avg(peer_review_ratings)`

### 3. Collaboration (20% default)

| Factor | Weight within Category | Description |
|--------|----------------------|-------------|
| **Peer Recognition** | 40% | Kudos/appreciation received |
| **Help Given** | 30% | Unblocking others, mentoring |
| **Communication** | 30% | Timely updates, meeting participation |

**Metrics Calculated:**
- `recognition_score = kudos_received / team_avg_kudos`
- `help_score = help_actions / assigned_workload`
- `communication_score = (updates_given + meetings_attended) / expected`

### 4. Learning & Growth (15% default)

| Factor | Weight within Category | Description |
|--------|----------------------|-------------|
| **Skill Acquisition** | 40% | New skills learned/certified |
| **Knowledge Sharing** | 30% | Training delivered, docs written |
| **Challenge Acceptance** | 30% | Taking stretch assignments |

**Metrics Calculated:**
- `skill_score = new_skills_certified / expected_per_period`
- `sharing_score = training_sessions + docs_created`
- `challenge_score = stretch_tickets / total_tickets`

### 5. AI Adoption (5% default)

| Factor | Weight within Category | Description |
|--------|----------------------|-------------|
| **AI Tool Usage** | 50% | Effective use of AI assistance |
| **Efficiency Gain** | 50% | Time saved through AI tools |

**Metrics Calculated:**
- `ai_usage_score = ai_assisted_tickets / total_tickets`
- `efficiency_score = ai_time_saved / baseline_time`

---

## Ranking Calculation Formula

```
Final Score =
  (Delivery Score × Delivery Weight) +
  (Quality Score × Quality Weight) +
  (Collaboration Score × Collaboration Weight) +
  (Learning Score × Learning Weight) +
  (AI Adoption Score × AI Weight)

Where each category score is 0-100 normalized
```

### Example Calculation

```
User: Jane Doe
Period: December 2025

Delivery Score: 85/100
  - Completion Rate: 92% → 92 points × 0.40 = 36.8
  - Story Points: 45 vs avg 40 → 112% → 90 points × 0.30 = 27
  - On-Time: 88% → 88 points × 0.30 = 26.4
  - Category Total: 90.2 → normalized to 85

Quality Score: 78/100
Collaboration Score: 92/100
Learning Score: 65/100
AI Adoption Score: 70/100

Final Score = (85 × 0.35) + (78 × 0.25) + (92 × 0.20) + (65 × 0.15) + (70 × 0.05)
            = 29.75 + 19.5 + 18.4 + 9.75 + 3.5
            = 80.9/100

Rank: B+ (see tiers below)
```

---

## Ranking Tiers

| Tier | Score Range | Label | Badge |
|------|-------------|-------|-------|
| S | 95-100 | Elite Performer | Diamond |
| A+ | 90-94 | Outstanding | Gold Star |
| A | 85-89 | Excellent | Gold |
| B+ | 80-84 | Very Good | Silver Star |
| B | 75-79 | Good | Silver |
| C+ | 70-74 | Satisfactory | Bronze Star |
| C | 65-69 | Needs Improvement | Bronze |
| D | 50-64 | Below Expectations | - |
| F | 0-49 | Critical | Warning |

---

## Configuration System

### Organization-Level Settings

Each organization can customize:

```typescript
interface RankingConfig {
  org_id: string;

  // Category weights (must sum to 100)
  weights: {
    delivery: number;      // default: 35
    quality: number;       // default: 25
    collaboration: number; // default: 20
    learning: number;      // default: 15
    ai_adoption: number;   // default: 5
  };

  // Sub-factor weights within each category
  delivery_factors: {
    completion_rate: number;  // default: 40
    story_points: number;     // default: 30
    on_time: number;          // default: 30
  };

  quality_factors: {
    defect_rate: number;      // default: 40
    rework_rate: number;      // default: 30
    review_score: number;     // default: 30
  };

  collaboration_factors: {
    peer_recognition: number; // default: 40
    help_given: number;       // default: 30
    communication: number;    // default: 30
  };

  learning_factors: {
    skill_acquisition: number;  // default: 40
    knowledge_sharing: number;  // default: 30
    challenge_acceptance: number; // default: 30
  };

  ai_factors: {
    tool_usage: number;       // default: 50
    efficiency_gain: number;  // default: 50
  };

  // Ranking period
  calculation_period: 'weekly' | 'bi-weekly' | 'monthly' | 'quarterly';

  // Display options
  show_rankings_to_team: boolean;
  anonymize_rankings: boolean;

  updated_at: Date;
  updated_by: string;
}
```

### Preset Configurations

| Preset | Delivery | Quality | Collaboration | Learning | AI | Use Case |
|--------|----------|---------|---------------|----------|-----|----------|
| **Balanced** | 35% | 25% | 20% | 15% | 5% | Most teams |
| **Speed-Focused** | 50% | 20% | 15% | 10% | 5% | Startup sprints |
| **Quality-First** | 25% | 40% | 20% | 10% | 5% | Healthcare, Finance |
| **Team-Centric** | 25% | 20% | 35% | 15% | 5% | Collaborative cultures |
| **Growth-Oriented** | 25% | 20% | 20% | 30% | 5% | Training-focused orgs |
| **AI-Forward** | 30% | 20% | 15% | 15% | 20% | AI-native teams |

---

## Database Schema

### New Tables Required

```sql
-- Organization ranking configuration
CREATE TABLE QUAD_ranking_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  -- Main category weights (sum to 100)
  weight_delivery INT NOT NULL DEFAULT 35,
  weight_quality INT NOT NULL DEFAULT 25,
  weight_collaboration INT NOT NULL DEFAULT 20,
  weight_learning INT NOT NULL DEFAULT 15,
  weight_ai_adoption INT NOT NULL DEFAULT 5,

  -- Sub-factor weights stored as JSONB
  delivery_factors JSONB DEFAULT '{"completion_rate":40,"story_points":30,"on_time":30}',
  quality_factors JSONB DEFAULT '{"defect_rate":40,"rework_rate":30,"review_score":30}',
  collaboration_factors JSONB DEFAULT '{"peer_recognition":40,"help_given":30,"communication":30}',
  learning_factors JSONB DEFAULT '{"skill_acquisition":40,"knowledge_sharing":30,"challenge_acceptance":30}',
  ai_factors JSONB DEFAULT '{"tool_usage":50,"efficiency_gain":50}',

  -- Settings
  calculation_period VARCHAR(20) DEFAULT 'monthly',
  show_rankings_to_team BOOLEAN DEFAULT true,
  anonymize_rankings BOOLEAN DEFAULT false,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID REFERENCES QUAD_users(id),

  UNIQUE(org_id)
);

-- User ranking history
CREATE TABLE QUAD_user_rankings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,

  -- Category scores (0-100)
  delivery_score DECIMAL(5,2),
  quality_score DECIMAL(5,2),
  collaboration_score DECIMAL(5,2),
  learning_score DECIMAL(5,2),
  ai_adoption_score DECIMAL(5,2),

  -- Final calculated score
  final_score DECIMAL(5,2) NOT NULL,
  tier VARCHAR(2) NOT NULL, -- S, A+, A, B+, B, C+, C, D, F
  rank_in_org INT, -- Position among all users

  -- Raw metrics snapshot (for audit)
  metrics_snapshot JSONB,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE(user_id, period_start, period_end)
);

-- Peer recognition / Kudos
CREATE TABLE QUAD_kudos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id UUID NOT NULL REFERENCES QUAD_users(id),
  to_user_id UUID NOT NULL REFERENCES QUAD_users(id),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  kudos_type VARCHAR(50) NOT NULL, -- 'appreciation', 'help', 'mentoring', 'teamwork'
  message TEXT,
  ticket_id UUID REFERENCES QUAD_tickets(id), -- Optional link to specific work

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- Prevent self-kudos
  CHECK (from_user_id != to_user_id)
);

-- Learning & Skills tracking
CREATE TABLE QUAD_user_skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  skill_name VARCHAR(100) NOT NULL,
  skill_category VARCHAR(50), -- 'technical', 'soft', 'domain', 'ai'
  proficiency_level INT DEFAULT 1, -- 1-5
  certified BOOLEAN DEFAULT false,
  certification_date DATE,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE(user_id, skill_name)
);
```

---

## API Endpoints

### Configuration

```
GET  /api/rankings/config           - Get org ranking config
PUT  /api/rankings/config           - Update config (admin only)
POST /api/rankings/config/preset    - Apply preset configuration
```

### Rankings

```
GET  /api/rankings                  - Get current period rankings
GET  /api/rankings/history          - Get historical rankings
GET  /api/rankings/user/:id         - Get specific user's ranking details
POST /api/rankings/calculate        - Trigger ranking calculation (admin)
```

### Kudos

```
GET  /api/kudos                     - Get kudos for current user
POST /api/kudos                     - Give kudos to team member
GET  /api/kudos/leaderboard         - Top kudos recipients
```

### Skills

```
GET  /api/skills                    - Get user's skills
POST /api/skills                    - Add new skill
PUT  /api/skills/:id                - Update skill/certification
GET  /api/skills/org                - Get all skills in org
```

---

## UI Components

### Rankings Dashboard

1. **Leaderboard View**
   - Top 10 performers with tier badges
   - Current user highlighted
   - Period selector (this month, last month, quarter)

2. **Personal Score Card**
   - Radar chart of 5 categories
   - Trend line vs previous periods
   - Specific improvement suggestions

3. **Configuration Panel** (Admin)
   - Slider controls for weights
   - Real-time preview of weight distribution
   - Preset selection dropdown
   - Save/Reset buttons

4. **Kudos Widget**
   - Quick kudos button on team member cards
   - Recent kudos feed
   - Monthly kudos summary

---

## Implementation Phases

### Phase 1 (MVP)
- Basic ranking calculation with default weights
- Organization-level weight configuration
- User ranking history storage
- Simple leaderboard display

### Phase 2
- Kudos system
- Skill tracking
- Radar chart visualization
- Historical trend analysis

### Phase 3
- AI-powered improvement suggestions
- Predictive ranking forecasts
- Team comparison analytics
- Integration with HR systems

---

## Privacy & Ethics Considerations

1. **Transparency**: Users can see how their score is calculated
2. **Appeals**: Process for contesting rankings
3. **Context**: Rankings consider role complexity and tenure
4. **Growth Focus**: Emphasis on improvement, not just absolute scores
5. **No Surveillance**: Metrics from work outputs only, not monitoring
6. **Opt-Out**: Organizations can disable rankings entirely

---

## Version History

| Date | Change |
|------|--------|
| Jan 2, 2026 | Initial design document created |

---

*Last Updated: January 2, 2026*
