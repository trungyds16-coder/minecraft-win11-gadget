@echo off
setlocal
cd /d "%~dp0"
title Cai Dat Minecraft Win11 Mini Gadget
chcp 65001 >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Cai_Dat_Gadget.ps1"

echo.
pause
