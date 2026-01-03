# QUAD AI Models Catalog

**Last Updated:** January 3, 2026
**Purpose:** Reference guide for AI model selection and intelligent routing
**Vision:** 20+ years of continuous model research and integration

---

## Executive Summary

QUAD uses **intelligent model routing** to select the best AI model for each task. This reduces costs by 86-92% while maintaining quality.

---

## 1. Supported AI Providers

### Tier 1: Primary Providers (Production Ready)

| Provider | Models | Best For | Cost Level |
|----------|--------|----------|------------|
| **Google** | Gemini 3 Pro, Flash, Deep Think | General, Fast tasks, Complex reasoning | Free tier + Paid |
| **Anthropic** | Claude Opus 4.5, Sonnet, Haiku | Code, Analysis, Safety-critical | Paid |
| **Groq** | Llama 3.3 70B, Mixtral | Fast inference, Extraction | Free tier |
| **DeepSeek** | DeepSeek V3, Coder | Budget code generation | Very cheap |

### Tier 2: Specialized Providers

| Provider | Models | Best For | Notes |
|----------|--------|----------|-------|
| **OpenAI** | GPT-4o, o1-preview | Reasoning, Multi-modal | Expensive |
| **Mistral** | Mistral Large, Codestral | European compliance, Code | GDPR-friendly |
| **Cohere** | Command R+ | Enterprise RAG, Search | Good embeddings |
| **Meta** | Llama 3.3 (via Groq/Together) | Open source, Self-hosted | Free weights |

### Tier 3: Domain-Specific (Future)

| Domain | Potential Models | Use Cases |
|--------|------------------|-----------|
| **Healthcare** | Med-PaLM 2, BioMistral | Medical reports, Drug interactions |
| **Legal** | Harvey AI, CaseText | Contract analysis, Compliance |
| **Finance** | BloombergGPT, FinGPT | Market analysis, Risk assessment |
| **Code** | CodeLlama, StarCoder2 | Specialized code generation |

---

## 2. Model Specializations

### By Task Type

| Task Type | Primary Model | Fallback | Reasoning |
|-----------|--------------|----------|-----------|
| **Code Generation** | Claude Sonnet 4.5 | DeepSeek Coder | Best code quality |
| **Code Review** | Claude Sonnet 4.5 | Gemini 3 Pro | Security awareness |
| **Complex Reasoning** | Gemini 3 Deep Think | Claude Opus 4.5 | Extended thinking |
| **Fast Classification** | Gemini 3 Flash | Groq Llama | Speed + Free |
| **Documentation** | Gemini 3 Pro | Claude Haiku | Good + Cheap |
| **Data Extraction** | Groq Llama 3.3 | Gemini Flash | Speed critical |
| **Embeddings** | text-embedding-3-small | Cohere Embed | Vector search |
| **Translation** | Gemini 3 Pro | Claude | Multilingual |
| **Summarization** | Gemini 3 Flash | Claude Haiku | Cost effective |
| **Chat/Conversation** | Gemini 3 Pro | Claude Sonnet | Balance |

### By Domain

| Domain | Recommended Stack | Why |
|--------|------------------|-----|
| **Software Development** | Claude Sonnet + Gemini Flash | Best code + fast tasks |
| **Healthcare** | Claude Opus + Med-PaLM (future) | Safety critical |
| **Finance** | Claude Opus + Gemini Pro | Accuracy matters |
| **Education** | Gemini Pro + Claude Haiku | Cost effective |
| **Legal** | Claude Opus | Reasoning + Safety |
| **E-commerce** | Gemini Flash + Groq | Speed + Cost |
| **Manufacturing** | Gemini Pro + DeepSeek | Balance |

---

## 3. Detailed Model Profiles

### Google Gemini 3 Family

#### Gemini 3 Pro
- **Strengths:** Multimodal, Long context (1M tokens), Free tier
- **Weaknesses:** Sometimes verbose
- **Best For:** General tasks, Documentation, Understanding
- **Pricing:** $2/1M input, $12/1M output (≤200K)
- **Free Tier:** 1,500 requests/day

#### Gemini 3 Flash
- **Strengths:** Fastest, Cheapest, Good quality
- **Weaknesses:** Less reasoning depth
- **Best For:** Classification, Quick tasks, High volume
- **Pricing:** $0.50/1M input, $3/1M output
- **Free Tier:** 1,500 requests/day

#### Gemini 3 Deep Think
- **Strengths:** Extended reasoning, Complex problems
- **Weaknesses:** Slower, Thinking tokens add cost
- **Best For:** Architecture decisions, Complex bugs, Planning
- **Pricing:** $2/1M input, $12/1M output + thinking tokens
- **When to Use:** Problems requiring multi-step reasoning

### Anthropic Claude Family

#### Claude Opus 4.5
- **Strengths:** Best reasoning, Safety, Long outputs (64K)
- **Weaknesses:** Most expensive
- **Best For:** Critical decisions, Complex analysis, Safety-critical
- **Pricing:** $5/1M input, $25/1M output
- **Context:** 200K tokens

#### Claude Sonnet 4.5
- **Strengths:** Best code quality, Fast, Balanced
- **Weaknesses:** None significant
- **Best For:** Code generation, Code review, Daily tasks
- **Pricing:** $1/1M input, $3/1M output
- **Context:** 200K tokens

#### Claude Haiku 3.5
- **Strengths:** Fastest Claude, Very cheap
- **Weaknesses:** Less capable for complex tasks
- **Best For:** Quick responses, Simple tasks, High volume
- **Pricing:** $0.25/1M input, $1.25/1M output
- **Context:** 200K tokens

### Speed Providers

#### Groq (Llama 3.3 70B)
- **Strengths:** Extremely fast (500+ tokens/sec), Free tier
- **Weaknesses:** Less capable than Claude/Gemini
- **Best For:** Data extraction, Fast responses, Prototyping
- **Pricing:** Free tier available, then $0.59/1M input
- **Speed:** 10-50x faster than others

#### DeepSeek V3 / Coder
- **Strengths:** Very cheap, Good for code
- **Weaknesses:** Less reliable, Chinese company concerns
- **Best For:** Budget code generation, Bulk processing
- **Pricing:** $0.14/1M input, $0.28/1M output
- **Note:** BYOK - user provides key

---

## 4. QUAD Intelligent Routing

### Routing Algorithm (High Level)

```
Task Received
    ↓
Step 1: Classify Task Type
    - Use Gemini Flash (free, fast)
    - Categories: code, review, docs, extraction, reasoning, chat
    ↓
Step 2: Check Complexity
    - Simple → Use cheaper model
    - Complex → Use premium model
    ↓
Step 3: Check User Tier
    - Turbo → Cheapest options
    - Balanced → Mix based on task
    - Quality → Best models always
    ↓
Step 4: Check Budget
    - Under budget → Proceed
    - Over budget → Downgrade or queue
    ↓
Step 5: Execute with Fallback
    - Primary fails → Try fallback
    - Log for optimization
```

### Cost Optimization Results

| Approach | Monthly Cost (10 devs) | Savings |
|----------|----------------------|---------|
| Claude Only | ~$450 | Baseline |
| Gemini Only | ~$60-120 | 73-87% |
| **QUAD Turbo** | ~$50 | **89%** |
| **QUAD Balanced** | ~$150 | **67%** |
| **QUAD Quality** | ~$350 | **22%** |

---

## 5. Model Research Roadmap

### 2026 Q1
- [ ] Integrate Gemini 3 Deep Think
- [ ] Add Mistral Large for EU compliance
- [ ] Evaluate Claude 4 when released

### 2026 Q2
- [ ] Healthcare models evaluation (Med-PaLM 2)
- [ ] Legal models evaluation
- [ ] Fine-tuned models for QUAD-specific tasks

### 2026 H2
- [ ] Self-hosted models for enterprise
- [ ] Multi-modal (image/video) support
- [ ] Voice model integration

### Long Term (5+ years)
- [ ] Domain-specific fine-tuning
- [ ] On-device models for privacy
- [ ] Custom QUAD models

---

## 6. BYOK (Bring Your Own Key) Support

| Provider | BYOK Supported | Notes |
|----------|----------------|-------|
| Google Gemini | ✅ Yes | Free tier or paid |
| Anthropic Claude | ✅ Yes | API key required |
| OpenAI | ✅ Yes | API key required |
| Groq | ✅ Yes | Free tier available |
| DeepSeek | ✅ Yes | Very cheap |
| Mistral | ✅ Yes | EU hosting available |
| AWS Bedrock | ✅ Yes | Enterprise/HIPAA |
| Azure OpenAI | ✅ Yes | Enterprise |

---

## 7. Model Selection Guidelines

### When to Use Premium Models (Claude Opus, Gemini Deep Think)
- Architecture decisions
- Security-critical code review
- Complex debugging
- Production deployment decisions
- Legal/compliance analysis

### When to Use Balanced Models (Claude Sonnet, Gemini Pro)
- Daily code generation
- Code reviews
- Documentation
- General chat
- Ticket analysis

### When to Use Fast/Cheap Models (Gemini Flash, Groq, Haiku)
- Task classification
- Simple extraction
- Status checks
- Bulk operations
- Development/testing

---

## 8. Adding New Models

### Evaluation Criteria
1. **Quality:** Benchmark against Claude Sonnet
2. **Speed:** Measure tokens/second
3. **Cost:** Calculate per-task cost
4. **Reliability:** 99%+ uptime required
5. **Safety:** Content filtering capability
6. **Context:** Minimum 32K tokens

### Integration Steps
1. Add to `ai-router.ts` provider list
2. Create adapter in `providers/` directory
3. Add to BYOK settings UI
4. Update routing rules
5. A/B test against existing models
6. Document in this catalog

---

*This catalog is updated quarterly. Last review: January 2026*
*Next review: April 2026*
