@echo off
setlocal
title Dong Minecraft Mini Gadget
echo Dang tat Minecraft Mini Gadget...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*Minecraft_Gadget_Win11.ps1*' } | Stop-Process -Force"
echo Da dong Gadget thanh cong!
timeout /t 2 >nul
