# ==============================================================================
# QUAD Framework - Interactive Setup Script (PowerShell)
# ==============================================================================
# Compatible with: PowerShell 5.1+ (Windows 10+) and PowerShell 7+
#
# Usage: powershell -ExecutionPolicy Bypass -File .\deployment\scripts\setup.ps1
#
# This script will:
# 1. Check prerequisites (Docker, Node.js, Java, Maven, etc.)
# 2. Fetch secrets from Vaultwarden (OAuth credentials)
# 3. Set up Caddy reverse proxy configuration
# 4. Create Docker networks
# 5. Optionally deploy to DEV/QA
# ==============================================================================

#Requires -Version 5.1

# Error handling
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"  # Faster downloads

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

# ==============================================================================
# Helper Functions
# ==============================================================================

function Write-Status {
    param([string]$Message)
    Write-Host "[" -NoNewline
    Write-Host "✓" -ForegroundColor Green -NoNewline
    Write-Host "] $Message"
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[" -NoNewline
    Write-Host "!" -ForegroundColor Yellow -NoNewline
    Write-Host "] $Message"
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[" -NoNewline
    Write-Host "✗" -ForegroundColor Red -NoNewline
    Write-Host "] $Message"
}

function Write-Info {
    param([string]$Message)
    Write-Host "[" -NoNewline
    Write-Host "i" -ForegroundColor Cyan -NoNewline
    Write-Host "] $Message"
}

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━ $Message ━━━" -ForegroundColor Cyan
    Write-Host ""
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# ==============================================================================
# Banner
# ==============================================================================

Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "QUAD Framework - Interactive Setup" -ForegroundColor Yellow -NoNewline
Write-Host "                    ║" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "This wizard will help you set up QUAD for the first  " -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "time by:                                               " -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "  • Checking prerequisites                             " -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "  • Fetching secrets from Vaultwarden                  " -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "  • Configuring reverse proxy                          " -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "  • Creating Docker networks                           " -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  " -ForegroundColor Cyan -NoNewline
Write-Host "  • Deploying to DEV/QA                                " -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to continue"
Write-Host ""

# ==============================================================================
# Step 1: Prerequisites Check
# ==============================================================================

Write-Section "Step 1: Checking Prerequisites"

$MissingRequired = @()
$MissingOptional = @()

# Check Docker
if (Test-CommandExists "docker") {
    $dockerVersion = docker --version
    Write-Status "Docker: $dockerVersion"

    # Check if Docker daemon is running
    try {
        docker info | Out-Null
        Write-Status "Docker daemon is running"
    } catch {
        Write-Error-Custom "Docker daemon is not running - Start Docker Desktop"
        $MissingRequired += "Docker daemon"
    }
} else {
    Write-Error-Custom "Docker: Not installed"
    Write-Host "   Install: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    $MissingRequired += "Docker"
}

# Check Node.js
if (Test-CommandExists "node") {
    $nodeVersion = node --version
    Write-Status "Node.js: $nodeVersion"
} else {
    Write-Error-Custom "Node.js: Not installed"
    Write-Host "   Install: https://nodejs.org/" -ForegroundColor Yellow
    $MissingRequired += "Node.js"
}

# Check npm
if (Test-CommandExists "npm") {
    $npmVersion = npm --version
    Write-Status "npm: $npmVersion"
} else {
    Write-Error-Custom "npm: Not installed (comes with Node.js)"
    $MissingRequired += "npm"
}

# Check Java
if (Test-CommandExists "java") {
    $javaVersion = java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString() }
    Write-Status "Java: $javaVersion"
} else {
    Write-Error-Custom "Java: Not installed"
    Write-Host "   Install: https://adoptium.net/" -ForegroundColor Yellow
    $MissingRequired += "Java"
}

# Check Maven
if (Test-CommandExists "mvn") {
    $mvnVersion = mvn --version | Select-String "Apache Maven" | ForEach-Object { $_.ToString() }
    Write-Status "Maven: $mvnVersion"
} else {
    Write-Error-Custom "Maven: Not installed"
    Write-Host "   Install: https://maven.apache.org/download.cgi" -ForegroundColor Yellow
    $MissingRequired += "Maven"
}

# Check Git
if (Test-CommandExists "git") {
    $gitVersion = git --version
    Write-Status "Git: $gitVersion"
} else {
    Write-Error-Custom "Git: Not installed"
    Write-Host "   Install: https://git-scm.com/download/win" -ForegroundColor Yellow
    $MissingRequired += "Git"
}

Write-Host ""
Write-Host "Optional Software (Recommended):" -ForegroundColor Cyan
Write-Host ""

# Check Bitwarden CLI
if (Test-CommandExists "bw") {
    $bwVersion = bw --version
    Write-Status "Bitwarden CLI: $bwVersion"
} else {
    Write-Warning-Custom "Bitwarden CLI: Not installed"
    Write-Host "   Install: npm install -g @bitwarden/cli" -ForegroundColor Yellow
    $MissingOptional += "Bitwarden CLI"
}

Write-Host ""

# Check for missing required software
if ($MissingRequired.Count -gt 0) {
    Write-Error-Custom "Missing required software:"
    $MissingRequired | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host ""
    $Continue = Read-Host "Continue anyway? (y/N)"
    if ($Continue -ne "y" -and $Continue -ne "Y") {
        Write-Info "Setup cancelled. Please install missing software and try again."
        exit 1
    }
}

Write-Host ""
Read-Host "Press Enter to continue"
Write-Host ""

# ==============================================================================
# Step 2: Choose Environment
# ==============================================================================

Write-Section "Step 2: Environment Selection"

Write-Host "Which environment(s) do you want to set up?"
Write-Host "  1) DEV only"
Write-Host "  2) QA only"
Write-Host "  3) Both DEV and QA"
Write-Host ""

$EnvChoice = Read-Host "Enter choice (1-3) [1]"
if ([string]::IsNullOrWhiteSpace($EnvChoice)) { $EnvChoice = "1" }

$Environments = @()
switch ($EnvChoice) {
    "1" { $Environments = @("dev") }
    "2" { $Environments = @("qa") }
    "3" { $Environments = @("dev", "qa") }
    default {
        Write-Error-Custom "Invalid choice"
        exit 1
    }
}

Write-Status "Selected: $($Environments -join ', ')"
Write-Host ""

# ==============================================================================
# Step 3: Fetch Secrets (Windows users need WSL or manual .env creation)
# ==============================================================================

Write-Section "Step 3: Secrets Configuration"

Write-Warning-Custom "Bitwarden CLI (bw) requires Linux/WSL on Windows"
Write-Host ""
Write-Host "Options:"
Write-Host "  1) I have WSL installed - fetch secrets via WSL"
Write-Host "  2) I'll manually create .env files (see .env.example)"
Write-Host ""

$SecretChoice = Read-Host "Enter choice (1-2) [2]"
if ([string]::IsNullOrWhiteSpace($SecretChoice)) { $SecretChoice = "2" }

if ($SecretChoice -eq "1") {
    # Try to run bw via WSL
    if (Test-CommandExists "wsl") {
        Write-Info "Running fetch-secrets.sh via WSL..."
        foreach ($env in $Environments) {
            wsl bash "$ProjectRoot/deployment/scripts/fetch-secrets.sh" $env
        }
    } else {
        Write-Error-Custom "WSL not found"
        Write-Host "Install WSL: wsl --install" -ForegroundColor Yellow
        $SecretChoice = "2"
    }
}

if ($SecretChoice -eq "2") {
    Write-Warning-Custom "You'll need to manually create .env files"
    Write-Host ""
    Write-Host "Steps:"
    Write-Host "  1. Copy .env.example to .env in each environment folder"
    Write-Host "  2. Fill in OAuth credentials from Vaultwarden (vault.nutrinine.app)"
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  cd quad-web\deployment\dev"
    Write-Host "  copy .env.example .env"
    Write-Host "  notepad .env  # Edit and fill in real values"
    Write-Host ""
}

Write-Host ""
Read-Host "Press Enter to continue"
Write-Host ""

# ==============================================================================
# Step 4: Docker Networks
# ==============================================================================

Write-Section "Step 4: Docker Networks"

foreach ($env in $Environments) {
    $network = "docker_$env-network"

    $networkExists = docker network inspect $network 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Network exists: $network"
    } else {
        Write-Info "Creating network: $network"
        docker network create $network
        Write-Status "Created: $network"
    }
}

Write-Host ""

# ==============================================================================
# Step 5: Deploy
# ==============================================================================

Write-Section "Step 5: Deploy to Environment(s)"

Write-Host "Deploy now or deploy manually later?"
Write-Host "  1) Deploy now"
Write-Host "  2) Skip deployment (I'll deploy manually later)"
Write-Host ""

$DeployChoice = Read-Host "Enter choice (1-2) [2]"
if ([string]::IsNullOrWhiteSpace($DeployChoice)) { $DeployChoice = "2" }

if ($DeployChoice -eq "1") {
    Write-Host ""
    Write-Warning-Custom "Deployment on Windows requires WSL or Git Bash"
    Write-Host ""

    if (Test-CommandExists "wsl") {
        foreach ($env in $Environments) {
            Write-Info "Deploying to $env via WSL..."
            wsl bash "$ProjectRoot/quad-web/deployment/$env/$env-deploy.sh"
        }
    } elseif (Test-CommandExists "bash") {
        foreach ($env in $Environments) {
            Write-Info "Deploying to $env via Git Bash..."
            bash "$ProjectRoot/quad-web/deployment/$env/$env-deploy.sh"
        }
    } else {
        Write-Error-Custom "Neither WSL nor Git Bash found"
        Write-Host "Install WSL: wsl --install" -ForegroundColor Yellow
        Write-Host "Or install Git Bash: https://gitforwindows.org/" -ForegroundColor Yellow
    }
} else {
    Write-Info "Skipping deployment"
    Write-Host ""
    Write-Host "Deploy manually when ready:"
    foreach ($env in $Environments) {
        Write-Host "  bash quad-web/deployment/$env/$env-deploy.sh"
    }
}

Write-Host ""

# ==============================================================================
# Summary
# ==============================================================================

Write-Section "Setup Complete!"

Write-Host "✓ QUAD Framework setup finished!" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host ""

if ($DeployChoice -eq "2") {
    Write-Host "1. Deploy to environment(s):"
    foreach ($env in $Environments) {
        Write-Host "   bash quad-web/deployment/$env/$env-deploy.sh"
    }
    Write-Host ""
}

Write-Host "2. Access your deployments:"
foreach ($env in $Environments) {
    if ($env -eq "dev") {
        Write-Host "   DEV: https://dev.quadframe.work"
    } elseif ($env -eq "qa") {
        Write-Host "   QA: https://qa.quadframe.work"
    }
}

Write-Host ""
Write-Host "3. Check deployment status:"
Write-Host "   docker ps | findstr quad"
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  - Deployment guide: deployment\README.md"
Write-Host "  - Project docs: CLAUDE.md"
Write-Host ""

Write-Host "Happy coding, macha! 🚀" -ForegroundColor Green
Write-Host ""
