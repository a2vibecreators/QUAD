# QUAD Framework

**Quick Unified Agentic Development** - A modern software development methodology for the AI era.

Website: [quadframe.work](https://quadframe.work)

## About QUAD

QUAD is a software development methodology that replaces traditional Agile/Scrum with:
- **AI-powered automation** - AI agents handle repetitive tasks
- **Documentation-first practices** - Docs written before code
- **Four functional circles** - Management, Development, QA, Infrastructure

### The 1-2-3-4 Hierarchy

- **1 Method** → QUAD (Quick Unified Agentic Development)
- **2 Dimensions** → Business + Technical
- **3 Axioms** → Operators, AI Agents, Docs-First
- **4 Circles** → Management, Development, QA, Infrastructure

## Tech Stack

- **Framework**: Next.js 15 with App Router
- **Styling**: Tailwind CSS
- **Language**: TypeScript
- **Deployment**: Docker + nginx (static export)

## Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev
# Open http://localhost:3003

# Build for production
npm run build
```

## Deployment

```bash
# Deploy to DEV (dev.quadframe.work) - Mac Studio
./deploy-studio.sh dev

# Deploy to QA (qa.quadframe.work) - Mac Studio
./deploy-studio.sh qa

# Deploy to PROD (quadframe.work) - GCP Cloud Run
./deploy-gcp.sh

# Deploy to both
./deploy-studio.sh all
```

## Project Structure

```
quadframework/
├── src/app/
│   ├── page.tsx          # Homepage
│   ├── concept/          # Main concept page
│   ├── details/          # Technical details + Enabling Teams
│   ├── jargons/          # Terminology glossary
│   ├── summary/          # Executive summary
│   ├── case-study/       # Calculator app comparison
│   └── demo/             # Dashboard demo
├── Dockerfile            # Docker build config
├── deploy-studio.sh      # Deployment script
└── package.json
```

## DNS Configuration (Namecheap)

Configure Custom DNS to point to Cloudflare:
- ns1.cloudflare.com
- ns2.cloudflare.com

Then in Cloudflare, add A records:
- `@` → Mac Studio public IP
- `dev` → Mac Studio public IP

## License

Copyright 2025 A2 Vibe Creators LLC. All rights reserved.

QUAD™ is a trademark of A2 Vibe Creators LLC.
