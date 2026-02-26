@echo off
title Multi-App Installer v0.3 Launcher

echo ===============================
echo Multi-App Installer v0.3
echo Starting...
echo ===============================

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo This script must be run as Administrator.
    echo Right-click and choose "Run as administrator".
    pause
    exit /b 1
)

:: Run PowerShell script with temporary execution policy bypass
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Multi-App-Installer-v0.3.ps1"

echo.
echo Script finished with exit code %errorlevel%
pause