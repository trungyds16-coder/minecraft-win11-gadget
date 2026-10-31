# ==============================================================================
# TRÌNH CÀI ĐẶT TỰ ĐỘNG - MINECRAFT WIN11 MINI GADGET v2.0 (POWERSHELL)
# ==============================================================================
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "       TRÌNH CÀI ĐẶT TỰ ĐỘNG - MINECRAFT WIN11 MINI GADGET v2.0" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tiện ích Desktop Gadget phong cách Windows 11 Fluent Acrylic:" -ForegroundColor White
Write-Host "- Đảo lập phương Voxel lơ lửng, thác nước êm đềm, mưa rơi, sao đêm lấp lánh" -ForegroundColor Gray
Write-Host "- Icon khối lập phương 3D Minecraft isometric cho Desktop & Start Menu" -ForegroundColor Gray
Write-Host "- Tự động đồng bộ thời tiết TP.HCM thời gian thực" -ForegroundColor Gray
Write-Host "- 100% mã nguồn mở an toàn, không virus, không cần cài file .EXE" -ForegroundColor Gray
Write-Host ""
Write-Host "------------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Vui lòng chọn tác vụ cài đặt:" -ForegroundColor Yellow
Write-Host "  [1] Cài đặt vào máy (Tạo phím tắt Desktop + Start Menu)" -ForegroundColor White
Write-Host "  [2] Cài đặt + Tự động khởi động cùng Windows (Startup)" -ForegroundColor White
Write-Host "  [3] Chạy ngay phiên bản Portable (Không cần cài đặt)" -ForegroundColor White
Write-Host "  [4] Thoát" -ForegroundColor White
Write-Host "------------------------------------------------------------------------------" -ForegroundColor DarkGray

$choice = Read-Host "Nhập lựa chọn của bạn (1/2/3/4) [Mặc định 1]"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }
if ($choice -eq "4") { exit 0 }

if ($choice -eq "3") {
    Write-Host ""
    Write-Host "Đang khởi chạy Gadget chế độ Portable..." -ForegroundColor Cyan
    Start-Process "powershell.exe" -ArgumentList @("-Sta", "-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-NoProfile", "-File", (Join-Path $scriptDir "Minecraft_Gadget_Win11.ps1"))
    Write-Host "Đã khởi chạy thành công!" -ForegroundColor Green
    return
}

$enableStartup = ($choice -eq "2")

Write-Host ""
Write-Host "Đang tiến hành cài đặt tiện ích vào hệ thống..." -ForegroundColor Cyan

$target = Join-Path $env:LOCALAPPDATA "Programs\Minecraft_Win11_Gadget"
if (-not (Test-Path $target)) {
    New-Item -ItemType Directory -Path $target -Force | Out-Null
}

# 1. Đóng phiên bản đang chạy nếu có
try {
    Get-CimInstance Win32_Process | Where-Object { 
        $_.Name -eq 'powershell.exe' -and 
        $_.CommandLine -match 'Minecraft_Gadget_Win11\.ps1' 
    } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
} catch {}

# 2. Sao chép tệp cần thiết
$files = @(
    "Minecraft_Gadget_Win11.ps1",
    "island_clean.png",
    "gadget.ico",
    "minecraft_cube.png",
    "Chay_Gadget_Win11.bat",
    "Chay_Gadget_Win11.vbs",
    "Dung_Gadget.bat",
    "Go_Cai_Dat_Gadget.bat",
    "Go_Cai_Dat_Gadget.ps1",
    "HUONG_DAN_MINI_1_2CM.txt",
    "NHAT_KY_KIEN_TRUC_GADGET.md"
)

foreach ($f in $files) {
    $srcFile = Join-Path $scriptDir $f
    if (Test-Path $srcFile) {
        Copy-Item $srcFile (Join-Path $target $f) -Force
    }
}

# Giữ nguyên settings nếu đã có, nếu chưa thì chép mặc định
$setSrc = Join-Path $scriptDir "settings.json"
$setDst = Join-Path $target "settings.json"
if (Test-Path $setSrc -and (-not (Test-Path $setDst))) {
    Copy-Item $setSrc $setDst -Force
}

$wsh = New-Object -ComObject WScript.Shell
$psExe = "C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe"
$targetScript = Join-Path $target "Minecraft_Gadget_Win11.ps1"
$targetIco = Join-Path $target "gadget.ico"

# 3. Tạo phím tắt Desktop với icon khối lập phương Minecraft
$desktop = [Environment]::GetFolderPath('Desktop')
$deskLnk = Join-Path $desktop "Minecraft Win11 Gadget.lnk"
$sc = $wsh.CreateShortcut($deskLnk)
$sc.TargetPath = $psExe
$sc.Arguments = "-Sta -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File `"$targetScript`""
$sc.WorkingDirectory = $target
$sc.IconLocation = "$targetIco,0"
$sc.Description = "Minecraft Windows 11 Mini Desktop Gadget (1.0 - 5.0 cm)"
$sc.WindowStyle = 7
$sc.Save()

# 4. Tạo phím tắt Start Menu
$startDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Minecraft Win11 Gadget"
if (-not (Test-Path $startDir)) { New-Item -ItemType Directory -Path $startDir -Force | Out-Null }

$startLnk = Join-Path $startDir "Minecraft Win11 Gadget.lnk"
$sc2 = $wsh.CreateShortcut($startLnk)
$sc2.TargetPath = $psExe
$sc2.Arguments = "-Sta -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File `"$targetScript`""
$sc2.WorkingDirectory = $target
$sc2.IconLocation = "$targetIco,0"
$sc2.Description = "Minecraft Windows 11 Mini Desktop Gadget"
$sc2.WindowStyle = 7
$sc2.Save()

$uninstLnk = Join-Path $startDir "Gỡ cài đặt Minecraft Gadget.lnk"
$sc3 = $wsh.CreateShortcut($uninstLnk)
$sc3.TargetPath = Join-Path $target "Go_Cai_Dat_Gadget.bat"
$sc3.WorkingDirectory = $target
$sc3.IconLocation = "shell32.dll,31"
$sc3.Description = "Gỡ cài đặt Minecraft Win11 Gadget sạch sẽ"
$sc3.Save()

# 5. Cấu hình tự khởi động cùng Windows
if ($enableStartup) {
    $startupDir = [Environment]::GetFolderPath('Startup')
    $startupLnk = Join-Path $startupDir "Minecraft_Win11_Gadget.lnk"
    $sc4 = $wsh.CreateShortcut($startupLnk)
    $sc4.TargetPath = $psExe
    $sc4.Arguments = "-Sta -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File `"$targetScript`""
    $sc4.WorkingDirectory = $target
    $sc4.IconLocation = "$targetIco,0"
    $sc4.Description = "Khởi động Minecraft Gadget cùng Windows"
    $sc4.WindowStyle = 7
    $sc4.Save()
}

# 6. Khởi động Gadget ngay lập tức từ thư mục đã cài đặt
Start-Process "powershell.exe" -ArgumentList @("-Sta", "-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-NoProfile", "-File", $targetScript)

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "                     CÀI ĐẶT HOÀN TẤT THÀNH CÔNG!" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "- Thư mục cài đặt: $target" -ForegroundColor White
Write-Host "- Đã tạo icon khối lập phương Minecraft ngoài Màn hình Desktop" -ForegroundColor White
Write-Host "- Đã tạo nhóm phím tắt trong Start Menu" -ForegroundColor White
if ($enableStartup) {
    Write-Host "- Đã bật tự khởi động cùng Windows khi bật máy tính" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Gadget đã được kích hoạt và xuất hiện ở góc dưới bên phải màn hình!" -ForegroundColor Cyan
Write-Host "(Đưa chuột lên Gadget và lăn con lăn chuột để thu phóng từ 1.0 đến 5.5 cm)" -ForegroundColor Gray
Write-Host "==============================================================================" -ForegroundColor Green
