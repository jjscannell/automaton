@echo off
echo ========================================
echo   Stopping Orchestration System
echo ========================================
echo.

cd /d %~dp0
docker-compose down

echo.
echo System stopped successfully.
echo.
pause
