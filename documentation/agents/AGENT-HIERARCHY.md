# QUAD Agent Hierarchy & Types

**Patent Pending: 63/956,810**
**Date: January 11, 2026**

---

## 🏗️ **Complete Agent Hierarchy**

```
┌─────────────────────────────────────────────────────────────────┐
│                         SUMA (God-Level)                        │
│                                                                 │
│  Role: Ultimate orchestrator and generator                     │
│  Powers:                                                        │
│  - Generates ANY specialized agent                             │
│  - Access to all AI models (GPT-4, Claude, Gemini)            │
│  - Full database access                                        │
│  - Can create agents with ANY capabilities                     │
│                                                                 │
│  Example: User says "Build me a robo dog controller app"      │
│  SUMA generates complete iOS app + Python Bluetooth agent      │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          │ generates
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Specialized Agents (Level 1)                  │
│                                                                 │
│  Role: Domain experts with specific purposes                   │
│  Examples:                                                      │
│  1. SUMA iOS App (smart home controller)                       │
│  2. SUMA Voice Assistant (like Alexa)                          │
│  3. Robo Dog Controller App                                    │
│  4. Smart Home Dashboard                                       │
│                                                                 │
│  Powers:                                                        │
│  - Can generate LIMITED QUAD agents                            │
│  - Talk to other agents via SUMA WIRE                          │
│  - Self-heal (fix their own code)                             │
│  - Domain expertise (e.g., Bluetooth LE, Voice, UI)           │
│                                                                 │
│  Restrictions:                                                  │
│  - Can only generate Type 1 or Type 2 QUAD agents             │
│  - Cannot generate other Specialized Agents                    │
│  - Limited to specific APIs (defined by SUMA)                 │
│                                                                 │
│  Example: Robo Dog App generates a Bluetooth agent to          │
│  communicate with the dog, but can't generate another iOS app  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          │ can generate (with restrictions)
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    QUAD Agents (Level 2)                        │
│                                                                 │
│  Role: Helper agents with narrow responsibilities              │
│  Created by: Specialized Agents (NOT by SUMA directly)         │
│                                                                 │
│  Three Types:                                                   │
│  ├─ Type 1: Pure Static (no modification ability)             │
│  ├─ Type 2: Self-Healing (can fix 2-3 functions)             │
│  └─ Type 3: Generator (can create Type 1/2 only)             │
│                                                                 │
│  Restrictions:                                                  │
│  - Cannot generate Specialized Agents                          │
│  - Type 3 cannot generate other Type 3 (no recursion)         │
│  - Limited API access (whitelist only)                        │
│  - Maximum 5 agents per parent (configurable)                 │
│                                                                 │
│  Example: Robo Dog's Bluetooth agent (Type 2) can fix         │
│  connection errors but cannot create other agents              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 **Agent Type Comparison Table**

| Feature | SUMA | Specialized Agent | Type 1 QUAD | Type 2 QUAD | Type 3 QUAD |
|---------|------|-------------------|-------------|-------------|-------------|
| **Self-Healing** | ✅ Full | ✅ Full | ❌ None | ✅ Limited (2-3 functions) | ✅ Limited |
| **Generate Specialized Agents** | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |
| **Generate QUAD Agents** | ✅ Yes | ✅ Limited | ❌ No | ❌ No | ✅ Type 1/2 only |
| **Talk to Agents (SUMA WIRE)** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Persist to Database** | ✅ Yes | ✅ Yes | ⚠️ Optional | ⚠️ Optional | ⚠️ Optional |
| **HTTP Endpoint** | ✅ Yes | ✅ Yes | ⚠️ Optional | ⚠️ Optional | ⚠️ Optional |
| **PRETEXT Sections** | N/A | ✅ Multiple | ❌ None | ✅ 2-3 functions | ✅ Limited |
| **Access to AI Models** | ✅ All | ⚠️ Limited | ❌ None | ⚠️ Via SUMA API | ⚠️ Via SUMA API |
| **Lifespan** | ♾️ Forever | ♾️ Forever | ⏱️ Temporary | ⏱️ Temporary | ⏱️ Temporary |
| **Auto-Destroy** | ❌ No | ❌ No | ✅ Yes (idle) | ✅ Yes (idle) | ✅ Yes (idle) |

---

## 🎯 **The Three Types of QUAD Agents (Detailed)**

### **Type 1: Pure Static Agent**
**No modification ability. Does one thing forever.**

```python
# Example: File Watcher Agent
class FileWatcherAgent(QUADAgent):
    """
    Watches a folder, sends notification when file created.
    Cannot heal, cannot generate, cannot modify itself.
    """

    def __init__(self):
        super().__init__(
            agent_id="file-watcher-001",
            agent_type="file_watcher",
            port=None,  # No HTTP server needed
            capabilities=[]  # No special capabilities
        )

    def execute_task(self, **kwargs):
        # Static code - never changes
        folder = kwargs.get("folder", "/tmp/watch")
        pattern = kwargs.get("pattern", "*.txt")

        files = glob.glob(f"{folder}/{pattern}")

        if len(files) > 0:
            # Found files, send notification via SUMA WIRE
            self.talk_to_agent("email", {
                "to": "user@example.com",
                "subject": f"Found {len(files)} files",
                "body": f"Files: {files}"
            })

        return {"success": True, "data": {"files_found": len(files)}}

    def _get_pretext(self):
        return "NO PRETEXT - Pure static agent"

    def self_heal(self, error):
        # Override to disable
        return {"healed": False, "error": "Static agent cannot heal"}
```

**When to use:**
- Simple, unchanging tasks
- High security requirements (immutable code)
- Temporary one-time tasks

---

### **Type 2: Self-Healing Agent**
**Can rewrite 2-3 functions when external APIs change.**

```python
# Example: Weather Notification Agent
class WeatherAgent(QUADAgent):
    """
    Fetches weather, sends notification if rain expected.
    CAN heal if weather API changes.
    """

    def __init__(self):
        super().__init__(
            agent_id="weather-001",
            agent_type="weather",
            port=5100,
            capabilities=["self_heal"]
        )

    def execute_task(self, **kwargs):
        location = kwargs.get("location", "San Francisco")

        # Call healable function
        weather = self._fetch_weather(location)

        if weather.get("condition") == "rain":
            # Send notification
            self.talk_to_agent("email", {
                "to": "user@example.com",
                "subject": "Rain Alert!",
                "body": f"It's going to rain in {location}"
            })

        return {"success": True, "data": weather}

    # PRETEXT: AI can modify this function ONLY
    # RESTRICTIONS:
    # - Must use WeatherAPI.com or OpenWeatherMap.org
    # - Timeout must be <= 5 seconds
    # - Return format: {"temperature": float, "condition": str, "humidity": int}
    def _fetch_weather(self, location: str) -> Dict[str, Any]:
        response = requests.get(
            "https://api.weatherapi.com/v1/current.json",
            params={"key": self.config.get("api_key"), "q": location},
            timeout=5
        )

        data = response.json()

        return {
            "temperature": data["current"]["temp_f"],
            "condition": data["current"]["condition"]["text"].lower(),
            "humidity": data["current"]["humidity"]
        }

    def _get_pretext(self):
        return """
        PRETEXT: Weather Agent

        AI can modify ONLY:
        1. _fetch_weather() method

        RESTRICTIONS:
        - Allowed APIs: weatherapi.com, openweathermap.org
        - Timeout: <= 5 seconds
        - Return format: {"temperature": float, "condition": str, "humidity": int}
        - No other code can be modified
        """
```

**When to use:**
- Tasks that interact with external APIs
- APIs that might change (version updates)
- Need reliability but some flexibility

**What happens when API changes:**
1. WeatherAPI.com updates from `/v1/` to `/v2/`
2. Agent gets 404 error
3. Agent calls `SUMA API /api/agent/fix`
4. SUMA AI analyzes PRETEXT, generates fix
5. Agent applies fix (updates URL to `/v2/`)
6. Agent retries successfully
7. Solution saved to healing log (instant next time)

---

### **Type 3: Generator Agent**
**Can create Type 1 or Type 2 agents (with restrictions).**

```python
# Example: Robo Dog App (Specialized Agent that can generate helpers)
class RoboDogApp(QUADAgent):
    """
    iOS app that controls a robo dog.
    Can generate helper agents (Bluetooth, Camera, etc.)
    """

    def __init__(self):
        super().__init__(
            agent_id="robo-dog-app-001",
            agent_type="robo_dog_controller",
            port=5200,
            capabilities=["self_heal", "generate_agent"]
        )

        # Restrictions on what this app can generate
        self.generation_restrictions = {
            "allowed_types": ["static", "self_healing"],  # No generators
            "max_agents": 3,  # Can create 3 helpers max
            "allowed_apis": ["bluetooth_le", "camera"],  # Whitelist
            "allowed_commands": ["forward", "backward", "sit", "stay"],
            "max_speed": 5,  # Safety limit
            "auto_destroy": True  # Helpers die when app closes
        }

        self.generated_agents = []  # Track helpers

    def execute_task(self, **kwargs):
        command = kwargs.get("command")

        if command == "connect_dog":
            # Generate Bluetooth agent if not exists
            if not self._has_agent("bluetooth"):
                return self._generate_bluetooth_agent()

        elif command == "start_camera":
            # Generate Camera agent if not exists
            if not self._has_agent("camera"):
                return self._generate_camera_agent()

        elif command in ["forward", "backward", "sit", "stay"]:
            # Use Bluetooth agent to send command
            return self.talk_to_agent("bluetooth", {
                "command": command,
                "params": kwargs.get("params", {})
            })

        else:
            return {"success": False, "error": "Unknown command"}

    def _generate_bluetooth_agent(self):
        """Generate a Bluetooth LE agent"""

        if len(self.generated_agents) >= self.generation_restrictions["max_agents"]:
            return {"success": False, "error": "Max agents reached"}

        # Call SUMA to generate agent
        result = requests.post(
            f"{self.suma_api_url}/api/agent/generate",
            json={
                "creator_agent_id": self.agent_id,
                "agent_type": "bluetooth_le",
                "task_description": "Control robo dog via Bluetooth LE",
                "restrictions": {
                    "protocol": "bluetooth_le",
                    "allowed_commands": self.generation_restrictions["allowed_commands"],
                    "max_speed": self.generation_restrictions["max_speed"],
                    "auto_destroy": {
                        "on": "parent_destroy",
                        "parent_agent_id": self.agent_id
                    }
                },
                "language": "python",
                "include_self_healing": True
            },
            timeout=30
        )

        if result.status_code == 200:
            agent_data = result.json()["data"]
            self.generated_agents.append(agent_data["agent_id"])

            # TODO: Actually deploy the agent
            # For POC, just return the code
            return {
                "success": True,
                "data": {
                    "agent_id": agent_data["agent_id"],
                    "code": agent_data["code"],
                    "message": "Bluetooth agent generated"
                }
            }
        else:
            return {"success": False, "error": "Failed to generate agent"}

    def _generate_camera_agent(self):
        """Generate a Camera agent (similar to Bluetooth)"""
        # Similar implementation...
        pass

    def _has_agent(self, agent_type: str) -> bool:
        """Check if helper agent exists"""
        return any(agent_type in agent_id for agent_id in self.generated_agents)

    def _get_pretext(self):
        return """
        PRETEXT: Robo Dog Controller App

        Can generate:
        - Type 1 (static) or Type 2 (self-healing) agents only
        - Maximum 3 helper agents
        - Allowed APIs: bluetooth_le, camera

        Cannot generate:
        - Type 3 (generator) agents
        - Agents with unrestricted API access
        - Agents that persist after this app closes

        All generated agents:
        - Auto-destroy when parent destroys
        - Must follow safety restrictions (max_speed, allowed_commands)
        - Cannot modify parent app
        """
```

**When to use:**
- Complex apps that need helper agents
- Dynamic workloads (create agent when needed)
- Resource optimization (destroy when done)

**Example scenario:**
1. User opens Robo Dog app
2. User clicks "Connect to Dog"
3. App generates Bluetooth agent (Type 2, self-healing)
4. User clicks "Start Camera"
5. App generates Camera agent (Type 1, static)
6. Both agents run in background
7. User closes app
8. Both helper agents auto-destroy

---

## 🔄 **Agent Pooling: How SUMA Manages Instances**

### **Scenario 1: First Request (No Pool)**

```
User → SUMA API → "I need weather agent"
                   │
                   ├─ Check pool: EMPTY
                   ├─ Check database: NOT FOUND
                   │
                   └─ Create new instance:
                      1. Generate code via AI
                      2. Write to file
                      3. Start process (port 5100)
                      4. Register in database
                      5. Add to pool

                   ✅ Return: weather agent instance
```

### **Scenario 2: Second Request (Pool Hit)**

```
Another User → SUMA API → "I need weather agent"
                           │
                           ├─ Check pool: FOUND!
                           │   └─ Status: idle ✅
                           │
                           ├─ Mark as busy
                           └─ Return existing instance (5ms, not 5s!)
```

### **Scenario 3: All Busy (Create New)**

```
Many Users → SUMA API → "I need weather agent"
                         │
                         ├─ Check pool: 3 instances
                         │   ├─ Instance 1: busy
                         │   ├─ Instance 2: busy
                         │   └─ Instance 3: busy
                         │
                         ├─ Current count: 3
                         ├─ Max allowed: 5
                         │
                         └─ Create instance 4 ✅

                         (If max reached, wait for one to become idle)
```

### **Scenario 4: Cleanup (Idle Too Long)**

```
Cleanup Task (runs every minute)
│
├─ Check all instances:
│  ├─ Instance 1: last_used 2 mins ago → Keep
│  ├─ Instance 2: last_used 8 mins ago → DESTROY
│  └─ Instance 3: last_used 1 min ago → Keep
│
└─ Destroy Instance 2:
   1. Call /destroy endpoint
   2. Update database (status = 'destroyed')
   3. Remove from pool

Keep minimum instances (e.g., 1) always alive
```

---

## 📝 **Summary: Who Can Generate What?**

```
SUMA (God)
├─ Can generate: Specialized Agents (unlimited)
├─ Can generate: Type 1, 2, 3 QUAD Agents (unlimited)
└─ Powers: Full access to everything

Specialized Agent (e.g., Robo Dog App)
├─ Can generate: Type 1 QUAD Agents (limited)
├─ Can generate: Type 2 QUAD Agents (limited)
├─ Cannot generate: Type 3 QUAD Agents ❌
├─ Cannot generate: Specialized Agents ❌
└─ Powers: Limited by restrictions

Type 1 QUAD Agent (Static)
├─ Can generate: Nothing ❌
├─ Can self-heal: No ❌
└─ Powers: Execute task only

Type 2 QUAD Agent (Self-Healing)
├─ Can generate: Nothing ❌
├─ Can self-heal: Yes (2-3 functions) ✅
└─ Powers: Execute + heal

Type 3 QUAD Agent (Generator)
├─ Can generate: Type 1 QUAD Agents ✅
├─ Can generate: Type 2 QUAD Agents ✅
├─ Cannot generate: Type 3 QUAD Agents ❌ (no recursion)
├─ Cannot generate: Specialized Agents ❌
└─ Powers: Execute + heal + generate (limited)
```

---

## 🎯 **Real-World Example: Complete Flow**

**User Goal:** "I want a smart home app that plays music when I come home"

### **Step 1: SUMA Generates Specialized Agent**
```
User → SUMA API → "Build smart home app with music automation"
                   │
                   └─ SUMA AI:
                      1. Understands requirements
                      2. Generates iOS app code (Specialized Agent)
                      3. Includes QUAD SDK
                      4. Deploys to App Store (or TestFlight)
```

### **Step 2: User Installs & Opens App**
```
User opens app → App initializes
                 │
                 ├─ Registers as agent (agent_id: "smart-home-app-user123")
                 ├─ Discovers user's devices (Alexa, Google Home)
                 └─ Ready to receive commands
```

### **Step 3: User Configures Automation**
```
User: "Play music when I arrive home"
      │
      └─ App generates Geofence Agent (Type 2):
         - Monitors user location
         - Triggers when entering home zone
         - Can heal if Location API changes
```

### **Step 4: Automation Triggers**
```
User enters home geofence
      │
      ├─ Geofence Agent detects arrival
      │
      └─ Calls Smart Home App (via SUMA WIRE):
         {
           "command": "play_music",
           "params": {"playlist": "Welcome Home"}
         }
```

### **Step 5: App Executes Command**
```
Smart Home App receives command
      │
      ├─ Queries database for user's music devices
      ├─ Finds: "Alexa Living Room"
      │
      └─ Calls Alexa Agent (via SUMA WIRE):
         {
           "device_id": "alexa-living-001",
           "command": "play_music",
           "params": {"playlist": "Welcome Home"}
         }
```

### **Step 6: Music Plays**
```
Alexa Agent receives command
      │
      ├─ Calls Amazon Alexa API
      └─ Music starts playing ✅
```

---

**Copyright © 2026 Gopi Suman Addanke. All Rights Reserved.**
**Patent Pending: 63/956,810**
