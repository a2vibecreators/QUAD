@echo off
REM =============================================================================
REM QUAD Framework - Interactive Setup Script (Windows Batch)
REM =============================================================================
REM Compatible with: Windows 7+ Command Prompt
REM
REM Usage: setup.bat
REM
REM This script will:
REM 1. Check prerequisites (Docker, Node.js, Java, Maven, etc.)
REM 2. Guide you to set up .env files manually
REM 3. Create Docker networks
REM 4. Optionally deploy to DEV/QA (via WSL or Git Bash)
REM =============================================================================

setlocal enabledelayedexpansion

REM Colors (limited in CMD)
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

cls
echo.
echo ================================================================
echo.
echo   QUAD Framework - Interactive Setup (Windows)
echo.
echo   This wizard will help you set up QUAD for the first time
echo.
echo ================================================================
echo.
pause

REM =============================================================================
REM Step 1: Prerequisites Check
REM =============================================================================

echo.
echo ━━━ Step 1: Checking Prerequisites ━━━
echo.

set "MISSING=0"

REM Check Docker
where docker >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo %GREEN%[√]%NC% Docker: Found
) else (
    echo %RED%[X]%NC% Docker: Not found
    echo    Install: https://www.docker.com/products/docker-desktop/
    set /a MISSING+=1
)

REM Check Node.js
where node >nul 2>&1
if %ERRORLEVEL% == 0 (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VER=%%i
    echo %GREEN%[√]%NC% Node.js: !NODE_VER!
) else (
    echo %RED%[X]%NC% Node.js: Not found
    echo    Install: https://nodejs.org/
    set /a MISSING+=1
)

REM Check Java
where java >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo %GREEN%[√]%NC% Java: Found
) else (
    echo %RED%[X]%NC% Java: Not found
    echo    Install: https://adoptium.net/
    set /a MISSING+=1
)

REM Check Maven
where mvn >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo %GREEN%[√]%NC% Maven: Found
) else (
    echo %RED%[X]%NC% Maven: Not found
    echo    Install: https://maven.apache.org/download.cgi
    set /a MISSING+=1
)

REM Check Git
where git >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo %GREEN%[√]%NC% Git: Found
) else (
    echo %RED%[X]%NC% Git: Not found
    echo    Install: https://git-scm.com/download/win
    set /a MISSING+=1
)

echo.
if %MISSING% GTR 0 (
    echo %RED%Missing %MISSING% required software%NC%
    echo.
    set /p CONTINUE="Continue anyway? (y/N): "
    if /i not "!CONTINUE!"=="y" (
        echo Setup cancelled.
        exit /b 1
    )
)

pause

REM =============================================================================
REM Step 2: Environment Selection
REM =============================================================================

echo.
echo ━━━ Step 2: Environment Selection ━━━
echo.
echo Which environment(s) do you want to set up?
echo   1) DEV only
echo   2) QA only
echo   3) Both DEV and QA
echo.
set /p ENV_CHOICE="Enter choice (1-3) [1]: "
if "!ENV_CHOICE!"=="" set ENV_CHOICE=1

if "!ENV_CHOICE!"=="1" set ENVS=dev
if "!ENV_CHOICE!"=="2" set ENVS=qa
if "!ENV_CHOICE!"=="3" set ENVS=dev qa

echo Selected: !ENVS!
echo.
pause

REM =============================================================================
REM Step 3: Manual .env Setup
REM =============================================================================

echo.
echo ━━━ Step 3: Environment Variables Setup ━━━
echo.
echo %YELLOW%[!]%NC% Windows users must manually create .env files
echo.
echo Steps for each environment:
echo   1. Navigate to: quad-web\deployment\dev (or qa)
echo   2. Copy: .env.example to .env
echo   3. Edit .env with OAuth credentials from Vaultwarden
echo.
echo Example:
echo   cd quad-web\deployment\dev
echo   copy .env.example .env
echo   notepad .env
echo.
set /p DONE_ENV="Press Enter when .env files are ready..."

REM =============================================================================
REM Step 4: Docker Networks
REM =============================================================================

echo.
echo ━━━ Step 4: Docker Networks ━━━
echo.

for %%e in (%ENVS%) do (
    docker network inspect docker_%%e-network >nul 2>&1
    if %ERRORLEVEL% == 0 (
        echo %GREEN%[√]%NC% Network exists: docker_%%e-network
    ) else (
        echo Creating network: docker_%%e-network
        docker network create docker_%%e-network
        echo %GREEN%[√]%NC% Created: docker_%%e-network
    )
)

echo.
pause

REM =============================================================================
REM Step 5: Deployment
REM =============================================================================

echo.
echo ━━━ Step 5: Deploy to Environment(s) ━━━
echo.
echo Deploy now or deploy manually later?
echo   1) Deploy now (requires WSL or Git Bash)
echo   2) Skip deployment
echo.
set /p DEPLOY_CHOICE="Enter choice (1-2) [2]: "
if "!DEPLOY_CHOICE!"=="" set DEPLOY_CHOICE=2

if "!DEPLOY_CHOICE!"=="1" (
    echo.
    where wsl >nul 2>&1
    if %ERRORLEVEL% == 0 (
        for %%e in (%ENVS%) do (
            echo Deploying to %%e via WSL...
            wsl bash quad-web/deployment/%%e/%%e-deploy.sh
        )
    ) else (
        where bash >nul 2>&1
        if %ERRORLEVEL% == 0 (
            for %%e in (%ENVS%) do (
                echo Deploying to %%e via Git Bash...
                bash quad-web/deployment/%%e/%%e-deploy.sh
            )
        ) else (
            echo %RED%[X]%NC% Neither WSL nor Git Bash found
            echo Install WSL: wsl --install
            echo Or install Git Bash: https://gitforwindows.org/
        )
    )
) else (
    echo Skipping deployment
    echo.
    echo Deploy manually when ready:
    for %%e in (%ENVS%) do (
        echo   bash quad-web/deployment/%%e/%%e-deploy.sh
    )
)

REM =============================================================================
REM Summary
REM =============================================================================

echo.
echo ━━━ Setup Complete! ━━━
echo.
echo %GREEN%√ QUAD Framework setup finished!%NC%
echo.
echo Next Steps:
echo   1. Access your deployments:
for %%e in (%ENVS%) do (
    if "%%e"=="dev" echo      DEV: https://dev.quadframe.work
    if "%%e"=="qa" echo      QA: https://qa.quadframe.work
)
echo.
echo   2. Check status: docker ps ^| findstr quad
echo.
echo   3. Read docs: CLAUDE.md
echo.
echo Happy coding!
echo.
pause
