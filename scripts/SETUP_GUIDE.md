# QUAD Framework - Setup Guide

This guide explains how to set up QUAD Framework on different operating systems (Windows, Mac, Linux).

## Quick Start by Platform

### Windows

1. **Open PowerShell as Administrator** (right-click → "Run as Administrator")

2. **Run prerequisites check:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup-prerequisites.ps1
   ```

3. **Install missing dependencies** (script will show you what's needed)

4. **After prerequisites are installed, continue with:**
   - Use **Git Bash** to run `.sh` scripts
   - Or install **WSL2** for full Linux compatibility

### Mac

1. **Open Terminal**

2. **Run prerequisites check:**
   ```bash
   ./scripts/setup-prerequisites.sh
   ```

3. **Install missing dependencies** (script will show Homebrew commands)

4. **After prerequisites are installed, continue with full setup:**
   ```bash
   ./deployment/scripts/setup-local.sh
   ```

### Linux (Ubuntu/Debian)

1. **Open Terminal**

2. **Run prerequisites check:**
   ```bash
   ./scripts/setup-prerequisites.sh
   ```

3. **Install missing dependencies** (script will show apt-get commands)

4. **After prerequisites are installed, continue with full setup:**
   ```bash
   ./deployment/scripts/setup-local.sh
   ```

---

## Prerequisites

All platforms need:

| Software | Version | Purpose | Windows | Mac | Linux |
|----------|---------|---------|---------|-----|-------|
| **Node.js** | 18+ | Next.js web app | [Download](https://nodejs.org) | `brew install node` | `apt install nodejs npm` |
| **Docker Desktop** | Latest | Containers | [Download](https://docs.docker.com/desktop/windows/install/) | `brew install --cask docker` | [Install](https://docs.docker.com/engine/install/) |
| **Git** | Latest | Version control | [Download](https://git-scm.com/download/win) | `brew install git` | `apt install git` |
| **Java JDK** | 17+ | Spring Boot services | [Download](https://adoptium.net) | `brew install openjdk@17` | `apt install openjdk-17-jdk` |
| **Maven** | 3.8+ | Java build tool | [Download](https://maven.apache.org) | `brew install maven` | `apt install maven` |
| **Bitwarden CLI** | Latest | Vault secrets (optional) | `choco install bitwarden-cli` | `brew install bitwarden-cli` | [Download](https://bitwarden.com/help/cli/) |

---

## Platform-Specific Notes

### Windows Development

**Recommended Setup:**
1. Install **Chocolatey** (package manager): https://chocolatey.org/install
2. Install **Git Bash** (comes with Git for Windows)
3. Use **Windows Terminal** for better CLI experience
4. Install **WSL2** (optional but recommended): https://docs.microsoft.com/en-us/windows/wsl/install

**Using Git Bash (Recommended):**
```bash
# Open Git Bash (installed with Git for Windows)
cd /c/Users/YourName/git/QUAD
./deployment/scripts/setup-local.sh
```

**Using WSL2 (Advanced):**
```bash
# In WSL2 Ubuntu terminal
cd /mnt/c/Users/YourName/git/QUAD
./deployment/scripts/setup-local.sh
```

**Using PowerShell (Windows-native):**
```powershell
# Run prerequisites check
.\scripts\setup-prerequisites.ps1

# Then use Git Bash for .sh scripts
# (PowerShell doesn't run bash scripts natively)
```

**Docker Desktop Configuration:**
- Enable WSL2 backend (Settings → General → Use WSL2 based engine)
- Increase memory to 4GB+ (Settings → Resources → Advanced)
- Enable file sharing for your project directory

### Mac Development

**Recommended Setup:**
1. Install **Homebrew**: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
2. Install **iTerm2** (better terminal): `brew install --cask iterm2`
3. Install **VS Code**: `brew install --cask visual-studio-code`

**Docker Desktop Configuration:**
- Increase memory to 4GB+ (Preferences → Resources → Advanced)
- Increase CPU cores to 4+ (Preferences → Resources → Advanced)

### Linux Development

**Docker Permissions:**
```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
# Or restart your session
```

**Port Conflicts:**
```bash
# Check if ports 14001, 15001, 14201, 15201 are in use
sudo netstat -tulpn | grep -E '14001|15001|14201|15201'
```

---

## Setup Scripts

| Script | Platform | Purpose |
|--------|----------|---------|
| `scripts/setup-prerequisites.ps1` | Windows | Check and install prerequisites |
| `scripts/setup-prerequisites.sh` | Mac/Linux | Check and install prerequisites |
| `deployment/scripts/setup-local.sh` | Mac/Linux | Full local development setup |
| `scripts/setup-dev-environment.sh` | Mac/Linux | Fetch secrets from Vaultwarden |
| `deployment/scripts/deploy-studio.sh` | Mac/Linux | Deploy to Mac Studio (DEV/QA) |

---

## Step-by-Step Setup

### 1. Check Prerequisites

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-prerequisites.ps1
```

**Mac/Linux:**
```bash
./scripts/setup-prerequisites.sh
```

### 2. Install Missing Dependencies

Follow the script's output to install any missing software.

### 3. Clone Repository

```bash
git clone git@github.com:a2Vibes/QUAD.git
cd QUAD
git submodule update --init --recursive
```

### 4. Setup Environment

**Option A: Using Vaultwarden (if you have access):**
```bash
# Login to Vaultwarden
bw config server https://vault.nutrinine.app
bw login

# Unlock vault
export BW_SESSION=$(bw unlock --raw)

# Fetch credentials and create .env files
./scripts/setup-dev-environment.sh
```

**Option B: Manual .env.local creation:**
```bash
# Create quad-web/.env.local manually
cp quad-web/.env.example quad-web/.env.local
# Edit .env.local with your credentials
```

### 5. Run Local Development Setup

**Mac/Linux:**
```bash
./deployment/scripts/setup-local.sh
```

**Windows (Git Bash):**
```bash
bash deployment/scripts/setup-local.sh
```

This script will:
- Create PostgreSQL container
- Run database migrations
- Install dependencies
- Generate Prisma client
- Seed test data

### 6. Start Development Server

```bash
cd quad-web
npm run dev
```

Visit: http://localhost:14001

---

## Troubleshooting

### Windows

**PowerShell execution policy error:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

**Docker not starting:**
- Ensure Hyper-V is enabled (Windows Features)
- Ensure WSL2 is installed and updated
- Restart Docker Desktop

**Git Bash not found:**
```powershell
choco install git -y
# Git Bash is included with Git for Windows
```

### Mac

**Homebrew not found:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Docker permission denied:**
- Open Docker Desktop and make sure it's running
- Check Docker Desktop settings → Resources

**Port already in use:**
```bash
# Find process using port 14001
lsof -i :14001

# Kill process (replace PID)
kill -9 <PID>
```

### Linux

**Docker permission denied:**
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

**Docker not starting:**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

---

## Port Allocations

| Environment | Service | Port | Container |
|-------------|---------|------|-----------|
| DEV | Web | 14001 | quad-web-dev |
| DEV | API | 14101 | quad-services-dev |
| DEV | Database | 14201 | postgres-quad-dev |
| QA | Web | 15001 | quad-web-qa |
| QA | API | 15101 | quad-services-qa |
| QA | Database | 15201 | postgres-quad-qa |
| Local | Web | 3000 | (npm run dev) |
| Local | Database | 5432 | quad-local-db |

---

## Next Steps

After successful setup:

1. **Explore the codebase:**
   - `quad-web/` - Next.js frontend
   - `quad-services/` - Java Spring Boot backend
   - `quad-database/` - Database migrations
   - `documentation/` - Project documentation

2. **Read documentation:**
   - `CLAUDE.md` - Project overview and development guide
   - `documentation/QUAD_DEVELOPMENT_MODEL.md` - QUAD methodology
   - `documentation/TEST_JOURNEYS.md` - Test scenarios

3. **Access Vaultwarden** (if team member):
   - https://vault.nutrinine.app
   - Request access from admin (sumanaddanki)

4. **Join GitHub organization:**
   - https://github.com/a2Vibes
   - Request access from admin

---

## Support

**Documentation:**
- Main docs: `CLAUDE.md`
- This guide: `scripts/SETUP_GUIDE.md`
- Deployment: `deployment/scripts/deploy-studio.sh`

**Contact:**
- GitHub Issues: https://github.com/a2Vibes/QUAD/issues
- Email: (to be added)

---

**Last Updated:** January 4, 2026
