# QUAD Platform - Getting Started Guide

**Date:** December 31, 2025

---

## Prerequisites

Before you begin, ensure you have:

✅ **Node.js** 20.x or higher ([Download](https://nodejs.org/))
✅ **PostgreSQL** 15.x ([Download](https://www.postgresql.org/download/))
✅ **Git** ([Download](https://git-scm.com/downloads))
✅ **Code Editor** (VS Code recommended)

**Optional:**
- Docker Desktop (for containerized development)
- Puppeteer dependencies (for screenshot service)

---

## Quick Start (5 Minutes)

### 1. Clone Repository

```bash
git clone https://github.com/a2vibecreators/quadframework.git
cd quadframework
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Set Up Database

**Option A: Use Existing NutriNine Database (Mac Studio)**
```bash
# Database already running at localhost:16201
# Skip database setup
```

**Option B: Create New PostgreSQL Database**
```bash
# Create database
psql postgres
CREATE DATABASE quad_dev_db;
CREATE USER quad_user WITH PASSWORD 'quad_dev_pass';
GRANT ALL PRIVILEGES ON DATABASE quad_dev_db TO quad_user;
\q

# Run migrations
psql -U quad_user -d quad_dev_db -f database/migrations/001_create_resource_attribute_model.sql
```

### 4. Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:
```env
# Database (Mac Studio - NutriNine DEV database)
DATABASE_URL=postgresql://nutrinine_user:nutrinine_dev_pass@localhost:16201/nutrinine_dev_db

# Authentication
NEXTAUTH_SECRET=your-secret-key-here
NEXTAUTH_URL=http://localhost:3000

# Optional: Git Access Token (for private repo analysis)
GIT_ACCESS_TOKEN=ghp_your_github_token
```

### 5. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## Project Structure

```
quadframework/
├── database/
│   └── migrations/              # SQL schema migrations
│       └── 001_create_resource_attribute_model.sql
│
├── documentation/               # Project documentation
│   ├── PROJECT_OVERVIEW.md
│   ├── ARCHITECTURE.md
│   ├── GETTING_STARTED.md (this file)
│   ├── BLUEPRINT_AGENT_API_REFERENCE.md
│   └── BLUEPRINT_AGENT_SERVICES.md
│
├── src/
│   ├── app/                     # Next.js App Router
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── api/                 # API routes
│   │   │   ├── auth/
│   │   │   ├── resources/
│   │   │   └── blueprint-agent/
│   │   ├── dashboard/           # Dashboard page
│   │   ├── configure/           # Configuration pages
│   │   └── docs/                # Documentation pages
│   │
│   ├── components/              # React components
│   │   ├── ui/                  # shadcn/ui components
│   │   ├── layout/
│   │   ├── domain/
│   │   └── blueprint/
│   │
│   ├── lib/                     # Utilities & services
│   │   ├── db.ts                # Database connection
│   │   ├── auth.ts              # Authentication helpers
│   │   └── services/            # Backend services
│   │       ├── GitRepoAnalyzer.ts
│   │       ├── ScreenshotService.ts
│   │       └── MockupGenerator.ts
│   │
│   └── types/                   # TypeScript types
│
├── .env.example                 # Environment variables template
├── .env                         # Environment variables (git-ignored)
├── package.json
├── tsconfig.json
├── tailwind.config.ts
└── next.config.ts
```

---

## Database Setup (Detailed)

### Mac Studio (Existing Database)

If you're on Mac Studio with existing NutriNine database:

```bash
# Check if database is running
docker ps | grep postgres-dev

# If running, just use it
# Connection: postgresql://nutrinine_user:nutrinine_dev_pass@localhost:16201/nutrinine_dev_db
```

### Fresh PostgreSQL Setup

**1. Install PostgreSQL 15:**
```bash
# macOS (Homebrew)
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt-get install postgresql-15

# Windows
# Download installer from postgresql.org
```

**2. Create Database:**
```bash
# Connect to PostgreSQL
psql postgres

# Create database and user
CREATE DATABASE quad_dev_db;
CREATE USER quad_user WITH PASSWORD 'quad_dev_pass';
GRANT ALL PRIVILEGES ON DATABASE quad_dev_db TO quad_user;

# Exit
\q
```

**3. Run Migrations:**
```bash
cd quadframework
psql -U quad_user -d quad_dev_db -f database/migrations/001_create_resource_attribute_model.sql
```

**4. Verify Tables Created:**
```bash
psql -U quad_user -d quad_dev_db

\dt QUAD_*

# Should show:
# QUAD_domain_resources
# QUAD_resource_attributes
# QUAD_resource_attribute_requirements

\q
```

---

## Running the Application

### Development Mode

```bash
npm run dev
```

**Access:**
- Frontend: http://localhost:3000
- API: http://localhost:3000/api/*

**Features:**
- Hot reload on file changes
- TypeScript type checking
- Tailwind CSS compilation

### Production Build

```bash
# Build for production
npm run build

# Start production server
npm start
```

### Docker (Recommended for Deployment)

```bash
# Build Docker image
docker build -t quadframework:dev .

# Run container
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://quad_user:quad_dev_pass@host.docker.internal:16201/quad_dev_db \
  quadframework:dev
```

---

## Testing APIs

### Using cURL

**1. Upload Blueprint:**
```bash
curl -X POST http://localhost:3000/api/resources/550e8400-e29b-41d4-a716-446655440000/attributes/blueprint \
  -H "Content-Type: application/json" \
  -d '{
    "blueprintUrl": "https://figma.com/file/abc123",
    "blueprintType": "figma_url"
  }'
```

**2. Link Git Repository:**
```bash
curl -X POST http://localhost:3000/api/resources/550e8400-e29b-41d4-a716-446655440000/attributes/git-repo \
  -H "Content-Type: application/json" \
  -d '{
    "gitRepoUrl": "https://github.com/vercel/next.js",
    "gitRepoPrivate": false,
    "triggerAnalysis": true
  }'
```

**3. Start Blueprint Agent Interview:**
```bash
curl -X POST http://localhost:3000/api/blueprint-agent/start-interview \
  -H "Content-Type: application/json" \
  -d '{
    "resourceId": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

### Using Postman

1. Import collection: `quadframework/postman/QUAD_API_Collection.json` (future)
2. Set base URL: `http://localhost:3000/api`
3. Test all endpoints

---

## Common Issues

### Issue 1: Database Connection Error

**Error:**
```
Error: connect ECONNREFUSED 127.0.0.1:16201
```

**Solution:**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres-dev

# If not running, start it
docker start postgres-dev

# Or check PostgreSQL service
brew services list | grep postgresql
```

### Issue 2: Port 3000 Already in Use

**Error:**
```
Error: Port 3000 is already in use
```

**Solution:**
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or use different port
PORT=3001 npm run dev
```

### Issue 3: Puppeteer Install Fails

**Error:**
```
Error: Failed to download Chromium
```

**Solution:**
```bash
# Install Chromium manually
npx puppeteer browsers install chrome

# Or skip Chromium download
PUPPETEER_SKIP_DOWNLOAD=true npm install
```

### Issue 4: TypeScript Errors

**Error:**
```
Type 'string | undefined' is not assignable to type 'string'
```

**Solution:**
```bash
# Clear Next.js cache
rm -rf .next

# Rebuild
npm run dev
```

---

## Development Workflow

### 1. Create New Feature Branch

```bash
git checkout -b feature/blueprint-upload-ui
```

### 2. Make Changes

```typescript
// Example: Create new API route
// src/app/api/my-feature/route.ts

import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  // Your code here
  return NextResponse.json({ success: true });
}
```

### 3. Test Locally

```bash
npm run dev
# Test in browser: http://localhost:3000
```

### 4. Commit & Push

```bash
git add .
git commit -m "Add blueprint upload UI"
git push origin feature/blueprint-upload-ui
```

### 5. Create Pull Request

Go to GitHub and create PR from your branch to `main`.

---

## Next Steps

Now that you have the project running:

1. **Explore the Dashboard:** http://localhost:3000/dashboard
2. **Read API Documentation:** [BLUEPRINT_AGENT_API_REFERENCE.md](BLUEPRINT_AGENT_API_REFERENCE.md)
3. **Understand Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md)
4. **Check Services:** [BLUEPRINT_AGENT_SERVICES.md](BLUEPRINT_AGENT_SERVICES.md)

### Recommended Learning Path

**Day 1:**
- Set up local environment
- Run development server
- Test basic API endpoints

**Day 2:**
- Read PROJECT_OVERVIEW.md
- Understand domain/resource/attribute model
- Explore database schema

**Day 3:**
- Read ARCHITECTURE.md
- Understand Next.js App Router
- Explore API routes

**Day 4:**
- Build first feature (e.g., blueprint upload UI)
- Test with real data
- Submit PR

---

## Support

**Questions?**
- Check [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)
- Email: contact@a2vibecreators.com
- GitHub Issues: https://github.com/a2vibecreators/quadframework/issues

---

**Ready to build?** Start with [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
