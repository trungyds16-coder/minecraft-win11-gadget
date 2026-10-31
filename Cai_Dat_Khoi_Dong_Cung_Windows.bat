@echo off
setlocal
chcp 65001 >nul
title Cài đặt Khởi động cùng Windows cho Minecraft Gadget

set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT_PATH=%STARTUP_DIR%\Minecraft_Win11_Gadget.lnk"
set "PS_SCRIPT=%~dp0Minecraft_Gadget_Win11.ps1"

echo ========================================================================
echo   CÀI ĐẶT KHỞI ĐỘNG CÙNG WINDOWS - MINECRAFT WIN 11 MINI GADGET
echo ========================================================================
echo.
if exist "%SHORTCUT_PATH%" (
    echo [TRẠNG THÁI] Gadget ĐANG được bật khởi động cùng Windows.
    echo.
    echo 1. Tắt khởi động cùng Windows (Xóa phím tắt)
    echo 2. Thoát
    echo.
    set /p choice="Nhập lựa chọn của bạn (1/2): "
    if "%choice%"=="1" (
        del /f /q "%SHORTCUT_PATH%"
        echo [THÀNH CÔNG] Đã tắt khởi động cùng Windows!
    )
) else (
    echo [TRẠNG THÁI] Gadget CHƯA bật khởi động cùng Windows.
    echo.
    echo 1. Bật khởi động cùng Windows (Tự mở Gadget khi bật máy tính)
    echo 2. Thoát
    echo.
    set /p choice="Nhập lựa chọn của bạn (1/2): "
    if "%choice%"=="1" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$wsh = New-Object -ComObject WScript.Shell; $sc = $wsh.CreateShortcut('%SHORTCUT_PATH%'); $sc.TargetPath = 'powershell.exe'; $sc.Arguments = '-Sta -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File \"%PS_SCRIPT%\"'; $sc.WorkingDirectory = '%~dp0'; $sc.WindowStyle = 7; $sc.Save()"
        echo [THÀNH CÔNG] Đã bật tự khởi động cùng Windows thành công!
    )
)
echo.
pause
