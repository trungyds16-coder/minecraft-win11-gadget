@echo off
setlocal
cd /d "%~dp0"
title Dong Goi Release Cho GitHub
chcp 65001 >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Dong_Goi_Release.ps1"

echo.
pause
