# ==============================================================================
# SCRIPT ĐÓNG GÓI PHÁT HÀNH CHO GITHUB (POWERSHELL)
# ==============================================================================
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "       ĐÓNG GÓI PHÁT HÀNH GITHUB - MINECRAFT WIN11 MINI GADGET v2.0" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Đang chuẩn bị các tệp và nén thành gói cài đặt phát hành..." -ForegroundColor Gray

$parent = Split-Path -Parent $scriptDir
$zipName = "Minecraft_Win11_Gadget_v2.0_Setup.zip"
$outZip = Join-Path $parent $zipName

if (Test-Path $outZip) {
    Remove-Item $outZip -Force
}

$includeFiles = @(
    "Cai_Dat_Gadget.bat",
    "Cai_Dat_Gadget.ps1",
    "Go_Cai_Dat_Gadget.bat",
    "Go_Cai_Dat_Gadget.ps1",
    "Chay_Gadget_Win11.bat",
    "Chay_Gadget_Win11.vbs",
    "Dung_Gadget.bat",
    "Khoi_Chay_Gadget.lnk",
    "Cai_Dat_Khoi_Dong_Cung_Windows.bat",
    "Minecraft_Gadget_Win11.ps1",
    "island_clean.png",
    "gadget.ico",
    "minecraft_cube.png",
    "settings.json",
    "HUONG_DAN_MINI_1_2CM.txt",
    "NHAT_KY_KIEN_TRUC_GADGET.md",
    "README.md",
    "LICENSE",
    ".gitignore"
)

$tempFolder = Join-Path $env:TEMP ("Minecraft_Release_" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
$releaseRoot = Join-Path $tempFolder "Minecraft_Win11_Gadget_v2.0"
New-Item -ItemType Directory -Path $releaseRoot -Force | Out-Null

foreach ($f in $includeFiles) {
    $p = Join-Path $scriptDir $f
    if (Test-Path $p) {
        Copy-Item $p (Join-Path $releaseRoot $f) -Force
    }
}

Compress-Archive -Path $releaseRoot -DestinationPath $outZip -CompressionLevel Optimal
Remove-Item $tempFolder -Recurse -Force -ErrorAction SilentlyContinue

if (Test-Path $outZip) {
    $fi = Get-Item $outZip
    Write-Host ""
    Write-Host "[THÀNH CÔNG] Đã đóng gói xong gói cài đặt phát hành:" -ForegroundColor Green
    Write-Host ("  Đường dẫn: " + $outZip) -ForegroundColor White
    Write-Host ("  Dung lượng: " + [Math]::Round($fi.Length / 1KB, 1) + " KB") -ForegroundColor Yellow
    Write-Host ""
    Write-Host "File ZIP này đã sẵn sàng để bạn đưa lên mục Releases trên GitHub!" -ForegroundColor Cyan
    Write-Host "==============================================================================" -ForegroundColor Cyan
} else {
    Write-Host "[LỖI] Không thể tạo file zip phát hành." -ForegroundColor Red
}
