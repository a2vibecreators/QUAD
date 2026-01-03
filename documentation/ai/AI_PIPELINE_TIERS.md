# QUAD Framework - AI Pipeline Tiers (NutriNine Style)

## Overview

Like NutriNine Voice's tiered AI approach (FREE → Paid fallback), QUAD uses a pipeline that tries cheaper options first and escalates to premium models only when needed.

---

## The $200 Claude Max Question - IMPORTANT CLARIFICATION

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CLAUDE PRODUCTS - WHAT CAN DO WHAT                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  YOUR $200/MONTH CLAUDE MAX (claude.ai)                                      │
│  ═══════════════════════════════════════                                     │
│                                                                              │
│  ✅ What it does:                                                            │
│     • Web chat interface with 20x more usage                                 │
│     • YOU use it to help YOU write code (Claude Code)                        │
│     • Personal productivity tool for the developer                           │
│                                                                              │
│  ❌ What it CANNOT do:                                                       │
│     • Be called programmatically from QUAD app                               │
│     • Serve QUAD users through your subscription                             │
│     • Be shared with your clients                                            │
│                                                                              │
│  Bottom line: Claude Max is for YOU to BUILD faster.                         │
│               QUAD app needs separate API access.                            │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ANTHROPIC API (console.anthropic.com)                                       │
│  ═══════════════════════════════════════                                     │
│                                                                              │
│  ✅ What it does:                                                            │
│     • Programmatic HTTP API access                                           │
│     • QUAD app calls this to serve users                                     │
│     • Pay-per-token ($3/$15 per MTok for Sonnet)                            │
│                                                                              │
│  This is SEPARATE from Claude Max. You need BOTH:                            │
│     • Claude Max → helps YOU code faster                                     │
│     • Anthropic API → QUAD serves users                                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Can Multi-API Give Same Results as Claude Code?

**Short answer: YES, but with smart routing!**

What you experience with Claude Code (Claude Max):
- Fast responses
- Great coding quality
- Understands context well

To replicate this in QUAD using APIs:

| Claude Code Feature | Multi-API Equivalent | How |
|---------------------|---------------------|-----|
| Fast responses | Groq (200ms) | Use for simple tasks |
| Great coding | Claude Sonnet API | Use for code generation |
| Context understanding | DeepSeek + Haiku | Cheaper, still good |
| Fallback safety | Pipeline approach | Try cheap → escalate |

---

## QUAD AI Pipeline (NutriNine Style)

### Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QUAD AI PIPELINE                                     │
│                    (Try Cheap First, Escalate if Needed)                     │
└─────────────────────────────────────────────────────────────────────────────┘

User Request
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 1: CLASSIFY TASK                                                       │
│                                                                              │
│  Is this:                                                                    │
│  • Extraction/Parsing? ──────────► Pipeline A (Cheapest)                     │
│  • Simple Coding? ───────────────► Pipeline B (Budget Coding)                │
│  • Complex Coding/Review? ───────► Pipeline C (Quality Coding)               │
│  • Architecture/Security? ───────► Pipeline D (Premium)                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Pipeline A: Extraction/Parsing (Cheapest)

**Use for:** Parse JSON, extract fields, summarize, classify

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   TIER 1     │     │   TIER 2     │     │   TIER 3     │     │   TIER 4     │
│   FREE       │ ──► │   ULTRA      │ ──► │   CHEAP      │ ──► │   RELIABLE   │
│              │     │   CHEAP      │     │              │     │              │
├──────────────┤     ├──────────────┤     ├──────────────┤     ├──────────────┤
│ Groq FREE    │     │ DeepSeek     │     │ GPT-4o-mini  │     │ Claude Haiku │
│ (14K req/day)│     │ $0.28/MTok   │     │ $0.15/MTok   │     │ $0.25/MTok   │
│              │     │              │     │              │     │              │
│ Gemini FREE  │     │ Gemini Flash │     │ Grok Mini    │     │ Mistral      │
│ (1.5K/day)   │     │ $0.08/MTok   │     │ $0.30/MTok   │     │ Codestral    │
├──────────────┤     ├──────────────┤     ├──────────────┤     ├──────────────┤
│ Quality: 85% │     │ Quality: 90% │     │ Quality: 93% │     │ Quality: 97% │
│ Speed: ⚡⚡⚡  │     │ Speed: ⚡⚡   │     │ Speed: ⚡⚡   │     │ Speed: ⚡⚡   │
│ Cost: $0     │     │ Cost: ~$0.20 │     │ Cost: ~$0.30 │     │ Cost: ~$0.50 │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘

When to escalate:
• Tier 1 → Tier 2: Rate limited or quota exceeded
• Tier 2 → Tier 3: Response quality < threshold
• Tier 3 → Tier 4: Critical task or user premium
```

---

## Pipeline B: Simple Coding (Budget)

**Use for:** Boilerplate, simple functions, bug fixes, formatting

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   TIER 1     │     │   TIER 2     │     │   TIER 3     │     │   TIER 4     │
│   BUDGET     │ ──► │   VALUE      │ ──► │   QUALITY    │ ──► │   PREMIUM    │
│   CODER      │     │   CODER      │     │   CODER      │     │   CODER      │
├──────────────┤     ├──────────────┤     ├──────────────┤     ├──────────────┤
│ DeepSeek V3  │     │ Mistral      │     │ Claude Haiku │     │ Claude       │
│ $0.28/MTok   │     │ Codestral    │     │ $0.25/MTok   │     │ Sonnet       │
│              │     │ $0.20/MTok   │     │              │     │ $3.00/MTok   │
│ Quality: 93% │     │              │     │              │     │              │
│ 338 languages│     │ Quality: 88% │     │ Quality: 92% │     │ Quality: 98% │
│              │     │ 80 languages │     │ Fast Claude  │     │ Best coding  │
├──────────────┤     ├──────────────┤     ├──────────────┤     ├──────────────┤
│ Speed: ⚡⚡   │     │ Speed: ⚡⚡   │     │ Speed: ⚡⚡   │     │ Speed: ⚡     │
│ Cost: ~$0.50 │     │ Cost: ~$0.40 │     │ Cost: ~$1.00 │     │ Cost: ~$5.00 │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘

When to escalate:
• Tier 1 → Tier 2: Code doesn't compile or tests fail
• Tier 2 → Tier 3: Quality issues or user feedback negative
• Tier 3 → Tier 4: Critical feature or explicit user request
```

---

## Pipeline C: Complex Coding/Review (Quality)

**Use for:** Multi-file changes, code review, debugging complex issues

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   TIER 1     │     │   TIER 2     │     │   TIER 3     │
│   GOOD       │ ──► │   BETTER     │ ──► │   BEST       │
│   CODER      │     │   CODER      │     │   CODER      │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ Claude Haiku │     │ Claude       │     │ Claude Opus  │
│ + DeepSeek   │     │ Sonnet 4     │     │ 4            │
│              │     │              │     │              │
│ $0.25-0.28   │     │ $3.00/MTok   │     │ $15.00/MTok  │
│              │     │              │     │              │
│ GPT-4o-mini  │     │ GPT-4o       │     │ GPT-4o +     │
│ as fallback  │     │ as fallback  │     │ Reasoning    │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ Quality: 88% │     │ Quality: 96% │     │ Quality: 99% │
│ Speed: ⚡⚡   │     │ Speed: ⚡     │     │ Speed: ★     │
│ Cost: ~$1    │     │ Cost: ~$6    │     │ Cost: ~$25   │
└──────────────┘     └──────────────┘     └──────────────┘

When to escalate:
• Tier 1 → Tier 2: Code review misses issues, complex logic
• Tier 2 → Tier 3: Architecture decisions, security audit
```

---

## Pipeline D: Architecture/Security (Premium)

**Use for:** System design, security audits, critical decisions

```
┌──────────────┐     ┌──────────────┐
│   TIER 1     │     │   TIER 2     │
│   EXPERT     │ ──► │   GENIUS     │
├──────────────┤     ├──────────────┤
│ Claude       │     │ Claude Opus  │
│ Sonnet 4     │     │ 4            │
│              │     │              │
│ $3.00/MTok   │     │ $15.00/MTok  │
│              │     │              │
│ Grok 4 or    │     │ Multiple     │
│ Gemini Pro   │     │ models agree │
│ as fallback  │     │ for safety   │
├──────────────┤     ├──────────────┤
│ Quality: 96% │     │ Quality: 99% │
│ Speed: ⚡     │     │ Speed: ★     │
│ Cost: ~$10   │     │ Cost: ~$40   │
└──────────────┘     └──────────────┘

For critical decisions: Run multiple models and compare!
```

---

## User-Facing Tier Options

### Option 1: 🚀 Turbo (Startup Mode) - ~$5/dev/month

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🚀 TURBO MODE                                                               │
│                                                                              │
│  "Fastest & Cheapest - Great for startups and side projects"                │
│                                                                              │
│  Pipeline Priority:                                                          │
│  ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐                          │
│  │ Groq   │ → │DeepSeek│ → │GPT-mini│ → │ Haiku  │                          │
│  │ FREE   │   │ $0.28  │   │ $0.15  │   │ $0.25  │                          │
│  └────────┘   └────────┘   └────────┘   └────────┘                          │
│                                                                              │
│  ✅ Uses FREE tiers first (Groq 14K/day, Gemini 1.5K/day)                   │
│  ✅ DeepSeek for coding (97% quality at 10x less cost)                      │
│  ✅ Only escalates when absolutely necessary                                 │
│  ✅ Async "Come back in 5 min" for batch tasks (50% savings)                │
│                                                                              │
│  Best for: MVP development, learning, experimentation                        │
│  Trade-off: May take longer, occasional quality dips                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Option 2: ⚡ Balanced (Team Mode) - ~$15/dev/month

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚡ BALANCED MODE                                                            │
│                                                                              │
│  "Best Value - Smart mix for production teams"                               │
│                                                                              │
│  Pipeline Priority:                                                          │
│  ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐                          │
│  │DeepSeek│ → │ Haiku  │ → │ Sonnet │ → │  Opus  │                          │
│  │ $0.28  │   │ $0.25  │   │ $3.00  │   │ $15.00 │                          │
│  └────────┘   └────────┘   └────────┘   └────────┘                          │
│                                                                              │
│  ✅ DeepSeek for extraction/simple tasks (cheap + good)                     │
│  ✅ Claude Haiku for simple coding (fast + quality)                         │
│  ✅ Claude Sonnet for complex coding (best coding model)                    │
│  ✅ Smart escalation based on task complexity                                │
│                                                                              │
│  Best for: Production apps, growing teams                                    │
│  Trade-off: Balanced cost vs quality                                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Option 3: 💎 Quality (Enterprise Mode) - ~$35/dev/month

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  💎 QUALITY MODE                                                             │
│                                                                              │
│  "Best Results - Claude-first for critical applications"                     │
│                                                                              │
│  Pipeline Priority:                                                          │
│  ┌────────┐   ┌────────┐   ┌────────┐                                       │
│  │ Haiku  │ → │ Sonnet │ → │  Opus  │                                       │
│  │ $0.25  │   │ $3.00  │   │ $15.00 │                                       │
│  └────────┘   └────────┘   └────────┘                                       │
│                                                                              │
│  ✅ Claude for everything (77.2% SWE-bench - best coding)                   │
│  ✅ Instant responses (no batching delay)                                   │
│  ✅ Premium fallbacks (GPT-4o, Gemini Pro)                                  │
│  ✅ Multi-model validation for critical decisions                           │
│                                                                              │
│  Best for: Enterprise, critical apps, compliance-heavy                       │
│  Trade-off: Higher cost for best quality                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Option 4: 🔑 BYOK (Your Keys) - You Pay Direct

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🔑 BYOK MODE (Bring Your Own Key)                                           │
│                                                                              │
│  "Full Control - Use your own API keys"                                      │
│                                                                              │
│  Your Keys:                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  ☑️ Anthropic API Key: sk-ant-xxx...                                 │   │
│  │  ☑️ Google AI Key: AIza...                                           │   │
│  │  ☐ OpenAI Key: (optional)                                            │   │
│  │  ☐ DeepSeek Key: (optional)                                          │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  Optimization Level:                                                         │
│  ○ None - Use Claude Sonnet for everything                                   │
│  ○ Light - Route simple tasks to cheaper models                              │
│  ● Aggressive - Full pipeline optimization                                   │
│                                                                              │
│  ✅ Use existing enterprise contracts                                        │
│  ✅ Full cost visibility and control                                         │
│  ✅ No QUAD markup                                                           │
│  ✅ Compliance with internal policies                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Pipeline Implementation Code

```typescript
// src/lib/ai/pipeline.ts

interface PipelineResult {
  success: boolean;
  content: string;
  provider: string;
  model: string;
  tier: number;
  cost: number;
  latencyMs: number;
  escalationReason?: string;
}

async function runPipeline(
  task: Task,
  userTier: 'turbo' | 'balanced' | 'quality' | 'byok'
): Promise<PipelineResult> {

  const pipeline = getPipelineForTask(task.type, userTier);

  for (let tierIndex = 0; tierIndex < pipeline.length; tierIndex++) {
    const tier = pipeline[tierIndex];

    try {
      // Try primary model
      const result = await callModel(tier.primary, task);

      // Quality check
      if (isQualitySufficient(result, task)) {
        return {
          success: true,
          content: result.content,
          provider: tier.primary.provider,
          model: tier.primary.model,
          tier: tierIndex + 1,
          cost: result.cost,
          latencyMs: result.latency,
        };
      }

      // Quality insufficient, try fallback or escalate
      if (tier.fallback) {
        const fallbackResult = await callModel(tier.fallback, task);
        if (isQualitySufficient(fallbackResult, task)) {
          return {
            success: true,
            content: fallbackResult.content,
            provider: tier.fallback.provider,
            model: tier.fallback.model,
            tier: tierIndex + 1,
            cost: fallbackResult.cost,
            latencyMs: fallbackResult.latency,
            escalationReason: 'Quality check failed on primary',
          };
        }
      }

      // Escalate to next tier
      console.log(`Escalating from tier ${tierIndex + 1} to ${tierIndex + 2}`);

    } catch (error) {
      // Rate limited or error, try next tier
      console.log(`Tier ${tierIndex + 1} failed: ${error.message}`);

      if (tier.fallback) {
        try {
          const fallbackResult = await callModel(tier.fallback, task);
          return {
            success: true,
            content: fallbackResult.content,
            provider: tier.fallback.provider,
            model: tier.fallback.model,
            tier: tierIndex + 1,
            cost: fallbackResult.cost,
            latencyMs: fallbackResult.latency,
            escalationReason: `Primary error: ${error.message}`,
          };
        } catch {
          // Fallback also failed, continue to next tier
        }
      }
    }
  }

  throw new Error('All pipeline tiers exhausted');
}
```

---

## Cost Comparison Summary

| Tier | Monthly Cost (10 devs) | Per Dev | Best For |
|------|------------------------|---------|----------|
| 🚀 Turbo | ~$50 | ~$5 | Startups, MVPs |
| ⚡ Balanced | ~$150 | ~$15 | Production teams |
| 💎 Quality | ~$350 | ~$35 | Enterprise, critical |
| 🔑 BYOK | Direct billing | Varies | Existing contracts |

---

## Sources

- [DeepSeek vs Claude Comparison](https://www.index.dev/blog/deepseek-vs-claude-ai-comparison)
- [AI Models Comparison 2025](https://collabnix.com/comparing-top-ai-models-in-2025-claude-grok-gpt-llama-gemini-and-deepseek-the-ultimate-guide/)
- [Best LLMs for Coding](https://codingscape.com/blog/best-llms-for-coding-developer-favorites)
- [DeepSeek API Pricing](https://api-docs.deepseek.com/quick_start/pricing)
- [Groq Pricing](https://groq.com/pricing)

---

*Last Updated: January 2, 2026*
*QUAD Framework Documentation*
