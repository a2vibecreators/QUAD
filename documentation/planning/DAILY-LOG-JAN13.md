# QUAD Project - Next Steps

**Date:** January 13, 2026
**Status:** Planning Phase

---

## Completed Today

### SUMA Platform
- [x] Fixed iOS app STT/TTS separation (Apple STT always, Sarvam TTS toggle)
- [x] Fixed Sarvam TTS: speaker=anushka, model=bulbul:v2
- [x] Fixed double-tap login issue
- [x] Created `suma_prod_db` in Cloud SQL (34.148.105.158)
- [x] Deployed 31 tables to production database
- [x] Redeployed suma-api with new DATABASE_URL
- [x] All changes committed and pushed

### Database Credentials (save to vault.a2vibes.tech under sumaprod)
```
Host: 34.148.105.158
Port: 5432
Database: suma_prod_db
Username: suma_user
Password: SumaProd2026
```

---

## Next Steps - QUAD Ecosystem

### Phase 1: QUAD-API (Backend)

Create `quad-api` similar to `suma-api`:

```
quad-api/
├── src/
│   ├── index.ts                 # Express entry point
│   ├── config/
│   │   └── index.ts             # Environment config
│   ├── api/
│   │   ├── pgce.ts              # PGCE algorithm endpoints
│   │   ├── agents.ts            # Agent registry & execution
│   │   ├── commands.ts          # QUAD command handlers
│   │   ├── generate.ts          # Code generation
│   │   └── health.ts            # Health checks
│   ├── engines/
│   │   ├── pgce-engine.ts       # Priority-Guided Code Evolution
│   │   └── agent-engine.ts      # Agent execution engine
│   ├── types/
│   │   └── index.ts             # TypeScript types
│   └── middleware/
│       └── auth.ts              # Authentication
├── package.json
├── tsconfig.json
└── Dockerfile
```

**Key Endpoints:**
- `POST /api/pgce/generate` - Generate code with PGCE
- `POST /api/agent/execute` - Execute agent
- `POST /api/agent/register` - Register new agent
- `POST /api/agent/fix` - Self-healing
- `GET /api/commands/list` - List QUAD commands
- `POST /api/commands/execute` - Execute QUAD command

### Phase 2: SUMA Plugin (VS Code Extension)

Create VS Code extension as Claude Code wrapper:

```
suma-plugin/
├── src/
│   ├── extension.ts             # Entry point
│   ├── commands/
│   │   ├── quad-status.ts       # /quad-status command
│   │   ├── quad-generate.ts     # /quad-gen command
│   │   └── suma-wire.ts         # SUMA WIRE routing
│   ├── providers/
│   │   ├── chat-provider.ts     # Chat UI provider
│   │   └── agent-provider.ts    # Agent suggestions
│   ├── api/
│   │   └── quad-client.ts       # QUAD-API client
│   └── utils/
│       └── config.ts            # Extension config
├── package.json
└── tsconfig.json
```

**QUAD Commands:**
- `/quad-status` - Show project status
- `/quad-gen <feature>` - Generate code with PGCE
- `/quad-agent <name>` - Execute specific agent
- `/quad-fix` - Self-heal current file
- `/quad-wire` - SUMA WIRE agent routing

### Phase 3: QUAD School Integration

- Connect to QUADSchool resources
- Interactive tutorials
- Example projects using QUAD methodology

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              SUMA PLUGIN (VS Code Extension)            │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Claude Code-style UI                              │  │
│  │  - Chat interface                                  │  │
│  │  - QUAD Commands (/quad-status, /quad-gen)        │  │
│  │  - Agent suggestions                              │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────┘
                          │ HTTP/WebSocket
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      QUAD-API                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ PGCE Engine │  │ Agent       │  │ Command         │  │
│  │             │  │ Registry    │  │ Handler         │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐│
│  │              SUMA WIRE (Agent Routing)              ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    quad_prod_db                          │
│  - agents, executions, commands, pgce_modules           │
└─────────────────────────────────────────────────────────┘
```

---

## Immediate Action Items

1. **Create quad-api structure** (copy from suma-api as template)
2. **Setup quad_prod_db** (already exists at 34.148.105.158)
3. **Deploy quad-api to GCP** (api.quadframe.work)
4. **Create suma-plugin VS Code extension**
5. **Implement QUAD commands**

---

## Commands to Run After Restart

```bash
# Navigate to project
cd /Users/semostudio/git/a2vibes

# Check status
git status

# Start working on quad-api
cd QUAD/quad-api

# Or create new suma-plugin
mkdir -p /Users/semostudio/git/a2vibes/SUMA/suma-plugin
```

---

**Notes:**
- quad_prod_db already exists in Cloud SQL (for MassMutual demo)
- Use same patterns as suma-api for consistency
- SUMA WIRE = invisible routing between agents
- QUAD FLUX = internal implementation (trade secret)
