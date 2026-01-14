# QUAD POC Plan - January 13, 2026

## Vision

Build a system where **code generates agents** that can:
1. Understand org structure from Excel/database
2. Answer questions with org context
3. Generate smaller specialized agents for specific tasks

---

## Authentication (Enterprise-Grade)

### quad-login Command

```
$ quad-login

  QUAD Authentication
  ───────────────────

  [1] Anthropic Account
      • Individual developers
      • Use your Claude API quota

  [2] Enterprise SSO
      • Corporate teams (MM, MM-WM, etc.)
      • Company pays via QUAD billing
      • SSO: Okta, Azure AD, Google

  Select [1/2]: _
```

### Two Auth Paths

```
┌─────────────────────────────────────────────────────────────────┐
│  OPTION 1: Anthropic Login (quad-login -a)                      │
│  ─────────────────────────────────────────                      │
│                                                                  │
│  • Opens: console.anthropic.com OAuth                           │
│  • User authorizes QUAD app                                     │
│  • Uses their API quota for Haiku calls                         │
│  • Best for: Individual devs, small teams                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  OPTION 2: Enterprise SSO (quad-login -e MM)                    │
│  ───────────────────────────────────────────                    │
│                                                                  │
│  • Looks up org config from api.quadframe.work                  │
│  • Redirects to company SSO (Okta, Azure AD, SAML)             │
│  • QUAD issues org-bound token                                  │
│  • Haiku calls billed to org via QUAD                          │
│  • Best for: Corporations, compliance                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Credentials Storage

```json
// ~/.quad/credentials.json
{
  "auth_type": "enterprise",
  "org_code": "MM-WM",
  "user": "suman@company.com",
  "token": "quad_xxx...",
  "sso_provider": "okta",
  "expires_at": "2026-01-14T09:00:00Z",
  "permissions": ["read", "write", "admin"]
}
```

### Billing Model

| Auth Type | Who Pays for Haiku |
|-----------|-------------------|
| Anthropic (-a) | User's Anthropic account |
| Enterprise (-e) | QUAD bills the org |

---

## Agent Hierarchy (What We're Building)

```
                    ┌─────────────────────┐
                    │   QUADAgent (Base)  │
                    │   ─────────────────  │
                    │   - run()           │
                    │   - self_heal()     │
                    │   - talk_to_agent() │
                    │   - _get_pretext()  │
                    └──────────┬──────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
    │ ContextAgent│    │ InitAgent   │    │ QueryAgent  │
    │ ───────────  │    │ ─────────   │    │ ──────────  │
    │ Fetches org │    │ Parses Excel│    │ Answers     │
    │ context from│    │ and stores  │    │ questions   │
    │ database    │    │ in database │    │ with context│
    └─────────────┘    └─────────────┘    └─────────────┘
           │                   │                   │
           │                   ▼                   │
           │          ┌─────────────┐              │
           │          │ Generated   │              │
           │          │ Sub-Agents  │              │
           │          │ ─────────── │              │
           │          │ - OrgAgent  │              │
           │          │ - TeamAgent │              │
           │          │ - AllocAgent│              │
           └──────────┴─────────────┴──────────────┘
                            │
                            ▼
                    ┌─────────────────┐
                    │  SUMA WIRE      │
                    │  (Agent Router) │
                    └─────────────────┘
```

---

## PGCE Build Order

Following **P = (D × 0.5) + (I × 0.3) + (C' × 0.2)**

| Priority | Component | Dependency | Impact | Description |
|----------|-----------|------------|--------|-------------|
| 1 | QUADAgent Base | None | High | Base class all agents inherit |
| 2 | Database Schema | QUADAgent | High | Tables for org, users, allocations |
| 3 | ContextAgent | Database | High | Fetches context from DB |
| 4 | API Endpoint | ContextAgent | High | api.quadframe.work/context |
| 5 | Hook Script | API | Medium | Claude Code integration |
| 6 | InitAgent | Database | Medium | Excel parser → DB |
| 7 | QueryAgent | ContextAgent | Medium | Answers with context |
| 8 | Agent Generator | All | Low | Generates specialized sub-agents |

---

## Phase 1: Foundation (Today)

### 1.1 QUADAgent Base Class

```python
# QUAD/quad-agents/quad_agent.py

class QUADAgent:
    """Base class for all QUAD agents"""

    def __init__(self, name: str, config: dict = None):
        self.name = name
        self.config = config or {}
        self.children = []  # Sub-agents

    def run(self, input_data: dict) -> dict:
        """Execute agent with self-healing"""
        try:
            return self.execute_task(input_data)
        except Exception as e:
            return self.self_heal(e, input_data)

    def self_heal(self, error: Exception, input_data: dict) -> dict:
        """Auto-fix errors (AI-assisted)"""
        # PRETEXT: Can modify API endpoints, retry logic
        pass

    def talk_to_agent(self, agent_name: str, message: dict) -> dict:
        """Communicate with another agent via SUMA WIRE"""
        pass

    def execute_task(self, input_data: dict) -> dict:
        """ABSTRACT - Override in subclass"""
        raise NotImplementedError

    def _get_pretext(self) -> str:
        """ABSTRACT - What AI can modify"""
        raise NotImplementedError

    def generate_sub_agent(self, spec: dict) -> 'QUADAgent':
        """Generate a specialized sub-agent from spec"""
        pass
```

### 1.2 Database (Already Exists)

Tables we'll use:
- `quad_organizations` - Company/Org
- `quad_users` - Team members
- `quad_domains` - Projects
- `quad_domain_members` - Allocations

### 1.3 ContextAgent

```python
# QUAD/quad-agents/context_agent.py

class ContextAgent(QUADAgent):
    """Fetches org context from database"""

    def execute_task(self, input_data: dict) -> dict:
        question = input_data.get("question", "")
        org_id = input_data.get("org_id")

        # Determine what context is needed
        context_type = self._analyze_question(question)

        # Fetch relevant data
        if context_type == "availability":
            return self._get_availability_context(org_id)
        elif context_type == "team":
            return self._get_team_context(org_id)
        elif context_type == "project":
            return self._get_project_context(org_id)
        else:
            return self._get_full_context(org_id)

    def _analyze_question(self, question: str) -> str:
        """Determine what context is needed"""
        q = question.lower()
        if "available" in q or "hours" in q or "capacity" in q:
            return "availability"
        elif "team" in q or "who" in q or "members" in q:
            return "team"
        elif "project" in q or "working on" in q:
            return "project"
        return "full"

    def _get_availability_context(self, org_id: str) -> dict:
        """Get team availability"""
        # Query database
        sql = """
            SELECT u.name, u.job_title, dm.role,
                   dm.allocation_percentage,
                   40 * (100 - dm.allocation_percentage) / 100 as available_hrs
            FROM quad_users u
            JOIN quad_domain_members dm ON u.id = dm.user_id
            JOIN quad_domains d ON dm.domain_id = d.id
            WHERE d.company_id = %s
            ORDER BY available_hrs DESC
        """
        # Execute and format
        return {"type": "availability", "data": [...], "summary": "..."}
```

---

## Phase 2: Integration

### 2.1 API Endpoint

```
POST https://api.quadframe.work/context

Request:
{
    "question": "Who has 20 hours availability?",
    "org_id": "uuid" (optional, from token)
}

Response:
{
    "summary": "Team availability for Acme Corp:\n- Dev One: 24 hrs...",
    "raw_data": [...],
    "context_type": "availability"
}
```

### 2.2 Hook Script (quad-context-hook.py)

Intercepts `quad-question` → calls ContextAgent → enhances prompt

### 2.3 InitAgent

```python
class InitAgent(QUADAgent):
    """Parses Excel and stores in database"""

    def execute_task(self, input_data: dict) -> dict:
        excel_path = input_data.get("excel_path")

        # Parse Excel tabs
        org_data = self._parse_org_tab(excel_path)
        team_data = self._parse_team_tab(excel_path)
        projects_data = self._parse_projects_tab(excel_path)
        allocations_data = self._parse_allocations_tab(excel_path)

        # Store in database
        self._store_org(org_data)
        self._store_users(team_data)
        self._store_domains(projects_data)
        self._store_allocations(allocations_data)

        return {"status": "success", "org_id": org_id}
```

---

## Phase 3: Agent Generation

The key innovation - **code that generates agents**:

```python
class AgentGenerator(QUADAgent):
    """Generates specialized sub-agents from specs"""

    def execute_task(self, input_data: dict) -> dict:
        spec = input_data.get("spec")

        # Example spec:
        # {
        #     "name": "AllocationAgent",
        #     "purpose": "Track and optimize team allocations",
        #     "data_sources": ["quad_domain_members", "quad_users"],
        #     "capabilities": ["query", "suggest", "alert"]
        # }

        # Generate agent code
        agent_code = self._generate_code(spec)

        # Create agent instance
        agent_class = self._compile_agent(agent_code)

        return {"agent": agent_class, "code": agent_code}

    def _generate_code(self, spec: dict) -> str:
        """Generate Python code for specialized agent"""
        template = '''
class {name}(QUADAgent):
    """{purpose}"""

    DATA_SOURCES = {data_sources}

    def execute_task(self, input_data: dict) -> dict:
        # Auto-generated query logic
        {query_logic}

    def _get_pretext(self) -> str:
        return """
        # PRETEXT: {name}
        # Allowed: Modify query parameters, add filters
        # Restricted: Cannot delete data, cannot access other orgs
        """
'''
        return template.format(**spec)
```

---

## File Structure

```
QUAD/
├── quad-agents/                    # Agent implementations
│   ├── __init__.py
│   ├── quad_agent.py              # Base class
│   ├── context_agent.py           # Fetches org context
│   ├── init_agent.py              # Excel → Database
│   ├── query_agent.py             # Answers questions
│   └── agent_generator.py         # Generates sub-agents
│
├── quad-api/                       # API server
│   └── src/
│       └── routes/
│           └── context.ts         # /context endpoint
│
├── scripts/
│   └── quad-context-hook.py       # Claude Code hook
│
└── templates/
    └── quad-org-template.md       # Excel template docs
```

---

## Commands (End Result)

```bash
# Initialize org from Excel
quad-init @org-setup.xlsx

# Ask question with org context
quad-question "Who has 20 hours availability this week?"

# Generate specialized agent
quad-generate-agent --name AllocationAgent --purpose "Track allocations"

# List generated agents
quad-agents list
```

---

## Success Criteria

1. [ ] `quad-init` successfully imports Excel → Database
2. [ ] `quad-question` enhances prompt with org context
3. [ ] ContextAgent correctly analyzes question intent
4. [ ] AgentGenerator produces working sub-agents
5. [ ] All agents can self-heal on errors
6. [ ] SUMA WIRE routes between agents

---

## Next Steps (In Order)

1. **Create QUADAgent base class** → `quad-agents/quad_agent.py`
2. **Create ContextAgent** → `quad-agents/context_agent.py`
3. **Create API endpoint** → `quad-api/src/routes/context.ts`
4. **Create Hook script** → `scripts/quad-context-hook.py`
5. **Create InitAgent** → `quad-agents/init_agent.py`
6. **Test flow end-to-end**

---

*Created: January 13, 2026*
*QUAD POC - Phase 1*
