@echo off
setlocal
cd /d "%~dp0"
title Minecraft Win11 Mini Gadget

start "" powershell.exe -Sta -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File ".\Minecraft_Gadget_Win11.ps1"
exit /b