@echo off
echo ============================================
echo   KZ Business Database - Starting server
echo ============================================
echo.

:: Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Install from https://python.org
    pause
    exit /b 1
)

:: Install dependencies
echo Installing dependencies...
pip install anthropic -q

:: Start server
echo.
echo Starting server at http://localhost:8000
echo Press Ctrl+C to stop
echo.
start "" http://localhost:8000
python server.py

pause
