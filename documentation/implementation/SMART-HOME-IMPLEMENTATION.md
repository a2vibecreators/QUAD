# QUAD Agent Orchestration System - Implementation Plan

**Project:** First complete QUAD implementation
**Use Cases:**
- Smart Home Control (Alexa, Google, SmartThings)
- File Operations (copy, move, batch processing)
- Email/Notifications
- Database operations
- **ANY system with an API or communication method**

**Author:** Gopi Suman Addanke
**Date:** January 11, 2026

---

## Overview

This is the **first complete QUAD system** demonstrating:
- Multi-agent orchestration (control ANYTHING with API)
- Local-first routing
- Self-healing
- Automated discovery
- Ticket system (scheduled tasks)
- Pre/post hooks

**Key Insight:** One agent system can control:
- Physical devices (smart home)
- Digital files (batch operations)
- Services (email, SMS)
- Databases
- Web APIs
- **Anything with an interface!**

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 SUMA iOS App                             │
│  - Voice/text input                                      │
│  - Display responses                                     │
│  - Local device cache                                    │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/JSON
                     ▼
┌─────────────────────────────────────────────────────────┐
│             SUMA API (suma-api/)                         │
│  - Agent orchestration                                   │
│  - Capability routing                                    │
│  - Session management                                    │
│  - Memory system                                         │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼             ▼
┌──────────────┬──────────────┬──────────────┐
│ Smart Home   │ Alexa        │ Google Home  │
│ Agent        │ Agent        │ Agent        │
│              │              │              │
│ Routes to:   │ Amazon API   │ Google API   │
│ - Alexa      │              │              │
│ - Google     │              │              │
│ - SmartThing│              │              │
└──────────────┴──────────────┴──────────────┘
        │
        ▼
┌──────────────────────────────────────────────┐
│ SmartThings Agent                             │
│ - Controls lights, locks, sensors             │
│ - Samsung SmartThings API                     │
└──────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────┐
│ Device Discovery Agent (Nightly)              │
│ - Scans for new devices                       │
│ - Creates tickets for registration            │
└──────────────────────────────────────────────┘
```

---

## Components to Build

### 1. Database Schema

**File:** `SUMA/suma-database/migrations/005_smart_home_schema.sql`

```sql
-- User devices table
CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    device_type VARCHAR(50) NOT NULL, -- 'alexa', 'google_home', 'smartthings'
    device_name VARCHAR(255) NOT NULL,
    location VARCHAR(255), -- 'bedroom', 'living room', etc.
    capabilities TEXT[], -- ['play_music', 'control_volume', etc.]
    metadata JSONB, -- Device-specific data
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'inactive', 'pending'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_seen TIMESTAMP,
    UNIQUE(user_id, device_id)
);

-- Tickets table
CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_type VARCHAR(50) NOT NULL, -- 'user_ticket', 'suma_ticket'
    user_id VARCHAR(255),
    assigned_to VARCHAR(255), -- agent_id
    title VARCHAR(500) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'critical'
    status VARCHAR(50) DEFAULT 'scheduled', -- 'scheduled', 'processing', 'completed', 'failed'
    scheduled_time TIMESTAMP,
    executed_time TIMESTAMP,
    pre_hooks JSONB DEFAULT '[]',
    post_hooks JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Agent registry table
CREATE TABLE IF NOT EXISTS agent_registry (
    agent_id VARCHAR(255) PRIMARY KEY,
    agent_type VARCHAR(100) NOT NULL,
    capabilities TEXT[],
    endpoint VARCHAR(500), -- HTTP endpoint if has one
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'inactive', 'error'
    last_heartbeat TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Device discovery log
CREATE TABLE IF NOT EXISTS device_discovery_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    discovered_devices JSONB,
    new_devices_count INT DEFAULT 0,
    scan_time TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);
CREATE INDEX idx_user_devices_type ON user_devices(device_type);
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_scheduled ON tickets(scheduled_time) WHERE status = 'scheduled';
CREATE INDEX idx_agent_registry_type ON agent_registry(agent_type);
```

### 2. SUMA API Endpoints

**File:** `SUMA/suma-api/src/api/smart-home.ts`

```typescript
// POST /api/smart-home/execute
// Execute smart home command
{
  userId: string;
  command: string; // "play my morning playlist", "turn on living room lights"
}

// GET /api/smart-home/devices/:userId
// Get user's registered devices

// POST /api/smart-home/devices/:userId
// Register a new device
{
  deviceId: string;
  deviceType: 'alexa' | 'google_home' | 'smartthings';
  deviceName: string;
  location?: string;
}

// DELETE /api/smart-home/devices/:userId/:deviceId
// Remove a device

// POST /api/agent/register
// Register an agent
{
  agentId: string;
  agentType: string;
  capabilities: string[];
  endpoint?: string;
}

// POST /api/agent/call
// Agent-to-agent communication (SUMA WIRE)
{
  callerAgentId: string;
  targetAgentName: string;
  params: any;
}

// POST /api/agent/fix
// Request agent fix (self-healing)
{
  agentId: string;
  errorType: string;
  errorMessage: string;
  currentCode: string;
  pretext: string;
}

// GET /api/tickets?status=scheduled&assigned_to=reminder_agent
// Get tickets for an agent

// POST /api/tickets
// Create a ticket
{
  ticketType: 'user_ticket' | 'suma_ticket';
  userId?: string;
  assignedTo: string;
  title: string;
  scheduledTime?: string;
  preHooks?: Hook[];
  postHooks?: Hook[];
}

// PATCH /api/tickets/:id
// Update ticket status
{
  status: 'processing' | 'completed' | 'failed';
}
```

### 3. Agent Implementations

#### 3.1 Smart Home Agent (Python)

**File:** `SUMA/suma-agents/smart_home_agent.py`

```python
from quad_agent import QUADAgent
import requests

class SmartHomeAgent(QUADAgent):
    def __init__(self):
        super().__init__(
            agent_id="smart-home-001",
            agent_type="smart_home",
            suma_api_url="http://localhost:3201/api"
        )
        self.register()

    def execute_task(self, request):
        user_id = request["userId"]
        command = request["command"].lower()

        # Route to appropriate handler
        if any(word in command for word in ["play", "music", "song"]):
            return self.handle_music(user_id, command)
        elif any(word in command for word in ["turn on", "turn off", "dim", "light"]):
            return self.handle_lights(user_id, command)
        elif any(word in command for word in ["lock", "unlock"]):
            return self.handle_locks(user_id, command)
        else:
            return {"success": False, "message": "I didn't understand that command"}

    def handle_music(self, user_id, command):
        # Get music-capable devices
        devices = self.get_devices(user_id, ["alexa", "google_home"])

        if len(devices) == 0:
            return {
                "success": False,
                "message": "No music devices found. Would you like to add one?",
                "action": "register_device"
            }

        if len(devices) == 1:
            return self.play_music_on_device(devices[0], command)

        # Multiple devices - ask which one
        return {
            "success": True,
            "message": f"Which device?\n" + "\n".join([f"- {d['device_name']}" for d in devices]),
            "action": "ask_device_selection",
            "devices": devices
        }

    def play_music_on_device(self, device, command):
        # Route to correct agent
        agent_name = "alexa_agent" if device["device_type"] == "alexa" else "google_home_agent"

        result = self.talk_to_agent(agent_name, {
            "device_id": device["device_id"],
            "action": "play_music",
            "query": command
        })

        return {
            "success": result["success"],
            "message": f"Playing on {device['device_name']}"
        }

    def get_devices(self, user_id, device_types):
        # Check local cache first
        cache_key = f"{user_id}:{','.join(device_types)}"
        cached = self.memoryCache.get(cache_key)
        if cached:
            return cached

        # Cache miss - call API
        response = requests.get(
            f"{self.suma_api_url}/smart-home/devices/{user_id}",
            params={"types": ",".join(device_types)}
        )

        devices = response.json()["data"]
        self.memoryCache.put(cache_key, devices, ttl=3600)
        return devices

    def _get_pretext(self):
        return """
        Smart Home Agent - Routes smart home commands to appropriate devices.
        Can modify device routing logic if new device types added.
        Cannot access other users' devices.
        """

if __name__ == "__main__":
    agent = SmartHomeAgent()
    # Keep running and listening for requests
    # In production, this would be a web server
    print(f"Smart Home Agent started: {agent.agent_id}")
```

#### 3.2 Alexa Agent (Python)

**File:** `SUMA/suma-agents/alexa_agent.py`

```python
from quad_agent import QUADAgent
import requests

class AlexaAgent(QUADAgent):
    def __init__(self):
        super().__init__(
            agent_id="alexa-001",
            agent_type="alexa",
            suma_api_url="http://localhost:3201/api"
        )
        self.register()

    # PRETEXT: Controls Alexa devices via Amazon API
    # Can update API endpoint if Amazon changes
    # Cannot access unauthorized devices
    def execute_task(self, request):
        device_id = request["device_id"]
        action = request["action"]

        if action == "play_music":
            return self.play_music(device_id, request["query"])

    def play_music(self, device_id, query):
        try:
            # Call Amazon Alexa API
            response = requests.post(
                f"https://api.amazonalexa.com/v1/devices/{device_id}/play",
                headers={"Authorization": f"Bearer {self.config['alexa_token']}"},
                json={"query": query}
            )

            return {"success": True, "message": "Playing on Alexa"}
        except Exception as e:
            return self.self_heal(e)
    # END_PRETEXT

    def _get_pretext(self):
        return """
        Alexa Agent - Controls Amazon Alexa devices.
        Can update Amazon API calls if API changes.
        Cannot access devices user doesn't own.
        """
```

#### 3.3 Google Home Agent (Python)

**File:** `SUMA/suma-agents/google_home_agent.py`

(Similar to Alexa Agent, calls Google Home API)

#### 3.4 SmartThings Agent (Python)

**File:** `SUMA/suma-agents/smartthings_agent.py`

(Controls lights, locks, sensors via SmartThings API)

#### 3.5 File Agent (Python) - EXAMPLE

**File:** `SUMA/suma-agents/file_agent.py`

```python
from quad_agent import QUADAgent
import shutil
import os

class FileAgent(QUADAgent):
    """
    File operations agent
    - Copy files
    - Move files
    - Batch operations
    - ZIP creation
    """

    def __init__(self):
        super().__init__(
            agent_id="file-001",
            agent_type="file_operations"
        )
        self.register()

    def execute_task(self, request):
        action = request["action"]

        if action == "copy":
            return self.copy_file(request["source"], request["destination"])
        elif action == "batch_copy":
            return self.batch_copy(request["files"], request["destination"])
        elif action == "zip":
            return self.create_zip(request["files"], request["output"])

    # PRETEXT: Performs file operations
    # Can modify file handling if OS changes
    # Cannot access files outside user's permissions
    def copy_file(self, source, destination):
        try:
            shutil.copy2(source, destination)
            return {"success": True, "message": f"Copied {source} to {destination}"}
        except Exception as e:
            return self.self_heal(e)

    def batch_copy(self, files, destination):
        results = []
        for file in files:
            result = self.copy_file(file, destination)
            results.append(result)

        success_count = len([r for r in results if r["success"]])
        return {
            "success": True,
            "message": f"Copied {success_count}/{len(files)} files",
            "results": results
        }
    # END_PRETEXT

    def _get_pretext(self):
        return "File Agent - Performs file operations. Can modify file handling logic."
```

#### 3.6 Email Agent (Python) - EXAMPLE

**File:** `SUMA/suma-agents/email_agent.py`

```python
from quad_agent import QUADAgent
import smtplib
from email.mime.text import MIMEText

class EmailAgent(QUADAgent):
    """
    Email sending agent
    - Send emails
    - Batch emails
    - Templates
    """

    def __init__(self):
        super().__init__(
            agent_id="email-001",
            agent_type="email"
        )
        self.register()

    def execute_task(self, request):
        action = request["action"]

        if action == "send_email":
            return self.send_email(
                request["to"],
                request["subject"],
                request["body"]
            )

    # PRETEXT: Sends emails via SMTP
    # Can update SMTP settings if server changes
    # Cannot send emails without user permission
    def send_email(self, to, subject, body):
        try:
            msg = MIMEText(body)
            msg['Subject'] = subject
            msg['From'] = self.config['from_email']
            msg['To'] = to

            with smtplib.SMTP(self.config['smtp_server'], self.config['smtp_port']) as server:
                server.starttls()
                server.login(self.config['smtp_user'], self.config['smtp_password'])
                server.send_message(msg)

            return {"success": True, "message": f"Email sent to {to}"}
        except Exception as e:
            return self.self_heal(e)
    # END_PRETEXT

    def _get_pretext(self):
        return "Email Agent - Sends emails via SMTP. Can adapt if SMTP server changes."
```

#### 3.7 Device Discovery Agent (Python)

**File:** `SUMA/suma-agents/device_discovery_agent.py`

```python
from quad_agent import QUADAgent
import requests
from datetime import datetime

class DeviceDiscoveryAgent(QUADAgent):
    def __init__(self):
        super().__init__(
            agent_id="device-discovery-001",
            agent_type="device_discovery",
            suma_api_url="http://localhost:3201/api",
            trigger={
                "type": "time",
                "schedule": "0 2 * * *"  # 2am daily
            }
        )
        self.register()

    def execute_task(self, request=None):
        # Get all users with smart home enabled
        users = self.get_smart_home_users()

        for user in users:
            self.scan_user_devices(user)

    def scan_user_devices(self, user):
        # Get registered devices
        registered = self.get_registered_devices(user["user_id"])

        # Discover via SmartThings (hub sees all devices)
        discovered = self.discover_via_smartthings(user)

        # Find new devices
        new_devices = []
        for device in discovered:
            if not self.is_registered(device, registered):
                new_devices.append(device)

        if len(new_devices) > 0:
            # Create ticket
            self.create_ticket({
                "ticket_type": "suma_ticket",
                "user_id": user["user_id"],
                "assigned_to": "notification_agent",
                "title": f"New devices found: {len(new_devices)}",
                "description": "\n".join([d["name"] for d in new_devices]),
                "priority": "low",
                "metadata": {"new_devices": new_devices}
            })

    def create_ticket(self, ticket_data):
        requests.post(
            f"{self.suma_api_url}/tickets",
            json=ticket_data
        )

    def _get_pretext(self):
        return "Device Discovery Agent - Scans for new smart home devices nightly."
```

### 4. SUMA API Implementation

**File:** `SUMA/suma-api/src/api/smart-home.ts`

```typescript
import { Router } from 'express';
import { db } from '../db';

const router = Router();

// Execute smart home command
router.post('/execute', async (req, res) => {
    const { userId, command } = req.body;

    // Call Smart Home Agent
    const result = await callAgent('smart_home_agent', {
        userId,
        command
    });

    res.json({ success: true, data: result });
});

// Get user devices
router.get('/devices/:userId', async (req, res) => {
    const { userId } = req.params;
    const { types } = req.query;

    let query = 'SELECT * FROM user_devices WHERE user_id = $1 AND status = $2';
    const params: any[] = [userId, 'active'];

    if (types) {
        query += ' AND device_type = ANY($3)';
        params.push((types as string).split(','));
    }

    const result = await db.query(query, params);

    res.json({
        success: true,
        data: result.rows,
        count: result.rows.length
    });
});

// Register device
router.post('/devices/:userId', async (req, res) => {
    const { userId } = req.params;
    const { deviceId, deviceType, deviceName, location } = req.body;

    const result = await db.query(`
        INSERT INTO user_devices (user_id, device_id, device_type, device_name, location)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (user_id, device_id) DO UPDATE
        SET device_name = $4, location = $5, status = 'active', updated_at = NOW()
        RETURNING *
    `, [userId, deviceId, deviceType, deviceName, location]);

    res.json({ success: true, data: result.rows[0] });
});

export default router;
```

### 5. Agent Registry & SUMA WIRE

**File:** `SUMA/suma-api/src/api/agent.ts`

```typescript
// Agent registration
router.post('/register', async (req, res) => {
    const { agentId, agentType, capabilities, endpoint } = req.body;

    await db.query(`
        INSERT INTO agent_registry (agent_id, agent_type, capabilities, endpoint, last_heartbeat)
        VALUES ($1, $2, $3, $4, NOW())
        ON CONFLICT (agent_id) DO UPDATE
        SET agent_type = $2, capabilities = $3, endpoint = $4, last_heartbeat = NOW(), status = 'active'
    `, [agentId, agentType, capabilities, endpoint]);

    res.json({ success: true, message: 'Agent registered' });
});

// SUMA WIRE - Agent-to-agent call
router.post('/call', async (req, res) => {
    const { callerAgentId, targetAgentName, params } = req.body;

    // Find target agent
    const result = await db.query(
        'SELECT * FROM agent_registry WHERE agent_type = $1 AND status = $2',
        [targetAgentName, 'active']
    );

    if (result.rows.length === 0) {
        return res.status(404).json({ success: false, error: 'Agent not found' });
    }

    const targetAgent = result.rows[0];

    // Call agent endpoint if it has one
    if (targetAgent.endpoint) {
        const response = await fetch(`${targetAgent.endpoint}/execute`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ caller_agent_id: callerAgentId, ...params })
        });

        const data = await response.json();
        res.json({ success: true, data });
    } else {
        res.status(503).json({ success: false, error: 'Agent has no endpoint' });
    }
});
```

---

## Implementation Order

### Phase 1: Database & Infrastructure (Day 1)
1. ✅ Create database migration (`005_smart_home_schema.sql`)
2. ✅ Run migration
3. ✅ Test tables created

### Phase 2: SUMA API Endpoints (Day 1-2)
1. ✅ Implement `/api/smart-home/*` endpoints
2. ✅ Implement `/api/agent/*` endpoints
3. ✅ Implement `/api/tickets/*` endpoints
4. ✅ Test with curl/Postman

### Phase 3: QUAD Agent Base Class (Day 2)
1. ✅ Create `quad_agent.py` base class
2. ✅ Implement local caching
3. ✅ Implement self-healing
4. ✅ Implement talk_to_agent

### Phase 4: Agent Implementations (Day 2-3)
1. ✅ Smart Home Agent
2. ✅ Alexa Agent
3. ✅ Google Home Agent
4. ✅ SmartThings Agent
5. ✅ Device Discovery Agent

### Phase 5: Integration Testing (Day 3)
1. ✅ Register all agents
2. ✅ Test device registration
3. ✅ Test music playback flow
4. ✅ Test device control flow
5. ✅ Test device discovery

### Phase 6: iOS App Integration (Day 4)
1. ✅ Update SUMA iOS app to call smart home endpoints
2. ✅ Test end-to-end flow
3. ✅ Demo with real devices

---

## Testing Plan

### Unit Tests
- Database queries
- API endpoints
- Agent routing logic

### Integration Tests
- Agent-to-agent communication
- Device registration flow
- Command execution flow

### End-to-End Tests
1. User says "Play my morning playlist"
2. iOS app → SUMA API → Smart Home Agent → Alexa Agent → Amazon API
3. Music plays on Alexa

---

## Files to Create/Modify

```
SUMA/
├── suma-database/
│   └── migrations/
│       └── 005_smart_home_schema.sql (NEW)
│
├── suma-api/
│   └── src/
│       └── api/
│           ├── smart-home.ts (NEW)
│           ├── agent.ts (NEW)
│           └── tickets.ts (NEW)
│
└── suma-agents/ (NEW)
    ├── quad_agent.py (NEW - Base class)
    ├── smart_home_agent.py (NEW)
    ├── alexa_agent.py (NEW)
    ├── google_home_agent.py (NEW)
    ├── smartthings_agent.py (NEW)
    └── device_discovery_agent.py (NEW)
```

---

**Ready to build! Let's start with Phase 1.**

**Copyright © 2026 Gopi Suman Addanke. All Rights Reserved.**
