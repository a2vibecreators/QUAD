# QUAD Framework - Windows Prerequisites Setup
# Purpose: Check and install required software for QUAD development on Windows
# Usage: powershell -ExecutionPolicy Bypass -File .\scripts\setup-prerequisites.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║     QUAD Framework - Windows Prerequisites Setup              ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  Warning: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "   Some installations may require admin privileges" -ForegroundColor Yellow
    Write-Host ""
}

# Track what needs to be installed
$missingDeps = @()
$installCommands = @()

Write-Host "Checking prerequisites..." -ForegroundColor Blue
Write-Host ""

# Function to check if command exists
function Test-Command {
    param($command)
    try {
        if (Get-Command $command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

# Function to get command version
function Get-CommandVersion {
    param($command, $versionArg = "--version")
    try {
        $output = & $command $versionArg 2>&1
        return $output
    }
    catch {
        return "unknown"
    }
}

# Check Chocolatey (package manager for Windows)
if (Test-Command "choco") {
    Write-Host "  ✓ Chocolatey found" -ForegroundColor Green
    $hasChoco = $true
}
else {
    Write-Host "  ⚠️  Chocolatey not found (recommended for auto-install)" -ForegroundColor Yellow
    Write-Host "     Install from: https://chocolatey.org/install" -ForegroundColor Gray
    $hasChoco = $false
    Write-Host ""
}

# Check Node.js
if (Test-Command "node") {
    $nodeVersion = node -v
    $nodeMajorVersion = [int]($nodeVersion -replace "v", "" -split "\.")[0]

    if ($nodeMajorVersion -ge 18) {
        Write-Host "  ✓ Node.js $nodeVersion found" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Node.js version 18+ required (found $nodeVersion)" -ForegroundColor Red
        $missingDeps += "Node.js 18+"
        if ($hasChoco) {
            $installCommands += "choco install nodejs-lts -y"
        }
    }
}
else {
    Write-Host "  ✗ Node.js not found" -ForegroundColor Red
    $missingDeps += "Node.js"
    if ($hasChoco) {
        $installCommands += "choco install nodejs-lts -y"
    }
}

# Check npm
if (Test-Command "npm") {
    $npmVersion = npm -v
    Write-Host "  ✓ npm $npmVersion found" -ForegroundColor Green
}
else {
    Write-Host "  ✗ npm not found" -ForegroundColor Red
    $missingDeps += "npm (comes with Node.js)"
}

# Check Docker
if (Test-Command "docker") {
    try {
        docker info 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $dockerVersion = (docker --version).Split(" ")[2].TrimEnd(",")
            Write-Host "  ✓ Docker $dockerVersion running" -ForegroundColor Green
        }
        else {
            Write-Host "  ⚠️  Docker installed but not running" -ForegroundColor Yellow
            Write-Host "     Start Docker Desktop" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  ⚠️  Docker installed but not running" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  ✗ Docker not found" -ForegroundColor Red
    $missingDeps += "Docker Desktop"
    if ($hasChoco) {
        $installCommands += "choco install docker-desktop -y"
    }
}

# Check Git
if (Test-Command "git") {
    $gitVersion = (git --version).Split(" ")[2]
    Write-Host "  ✓ Git $gitVersion found" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Git not found" -ForegroundColor Red
    $missingDeps += "Git"
    if ($hasChoco) {
        $installCommands += "choco install git -y"
    }
}

# Check Java
if (Test-Command "java") {
    $javaVersion = java -version 2>&1 | Select-String -Pattern "version" | Out-String
    Write-Host "  ✓ Java found ($($javaVersion.Trim()))" -ForegroundColor Green
}
else {
    Write-Host "  ⚠️  Java not found (required for QUAD services)" -ForegroundColor Yellow
    $missingDeps += "Java JDK 17+"
    if ($hasChoco) {
        $installCommands += "choco install openjdk17 -y"
    }
}

# Check Maven
if (Test-Command "mvn") {
    $mvnVersion = (mvn -v | Select-String -Pattern "Apache Maven").ToString().Split(" ")[2]
    Write-Host "  ✓ Maven $mvnVersion found" -ForegroundColor Green
}
else {
    Write-Host "  ⚠️  Maven not found (required for QUAD services)" -ForegroundColor Yellow
    $missingDeps += "Maven"
    if ($hasChoco) {
        $installCommands += "choco install maven -y"
    }
}

# Check Bitwarden CLI (optional)
if (Test-Command "bw") {
    $bwVersion = (bw --version).ToString()
    Write-Host "  ✓ Bitwarden CLI $bwVersion found (optional)" -ForegroundColor Green
}
else {
    Write-Host "  ℹ️  Bitwarden CLI not found (optional - for vault secrets)" -ForegroundColor Cyan
}

Write-Host ""

# Summary
if ($missingDeps.Count -eq 0) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              ✅ All prerequisites met!                         ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "  1. cd quad-web" -ForegroundColor White
    Write-Host "  2. npm install" -ForegroundColor White
    Write-Host "  3. npm run dev" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run the full setup:" -ForegroundColor Green
    Write-Host "  .\scripts\setup-local.sh (in Git Bash)" -ForegroundColor White
    Write-Host ""
}
else {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║              Missing Dependencies                              ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""

    foreach ($dep in $missingDeps) {
        Write-Host "  ✗ $dep" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""

    if ($hasChoco -and $installCommands.Count -gt 0) {
        Write-Host "Automatic Installation (with Chocolatey):" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Run these commands as Administrator:" -ForegroundColor Yellow
        Write-Host ""
        foreach ($cmd in $installCommands) {
            Write-Host "  $cmd" -ForegroundColor Cyan
        }
        Write-Host ""
        Write-Host "Or install all at once:" -ForegroundColor Yellow
        Write-Host "  " + ($installCommands -join "; ") -ForegroundColor Cyan
        Write-Host ""
    }

    Write-Host "Manual Installation Links:" -ForegroundColor Yellow
    Write-Host ""

    foreach ($dep in $missingDeps) {
        switch -Wildcard ($dep) {
            "Node.js*" {
                Write-Host "  Node.js: https://nodejs.org/en/download/" -ForegroundColor White
            }
            "Docker*" {
                Write-Host "  Docker Desktop: https://docs.docker.com/desktop/windows/install/" -ForegroundColor White
            }
            "Git" {
                Write-Host "  Git: https://git-scm.com/download/win" -ForegroundColor White
            }
            "Java*" {
                Write-Host "  Java JDK 17: https://adoptium.net/temurin/releases/?os=windows" -ForegroundColor White
            }
            "Maven" {
                Write-Host "  Maven: https://maven.apache.org/download.cgi" -ForegroundColor White
            }
        }
    }

    Write-Host ""
    Write-Host "After installing, run this script again to verify." -ForegroundColor Yellow
    Write-Host ""
}

# Additional notes
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tips for Windows Development:" -ForegroundColor Cyan
Write-Host "  • Use Git Bash for running .sh scripts" -ForegroundColor Gray
Write-Host "  • Or install WSL2 (Windows Subsystem for Linux)" -ForegroundColor Gray
Write-Host "  • Configure Docker Desktop to use WSL2 backend" -ForegroundColor Gray
Write-Host "  • Use Windows Terminal for better CLI experience" -ForegroundColor Gray
Write-Host ""
