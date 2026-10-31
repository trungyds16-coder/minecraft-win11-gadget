# ==============================================================================
# TRÌNH GỠ CÀI ĐẶT SẠCH SẼ - MINECRAFT WIN11 MINI GADGET (POWERSHELL)
# ==============================================================================
Write-Host "==============================================================================" -ForegroundColor Red
Write-Host "       GỠ CÀI ĐẶT SẠCH SẼ - MINECRAFT WIN11 MINI GADGET" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Red
Write-Host ""
Write-Host "Bạn có chắc chắn muốn gỡ cài đặt Minecraft Win11 Gadget khỏi máy tính không?" -ForegroundColor White
Write-Host "Toàn bộ phím tắt Desktop, Start Menu và dữ liệu cài đặt sẽ được dọn dẹp sạch sẽ." -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Nhập 'Y' để xác nhận gỡ bỏ [Y/N]"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Đã hủy thao tác gỡ cài đặt." -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "Đang tiến hành gỡ bỏ tiện ích..." -ForegroundColor Cyan

# 1. Dừng tiến trình Gadget
try {
    Get-CimInstance Win32_Process | Where-Object { 
        $_.Name -eq 'powershell.exe' -and 
        $_.CommandLine -match 'Minecraft_Gadget_Win11\.ps1' 
    } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
} catch {}

# 2. Xóa phím tắt Desktop
$desktop = [Environment]::GetFolderPath('Desktop')
$deskLnk = Join-Path $desktop "Minecraft Win11 Gadget.lnk"
if (Test-Path $deskLnk) { Remove-Item $deskLnk -Force -ErrorAction SilentlyContinue }

# 3. Xóa phím tắt Start Menu
$startDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Minecraft Win11 Gadget"
if (Test-Path $startDir) { Remove-Item $startDir -Recurse -Force -ErrorAction SilentlyContinue }

# 4. Xóa phím tắt Startup
$startupDir = [Environment]::GetFolderPath('Startup')
$startupLnk = Join-Path $startupDir "Minecraft_Win11_Gadget.lnk"
if (Test-Path $startupLnk) { Remove-Item $startupLnk -Force -ErrorAction SilentlyContinue }

# 5. Xóa thư mục cài đặt trong LocalAppData
$installDir = Join-Path $env:LOCALAPPDATA "Programs\Minecraft_Win11_Gadget"
if (Test-Path $installDir) {
    Start-Sleep -Seconds 1
    Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "                ĐÃ GỠ CÀI ĐẶT THÀNH CÔNG VÀ SẠCH SẼ!" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "Cảm ơn bạn đã trải nghiệm Minecraft Win11 Mini Gadget." -ForegroundColor White
