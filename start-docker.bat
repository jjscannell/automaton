@echo off
echo ========================================
echo   Docker Orchestration System
echo ========================================
echo.
echo Starting containers...
echo.

cd /d %~dp0

REM Check if .env exists
if not exist .env (
    echo ERROR: .env file not found!
    echo Please copy .env.template to .env and configure it.
    echo.
    pause
    exit /b 1
)

docker-compose up -d

echo.
echo ========================================
echo   System Started!
echo ========================================
echo.
echo n8n Dashboard: http://localhost:5678
echo ngrok Status:  http://localhost:4040
echo.
echo Container Status:
docker-compose ps
echo.
echo Press any key to open n8n in browser...
pause >nul
start http://localhost:5678
