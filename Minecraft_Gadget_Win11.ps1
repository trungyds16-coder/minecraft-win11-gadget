﻿# ==============================================================================
# MINECRAFT WIN11 MINI GADGET (1.0 - 5.0 CM) - NATIVE WPF
# Thiết kế chuẩn Windows 11 Fluent: Bo góc mềm mại, Acrylic mờ siêu trong suốt
# Hiệu ứng đảo lơ lửng không gian, thác nước êm đềm, mưa rơi, sao đêm lấp lánh
# 100% mã nguồn mở an toàn & trong suốt. Không cần cài file EXE.
# ==============================================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# 1. Đảm bảo duy nhất 1 bản chạy ngầm (Đóng bản cũ nếu có)
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }
$settingsPath = Join-Path $scriptDir "settings.json"
$imgPath = Join-Path $scriptDir "island_clean.png"
$icoPath = Join-Path $scriptDir "gadget.ico"

try {
    Get-CimInstance Win32_Process | Where-Object { 
        $_.Name -eq 'powershell.exe' -and 
        $_.ProcessId -ne $PID -and 
        $_.CommandLine -match 'powershell(\.exe)?\s+.*-File\s+.*Minecraft_Gadget_Win11\.ps1' 
    } | ForEach-Object { 
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue 
    }
} catch {}

# 2. Cấu hình Mặc định & Tải Cài Đặt
$settings = @{
    size_cm = 1.2
    size_px = 46
    posX = -1
    posY = -1
    latitude = 10.8231
    longitude = 106.6297
    city = "TP.HCM"
    weather_mode = "auto"
    display_mode = "weather"
    always_on_top = $true
}

if (Test-Path $settingsPath) {
    try {
        $json = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.size_px -gt 0) { $settings.size_px = [int]$json.size_px }
        elseif ($json.size_cm -gt 0) { $settings.size_px = [int]([double]$json.size_cm * 38.0) }
        if ($null -ne $json.posX -and -not [double]::IsNaN([double]$json.posX)) { $settings.posX = [double]$json.posX }
        if ($null -ne $json.posY -and -not [double]::IsNaN([double]$json.posY)) { $settings.posY = [double]$json.posY }
        if ($json.latitude) { $settings.latitude = [double]$json.latitude }
        if ($json.longitude) { $settings.longitude = [double]$json.longitude }
        if ($json.city) { $settings.city = [string]$json.city }
        if ($json.weather_mode) { $settings.weather_mode = [string]$json.weather_mode }
        if ($json.display_mode) { $settings.display_mode = [string]$json.display_mode }
        if ($null -ne $json.always_on_top) { $settings.always_on_top = [bool]$json.always_on_top }
    } catch {}
}

if ($settings.size_px -lt 36) { $settings.size_px = 36 }
if ($settings.size_px -gt 220) { $settings.size_px = 220 }

function Save-SettingsFile {
    try {
        $workArea = [System.Windows.SystemParameters]::WorkArea
        $validPos = (-not [double]::IsNaN($window.Left)) -and ($window.Left -ge 0) -and ($window.Left -lt $workArea.Right) -and (-not [double]::IsNaN($window.Top)) -and ($window.Top -ge 0) -and ($window.Top -lt $workArea.Bottom)
        $curLeft = if ($validPos) { [Math]::Round($window.Left, 0) } else { $settings.posX }
        $curTop = if ($validPos) { [Math]::Round($window.Top, 0) } else { $settings.posY }
        
        $export = [ordered]@{
            size_cm = [Math]::Round($script:currentCardSize / 38.0, 1)
            size_px = [int]$script:currentCardSize
            huong_dan_kich_thuoc = "1.2 cm = 46 px | 2.0 cm = 76 px | 3.0 cm = 114 px | 4.0 cm = 152 px | 5.0 cm = 190 px. Lan con lan chuot de thu phong tuy y!"
            posX = $curLeft
            posY = $curTop
            latitude = $settings.latitude
            longitude = $settings.longitude
            city = $settings.city
            weather_mode = $script:weatherMode
            display_mode = $script:displayMode
            always_on_top = [bool]$window.Topmost
        }
        $export | ConvertTo-Json -Depth 4 | Set-Content $settingsPath -Encoding UTF8
    } catch {}
}

# 3. Giao diện XAML phong cách Windows 11 Fluent Acrylic
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Minecraft Win11 Mini Gadget"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        ResizeMode="NoResize"
        SnapsToDevicePixels="True"
        UseLayoutRounding="True">
    <Grid x:Name="RootGrid" Margin="10">
        <!-- Khung the kinh Acrylic phong cach Windows 11 Fluent -->
        <Border x:Name="CardBorder" 
                CornerRadius="14" 
                Background="#380F172A" 
                BorderBrush="#35FFFFFF" 
                BorderThickness="1" 
                ClipToBounds="True">
            <Border.Effect>
                <DropShadowEffect x:Name="CardShadow" BlurRadius="12" ShadowDepth="2" Direction="270" Color="#000000" Opacity="0.45"/>
            </Border.Effect>
            
            <Grid x:Name="ClipGrid">
                <!-- Khoi dao Voxel vua van khung hinh 100% -->
                <Grid x:Name="IslandBox" Margin="-2">
                    <Grid.RenderTransform>
                        <TranslateTransform x:Name="IslandFloat" Y="0"/>
                    </Grid.RenderTransform>
                    <Image x:Name="IslandImg" Stretch="UniformToFill" RenderOptions.BitmapScalingMode="HighQuality" Margin="0"/>
                    <!-- Canvas hieu ung hat thac nuoc & tia lua dung nham -->
                    <Canvas x:Name="FxCanvas" IsHitTestVisible="False"/>
                </Grid>
                
                <!-- Canvas bau troi: Hat mua & Sao dem phu tren nen canh -->
                <Canvas x:Name="SkyCanvas" IsHitTestVisible="False"/>
                
                <!-- Huy hieu thoi tiet / dong ho tinh te tren dinh -->
                <Border x:Name="BadgeBorder" 
                        CornerRadius="99" 
                        Background="#600B1322" 
                        BorderBrush="#30FFFFFF" 
                        BorderThickness="0.8" 
                        HorizontalAlignment="Center" 
                        VerticalAlignment="Top" 
                        Margin="0,3,0,0" 
                        Padding="4,0.5" 
                        Cursor="Hand"
                        ToolTip="Nhap chuot: Doi che do | Lan chuot: Thu phong (1 - 5 cm) | Nhap dup: Phun nham thach!">
                    <TextBlock x:Name="BadgeText" 
                               Text="28 deg" 
                               FontSize="7.5" 
                               Foreground="#F8FAFC" 
                               FontFamily="Segoe UI Variable Display, Segoe UI" 
                               FontWeight="SemiBold" 
                               VerticalAlignment="Center"
                               HorizontalAlignment="Center"/>
                </Border>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$rootGrid = $window.FindName("RootGrid")
$cardBorder = $window.FindName("CardBorder")
$clipGrid = $window.FindName("ClipGrid")
$islandBox = $window.FindName("IslandBox")
$islandFloat = $window.FindName("IslandFloat")
$islandImg = $window.FindName("IslandImg")
$badgeBorder = $window.FindName("BadgeBorder")
$badgeText = $window.FindName("BadgeText")
$skyCanvas = $window.FindName("SkyCanvas")
$fxCanvas = $window.FindName("FxCanvas")

# Tải ảnh voxel đảo nổi
if (Test-Path $imgPath) {
    try {
        $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
        $bitmap.BeginInit()
        $bitmap.UriSource = New-Object System.Uri($imgPath, [System.UriKind]::Absolute)
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.EndInit()
        $islandImg.Source = $bitmap
    } catch {}
}
if (Test-Path $icoPath) {
    try { $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create((New-Object System.Uri($icoPath, [System.UriKind]::Absolute))) } catch {}
}

# 4. Trạng thái hoạt động
$script:currentCardSize = $settings.size_px
$script:weatherMode = $settings.weather_mode
$script:displayMode = $settings.display_mode
$script:activeVisualMode = "sunny"
$script:realTemp = 28
$script:realWeatherCode = 0
$script:tick = 0
$rng = New-Object System.Random

# Biểu tượng thời tiết chuẩn BMP (khong gay loi font lexer PowerShell 5.1)
$script:ICON_SUN = [char]0x2600
$script:ICON_RAIN = [char]0x2614
$script:ICON_NIGHT = [char]0x263E

$script:waterList = [System.Collections.Generic.List[PSObject]]::new()
$script:lavaList = [System.Collections.Generic.List[PSObject]]::new()
$script:starList = [System.Collections.Generic.List[PSObject]]::new()
$script:rainList = [System.Collections.Generic.List[PSObject]]::new()

function Rebuild-StaticParticles {
    $skyCanvas.Children.Clear()
    $script:starList.Clear()
    $script:rainList.Clear()
    
    $sz = $script:currentCardSize
    
    # 32 ngoi sao dem lap lanh voi 3 tang kich thuoc khac nhau
    for ($i = 0; $i -lt 32; $i++) {
        $star = New-Object System.Windows.Shapes.Ellipse
        
        $tier = $rng.NextDouble()
        $baseR = if ($tier -lt 0.60) { 0.9 } elseif ($tier -lt 0.90) { 1.5 } else { 2.2 }
        $starSz = [Math]::Max(0.8, $baseR * ($sz / 90.0))
        $star.Width = $starSz
        $star.Height = $starSz
        
        if ($tier -ge 0.90) {
            $star.Fill = [System.Windows.Media.Brushes]::White
            $glow = New-Object System.Windows.Media.Effects.DropShadowEffect
            $glow.BlurRadius = [Math]::Max(2.0, $starSz * 1.5)
            $glow.Color = [System.Windows.Media.Color]::FromRgb(224, 242, 254)
            $glow.ShadowDepth = 0
            $glow.Opacity = 0.8
            $star.Effect = $glow
        } elseif ($tier -ge 0.60) {
            $star.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(230, 224, 242, 254))
        } else {
            $star.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(180, 186, 230, 253))
        }
        
        $sx = $rng.NextDouble() * $sz
        $sy = $rng.NextDouble() * ($sz * 0.92)
        [System.Windows.Controls.Canvas]::SetLeft($star, $sx)
        [System.Windows.Controls.Canvas]::SetTop($star, $sy)
        $skyCanvas.Children.Add($star) | Out-Null
        
        $script:starList.Add([PSCustomObject]@{
            Element = $star
            Phase = $rng.NextDouble() * 6.28
            Speed = 0.03 + ($rng.NextDouble() * 0.05)
            BaseOpacity = if ($tier -ge 0.90) { 0.9 } else { 0.65 }
        })
    }
    
    # 36 hat mua roi nhe nhang theo goc nghieng
    for ($i = 0; $i -lt 36; $i++) {
        $drop = New-Object System.Windows.Shapes.Rectangle
        $dropW = [Math]::Max(0.8, 1.0 * ($sz / 90.0))
        $dropH = [Math]::Max(2.5, (3.5 + ($rng.NextDouble() * 3.0)) * ($sz / 90.0))
        $drop.Width = $dropW
        $drop.Height = $dropH
        $drop.RadiusX = 0.5
        $drop.RadiusY = 0.5
        $drop.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(145, 186, 230, 253))
        $skyCanvas.Children.Add($drop) | Out-Null
        
        $script:rainList.Add([PSCustomObject]@{
            Element = $drop
            X = $rng.NextDouble()
            Y = $rng.NextDouble()
            Speed = 0.005 + ($rng.NextDouble() * 0.005) # Mua roi cham rai, nhe nhang, thu thai
        })
    }
}

function Apply-GadgetSize([int]$cardPx, [bool]$save = $true) {
    if ($cardPx -lt 36) { $cardPx = 36 }
    if ($cardPx -gt 220) { $cardPx = 220 }
    $script:currentCardSize = $cardPx
    
    $windowPadding = 20
    $window.Width = $cardPx + $windowPadding
    $window.Height = $cardPx + $windowPadding
    
    $cardBorder.Width = $cardPx
    $cardBorder.Height = $cardPx
    
    # Bo goc chuan Windows 11 Fluent ti le theo kich thuoc
    $rad = [Math]::Max(10, [int]($cardPx / 4.4))
    $cardBorder.CornerRadius = New-Object System.Windows.CornerRadius($rad)
    
    # Bo goc tron tuyet doi khop 100% vien trong khung the Windows 11
    $innerSz = [Math]::Max(1, $cardPx - 2)
    $innerRad = [Math]::Max(1, $rad - 1)
    $clipGeom = New-Object System.Windows.Media.RectangleGeometry
    $clipGeom.Rect = New-Object System.Windows.Rect(0, 0, $innerSz, $innerSz)
    $clipGeom.RadiusX = $innerRad
    $clipGeom.RadiusY = $innerRad
    $clipGrid.Clip = $clipGeom
    
    $fontSize = [Math]::Max(6.5, [Math]::Min(13.0, $cardPx * 0.14))
    $badgeText.FontSize = $fontSize
    $badgeBorder.Margin = New-Object System.Windows.Thickness(0, [Math]::Max(2.0, $cardPx * 0.04), 0, 0)
    
    Rebuild-StaticParticles
    if ($save) { Save-SettingsFile }
}

# Hieu ung dao lo lung nhip nhang (GPU Storyboard 60 FPS)
$floatAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
$floatAnim.From = -1.8
$floatAnim.To = 1.8
$floatAnim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromSeconds(3.4))
$floatAnim.AutoReverse = $true
$floatAnim.RepeatBehavior = [System.Windows.Media.Animation.RepeatBehavior]::Forever
$ease = New-Object System.Windows.Media.Animation.SineEase
$ease.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseInOut
$floatAnim.EasingFunction = $ease

$storyboard = New-Object System.Windows.Media.Animation.Storyboard
$storyboard.Children.Add($floatAnim)
[System.Windows.Media.Animation.Storyboard]::SetTarget($floatAnim, $islandFloat)
[System.Windows.Media.Animation.Storyboard]::SetTargetProperty($floatAnim, (New-Object System.Windows.PropertyPath("Y")))
$storyboard.Begin()

# 5. He thong hat: Thac nuoc chay nhe nhang & Tia lua nham thach
function Create-WaterDrop([bool]$randomProgress) {
    $isStream = ($rng.NextDouble() -lt 0.28)
    $prog = 0.0
    if ($randomProgress) { $prog = [float]$rng.NextDouble() }
    
    $rect = New-Object System.Windows.Shapes.Rectangle
    if ($rng.NextDouble() -lt 0.32) {
        $rect.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(210, 255, 255, 255))
    } else {
        $rect.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(185, 56, 189, 248))
    }
    [System.Windows.Controls.Canvas]::SetLeft($rect, -100)
    [System.Windows.Controls.Canvas]::SetTop($rect, -100)
    $fxCanvas.Children.Add($rect) | Out-Null
    
    # Toc do chay nhe nhang, thanh thoi (~3x cham hon ban cu)
    $spd = 0.005 + ($rng.NextDouble() * 0.006)
    $streamFactor = if ($isStream) { 0.02 } else { 0.035 }
    $offX = ($rng.NextDouble() - 0.5) * $streamFactor
    $sz = 0.9 + ($rng.NextDouble() * 1.3)
    
    return [PSCustomObject]@{
        Element = $rect
        IsStream = $isStream
        Progress = $prog
        Speed = $spd
        OffsetX = $offX
        Size = $sz
    }
}

function Spawn-LavaSparks([bool]$intense) {
    $count = 1 + $rng.Next(2)
    if ($intense) { $count = 18 }
    for ($i = 0; $i -lt $count; $i++) {
        $rect = New-Object System.Windows.Shapes.Rectangle
        $isBright = ($rng.NextDouble() -lt 0.5)
        if ($isBright) {
            $rect.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(250, 255, 230, 80))
        } else {
            $rect.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(250, 255, 90, 10))
        }
        $fxCanvas.Children.Add($rect) | Out-Null
        
        $vxMult = if ($intense) { 0.010 } else { 0.005 }
        $vyMult = if ($intense) { 0.012 } else { 0.007 }
        $vx = ($rng.NextDouble() - 0.5) * $vxMult
        $vy = -(0.005 + ($rng.NextDouble() * $vyMult))
        $dec = 0.022 + ($rng.NextDouble() * 0.018)
        $bsz = 1.0 + ($rng.NextDouble() * 1.6)
        
        $script:lavaList.Add([PSCustomObject]@{
            Element = $rect
            X = 0.505 + ($rng.NextDouble() - 0.5) * 0.07
            Y = 0.705 + ($rng.NextDouble() - 0.5) * 0.03
            VX = $vx
            VY = $vy
            Gravity = 0.00035
            Life = 1.0
            Decay = $dec
            BaseSize = $bsz
        })
    }
}

for ($i = 0; $i -lt 24; $i++) {
    $script:waterList.Add((Create-WaterDrop -randomProgress $true))
}

# 6. Vong lap cap nhat DispatcherTimer
$animTimer = New-Object System.Windows.Threading.DispatcherTimer
$animTimer.Interval = [TimeSpan]::FromMilliseconds(33)
$animTimer.Add_Tick({
    $script:tick++
    $W = $script:currentCardSize
    $H = $script:currentCardSize
    
    # Cap nhat nuoc chay nhe nhang theo toa do can xung moi
    foreach ($wp in $script:waterList) {
        $wp.Progress += $wp.Speed
        if ($wp.Progress -ge 1.0) {
            $wp.Progress = 0.0
            $wpStreamMult = if ($wp.IsStream) { 0.02 } else { 0.035 }
            $wp.OffsetX = ($rng.NextDouble() - 0.5) * $wpStreamMult
        }
        
        $px = 0.0
        $py = 0.0
        if ($wp.IsStream) {
            # Suoi nuoc tu dinh ra mep vach da
            $px = (0.520 + ($wp.Progress * 0.120) + $wp.OffsetX) * $W
            $py = (0.280 + ($wp.Progress * 0.080)) * $H
        } else {
            # Thac nuoc do em dem tu vach da xuong day hang (khop pixel-perfect voi buc hoa goc)
            $px = (0.655 + ($wp.Progress * 0.040) + $wp.OffsetX) * $W
            $py = (0.360 + ($wp.Progress * 0.580)) * $H
        }
        
        $s = [Math]::Max(1.0, $wp.Size * ($W / 75.0))
        $wp.Element.Width = $s
        $wpHeight = if ($wp.IsStream) { $s } else { $s * 1.5 }
        $wp.Element.Height = $wpHeight
        [System.Windows.Controls.Canvas]::SetLeft($wp.Element, $px)
        [System.Windows.Controls.Canvas]::SetTop($wp.Element, $py)
    }
    
    # Nham thach thinh thoang ban dom lua
    if ($rng.NextDouble() -lt 0.08) {
        Spawn-LavaSparks -intense $false
    }
    
    for ($i = $script:lavaList.Count - 1; $i -ge 0; $i--) {
        $d = $script:lavaList[$i]
        $d.X += $d.VX
        $d.Y += $d.VY
        $d.VY += $d.Gravity
        $d.Life -= $d.Decay
        
        if ($d.Life -le 0) {
            $fxCanvas.Children.Remove($d.Element) | Out-Null
            $script:lavaList.RemoveAt($i)
        } else {
            $s = [Math]::Max(1.0, $d.BaseSize * ($W / 75.0) * $d.Life)
            $d.Element.Width = $s
            $d.Element.Height = $s
            $d.Element.Opacity = $d.Life
            [System.Windows.Controls.Canvas]::SetLeft($d.Element, $d.X * $W)
            [System.Windows.Controls.Canvas]::SetTop($d.Element, $d.Y * $H)
        }
    }
    
    # Hieu ung bau troi: Sao dem lap lanh & Mua roi
    if ($script:activeVisualMode -eq "night") {
        $skyCanvas.Visibility = [System.Windows.Visibility]::Visible
        foreach ($s in $script:starList) {
            $s.Phase += $s.Speed
            $s.Element.Visibility = [System.Windows.Visibility]::Visible
            $pulsing = 0.2 + (0.8 * [Math]::Pow([Math]::Abs([Math]::Sin($s.Phase)), 1.5))
            $s.Element.Opacity = $pulsing * $s.BaseOpacity
        }
        foreach ($r in $script:rainList) {
            $r.Element.Visibility = [System.Windows.Visibility]::Collapsed
        }
    } elseif ($script:activeVisualMode -eq "rain") {
        $skyCanvas.Visibility = [System.Windows.Visibility]::Visible
        foreach ($s in $script:starList) {
            $s.Element.Visibility = [System.Windows.Visibility]::Collapsed
        }
        foreach ($r in $script:rainList) {
            $r.Element.Visibility = [System.Windows.Visibility]::Visible
            $r.Y += $r.Speed
            $r.X -= $r.Speed * 0.12
            if ($r.Y -gt 1.05) { $r.Y = -0.06; $r.X = $rng.NextDouble() }
            if ($r.X -lt -0.05) { $r.X = 1.05 }
            [System.Windows.Controls.Canvas]::SetLeft($r.Element, $r.X * $W)
            [System.Windows.Controls.Canvas]::SetTop($r.Element, $r.Y * $H)
        }
    } else {
        $skyCanvas.Visibility = [System.Windows.Visibility]::Collapsed
    }
})
$animTimer.Start()

# 7. Cap nhat Thoi tiet & Nhan hien thi Win 11 Acrylic
function Update-VisualState {
    $hour = (Get-Date).Hour
    $isNight = ($hour -ge 18 -or $hour -lt 6)
    $isRain = ($script:realWeatherCode -ge 51 -and $script:realWeatherCode -le 99)
    
    if ($script:weatherMode -eq "auto") {
        if ($isRain) { $script:activeVisualMode = "rain" }
        elseif ($isNight) { $script:activeVisualMode = "night" }
        else { $script:activeVisualMode = "sunny" }
    } else {
        $script:activeVisualMode = $script:weatherMode
    }
    
    # Doi mau nen kinh Acrylic trong suot tuy theo thoi tiet
    switch ($script:activeVisualMode) {
        "night" {
            # Ban dem: Nen toi huyen ao, sau tham, sao sang
            $cardBorder.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(90, 3, 7, 18))
            $cardBorder.BorderBrush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(65, 147, 197, 253))
        }
        "rain" {
            # Mua: Nen kinh xam lam diu mat, trong suot
            $cardBorder.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(68, 10, 20, 36))
            $cardBorder.BorderBrush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(60, 186, 230, 253))
        }
        default {
            # Nang: Nen kinh acrylic trong suot sieu dep, thay hinh nen
            $cardBorder.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(55, 15, 23, 42))
            $cardBorder.BorderBrush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(55, 255, 255, 255))
        }
    }
    
    if ($script:displayMode -eq "time") {
        $badgeText.Text = (Get-Date).ToString("HH:mm")
    } else {
        $icon = switch ($script:activeVisualMode) {
            "sunny" { "$($script:ICON_SUN)" }
            "rain"  { "$($script:ICON_RAIN)" }
            "night" { "$($script:ICON_NIGHT)" }
            default { "$($script:ICON_SUN)" }
        }
        $badgeText.Text = "$icon $($script:realTemp)" + [char]0x00B0
    }
}

# Tai thoi tiet Bat Dong Bo (Async, khong bao gio do giao dien)
function Fetch-WeatherAsync {
    Update-VisualState
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $lat = $settings.latitude.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        $lon = $settings.longitude.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        $url = "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=Asia%2FBangkok"
        
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "MinecraftWin11Gadget/2.0")
        $wc.Add_DownloadStringCompleted({
            param($s, $e)
            try {
                if ($null -eq $e.Error -and -not [string]::IsNullOrEmpty($e.Result)) {
                    $jsonStr = $e.Result
                    if ($jsonStr -match '"temperature"\s*:\s*([0-9.]+)') {
                        $script:realTemp = [int][Math]::Round([double]::Parse($matches[1], [System.Globalization.CultureInfo]::InvariantCulture))
                    }
                    if ($jsonStr -match '"weathercode"\s*:\s*(\d+)') {
                        $script:realWeatherCode = [int]$matches[1]
                    }
                    Update-VisualState
                }
            } catch {}
            try { $s.Dispose() } catch {}
        })
        $wc.DownloadStringAsync((New-Object System.Uri($url)))
    } catch {}
}

$weatherTimer = New-Object System.Windows.Threading.DispatcherTimer
$weatherTimer.Interval = [TimeSpan]::FromMinutes(10)
$weatherTimer.Add_Tick({ Fetch-WeatherAsync })
$weatherTimer.Start()

# 8. Tuong tac: Keo tha, Lan chuot thu phong (1 - 5 cm), Nhap dup
$window.Add_MouseLeftButtonDown({
    param($s, $e)
    if ($e.ClickCount -ge 2) {
        Spawn-LavaSparks -intense $true
    } else {
        try {
            $window.DragMove()
            Save-SettingsFile
        } catch {}
    }
})

$window.Add_MouseWheel({
    param($s, $e)
    $step = if ($e.Delta -gt 0) { 4 } else { -4 }
    Apply-GadgetSize ($script:currentCardSize + $step) $true
})

$badgeBorder.Add_MouseLeftButtonDown({
    param($s, $e)
    $e.Handled = $true
    if ($script:displayMode -eq "time") {
        $script:displayMode = "weather"
    } else {
        $modes = @("auto", "sunny", "rain", "night")
        $idx = ($modes.IndexOf($script:weatherMode) + 1) % $modes.Length
        $script:weatherMode = $modes[$idx]
    }
    Spawn-LavaSparks -intense $false
    Update-VisualState
    Save-SettingsFile
})

# 9. Menu Chuot Phai Chuan Windows 11 Fluent
$contextMenu = New-Object System.Windows.Controls.ContextMenu
$contextMenu.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(235, 15, 23, 42))
$contextMenu.BorderBrush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(60, 255, 255, 255))
$contextMenu.BorderThickness = New-Object System.Windows.Thickness(1)

function Add-MenuItem([string]$header, [scriptblock]$action, [bool]$isChecked = $false) {
    $item = New-Object System.Windows.Controls.MenuItem
    $item.Header = $header
    $item.Foreground = [System.Windows.Media.Brushes]::White
    $item.FontSize = 11.5
    $item.IsChecked = $isChecked
    $item.Add_Click($action)
    $contextMenu.Items.Add($item) | Out-Null
    return $item
}

function Add-MenuSeparator {
    $sep = New-Object System.Windows.Controls.Separator
    $sep.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(40, 255, 255, 255))
    $contextMenu.Items.Add($sep) | Out-Null
}

$titleItem = New-Object System.Windows.Controls.MenuItem
$titleItem.Header = "Minecraft Mini Gadget (Win 11)"
$titleItem.FontWeight = [System.Windows.FontWeights]::Bold
$titleItem.Foreground = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(56, 189, 248))
$titleItem.IsEnabled = $false
$contextMenu.Items.Add($titleItem) | Out-Null

Add-MenuSeparator

# Cac muc kich thuoc san co theo dung yeu cau: 1.2 cm, 2.0 cm, 3 cm, 4 cm, 5 cm
[void](Add-MenuItem "Kich thuoc: 1.2 cm (46 px) - Mac dinh" { Apply-GadgetSize 46 $true })
[void](Add-MenuItem "Kich thuoc: 2.0 cm (76 px) - Vua van" { Apply-GadgetSize 76 $true })
[void](Add-MenuItem "Kich thuoc: 3.0 cm (114 px) - Rong rai (3 cm)" { Apply-GadgetSize 114 $true })
[void](Add-MenuItem "Kich thuoc: 4.0 cm (152 px) - To ro net (4 cm)" { Apply-GadgetSize 152 $true })
[void](Add-MenuItem "Kich thuoc: 5.0 cm (190 px) - Co dai (5 cm)" { Apply-GadgetSize 190 $true })

Add-MenuSeparator

[void](Add-MenuItem "Thoi tiet: Tu dong theo thuc te" { $script:weatherMode = "auto"; Update-VisualState; Save-SettingsFile })
[void](Add-MenuItem "Thoi tiet: Nang dep" { $script:weatherMode = "sunny"; Update-VisualState; Save-SettingsFile })
[void](Add-MenuItem "Thoi tiet: Mua roi" { $script:weatherMode = "rain"; Update-VisualState; Save-SettingsFile })
[void](Add-MenuItem "Thoi tiet: Dem day sao" { $script:weatherMode = "night"; Update-VisualState; Save-SettingsFile })

Add-MenuSeparator

[void](Add-MenuItem "Hien thi: Doi Dong ho / Thoi tiet" { 
    $script:displayMode = if ($script:displayMode -eq "time") { "weather" } else { "time" }
    Update-VisualState
    Save-SettingsFile
})

$topItem = Add-MenuItem "Ghim: Luon noi tren cung (Topmost)" {
    $window.Topmost = -not $window.Topmost
    $topItem.IsChecked = $window.Topmost
    Save-SettingsFile
} -isChecked $settings.always_on_top

[void](Add-MenuItem "Vi tri: Dat lai goc duoi phai man hinh" {
    $workArea = [System.Windows.SystemParameters]::WorkArea
    $window.Left = $workArea.Right - $window.Width - 20
    $window.Top = $workArea.Bottom - $window.Height - 20
    Save-SettingsFile
})

[void](Add-MenuItem "Cai dat: Mo file settings.json" {
    Start-Process "notepad.exe" $settingsPath
})

Add-MenuSeparator

[void](Add-MenuItem "Thoat Gadget" {
    if ($trayIcon) {
        $trayIcon.Visible = $false
        $trayIcon.Dispose()
    }
    $window.Close()
    if ($app) { $app.Shutdown() }
})

$window.ContextMenu = $contextMenu

# 10. Bieu tuong Khay He thong (System Tray Icon)
$trayIcon = New-Object System.Windows.Forms.NotifyIcon
if (Test-Path $icoPath) {
    try { $trayIcon.Icon = New-Object System.Drawing.Icon($icoPath) } catch { $trayIcon.Icon = [System.Drawing.SystemIcons]::Application }
} else {
    $trayIcon.Icon = [System.Drawing.SystemIcons]::Application
}
$trayIcon.Text = "Minecraft Win11 Mini Gadget (1.2 - 5.0 cm)"
$trayIcon.Visible = $true

$trayMenu = New-Object System.Windows.Forms.ContextMenuStrip
$trayMenu.Items.Add("Hien Gadget / Len tren cung", $null, {
    $window.Activate()
    $window.Topmost = $true
    Spawn-LavaSparks -intense $true
}) | Out-Null
$trayMenu.Items.Add("-") | Out-Null
$trayMenu.Items.Add("Dat lai goc man hinh", $null, {
    $workArea = [System.Windows.SystemParameters]::WorkArea
    $window.Left = $workArea.Right - $window.Width - 20
    $window.Top = $workArea.Bottom - $window.Height - 20
    Save-SettingsFile
}) | Out-Null
$trayMenu.Items.Add("Thoat Gadget", $null, {
    $trayIcon.Visible = $false
    $trayIcon.Dispose()
    $window.Close()
    if ($app) { $app.Shutdown() }
}) | Out-Null

$trayIcon.ContextMenuStrip = $trayMenu
$trayIcon.Add_DoubleClick({
    $window.Activate()
    Spawn-LavaSparks -intense $true
})

# 11. Dat vi tri ban dau va khoi chay
$window.Add_SourceInitialized({
    Apply-GadgetSize $script:currentCardSize $false
    $window.Topmost = $settings.always_on_top
    
    $workArea = [System.Windows.SystemParameters]::WorkArea
    if ($settings.posX -ge 0 -and $settings.posY -ge 0 -and $settings.posX -lt ($workArea.Right - 10) -and $settings.posY -lt ($workArea.Bottom - 10)) {
        $window.Left = $settings.posX
        $window.Top = $settings.posY
    } else {
        $window.Left = [Math]::Max(10, $workArea.Right - $window.Width - 20)
        $window.Top = [Math]::Max(10, $workArea.Bottom - $window.Height - 20)
    }
    
    Fetch-WeatherAsync
})

$window.Add_ContentRendered({
    $window.Activate()
    try {
        $trayIcon.ShowBalloonTip(2500, "Minecraft Mini Gadget", "Gadget da san sang o goc man hinh! (Lan chuot de thu phong 1 - 5 cm)", [System.Windows.Forms.ToolTipIcon]::Info)
    } catch {}
})

$window.Add_Closed({
    if ($trayIcon) {
        $trayIcon.Visible = $false
        $trayIcon.Dispose()
    }
})

$app = [System.Windows.Application]::Current
if ($null -eq $app) {
    $app = New-Object System.Windows.Application
}
$app.ShutdownMode = [System.Windows.ShutdownMode]::OnExplicitShutdown
$app.Run($window) | Out-Null
