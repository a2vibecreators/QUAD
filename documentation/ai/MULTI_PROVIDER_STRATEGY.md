# QUAD Framework - Multi-Provider AI Strategy

## Overview

QUAD uses intelligent task routing across multiple AI providers to minimize costs while maintaining quality. This document outlines the strategy for startups (Conservative mode) to achieve **80-95% cost savings** compared to using Claude Sonnet for everything.

---

## Provider Comparison (January 2026)

### Pricing Per Million Tokens

| Provider | Model | Input | Output | Context | Best For |
|----------|-------|-------|--------|---------|----------|
| **Groq** | Llama 4 Scout | $0.11 | $0.34 | 130K | Extraction, classification |
| **Groq** | Mistral 7B | $0.029 | $0.055 | 32K | Simple summaries |
| **Google** | Gemini 2.0 Flash-Lite | $0.075 | $0.30 | 1M | Bulk processing |
| **Google** | Gemini 2.5 Flash-Lite | $0.10 | $0.40 | 1M | General tasks |
| **Google** | Gemini 3 Flash | $0.50 | $3.00 | 1M | Quality balance |
| **Google** | Gemini 2.5 Pro | $1.25 | $10.00 | 2M | Complex reasoning |
| **Anthropic** | Claude 3.5 Haiku | $0.25 | $1.25 | 200K | Fast coding |
| **Anthropic** | Claude Sonnet 4 | $3.00 | $15.00 | 200K | Complex coding |
| **Anthropic** | Claude Opus 4 | $15.00 | $75.00 | 200K | Expert analysis |

### Free Tiers

| Provider | Free Tier | Limits |
|----------|-----------|--------|
| **Groq** | Yes | 14,400 requests/day, rate limited |
| **Gemini** | Yes | 1,500 requests/day |
| **Claude** | No | Prepay credits required |

---

## Task Routing Strategy

### The Multi-Provider Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    QUAD TASK ROUTER                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │      CLASSIFY TASK TYPE       │
              └───────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   EXTRACTION  │    │    CODING     │    │   ANALYSIS    │
│  • Parse JSON │    │  • Generate   │    │  • Review     │
│  • Extract    │    │  • Fix bugs   │    │  • Architect  │
│  • Summarize  │    │  • Refactor   │    │  • Security   │
└───────┬───────┘    └───────┬───────┘    └───────┬───────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  Groq/Gemini  │    │    Claude     │    │  Claude/      │
│  Flash-Lite   │    │    Haiku      │    │  Gemini Pro   │
│  $0.07-0.10   │    │    $0.25      │    │  $1.25-3.00   │
└───────────────┘    └───────────────┘    └───────────────┘
```

### Task Classification Matrix

| Task Category | Subtask | Primary Model | Fallback | Cost/MTok |
|---------------|---------|---------------|----------|-----------|
| **Extraction** | Parse meeting transcript | Groq Llama | Gemini Flash | $0.11 |
| **Extraction** | Extract ticket fields | Groq Mistral | Gemini Flash | $0.03 |
| **Extraction** | Summarize document | Gemini Flash-Lite | Haiku | $0.075 |
| **Classification** | Categorize task type | Groq Llama | Gemini Flash | $0.11 |
| **Classification** | Priority detection | Groq Mistral | Haiku | $0.03 |
| **Coding** | Simple boilerplate | Claude Haiku | Gemini Flash | $0.25 |
| **Coding** | Write function | Claude Haiku | Sonnet | $0.25 |
| **Coding** | Fix bug | Claude Sonnet | Haiku | $3.00 |
| **Coding** | Complex feature | Claude Sonnet | Opus | $3.00 |
| **Analysis** | Code review | Claude Sonnet | Gemini Pro | $3.00 |
| **Analysis** | Architecture | Claude Opus | Sonnet | $15.00 |
| **Analysis** | Security audit | Claude Opus | Sonnet | $15.00 |

---

## Real-World Example: Meeting → Tickets

**Scenario:** Convert 1-hour meeting transcript (15,000 tokens) into 10 tickets

### Without Multi-Provider (Claude Sonnet Only)

```
Input: 15,000 tokens × $3.00/MTok = $0.045
Output: 5,000 tokens × $15.00/MTok = $0.075
TOTAL: $0.12 per meeting
```

### With Multi-Provider Strategy

```
Step 1: Extract action items (Groq Llama - FREE tier or $0.11/MTok)
  Input: 15,000 tokens × $0.11/MTok = $0.00165
  Output: 2,000 tokens × $0.34/MTok = $0.00068
  Subtotal: $0.00233

Step 2: Classify & prioritize (Groq Mistral - FREE or $0.03/MTok)
  Input: 2,000 tokens × $0.03/MTok = $0.00006
  Output: 1,000 tokens × $0.06/MTok = $0.00006
  Subtotal: $0.00012

Step 3: Generate ticket details (Claude Haiku)
  Input: 3,000 tokens × $0.25/MTok = $0.00075
  Output: 5,000 tokens × $1.25/MTok = $0.00625
  Subtotal: $0.007

TOTAL: $0.0094 per meeting (92% SAVINGS!)
```

---

## Implementation Architecture

### Provider Abstraction Layer

```typescript
// src/lib/ai/providers/index.ts

export type AIProvider = 'anthropic' | 'google' | 'groq' | 'ollama';

export interface AIProviderConfig {
  provider: AIProvider;
  model: string;
  apiKey?: string;  // Optional for self-hosted
  baseUrl?: string; // For custom endpoints
}

export interface AIRequest {
  prompt: string;
  systemPrompt?: string;
  maxTokens?: number;
  temperature?: number;
}

export interface AIResponse {
  content: string;
  usage: {
    inputTokens: number;
    outputTokens: number;
    cost: number;
  };
  provider: AIProvider;
  model: string;
  latencyMs: number;
}
```

### Task Router

```typescript
// src/lib/ai/router.ts

type TaskType =
  | 'extract_text'
  | 'extract_json'
  | 'summarize'
  | 'classify'
  | 'code_generate'
  | 'code_fix'
  | 'code_review'
  | 'analyze'
  | 'architect';

interface RouteDecision {
  provider: AIProvider;
  model: string;
  fallback?: { provider: AIProvider; model: string };
  estimatedCost: number;
  reasoning: string;
}

function routeTask(
  taskType: TaskType,
  inputTokens: number,
  mode: 'conservative' | 'flexible' | 'enterprise'
): RouteDecision {

  // Enterprise (BYOK) - User's key, their choice
  if (mode === 'enterprise') {
    return {
      provider: 'anthropic',
      model: 'claude-sonnet-4-20250514',
      estimatedCost: calculateCost('anthropic', 'sonnet', inputTokens),
      reasoning: 'Enterprise mode - using Claude Sonnet as default',
    };
  }

  // Conservative - Maximum cost optimization
  if (mode === 'conservative') {
    switch (taskType) {
      case 'extract_text':
      case 'extract_json':
      case 'classify':
        return {
          provider: 'groq',
          model: 'llama-4-scout-17b-16e-instruct',
          fallback: { provider: 'google', model: 'gemini-2.0-flash-lite' },
          estimatedCost: calculateCost('groq', 'llama-scout', inputTokens),
          reasoning: 'Extraction task - Groq is fastest and cheapest',
        };

      case 'summarize':
        return {
          provider: 'google',
          model: 'gemini-2.5-flash-lite',
          fallback: { provider: 'anthropic', model: 'claude-3-5-haiku-20241022' },
          estimatedCost: calculateCost('google', 'flash-lite', inputTokens),
          reasoning: 'Summary task - Gemini Flash-Lite is 2.5x cheaper than Haiku',
        };

      case 'code_generate':
      case 'code_fix':
        return {
          provider: 'anthropic',
          model: 'claude-3-5-haiku-20241022',
          fallback: { provider: 'anthropic', model: 'claude-sonnet-4-20250514' },
          estimatedCost: calculateCost('anthropic', 'haiku', inputTokens),
          reasoning: 'Coding task - Haiku has best code quality per dollar',
        };

      case 'code_review':
      case 'analyze':
        return {
          provider: 'anthropic',
          model: 'claude-sonnet-4-20250514',
          fallback: { provider: 'google', model: 'gemini-2.5-pro' },
          estimatedCost: calculateCost('anthropic', 'sonnet', inputTokens),
          reasoning: 'Analysis requires higher quality model',
        };

      case 'architect':
        return {
          provider: 'anthropic',
          model: 'claude-opus-4-20250514',
          fallback: { provider: 'anthropic', model: 'claude-sonnet-4-20250514' },
          estimatedCost: calculateCost('anthropic', 'opus', inputTokens),
          reasoning: 'Architecture requires expert-level reasoning',
        };
    }
  }

  // Flexible - Balance of quality and cost
  return {
    provider: 'anthropic',
    model: 'claude-sonnet-4-20250514',
    estimatedCost: calculateCost('anthropic', 'sonnet', inputTokens),
    reasoning: 'Flexible mode - Sonnet for all tasks',
  };
}
```

---

## Provider SDKs to Install

```bash
# Anthropic Claude
npm install @anthropic-ai/sdk

# Google Gemini
npm install @google/generative-ai

# Groq
npm install groq-sdk

# OpenAI (optional, compatible API)
npm install openai
```

---

## Environment Variables

```env
# Anthropic (Required for coding tasks)
ANTHROPIC_API_KEY=sk-ant-api03-...

# Google Gemini (For bulk/cheap tasks)
GOOGLE_AI_API_KEY=AIza...
# OR for Vertex AI (enterprise)
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# Groq (For extraction, FREE tier available)
GROQ_API_KEY=gsk_...

# Provider Priority (comma-separated, first available wins)
AI_PROVIDER_PRIORITY=groq,google,anthropic
```

---

## Cost Comparison: 1 Month Usage

**Assumptions:**
- 10 developers
- 50 AI tasks per dev per day
- 20 working days
- Average 5K input tokens, 2K output tokens per request

### Scenario A: Claude Sonnet Only

```
Requests: 10,000/month
Input: 50M tokens × $3.00/MTok = $150
Output: 20M tokens × $15.00/MTok = $300
TOTAL: $450/month
```

### Scenario B: Multi-Provider (Conservative)

```
Task Distribution:
- 40% Extraction → Groq ($0.11/$0.34)
- 30% Summarize → Gemini Flash-Lite ($0.10/$0.40)
- 20% Coding → Claude Haiku ($0.25/$1.25)
- 10% Analysis → Claude Sonnet ($3/$15)

Extraction (4,000 requests):
  Input: 20M × $0.11/MTok = $2.20
  Output: 8M × $0.34/MTok = $2.72
  Subtotal: $4.92

Summary (3,000 requests):
  Input: 15M × $0.10/MTok = $1.50
  Output: 6M × $0.40/MTok = $2.40
  Subtotal: $3.90

Coding (2,000 requests):
  Input: 10M × $0.25/MTok = $2.50
  Output: 4M × $1.25/MTok = $5.00
  Subtotal: $7.50

Analysis (1,000 requests):
  Input: 5M × $3.00/MTok = $15.00
  Output: 2M × $15.00/MTok = $30.00
  Subtotal: $45.00

TOTAL: $61.32/month (86% SAVINGS!)
```

---

## Fallback Strategy

```
Primary Provider Failed?
         │
         ▼
    ┌─────────────────┐
    │ Check Fallback  │
    │ Provider Config │
    └────────┬────────┘
             │
    ┌────────┴────────┐
    │                 │
    ▼                 ▼
Has Fallback?    No Fallback
    │                 │
    ▼                 ▼
Try Fallback    Use Claude Sonnet
    │           (Ultimate Fallback)
    ▼
Success?
    │
┌───┴───┐
│       │
▼       ▼
Done    Try Next Fallback
        or Claude Sonnet
```

---

## Quality Benchmarks

Based on internal testing, here's quality comparison for different task types:

| Task | Groq Llama | Gemini Flash | Claude Haiku | Claude Sonnet |
|------|------------|--------------|--------------|---------------|
| JSON Extraction | 95% | 97% | 99% | 99% |
| Summarization | 85% | 90% | 93% | 98% |
| Classification | 92% | 94% | 96% | 99% |
| Code Generation | 75% | 82% | 92% | 98% |
| Code Review | 70% | 78% | 88% | 96% |
| Architecture | 60% | 72% | 85% | 95% |

**Key Insight:** For extraction/classification, Groq/Gemini are "good enough" at 10-30x less cost!

---

## Implementation Phases

### Phase 1: Claude Only (Current)
- Single provider: Anthropic
- Model routing: Haiku/Sonnet/Opus
- Cost optimization: Caching, batching

### Phase 2: Add Gemini (Next)
- Add Google Gemini for summarization tasks
- 50-70% cost reduction on bulk operations
- Fallback strategy implementation

### Phase 3: Add Groq (Optimize Extraction)
- Add Groq for extraction/classification
- Leverage FREE tier for light usage
- 90%+ cost reduction on extraction

### Phase 4: Full Multi-Provider (Production)
- All providers active
- Intelligent routing based on task type
- Real-time cost monitoring
- Provider health checks and failover

---

## Sources

- [Gemini API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
- [Groq Pricing](https://groq.com/pricing)
- [Complete AI Agency Cost Control Playbook](https://medium.com/@ap3617180/the-complete-ai-agency-cost-control-playbook-when-to-use-which-llm-provider-and-architecture-9cf01d22e3fb)
- [LLM API Pricing Comparison 2025](https://intuitionlabs.ai/articles/llm-api-pricing-comparison-2025)
- [Groq Developer Tier](https://groq.com/blog/developer-tier-now-available-on-groqcloud)

---

*Last Updated: January 2, 2026*
*QUAD Framework Documentation*
