# QUAD Framework - AI Pricing Tiers

## User-Facing Options

When users configure QUAD, they can choose from 4 AI modes:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHOOSE YOUR AI MODE                                  │
│                                                                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────┐ │
│  │  🚀 TURBO       │  │  ⚡ BALANCED    │  │  💎 QUALITY     │  │ 🔑 BYOK │ │
│  │                 │  │                 │  │                 │  │         │ │
│  │  Fastest &      │  │  Best Value     │  │  Best Coding    │  │ Your    │ │
│  │  Cheapest       │  │  Mix            │  │  Results        │  │ Key     │ │
│  │                 │  │                 │  │                 │  │         │ │
│  │  ~$5/dev/mo     │  │  ~$15/dev/mo    │  │  ~$35/dev/mo    │  │ You pay │ │
│  │                 │  │                 │  │                 │  │         │ │
│  │  Groq + Gemini  │  │  Mix of all     │  │  Claude focus   │  │ Direct  │ │
│  │  DeepSeek       │  │  providers      │  │  + fallbacks    │  │         │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  └─────────┘ │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Complete Provider Comparison (January 2026)

### Pricing Per Million Tokens

| Provider | Model | Input | Output | Context | Speed | Coding | Notes |
|----------|-------|-------|--------|---------|-------|--------|-------|
| **Groq** | Llama 4 Scout | $0.11 | $0.34 | 130K | ⚡⚡⚡ | ★★★ | FREE tier! |
| **Groq** | Mistral 7B | $0.03 | $0.06 | 32K | ⚡⚡⚡ | ★★ | Cheapest |
| **Google** | Gemini 2.0 Flash-Lite | $0.075 | $0.30 | 1M | ⚡⚡⚡ | ★★★ | Huge context |
| **Google** | Gemini 2.5 Flash-Lite | $0.10 | $0.40 | 1M | ⚡⚡⚡ | ★★★ | FREE tier |
| **OpenAI** | GPT-4o-mini | $0.15 | $0.60 | 128K | ⚡⚡ | ★★★ | Great value |
| **Mistral** | Codestral | $0.20 | $0.60 | 32K | ⚡⚡ | ★★★★ | Code specialist |
| **xAI** | Grok 4.1 Fast | $0.20 | $0.50 | 2M | ⚡⚡⚡ | ★★★ | Huge context |
| **Anthropic** | Claude 3.5 Haiku | $0.25 | $1.25 | 200K | ⚡⚡ | ★★★★ | Fast Claude |
| **DeepSeek** | V3.2-Exp | $0.28 | $0.42 | 128K | ⚡⚡ | ★★★★★ | Best value! |
| **xAI** | Grok 3 Mini | $0.30 | $0.50 | 128K | ⚡⚡ | ★★★ | Good balance |
| **Google** | Gemini 3 Flash | $0.50 | $3.00 | 1M | ⚡⚡ | ★★★★ | Quality |
| **Mistral** | Large 3 | $0.50 | $1.50 | 256K | ⚡⚡ | ★★★★ | Good coder |
| **Google** | Gemini 2.5 Pro | $1.25 | $10.00 | 2M | ⚡ | ★★★★ | Large context |
| **OpenAI** | GPT-4o | $2.50 | $10.00 | 128K | ⚡ | ★★★★ | Reliable |
| **Anthropic** | Claude Sonnet 4 | $3.00 | $15.00 | 200K | ⚡ | ★★★★★ | Best coding |
| **xAI** | Grok 4 | $3.00 | $15.00 | 2M | ⚡ | ★★★★ | X integration |
| **Anthropic** | Claude Opus 4 | $15.00 | $75.00 | 200K | ★ | ★★★★★ | Expert |

### Free Tiers Available

| Provider | Free Tier | Daily Limit | Notes |
|----------|-----------|-------------|-------|
| **Groq** | ✅ Yes | 14,400 requests | No credit card needed |
| **Gemini** | ✅ Yes | 1,500 requests | Great for testing |
| **DeepSeek** | ✅ Yes | 5M tokens signup bonus | New users only |
| **OpenAI** | ❌ No | - | $5 min prepay |
| **Anthropic** | ❌ No | - | $5 min prepay |
| **xAI** | ❌ No | - | Pay as you go |

---

## Tier 1: 🚀 TURBO Mode (~$5/dev/month)

**Best for:** Startups, side projects, budget-conscious teams

**Strategy:** Use FREE tiers + cheapest models for everything possible

### Model Selection

| Task | Primary | Fallback | Cost/MTok |
|------|---------|----------|-----------|
| Extract/Parse | Groq Llama (FREE) | Gemini Flash-Lite | $0.00-0.11 |
| Summarize | Gemini Flash-Lite (FREE) | DeepSeek | $0.00-0.10 |
| Classify | Groq Mistral (FREE) | GPT-4o-mini | $0.00-0.03 |
| Simple Code | DeepSeek V3 | Mistral Codestral | $0.28 |
| Complex Code | DeepSeek V3 | Claude Haiku | $0.28 |
| Review | DeepSeek V3 | Grok 3 Mini | $0.28 |

### Why DeepSeek?

> "DeepSeek R1 shocked the AI community in 2025 by demonstrating competitive performance against leading frontier models at a fraction of the cost... achieving 97.3% on MATH-500 benchmark and 49.2% on SWE-bench Verified."
>
> — [Index.dev Comparison](https://www.index.dev/blog/deepseek-vs-claude-ai-comparison)

### Monthly Cost Example (10 devs, 50 tasks/day)

```
Extraction (40%): 4,000 requests × FREE Groq = $0
Summarize (20%): 2,000 requests × Gemini FREE = $0
Coding (30%): 3,000 requests × DeepSeek = $8.40
Complex (10%): 1,000 requests × DeepSeek = $2.80

TOTAL: ~$11.20/month for 10 devs = $1.12/dev/month
```

---

## Tier 2: ⚡ BALANCED Mode (~$15/dev/month)

**Best for:** Growing teams, production apps, quality-conscious

**Strategy:** Mix providers based on task type, prioritize quality for coding

### Model Selection

| Task | Primary | Fallback | Cost/MTok |
|------|---------|----------|-----------|
| Extract/Parse | Groq Llama | Gemini Flash | $0.11 |
| Summarize | Gemini Flash-Lite | GPT-4o-mini | $0.10 |
| Classify | GPT-4o-mini | Grok 3 Mini | $0.15 |
| Simple Code | Claude Haiku | Mistral Codestral | $0.25 |
| Complex Code | Claude Sonnet | DeepSeek V3 | $3.00 |
| Review | Claude Sonnet | Gemini Pro | $3.00 |
| Architecture | Claude Sonnet | Grok 4 | $3.00 |

### Why This Mix?

> "For most production development work, Claude produces more reliable, deployment-ready code."
>
> — [Bind AI Comparison](https://blog.getbind.co/2025/01/23/deepseek-r1-vs-gpt-o1-vs-claude-3-5-sonnet-which-is-best-for-coding/)

### Monthly Cost Example (10 devs, 50 tasks/day)

```
Extraction (30%): 3,000 requests × Groq $0.11 = $3.30
Summarize (20%): 2,000 requests × Gemini $0.10 = $2.00
Simple Code (25%): 2,500 requests × Haiku $0.25 = $6.25
Complex (15%): 1,500 requests × Sonnet $3.00 = $45.00
Review (10%): 1,000 requests × Sonnet $3.00 = $30.00

TOTAL: ~$86.55/month for 10 devs = $8.66/dev/month
```

---

## Tier 3: 💎 QUALITY Mode (~$35/dev/month)

**Best for:** Enterprise teams, critical applications, best-in-class results

**Strategy:** Claude-first with premium fallbacks, no compromises on quality

### Model Selection

| Task | Primary | Fallback | Cost/MTok |
|------|---------|----------|-----------|
| Extract/Parse | Claude Haiku | GPT-4o-mini | $0.25 |
| Summarize | Claude Haiku | Gemini Flash | $0.25 |
| Classify | Claude Haiku | GPT-4o-mini | $0.25 |
| Simple Code | Claude Haiku | Mistral Large | $0.25 |
| Complex Code | Claude Sonnet | GPT-4o | $3.00 |
| Review | Claude Sonnet | Grok 4 | $3.00 |
| Architecture | Claude Opus | Claude Sonnet | $15.00 |
| Security Audit | Claude Opus | GPT-4o | $15.00 |

### Why Claude-First?

> "Claude 4.5 Sonnet positions as 'the best coding model in the world' with demonstrated 30+ hour autonomous operation capability... 77.2% SWE-bench (real-world coding benchmark)."
>
> — [CodeGPT Guide](https://www.codegpt.co/blog/ai-coding-models-2025-comprehensive-guide)

### Monthly Cost Example (10 devs, 50 tasks/day)

```
Extract/Summarize (40%): 4,000 × Haiku $0.25 = $10.00
Simple Code (25%): 2,500 × Haiku $0.25 = $6.25
Complex Code (20%): 2,000 × Sonnet $3.00 = $60.00
Review (10%): 1,000 × Sonnet $3.00 = $30.00
Architecture (5%): 500 × Opus $15.00 = $75.00

TOTAL: ~$181.25/month for 10 devs = $18.13/dev/month
```

---

## Tier 4: 🔑 BYOK Mode (Bring Your Own Key)

**Best for:** Enterprise with existing contracts, compliance requirements, full control

**Strategy:** User provides their own API keys, QUAD just orchestrates

### Configuration Options

```typescript
interface BYOKConfig {
  provider: 'anthropic' | 'openai' | 'google' | 'xai' | 'mistral' | 'deepseek';
  apiKey: string;
  preferredModel?: string;  // Default model for this provider
  costOptimization?: 'none' | 'light' | 'aggressive';
}
```

### User Controls

| Setting | Options | Description |
|---------|---------|-------------|
| **Provider** | Any supported | Which API to use |
| **Model** | Provider's models | Default model selection |
| **Optimization** | None/Light/Aggressive | Cost optimization level |
| **Caching** | On/Off | Enable prompt caching |
| **Batching** | On/Off | Enable batch API |

### BYOK Benefits

- ✅ Use existing enterprise contracts
- ✅ Full cost control and visibility
- ✅ Compliance with internal policies
- ✅ No markup from QUAD
- ✅ Direct relationship with provider

---

## Task-to-Model Routing Matrix

### By Task Complexity

```
                        COMPLEXITY
           Low ◄────────────────────────► High
            │                              │
    ┌───────┴──────────────────────────────┴───────┐
    │                                              │
    │   Groq          DeepSeek        Claude       │
    │   Gemini        GPT-4o-mini     Sonnet       │
    │   Flash-Lite    Haiku           Opus         │
    │                                              │
    │   $0.03-0.15    $0.20-0.50     $3.00-15.00   │
    │                                              │
    │   Extract       Simple Code     Architecture │
    │   Classify      Bug Fixes       Security     │
    │   Summarize     Boilerplate     Complex      │
    │                                              │
    └──────────────────────────────────────────────┘
```

### By Speed Requirements

| Need | Model Choice | Latency |
|------|--------------|---------|
| **Instant** (<1s) | Groq Llama/Mistral | ~200ms |
| **Fast** (<3s) | Gemini Flash, Claude Haiku | ~500ms |
| **Standard** (<10s) | Claude Sonnet, GPT-4o | ~2-5s |
| **Async OK** (minutes) | Batch API any model | 1-5min |

---

## Coding Quality Benchmarks (2025)

Based on industry benchmarks and real-world testing:

| Model | SWE-Bench | HumanEval | Codeforces | Real-World |
|-------|-----------|-----------|------------|------------|
| Claude Sonnet 4 | 77.2% | 95%+ | 85% | ★★★★★ |
| DeepSeek V3 | 49.2% | 93% | 96.3% | ★★★★ |
| GPT-4o | 72% | 92% | 80% | ★★★★ |
| Claude Haiku | 65% | 88% | 70% | ★★★★ |
| Gemini Pro | 68% | 90% | 75% | ★★★★ |
| Grok 4 | 70% | 89% | 78% | ★★★★ |
| Mistral Codestral | 60% | 85% | 72% | ★★★ |
| GPT-4o-mini | 55% | 82% | 65% | ★★★ |

### Key Insights

> "Choose DeepSeek for budget-conscious development, algorithmic challenges, and math-heavy tasks. Choose Claude for production code quality, creative content, and enterprise reliability."
>
> — [AI Models Comparison 2025](https://collabnix.com/comparing-top-ai-models-in-2025-claude-grok-gpt-llama-gemini-and-deepseek-the-ultimate-guide/)

---

## Implementation: User Settings UI

```typescript
// src/types/ai-settings.ts

export type AITier = 'turbo' | 'balanced' | 'quality' | 'byok';

export interface AISettings {
  tier: AITier;

  // BYOK-specific settings
  byokConfig?: {
    provider: string;
    apiKey: string;
    preferredModel?: string;
  };

  // Optimization preferences
  enableCaching: boolean;
  enableBatching: boolean;
  maxCostPerRequest?: number;

  // Notification preferences
  notifyOnHighCost: boolean;
  costAlertThreshold?: number;
}

// Default configurations per tier
export const TIER_DEFAULTS: Record<AITier, Partial<AISettings>> = {
  turbo: {
    enableCaching: true,
    enableBatching: true,
    maxCostPerRequest: 0.01,
    notifyOnHighCost: true,
    costAlertThreshold: 5,
  },
  balanced: {
    enableCaching: true,
    enableBatching: true,
    maxCostPerRequest: 0.10,
    notifyOnHighCost: true,
    costAlertThreshold: 20,
  },
  quality: {
    enableCaching: true,
    enableBatching: false,
    maxCostPerRequest: 1.00,
    notifyOnHighCost: false,
  },
  byok: {
    enableCaching: true,
    enableBatching: true,
    notifyOnHighCost: false,
  },
};
```

---

## Sources

### Provider Pricing
- [DeepSeek Models & Pricing](https://api-docs.deepseek.com/quick_start/pricing)
- [Mistral AI Pricing](https://mistral.ai/pricing)
- [OpenAI API Pricing](https://openai.com/api/pricing/)
- [xAI Grok Models & Pricing](https://docs.x.ai/docs/models)
- [Gemini API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
- [Groq Pricing](https://groq.com/pricing)

### Benchmarks & Comparisons
- [GPT 5.1 vs Claude 4.5 vs Gemini 3 Comparison](https://www.getpassionfruit.com/blog/gpt-5-1-vs-claude-4-5-sonnet-vs-gemini-3-pro-vs-deepseek-v3-2-the-definitive-2025-ai-model-comparison)
- [AI Models Comparison 2025](https://collabnix.com/comparing-top-ai-models-in-2025-claude-grok-gpt-llama-gemini-and-deepseek-the-ultimate-guide/)
- [DeepSeek vs Claude Comparison](https://www.index.dev/blog/deepseek-vs-claude-ai-comparison)
- [DeepSeek R1 vs GPT o1 vs Claude - Coding](https://blog.getbind.co/2025/01/23/deepseek-r1-vs-gpt-o1-vs-claude-3-5-sonnet-which-is-best-for-coding/)
- [AI Coding Models 2025 Guide](https://www.codegpt.co/blog/ai-coding-models-2025-comprehensive-guide)
- [LLM API Pricing Comparison 2025](https://intuitionlabs.ai/articles/llm-api-pricing-comparison-2025)

---

*Last Updated: January 2, 2026*
*QUAD Framework Documentation*
