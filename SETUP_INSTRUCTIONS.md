# QUAD Platform - Setup Instructions

**Date:** December 31, 2025

---

## Quick Setup (3 Steps)

### Step 1: Run Database Setup

```bash
cd /Users/semostudio/git/a2vibecreators/quadframework
./database/setup-database.sh
```

This will:
- ✅ Create all tables (companies, users, domains, resources, attributes)
- ✅ Create A2Vibe Creators company
- ✅ Create test user (suman@a2vibecreators.com)
- ✅ Create test domain structure

---

### Step 2: Configure Google OAuth

1. **Add Google OAuth credentials to `.env`:**

```bash
# Copy example env
cp .env.example .env

# Edit .env and add:
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

NEXTAUTH_SECRET=any-random-string-here
NEXTAUTH_URL=http://localhost:3000
```

2. **Get Google OAuth credentials:**
   - Go to: https://console.cloud.google.com/apis/credentials
   - Create OAuth 2.0 Client ID
   - Add authorized redirect URI: `http://localhost:3000/api/auth/callback/google`
   - Copy Client ID and Client Secret to `.env`

---

### Step 3: Start Development Server

```bash
npm run dev
```

Open: http://localhost:3000

---

## Login Flow

### First Time (Google Sign-In)

1. Click "Sign in with Google"
2. Choose your Google account (suman@a2vibecreators.com)
3. NextAuth will:
   - ✅ Check if company exists (A2Vibe Creators - already created)
   - ✅ Auto-create user record with OAuth data
   - ✅ Assign DEVELOPER role
   - ✅ Redirect to dashboard

**Note:** You'll be auto-created as a user when you first sign in with Google, because the company `A2Vibe Creators` already exists with admin_email `suman@a2vibecreators.com`.

---

## Create NutriNine Domain (Manual via SQL)

After logging in, you can create NutriNine domain via SQL:

```sql
-- Connect to database
psql -h localhost -p 16201 -U nutrinine_user -d nutrinine_dev_db

-- Create NutriNine domain
INSERT INTO QUAD_domains (company_id, name, parent_domain_id, domain_type)
SELECT
  id,
  'NutriNine',
  NULL,  -- Root domain
  'healthcare'
FROM QUAD_companies
WHERE admin_email = 'suman@a2vibecreators.com';

-- Verify domain created
SELECT id, name, path FROM QUAD_domains WHERE name = 'NutriNine';
```

**Or wait for UI to be built** - then you can create domains via web interface!

---

## Test APIs (After Login)

```bash
# Get your user info
curl http://localhost:3000/api/auth/user-domains \
  -H "Cookie: next-auth.session-token=YOUR_TOKEN"

# Upload blueprint
curl -X POST http://localhost:3000/api/resources/{resourceId}/attributes/blueprint \
  -H "Content-Type: application/json" \
  -d '{
    "blueprintUrl": "https://figma.com/file/abc123"
  }'
```

---

## What You Get Out of the Box

After running setup:

✅ **Database:**
- All 10+ tables created
- Helper functions and triggers
- Validation logic

✅ **Company:**
- A2Vibe Creators company
- Your email as admin

✅ **Authentication:**
- Google OAuth configured
- Auto-create users on first login
- JWT session management

✅ **APIs (Ready to Use):**
- Blueprint upload
- Git repo linking
- Blueprint Agent interview
- Repo analysis

❌ **Not Ready Yet:**
- Frontend UI (needs to be built)
- Domain creation page
- Blueprint upload page

---

## Troubleshooting

### Database connection failed

```bash
# Check if PostgreSQL is running
docker ps | grep postgres-dev

# Start if not running
docker start postgres-dev
```

### Google OAuth not working

```bash
# Check .env file has credentials
cat .env | grep GOOGLE

# Make sure redirect URI matches in Google Console:
# http://localhost:3000/api/auth/callback/google
```

### Can't see domains after login

**Solution:** You need to manually create domains via SQL (see above) OR wait for domain creation UI to be built.

---

## Next Steps

1. ✅ Run `./database/setup-database.sh`
2. ✅ Configure `.env` with Google OAuth credentials
3. ✅ Run `npm run dev`
4. ✅ Sign in with Google
5. 🔜 Create NutriNine domain (via SQL or wait for UI)
6. 🔜 Test Blueprint Agent APIs

---

**Ready?** Run the setup script now! 🚀

```bash
./database/setup-database.sh
```
