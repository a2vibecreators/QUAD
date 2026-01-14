# QUAD Core Agent

**Base class for all QUAD agents**
**Patent Pending: 63/956,810**
**Author: Gopi Suman Addanke**
**Date: January 11, 2026**

---

## Overview

**Core Agent** is the base class that all QUAD agents extend. It provides:
- Local-first capability routing
- Caching for performance
- SUMA API integration
- Standard agent interface

---

## Architecture: Local First, API Second

```
┌─────────────────────────────────────────────────────────┐
│                    REQUEST COMES IN                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              CORE AGENT (Base Class)                     │
│                                                          │
│  Step 1: CHECK LOCAL CAPABILITIES                        │
│  ┌────────────────────────────────────────────────┐     │
│  │  ✓ Memory Cache (last 1 hour)                  │     │
│  │  ✓ Config File (local settings)                │     │
│  │  ✓ Healing Log (past solutions)                │     │
│  │  ✓ Local Functions (can I handle this?)        │     │
│  └────────────────────────────────────────────────┘     │
│                     │                                    │
│                     ├─ Found? → Return immediately       │
│                     │                                    │
│                     └─ Not found? → Go to Step 2         │
│                                                          │
│  Step 2: CALL SUMA API                                   │
│  ┌────────────────────────────────────────────────┐     │
│  │  POST /api/agent/execute                        │     │
│  │  POST /api/memory/{userId}                      │     │
│  │  POST /api/agent/fix                            │     │
│  └────────────────────────────────────────────────┘     │
│                     │                                    │
│                     └─ Cache result locally              │
│                                                          │
│  Step 3: RETURN RESULT                                   │
└─────────────────────────────────────────────────────────┘
```

---

## Core Agent Class Structure

### Java Implementation (Reference)

```java
package com.suma.quad;

import java.util.*;
import java.time.Instant;

/**
 * QUAD Core Agent - Base class for all agents
 *
 * Provides:
 * - Local-first capability routing
 * - Memory caching
 * - SUMA API integration
 * - Standard agent interface
 */
public abstract class QUADAgent {

    // ============================================
    // AGENT IDENTITY
    // ============================================

    protected String agentId;
    protected String agentType;
    protected String sumaApiUrl;

    // ============================================
    // LOCAL CACHES (Check here first!)
    // ============================================

    protected MemoryCache memoryCache;
    protected HealingLog healingLog;
    protected ConfigManager config;

    // ============================================
    // STATISTICS
    // ============================================

    protected int successCount = 0;
    protected int errorCount = 0;
    protected int cacheHits = 0;
    protected int apiCalls = 0;
    protected Instant createdAt;
    protected Instant lastRun;

    // ============================================
    // CONSTRUCTOR
    // ============================================

    public QUADAgent(String agentId, String agentType) {
        this(agentId, agentType, "https://asksuma.ai/api");
    }

    public QUADAgent(String agentId, String agentType, String sumaApiUrl) {
        this.agentId = agentId;
        this.agentType = agentType;
        this.sumaApiUrl = sumaApiUrl;
        this.createdAt = Instant.now();

        // Initialize local caches
        this.memoryCache = new MemoryCache(3600); // 1 hour TTL
        this.healingLog = new HealingLog(agentId + "_healing.json");
        this.config = new ConfigManager(agentId + "_config.json");

        // Register with SUMA (optional)
        // register();
    }

    // ============================================
    // MAIN EXECUTION (with local-first routing)
    // ============================================

    /**
     * Execute agent task with automatic capability routing
     *
     * Flow:
     * 1. Check local capabilities first
     * 2. Call SUMA API if needed
     * 3. Cache results
     * 4. Return response
     */
    public AgentResult run(AgentRequest request) {
        try {
            this.lastRun = Instant.now();

            // Route to capability (local first!)
            AgentResult result = routeToCapability(request);

            this.successCount++;
            return result;

        } catch (Exception e) {
            this.errorCount++;
            return selfHeal(e);
        }
    }

    // ============================================
    // CAPABILITY ROUTING (Local → API)
    // ============================================

    /**
     * Route request to appropriate capability
     *
     * Check order:
     * 1. Local cache
     * 2. Local functions
     * 3. SUMA API
     */
    protected AgentResult routeToCapability(AgentRequest request) {
        String capability = detectCapability(request);

        switch (capability) {
            case "memory":
                return handleMemoryCapability(request);

            case "voice":
                return handleVoiceCapability(request);

            case "generation":
                return handleGenerationCapability(request);

            case "custom":
                // Implemented by subclass (Story Agent, etc.)
                return executeTask(request);

            default:
                return AgentResult.error("Unknown capability: " + capability);
        }
    }

    /**
     * Detect which capability is needed
     *
     * Check locally before calling API
     */
    protected String detectCapability(AgentRequest request) {
        String input = request.getInput().toLowerCase();

        // Check locally first (no API call)
        if (containsKeywords(input, "remember", "recall", "memory", "forget")) {
            return "memory";
        }

        if (containsKeywords(input, "speak", "voice", "say", "listen")) {
            return "voice";
        }

        if (containsKeywords(input, "create agent", "generate", "build")) {
            return "generation";
        }

        // Default to custom (subclass handles it)
        return "custom";
    }

    // ============================================
    // MEMORY CAPABILITY (Local → API)
    // ============================================

    /**
     * Handle memory requests
     *
     * Flow:
     * 1. Check local cache (fast!)
     * 2. If miss → Call SUMA API
     * 3. Cache result
     */
    protected AgentResult handleMemoryCapability(AgentRequest request) {
        String userId = request.getUserId();
        String query = request.getInput();

        // STEP 1: CHECK LOCAL CACHE
        Memory cached = memoryCache.get(userId, query);
        if (cached != null && !cached.isExpired()) {
            this.cacheHits++;
            return AgentResult.success(cached)
                .withMetadata("source", "cache")
                .withMetadata("cache_hit", true);
        }

        // STEP 2: CACHE MISS → CALL SUMA API
        this.apiCalls++;

        try {
            // Call SUMA memory API
            String url = sumaApiUrl + "/api/memory/" + userId + "/search?q=" + query;
            Memory result = httpClient.get(url, Memory.class);

            // STEP 3: CACHE IT LOCALLY
            memoryCache.put(userId, query, result);

            return AgentResult.success(result)
                .withMetadata("source", "api")
                .withMetadata("cache_hit", false);

        } catch (Exception e) {
            return AgentResult.error("Failed to fetch memory: " + e.getMessage());
        }
    }

    // ============================================
    // VOICE CAPABILITY (Always API)
    // ============================================

    /**
     * Handle voice requests
     *
     * Always goes to API (no local processing)
     */
    protected AgentResult handleVoiceCapability(AgentRequest request) {
        // Voice processing always requires API
        this.apiCalls++;

        try {
            String url = sumaApiUrl + "/api/voiceprint/process";
            VoiceResult result = httpClient.post(url, request.toJSON(), VoiceResult.class);

            return AgentResult.success(result)
                .withMetadata("source", "api");

        } catch (Exception e) {
            return AgentResult.error("Voice processing failed: " + e.getMessage());
        }
    }

    // ============================================
    // GENERATION CAPABILITY (Always API)
    // ============================================

    /**
     * Handle agent generation requests
     *
     * Always goes to API (requires AI)
     */
    protected AgentResult handleGenerationCapability(AgentRequest request) {
        this.apiCalls++;

        try {
            String url = sumaApiUrl + "/api/agent/generate";
            GenerationRequest genReq = new GenerationRequest()
                .setCreatorAgentId(this.agentId)
                .setTaskDescription(request.getInput());

            GeneratedAgent result = httpClient.post(url, genReq.toJSON(), GeneratedAgent.class);

            return AgentResult.success(result)
                .withMetadata("source", "api");

        } catch (Exception e) {
            return AgentResult.error("Agent generation failed: " + e.getMessage());
        }
    }

    // ============================================
    // SELF-HEALING (Local → API)
    // ============================================

    /**
     * Self-heal when errors occur
     *
     * Flow:
     * 1. Check healing log (local)
     * 2. If found → Apply solution
     * 3. If not found → Ask SUMA API
     * 4. Cache solution
     */
    protected AgentResult selfHeal(Exception error) {
        String errorType = error.getClass().getSimpleName();
        String errorMsg = error.getMessage();

        // STEP 1: CHECK HEALING LOG (LOCAL)
        Solution cached = healingLog.getSolution(errorType);
        if (cached != null) {
            this.cacheHits++;
            return applySolution(cached)
                .withMetadata("healed", true)
                .withMetadata("source", "healing_log");
        }

        // STEP 2: NOT FOUND → ASK SUMA API
        this.apiCalls++;

        try {
            String url = sumaApiUrl + "/api/agent/fix";
            FixRequest fixReq = new FixRequest()
                .setAgentId(this.agentId)
                .setErrorType(errorType)
                .setErrorMessage(errorMsg)
                .setCurrentCode(getCurrentCode())
                .setPretext(getPretext());

            Solution solution = httpClient.post(url, fixReq.toJSON(), Solution.class);

            // STEP 3: CACHE SOLUTION
            healingLog.saveSolution(errorType, solution);

            return applySolution(solution)
                .withMetadata("healed", true)
                .withMetadata("source", "api");

        } catch (Exception e) {
            return AgentResult.error("Self-healing failed: " + e.getMessage());
        }
    }

    // ============================================
    // ABSTRACT METHODS (Subclass implements)
    // ============================================

    /**
     * Execute the agent's main task
     *
     * Implemented by subclasses (Story Agent, etc.)
     */
    protected abstract AgentResult executeTask(AgentRequest request);

    /**
     * Get pretext for AI modifications
     *
     * Describes what this agent does and restrictions
     */
    protected abstract String getPretext();

    // ============================================
    // UTILITIES
    // ============================================

    protected boolean containsKeywords(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    protected String getCurrentCode() {
        // Return source code of this class for AI analysis
        // Implementation depends on language
        return "";
    }

    protected AgentResult applySolution(Solution solution) {
        // Apply code/config updates from solution
        if (solution.hasCodeUpdate()) {
            updateCode(solution.getCodeUpdate());
        }
        if (solution.hasConfigUpdate()) {
            config.update(solution.getConfigUpdate());
        }
        // Retry the task
        return AgentResult.success("Solution applied");
    }

    protected void updateCode(String newCode) {
        // Update own code (only PRETEXT sections)
        // Implementation depends on language
    }

    // ============================================
    // STATISTICS
    // ============================================

    public AgentStats getStats() {
        return new AgentStats()
            .setAgentId(agentId)
            .setAgentType(agentType)
            .setSuccessCount(successCount)
            .setErrorCount(errorCount)
            .setCacheHits(cacheHits)
            .setApiCalls(apiCalls)
            .setCacheHitRate(cacheHits * 100.0 / (cacheHits + apiCalls))
            .setCreatedAt(createdAt)
            .setLastRun(lastRun);
    }
}
```

---

## Supporting Classes

### MemoryCache (Local Storage)

```java
/**
 * Local memory cache to avoid API calls
 *
 * TTL-based expiration (default 1 hour)
 */
public class MemoryCache {
    private Map<String, CachedMemory> cache;
    private long ttlSeconds;

    public MemoryCache(long ttlSeconds) {
        this.cache = new HashMap<>();
        this.ttlSeconds = ttlSeconds;
    }

    public Memory get(String userId, String query) {
        String key = userId + ":" + query;
        CachedMemory cached = cache.get(key);

        if (cached != null && !cached.isExpired(ttlSeconds)) {
            return cached.getMemory();
        }

        return null; // Cache miss
    }

    public void put(String userId, String query, Memory memory) {
        String key = userId + ":" + query;
        cache.put(key, new CachedMemory(memory, Instant.now()));
    }
}
```

### HealingLog (Local Storage)

```java
/**
 * Local log of past error solutions
 *
 * Persisted to disk (JSON file)
 */
public class HealingLog {
    private String filePath;
    private Map<String, Solution> solutions;

    public HealingLog(String filePath) {
        this.filePath = filePath;
        this.solutions = loadFromDisk();
    }

    public Solution getSolution(String errorType) {
        return solutions.get(errorType);
    }

    public void saveSolution(String errorType, Solution solution) {
        solutions.put(errorType, solution);
        saveToDisk();
    }

    private Map<String, Solution> loadFromDisk() {
        // Load JSON file
        return new HashMap<>();
    }

    private void saveToDisk() {
        // Save to JSON file
    }
}
```

### ConfigManager (Local Storage)

```java
/**
 * Local configuration manager
 *
 * Persisted to disk (JSON file)
 */
public class ConfigManager {
    private String filePath;
    private Map<String, Object> config;

    public ConfigManager(String filePath) {
        this.filePath = filePath;
        this.config = loadFromDisk();
    }

    public Object get(String key) {
        return config.get(key);
    }

    public void set(String key, Object value) {
        config.put(key, value);
        saveToDisk();
    }

    public void update(Map<String, Object> updates) {
        config.putAll(updates);
        saveToDisk();
    }
}
```

---

## Performance: Local vs API

### Example: Memory Query

**With Local Cache:**
```
Request → Check cache → Found! → Return (5ms)
✓ Fast!
✓ No API call
✓ No cost
```

**Without Local Cache:**
```
Request → Check cache → Miss → Call API → Wait → Return (500ms)
✗ Slower
✗ API call (costs money)
✗ Network latency
```

### Cache Hit Rate Goal: 80%+

Most common queries should hit cache:
- User profile
- Recent conversations
- Frequent searches

Rare queries go to API:
- First-time searches
- Expired cache (>1 hour old)
- Real-time data

---

## Statistics Tracking

Core Agent tracks:

```java
AgentStats stats = agent.getStats();

// Outputs:
{
  "agent_id": "story-agent-001",
  "agent_type": "story",
  "success_count": 1247,
  "error_count": 3,
  "cache_hits": 1021,
  "api_calls": 226,
  "cache_hit_rate": 81.9, // %
  "created_at": "2026-01-11T10:00:00Z",
  "last_run": "2026-01-11T14:30:25Z"
}
```

**Goal:** Maximize cache hit rate, minimize API calls.

---

## How Story Agent Extends Core Agent

```java
package com.suma.quad.agents;

import com.suma.quad.QUADAgent;
import com.suma.quad.AgentRequest;
import com.suma.quad.AgentResult;

/**
 * Story Agent - Creates stories for children
 *
 * Extends Core Agent with story-specific logic
 */
public class StoryAgent extends QUADAgent {

    public StoryAgent() {
        super("story-agent-001", "story");
    }

    // PRETEXT: Creates stories based on user input
    // Can modify story generation logic
    // Cannot access user's private memories without permission
    @Override
    protected AgentResult executeTask(AgentRequest request) {
        // Story Agent's custom logic
        String topic = request.getInput();
        String story = generateStory(topic);

        return AgentResult.success(story);
    }
    // END_PRETEXT

    @Override
    protected String getPretext() {
        return """
        This is a Story Agent that creates children's stories.

        Allowed modifications:
        - Update story generation logic
        - Update story templates

        Restrictions:
        - Cannot access user's private data
        - Must keep stories child-friendly
        """;
    }

    private String generateStory(String topic) {
        // Story generation logic here
        return "Once upon a time...";
    }
}
```

**Story Agent gets for free:**
- ✅ Local memory caching
- ✅ Self-healing
- ✅ Config management
- ✅ Statistics tracking
- ✅ SUMA API integration

**Story Agent only implements:**
- `executeTask()` - Story generation logic
- `getPretext()` - What AI can modify

---

## Next Steps

1. **Document Story Agent** - Full implementation with examples
2. **Build SUMA API endpoints** - `/api/agent/execute`, `/api/agent/fix`, etc.
3. **Create demo** - Story Agent generating stories with self-healing
4. **Add metrics** - Track cache hit rates, performance

---

**Copyright © 2026 Gopi Suman Addanke. All Rights Reserved.**
