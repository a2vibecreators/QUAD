# QUAD Agent - Universal Class Definition

**Patent Pending: 63/956,810**
**Author: Gopi Suman Addanke**
**Date: January 11, 2026**

---

## Core Concept

**Every program can be an agent.** An agent is just a class with specific capabilities.

```
┌─────────────────────────────────────────────────────────┐
│                    QUAD AGENT                           │
│                  (Universal Class)                      │
├─────────────────────────────────────────────────────────┤
│  CAPABILITIES (Built-in Methods):                       │
│                                                         │
│  1. self_heal()        - Fix own functions             │
│  2. generate_agent()   - Create other agents           │
│  3. talk_to_agent()    - Agent-to-agent communication  │
│  4. self_destroy()     - Terminate based on trigger    │
│  5. update_self()      - Modify own code               │
│  6. get_status()       - Report health/state           │
│  7. register()         - Register with SUMA WIRE       │
│  8. execute_task()     - Do the actual work            │
└─────────────────────────────────────────────────────────┘
```

---

## Agent Communication Modes

### Mode 1: Through SUMA Server (SUMA WIRE)
- Agent doesn't know where other agent lives
- Calls SUMA API: `call_agent("email_agent", {...})`
- SUMA routes the request
- Works across networks, languages, platforms

### Mode 2: Direct Agent-to-Agent
- Agent knows other agent's address (IP:port or process ID)
- Direct socket/IPC/HTTP call
- Faster, but requires discovery
- Use when agents are on same machine/network

---

## Universal Agent Class

### Python Reference Implementation

**Note:** This is the Python version. The SAME class structure applies to:
- **Swift** (iOS/macOS agents)
- **Java** (Android/server agents)
- **TypeScript** (Web/Node.js agents)
- **Kotlin** (Android agents)

The **interface is language-agnostic** - all agents have the same capabilities regardless of language.

```python
from abc import ABC, abstractmethod
from typing import Any, Dict, Optional, Callable
import requests
import json
from datetime import datetime
from flask import Flask, request, jsonify
import threading
import time
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class QUADAgent(ABC):
    """
    Universal QUAD Agent Base Class

    Every agent inherits from this and implements execute_task()
    All other capabilities are built-in.
    """

    def __init__(self,
                 agent_id: str,
                 agent_type: str,
                 suma_api_url: str = "https://asksuma.ai/api",
                 config_path: Optional[str] = None,
                 port: Optional[int] = None,
                 trigger: Optional[Dict[str, Any]] = None):
        """
        Initialize agent

        Args:
            agent_id: Unique identifier for this agent
            agent_type: Type of agent (weather, email, data_fetcher, etc.)
            suma_api_url: SUMA server URL for agent-to-agent routing
            config_path: Path to agent configuration file
            port: Port for HTTP endpoint (None = no endpoint)
            trigger: Trigger configuration (time, event, file_watch, http)
        """
        self.agent_id = agent_id
        self.agent_type = agent_type
        self.suma_api_url = suma_api_url
        self.config = self._load_config(config_path) if config_path else {}
        self.healing_log_path = f"{agent_id}_healing.json"
        self.healing_log = self._load_healing_log()
        self.status = "initialized"
        self.created_at = datetime.now()
        self.last_run = None
        self.error_count = 0
        self.success_count = 0

        # HTTP endpoint for receiving calls
        self.port = port
        self.endpoint = f"http://localhost:{port}" if port else None
        self.app = None
        self.server_thread = None

        # Trigger configuration
        self.trigger = trigger or {}
        self.trigger_active = False
        self.trigger_thread = None

    # ============================================
    # CAPABILITY 1: SELF-HEALING
    # ============================================

    def run(self) -> Dict[str, Any]:
        """
        Run agent with automatic self-healing
        """
        try:
            self.status = "running"
            result = self.execute_task()
            self.status = "success"
            self.success_count += 1
            self.last_run = datetime.now()
            return {"success": True, "result": result}
        except Exception as error:
            self.status = "error"
            self.error_count += 1
            return self.self_heal(error)

    def self_heal(self, error: Exception) -> Dict[str, Any]:
        """
        Automatic error recovery with AI assistance

        Flow:
        1. Check healing log for known solution
        2. If found, apply it
        3. If not, ask SUMA for help
        4. Save solution to healing log
        5. Retry task
        """
        error_type = type(error).__name__
        error_msg = str(error)

        print(f"[{self.agent_id}] ERROR: {error_type} - {error_msg}")
        print(f"[{self.agent_id}] Initiating self-heal...")

        # Check if we've seen this error before
        past_solution = self._check_healing_log(error_type)

        if past_solution:
            print(f"[{self.agent_id}] Found known solution in healing log")
            return self._apply_solution(past_solution)
        else:
            print(f"[{self.agent_id}] New error - asking SUMA for help")
            return self._ask_suma_for_help(error_type, error_msg)

    def _ask_suma_for_help(self, error_type: str, error_msg: str) -> Dict[str, Any]:
        """
        Call SUMA API to get AI-generated fix
        """
        try:
            response = requests.post(
                f"{self.suma_api_url}/agent/fix",
                json={
                    "agent_id": self.agent_id,
                    "agent_type": self.agent_type,
                    "error_type": error_type,
                    "error_message": error_msg,
                    "current_code": self._get_current_code(),
                    "pretext": self._get_pretext(),
                    "healing_log": self.healing_log
                },
                timeout=30
            )

            if response.status_code == 200:
                solution = response.json()["data"]
                self._save_to_healing_log(error_type, solution)
                return self._apply_solution(solution)
            else:
                return {
                    "success": False,
                    "error": "SUMA failed to provide solution",
                    "details": response.text
                }
        except Exception as e:
            return {
                "success": False,
                "error": "Failed to contact SUMA",
                "details": str(e)
            }

    def _apply_solution(self, solution: Dict[str, Any]) -> Dict[str, Any]:
        """
        Apply SUMA's solution (update code if needed, retry task)
        """
        if solution.get("code_update"):
            print(f"[{self.agent_id}] Applying code update...")
            self.update_self(solution["code_update"])

        if solution.get("config_update"):
            print(f"[{self.agent_id}] Updating configuration...")
            self.config.update(solution["config_update"])

        # Retry task
        print(f"[{self.agent_id}] Retrying task...")
        try:
            result = self.execute_task()
            self.status = "recovered"
            return {"success": True, "result": result, "recovered": True}
        except Exception as e:
            return {
                "success": False,
                "error": "Recovery failed",
                "details": str(e)
            }

    # ============================================
    # CAPABILITY 2: AGENT GENERATION
    # ============================================

    def generate_agent(self,
                      agent_type: str,
                      task_description: str,
                      restrictions: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Generate a new QUAD agent with restrictions

        Args:
            agent_type: Type of agent to create (weather, email, etc.)
            task_description: What the agent should do
            restrictions: Limitations on what agent can modify/access

        Returns:
            Generated agent info (agent_id, code, config)
        """
        try:
            response = requests.post(
                f"{self.suma_api_url}/agent/generate",
                json={
                    "creator_agent_id": self.agent_id,
                    "agent_type": agent_type,
                    "task_description": task_description,
                    "restrictions": restrictions or {},
                    "include_self_healing": True
                },
                timeout=60
            )

            if response.status_code == 200:
                return response.json()["data"]
            else:
                return {
                    "success": False,
                    "error": "Failed to generate agent",
                    "details": response.text
                }
        except Exception as e:
            return {
                "success": False,
                "error": "Failed to contact SUMA",
                "details": str(e)
            }

    # ============================================
    # CAPABILITY 3: AGENT-TO-AGENT COMMUNICATION
    # ============================================

    def talk_to_agent(self,
                     agent_name: str,
                     params: Dict[str, Any],
                     mode: str = "wire") -> Dict[str, Any]:
        """
        Talk to another agent

        Args:
            agent_name: Target agent identifier
            params: Parameters to send
            mode: "wire" (through SUMA) or "direct" (peer-to-peer)

        Returns:
            Response from target agent
        """
        if mode == "wire":
            return self._talk_via_suma_wire(agent_name, params)
        elif mode == "direct":
            return self._talk_direct(agent_name, params)
        else:
            raise ValueError(f"Unknown communication mode: {mode}")

    def _talk_via_suma_wire(self, agent_name: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Route through SUMA WIRE (server-based routing)
        """
        try:
            response = requests.post(
                f"{self.suma_api_url}/agent/call",
                json={
                    "caller_agent_id": self.agent_id,
                    "target_agent_name": agent_name,
                    "params": params
                },
                timeout=30
            )

            if response.status_code == 200:
                return response.json()["data"]
            else:
                return {
                    "success": False,
                    "error": "Agent call failed",
                    "details": response.text
                }
        except Exception as e:
            return {
                "success": False,
                "error": "Failed to contact SUMA WIRE",
                "details": str(e)
            }

    def _talk_direct(self, agent_address: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Direct agent-to-agent communication (if agent address is known)
        """
        try:
            # Direct HTTP call to agent's endpoint
            response = requests.post(
                f"{agent_address}/execute",
                json=params,
                timeout=30
            )
            return response.json()
        except Exception as e:
            return {
                "success": False,
                "error": "Direct agent call failed",
                "details": str(e)
            }

    # ============================================
    # CAPABILITY 4: SELF-DESTROY
    # ============================================

    def self_destroy(self, reason: str = "Task completed") -> None:
        """
        Self-destruct based on trigger or event

        Use cases:
        - One-time task completed
        - Error threshold exceeded
        - Triggered by another agent
        - Scheduled termination
        """
        print(f"[{self.agent_id}] Self-destructing: {reason}")

        # Notify SUMA before destruction
        try:
            requests.post(
                f"{self.suma_api_url}/agent/destroyed",
                json={
                    "agent_id": self.agent_id,
                    "reason": reason,
                    "stats": {
                        "success_count": self.success_count,
                        "error_count": self.error_count,
                        "created_at": self.created_at.isoformat(),
                        "destroyed_at": datetime.now().isoformat()
                    }
                },
                timeout=5
            )
        except:
            pass  # Don't let notification failure prevent destruction

        # Cleanup
        self.status = "destroyed"
        # Delete own files, close connections, etc.
        # In production, this would actually terminate the process

    # ============================================
    # CAPABILITY 5: SELF-MODIFICATION
    # ============================================

    def update_self(self, new_code: str) -> None:
        """
        Update own code (only AI-modifiable sections)

        IMPORTANT: Only sections marked with PRETEXT can be modified
        """
        import importlib
        import sys

        # Read current file
        current_file = sys.modules[self.__class__.__module__].__file__
        with open(current_file, 'r') as f:
            current_code = f.read()

        # Replace ONLY the AI-modifiable section
        # Section marked with: # PRETEXT: ... # END_PRETEXT
        updated_code = self._safe_code_replacement(current_code, new_code)

        # Write back
        with open(current_file, 'w') as f:
            f.write(updated_code)

        # Reload module
        importlib.reload(sys.modules[self.__class__.__module__])

        print(f"[{self.agent_id}] Code updated successfully")

    def _safe_code_replacement(self, current_code: str, new_code: str) -> str:
        """
        Safely replace only AI-modifiable sections
        """
        # Find sections marked with PRETEXT
        import re
        pattern = r'# PRETEXT:.*?# END_PRETEXT'

        def replace_match(match):
            return new_code

        return re.sub(pattern, replace_match, current_code, flags=re.DOTALL)

    # ============================================
    # CAPABILITY 6: STATUS REPORTING
    # ============================================

    def get_status(self) -> Dict[str, Any]:
        """
        Report current agent status
        """
        return {
            "agent_id": self.agent_id,
            "agent_type": self.agent_type,
            "status": self.status,
            "created_at": self.created_at.isoformat(),
            "last_run": self.last_run.isoformat() if self.last_run else None,
            "success_count": self.success_count,
            "error_count": self.error_count,
            "health": "healthy" if self.error_count == 0 else "degraded" if self.error_count < 5 else "critical"
        }

    # ============================================
    # CAPABILITY 7: REGISTRATION
    # ============================================

    def register(self) -> Dict[str, Any]:
        """
        Register with SUMA WIRE for agent discovery
        """
        try:
            response = requests.post(
                f"{self.suma_api_url}/agent/register",
                json={
                    "agent_id": self.agent_id,
                    "agent_type": self.agent_type,
                    "capabilities": self._get_capabilities(),
                    "endpoint": self._get_endpoint() if hasattr(self, 'endpoint') else None
                },
                timeout=10
            )

            if response.status_code == 200:
                print(f"[{self.agent_id}] Registered with SUMA WIRE")
                return response.json()["data"]
            else:
                print(f"[{self.agent_id}] Registration failed: {response.text}")
                return {"success": False}
        except Exception as e:
            print(f"[{self.agent_id}] Registration error: {e}")
            return {"success": False, "error": str(e)}

    # ============================================
    # ABSTRACT METHOD (Must be implemented by each agent)
    # ============================================

    @abstractmethod
    def execute_task(self) -> Any:
        """
        The actual work this agent does

        MUST be implemented by each specific agent type

        This is where you put your agent's logic:
        - Weather agent: fetch weather data
        - Email agent: send email
        - File transfer agent: copy files
        - etc.
        """
        pass

    @abstractmethod
    def _get_pretext(self) -> str:
        """
        Return the PRETEXT for AI modifications

        This tells SUMA what this agent does and what restrictions apply
        when modifying code.
        """
        pass

    # ============================================
    # UTILITY METHODS
    # ============================================

    def _load_config(self, path: str) -> Dict[str, Any]:
        try:
            with open(path, 'r') as f:
                return json.load(f)
        except:
            return {}

    def _load_healing_log(self) -> Dict[str, Any]:
        try:
            with open(self.healing_log_path, 'r') as f:
                return json.load(f)
        except:
            return {}

    def _save_to_healing_log(self, error_type: str, solution: Dict[str, Any]) -> None:
        self.healing_log[error_type] = {
            "solution": solution,
            "timestamp": datetime.now().isoformat(),
            "success_count": 1
        }
        with open(self.healing_log_path, 'w') as f:
            json.dump(self.healing_log, f, indent=2)

    def _check_healing_log(self, error_type: str) -> Optional[Dict[str, Any]]:
        return self.healing_log.get(error_type, {}).get("solution")

    def _get_current_code(self) -> str:
        import sys
        current_file = sys.modules[self.__class__.__module__].__file__
        with open(current_file, 'r') as f:
            return f.read()

    def _get_capabilities(self) -> list:
        return [
            "self_heal",
            "generate_agent",
            "talk_to_agent",
            "self_destroy",
            "update_self",
            "get_status",
            "register"
        ]

    def _get_endpoint(self) -> Optional[str]:
        """Override this if agent has HTTP endpoint for direct communication"""
        return None
```

---

## Agent Communication Routing

```
┌─────────────────────────────────────────────────────────────────┐
│                      AGENT COMMUNICATION                         │
└─────────────────────────────────────────────────────────────────┘

MODE 1: SUMA WIRE (Through Server)
====================================

Agent A                    SUMA Server                    Agent B
   │                            │                            │
   │  call_agent("email",...)   │                            │
   ├───────────────────────────>│                            │
   │                            │  Find "email" agent        │
   │                            │  Route request             │
   │                            ├───────────────────────────>│
   │                            │                            │
   │                            │         Response           │
   │                            │<───────────────────────────┤
   │         Response           │                            │
   │<───────────────────────────┤                            │
   │                            │                            │

- Agents don't know each other's location
- SUMA handles discovery and routing
- Works across networks/languages


MODE 2: DIRECT (Peer-to-Peer)
==============================

Agent A                                              Agent B
   │                                                    │
   │  talk_to_agent("http://localhost:5000", ...)      │
   ├───────────────────────────────────────────────────>│
   │                                                    │
   │                  Response                          │
   │<───────────────────────────────────────────────────┤
   │                                                    │

- Faster (no routing)
- Requires knowing agent address
- Use when agents are co-located
```

---

## Example: Weather Agent

```python
from quad_agent import QUADAgent

class WeatherAgent(QUADAgent):
    """
    Weather checking agent with self-healing
    """

    def __init__(self):
        super().__init__(
            agent_id="weather-001",
            agent_type="weather",
            suma_api_url="https://asksuma.ai/api"
        )

    # PRETEXT: This function fetches weather data from OpenWeather API.
    # You can ONLY modify:
    # 1. API endpoint URL if API changes
    # 2. Request parameters if API syntax changes
    # 3. Response parsing if response format changes
    # You CANNOT:
    # 1. Change function signature
    # 2. Remove error handling
    # 3. Access other APIs without permission
    def execute_task(self) -> dict:
        import requests

        api_key = self.config.get("weather_api_key")
        city = self.config.get("city", "Hyderabad")

        # Fetch weather
        response = requests.get(
            "https://api.openweathermap.org/data/2.5/weather",
            params={"q": city, "appid": api_key},
            timeout=10
        )

        data = response.json()

        # Check if raining
        is_raining = any(
            weather.get("main") == "Rain"
            for weather in data.get("weather", [])
        )

        if is_raining:
            # Call email agent to notify user
            self.talk_to_agent("email_agent", {
                "to": self.config.get("user_email"),
                "subject": "☔ Rain Alert",
                "body": f"It's raining in {city}!"
            })

        return {
            "city": city,
            "is_raining": is_raining,
            "temp": data.get("main", {}).get("temp")
        }
    # END_PRETEXT

    def _get_pretext(self) -> str:
        return """
        This is a weather checking agent.
        It fetches weather data and sends email if raining.

        Modifiable function: execute_task()

        Allowed modifications:
        - Update API endpoint if OpenWeather changes
        - Update request format if API syntax changes
        - Update response parsing if format changes

        Restrictions:
        - Cannot change function name
        - Cannot remove email notification
        - Cannot access APIs other than OpenWeather
        """
```

---

## Example: iOS App as Agent

```swift
// iOS App that IS an agent and can generate Python helpers

import Foundation

class SumaIOSAgent: QUADAgentProtocol {
    let agentId = "suma-ios-app"
    let agentType = "mobile_controller"
    let sumaApiUrl = "https://asksuma.ai/api"

    // Generate Python helper when needed
    func controlRoboDog(command: String) {
        // Check if we have a robo dog controller agent
        if !hasHelperAgent("robo_dog_controller") {
            // Generate one!
            let restrictions = [
                "allowed_commands": ["forward", "backward", "sit", "stand"],
                "max_speed": 5,
                "protocol": "bluetooth_le"
            ]

            let helper = generateAgent(
                agentType: "robo_dog_controller",
                taskDescription: "Control robo dog via Bluetooth LE",
                restrictions: restrictions
            )

            // Deploy helper (runs in app sandbox or separate process)
            deployHelper(helper)
        }

        // Call helper agent
        let result = talkToAgent("robo_dog_controller", params: [
            "command": command
        ])

        print("Robo dog response: \(result)")
    }
}
```

---

**Copyright © 2026 Gopi Suman Addanke. All Rights Reserved.**
