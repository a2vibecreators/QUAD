# QUAD Agent Protocol

**Language-Agnostic Specification**
**Patent Pending: 63/956,810**
**Author: Gopi Suman Addanke**
**Date: January 11, 2026**

---

## Core Concept

**Any program in any language can be a QUAD agent** by implementing this protocol.

Like HTTP - doesn't matter if you use Python, Swift, Java, or JavaScript - if you follow the protocol, you're an agent.

---

## Agent Protocol Specification

### 1. Agent Identity

Every agent MUST have:

```json
{
  "agentId": "unique-identifier",
  "agentType": "weather|email|file_transfer|custom",
  "capabilities": [
    "self_heal",
    "generate_agent",
    "talk_to_agent",
    "self_destroy",
    "update_self",
    "register"
  ],
  "endpoint": "http://ip:port" // Optional - for direct communication
}
```

### 2. Required Capabilities (Methods)

Every agent MUST implement these methods:

| Capability | Method Signature | Description |
|------------|------------------|-------------|
| **execute_task** | `execute_task() -> Result` | Do the actual work |
| **self_heal** | `self_heal(error) -> Result` | Fix errors automatically |
| **get_status** | `get_status() -> Status` | Report health/state |
| **register** | `register() -> Result` | Register with SUMA WIRE |

Every agent CAN implement these (optional):

| Capability | Method Signature | Description |
|------------|------------------|-------------|
| **generate_agent** | `generate_agent(type, task, restrictions) -> Agent` | Create new agents |
| **talk_to_agent** | `talk_to_agent(name, params, mode) -> Result` | Call other agents |
| **self_destroy** | `self_destroy(reason) -> void` | Terminate self |
| **update_self** | `update_self(code) -> Result` | Modify own code |

---

## Communication Protocol

### HTTP + JSON

All agents communicate using **HTTP POST** with **JSON payloads**.

### Standard Request Format

```json
{
  "caller_agent_id": "weather-001",
  "action": "execute|heal|generate|call|status|destroy",
  "params": {
    // Action-specific parameters
  },
  "timestamp": "2026-01-11T10:30:00Z",
  "transaction_id": "tx-12345"
}
```

### Standard Response Format

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "agent_id": "responder-agent-id",
  "timestamp": "2026-01-11T10:30:01Z",
  "transaction_id": "tx-12345",
  "execution_time_ms": 150
}
```

### Error Response Format

```json
{
  "success": false,
  "error": "Error description",
  "error_type": "APIError|NetworkError|ValidationError",
  "agent_id": "responder-agent-id",
  "timestamp": "2026-01-11T10:30:01Z",
  "transaction_id": "tx-12345"
}
```

---

## Agent Endpoints

### If agent has HTTP endpoint (for direct communication):

#### POST `/execute`
Execute the agent's task

**Request:**
```json
{
  "caller_agent_id": "another-agent",
  "params": {
    // Task parameters
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    // Task result
  }
}
```

#### POST `/heal`
Trigger self-healing

**Request:**
```json
{
  "caller_agent_id": "suma-server",
  "error_type": "APIError",
  "error_message": "Connection timeout",
  "code_update": "...",
  "config_update": {}
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "healed": true,
    "solution_applied": true
  }
}
```

#### GET `/status`
Get agent status

**Response:**
```json
{
  "success": true,
  "data": {
    "agent_id": "weather-001",
    "status": "running|idle|error|destroyed",
    "health": "healthy|degraded|critical",
    "uptime_seconds": 3600,
    "success_count": 150,
    "error_count": 2,
    "last_run": "2026-01-11T10:30:00Z"
  }
}
```

#### POST `/destroy`
Trigger self-destruction

**Request:**
```json
{
  "caller_agent_id": "suma-server",
  "reason": "Task completed"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "destroyed": true,
    "final_stats": {
      "success_count": 150,
      "error_count": 2,
      "lifetime_seconds": 86400
    }
  }
}
```

---

## SUMA WIRE Protocol

### Agent Registration

**POST** `https://asksuma.ai/api/agent/register`

```json
{
  "agent_id": "weather-001",
  "agent_type": "weather",
  "capabilities": ["self_heal", "talk_to_agent"],
  "endpoint": "http://192.168.1.100:5000", // Optional
  "pretext": "This agent checks weather..."
}
```

### Agent-to-Agent Call (via SUMA WIRE)

**POST** `https://asksuma.ai/api/agent/call`

```json
{
  "caller_agent_id": "weather-001",
  "target_agent_name": "email_agent",
  "params": {
    "to": "user@example.com",
    "subject": "Rain Alert",
    "body": "It's raining!"
  }
}
```

**SUMA finds "email_agent" and routes the request.**

### Request Agent Fix

**POST** `https://asksuma.ai/api/agent/fix`

```json
{
  "agent_id": "weather-001",
  "error_type": "APIError",
  "error_message": "Invalid API endpoint",
  "current_code": "...",
  "pretext": "...",
  "healing_log": {}
}
```

**SUMA returns:**
```json
{
  "success": true,
  "data": {
    "code_update": "fixed code here...",
    "config_update": {
      "api_endpoint": "https://new-endpoint.com"
    },
    "explanation": "Updated API endpoint..."
  }
}
```

### Generate New Agent

**POST** `https://asksuma.ai/api/agent/generate`

```json
{
  "creator_agent_id": "ios-app-001",
  "agent_type": "robo_dog_controller",
  "task_description": "Control robo dog via Bluetooth LE",
  "restrictions": {
    "allowed_commands": ["forward", "backward", "sit"],
    "max_speed": 5,
    "protocol": "bluetooth_le"
  },
  "language": "python|swift|javascript",
  "include_self_healing": true
}
```

**SUMA returns:**
```json
{
  "success": true,
  "data": {
    "agent_id": "robo-dog-ctrl-001",
    "code": "# Full agent code here...",
    "config": {},
    "deployment": {
      "method": "file|docker|lambda",
      "instructions": "Save to /tmp/robo_dog_ctrl.py and run..."
    }
  }
}
```

---

## Trigger Protocol

Agents can be trigger-based. Supported trigger types:

### 1. Time Trigger (Cron)

```json
{
  "trigger": {
    "type": "time",
    "schedule": "0 8 * * *", // Every day at 8am
    "timezone": "Asia/Kolkata"
  }
}
```

### 2. Event Trigger (File Watch)

```json
{
  "trigger": {
    "type": "file_watch",
    "path": "/tmp/watch_folder",
    "pattern": "*.txt",
    "action": "created|modified|deleted"
  }
}
```

### 3. HTTP Webhook Trigger

```json
{
  "trigger": {
    "type": "http",
    "endpoint": "/webhook",
    "method": "POST"
  }
}
```

### 4. Condition Trigger

```json
{
  "trigger": {
    "type": "condition",
    "check_interval_seconds": 60,
    "condition": {
      "type": "file_size",
      "path": "/tmp/logfile.txt",
      "operator": ">",
      "value": 10485760 // 10MB
    }
  }
}
```

**When trigger fires:**
1. Agent executes `execute_task()`
2. If successful, optionally calls `self_destroy()`
3. If error, calls `self_heal()`

---

## Self-Destruction Protocol

### Automatic Destruction Triggers

Agents can self-destruct when:

1. **Task completed** (one-time agents)
```json
{
  "auto_destroy": {
    "on": "task_complete",
    "notify": "https://asksuma.ai/api/agent/destroyed"
  }
}
```

2. **Error threshold exceeded**
```json
{
  "auto_destroy": {
    "on": "error_threshold",
    "max_errors": 5,
    "notify": "http://my-service.com/alert"
  }
}
```

3. **Time-based**
```json
{
  "auto_destroy": {
    "on": "time",
    "after_seconds": 3600, // 1 hour
    "notify": "https://asksuma.ai/api/agent/destroyed"
  }
}
```

4. **External trigger**
```json
{
  "auto_destroy": {
    "on": "http_call",
    "endpoint": "/destroy",
    "auth_required": true
  }
}
```

**When destroying:**
1. Agent saves final state
2. Sends notification (HTTP POST to notify URL)
3. Cleans up resources
4. Terminates process

**Notification Format:**
```json
POST {notify_url}
{
  "agent_id": "temp-agent-001",
  "reason": "Task completed",
  "created_at": "2026-01-11T10:00:00Z",
  "destroyed_at": "2026-01-11T10:05:23Z",
  "lifetime_seconds": 323,
  "stats": {
    "success_count": 1,
    "error_count": 0
  },
  "final_result": {
    // Last task result
  }
}
```

---

## Implementation Examples

### Python Agent

```python
class MyAgent(QUADAgent):
    def execute_task(self):
        # Do work
        pass

    def _get_pretext(self):
        return "Agent description..."

# Create and start
agent = MyAgent(
    agent_id="my-agent-001",
    agent_type="custom",
    port=5000,  # HTTP endpoint
    trigger={"type": "time", "schedule": "0 8 * * *"}
)

agent.start()  # Registers, starts HTTP server, starts trigger
```

### Swift Agent (iOS)

```swift
class MyAgent: QUADAgentProtocol {
    let agentId = "ios-agent-001"
    let agentType = "mobile"

    func executeTask() -> AgentResult {
        // Do work
    }

    func getPretext() -> String {
        return "Agent description..."
    }
}

let agent = MyAgent()
agent.register() // Registers with SUMA
agent.run() // Executes task
```

### JavaScript Agent (Node.js)

```javascript
class MyAgent extends QUADAgent {
  constructor() {
    super({
      agentId: 'js-agent-001',
      agentType: 'web',
      port: 3000
    });
  }

  async executeTask() {
    // Do work
  }

  getPretext() {
    return 'Agent description...';
  }
}

const agent = new MyAgent();
agent.start();
```

---

## Communication Examples

### Example 1: Direct Communication (Both have endpoints)

```
Weather Agent (Port 5000)    Email Agent (Port 5001)
       │                            │
       │  POST http://localhost:5001/execute
       │  { "to": "...", "body": "..." }
       ├───────────────────────────>│
       │                            │
       │         Response           │
       │<───────────────────────────┤
```

### Example 2: SUMA WIRE Communication

```
iOS Agent              SUMA Server            Python Agent
   │                        │                      │
   │  call("email", ...)    │                      │
   ├───────────────────────>│                      │
   │                        │  Find "email"        │
   │                        │  POST /execute       │
   │                        ├─────────────────────>│
   │                        │                      │
   │                        │      Response        │
   │                        │<─────────────────────┤
   │      Response          │                      │
   │<───────────────────────┤                      │
```

### Example 3: Iron Man Swarm (Multiple agents work together)

```
Main Agent (Orchestrator)
   │
   ├─> Spawns Agent 1 (File Watcher)
   │        ├─> Trigger: file created
   │        └─> On trigger: Call Agent 2
   │
   ├─> Spawns Agent 2 (File Processor)
   │        ├─> Receives file from Agent 1
   │        ├─> Processes it
   │        └─> Calls Agent 3
   │
   └─> Spawns Agent 3 (Uploader)
            ├─> Receives processed file
            ├─> Uploads to cloud
            └─> Destroys self

All agents work independently but communicate!
```

---

## Protocol Versioning

**Current Version:** `1.0`

Every request SHOULD include:
```json
{
  "protocol_version": "1.0"
}
```

Future versions will be backwards compatible or provide migration path.

---

**Copyright © 2026 Gopi Suman Addanke. All Rights Reserved.**
