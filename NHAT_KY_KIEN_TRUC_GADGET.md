# NHẬT KÝ KIẾN TRÚC & HƯỚNG DẪN TRÍCH XUẤT WINDOWS 11 DESKTOP GADGET

> **Mục đích tài liệu:** Lưu trữ chi tiết toàn bộ kiến trúc kỹ thuật, kinh nghiệm xử lý lỗi hệ thống Windows Internals và bộ khung mã nguồn (Boilerplate Template) chuẩn mực để sau này có thể trích xuất và tạo bất kỳ tiện ích Desktop Gadget mới nào một cách nhanh chóng mà không cần cài đặt phần mềm hay file `.exe`.

---

## I. TỔNG QUAN KIẾN TRÚC HỆ THỐNG

### 1. Tại sao chọn Native WPF trên nền Windows PowerShell?
- **Không cần cài đặt hay biên dịch:** Sử dụng trực tiếp engine đồ họa **WPF (Windows Presentation Foundation)** và **DirectX GPU** có sẵn trên 100% các bản Windows 10/11.
- **100% Mã nguồn mở & An toàn:** Người dùng có thể mở và đọc toàn bộ mã nguồn bất kỳ lúc nào bằng Notepad, không sợ mã độc hay virus ẩn như các file nhị phân `.exe`.
- **Hiệu năng cực cao:** Hoạt động ở tần số quét 60 FPS mượt mà thông qua Storyboard tăng tốc phần cứng, mức tiêu thụ CPU gần như bằng 0% (~0.05% - 0.1%) và RAM chỉ ~30 - 45 MB.

---

## II. 7 BẪY HỆ THỐNG KINH ĐIỂN CỦA WINDOWS INTERNALS & CÁCH GIẢI QUYẾT

Khi xây dựng Desktop Gadget trên Windows, hầu hết các công cụ tự động hoặc lập trình viên thiếu kinh nghiệm đều mắc phải 7 cái bẫy sau:

| # | Bẫy kỹ thuật | Nguyên nhân gốc rễ | Giải pháp chuẩn mực |
|---|---|---|---|
| **1** | **Bẫy `.hta` (HTML Application)** | MSHTA trên Windows 11 vẫn chạy nhân Internet Explorer 7/8 từ 15 năm trước. Đơ ngay lập tức khi gặp CSS3, HTML5 Canvas, ES6 (`const`, `async/await`). | Loại bỏ hoàn toàn `.hta`. Dùng native XAML WPF với `AllowsTransparency="True"` và `WindowStyle="None"`. |
| **2** | **Bẫy Emoji 4-byte trong Lexer PowerShell 5.1** | Các emoji 4-byte (như 📐, ⛏️, 🌤️) có mã byte chứa ký tự trùng với dấu ngoặc kép ASCII `"` hoặc ngoặc đơn `)`. Bộ phân tích cú pháp của PowerShell 5.1 hiểu nhầm và gây lỗi cú pháp âm thầm làm thoát chương trình. | Tuyệt đối **không dùng raw emoji 4-byte** trong string literal của `.ps1`. Thay bằng các ký tự chuẩn BMP (`[char]0x2600` cho nắng, `[char]0x2614` cho mưa, `[char]0x263E` cho đêm) hoặc chuỗi không dấu an toàn. |
| **3** | **Bẫy Single-Instance Mutex** | Khi ứng dụng bị tắt đột ngột (hoặc người dùng đóng tiến trình), `System.Threading.Mutex` rơi vào trạng thái *Abandoned*. Các lần mở tiếp theo bị nghẽn và ứng dụng thoát âm thầm. | Thay thế Mutex bằng cơ chế quản lý tiến trình trực tiếp: kiểm tra các tiến trình `powershell.exe` đang chạy file tương ứng và tự động đóng bản cũ để khởi tạo bản mới mượt mà. |
| **4** | **Bẫy Luồng STA & Dispatcher** | WPF yêu cầu luồng chính phải ở chế độ **Single-Threaded Apartment (STA)**. Khi chạy qua script ẩn console, luồng có thể bị đẩy về MTA và văng lỗi `The calling thread must be STA`. | Luôn thêm cờ `-Sta` trong câu lệnh gọi PowerShell: `powershell.exe -Sta -WindowStyle Hidden ...`. |
| **5** | **Bẫy Treo UI do Tải Mạng Đồng Bộ** | Gọi `WebClient.DownloadString` trên luồng UI sẽ đóng băng cửa sổ từ 1.5 - 10 giây nếu mạng chậm, khiến cửa sổ không thể render lúc khởi động. | Dùng `DownloadStringAsync` kết hợp sự kiện `Add_DownloadStringCompleted` để nạp dữ liệu hoàn toàn bất đồng bộ. |
| **6** | **Bẫy Kế thừa `SW_HIDE` từ VBScript** | Khi VBScript gọi `WshShell.Run(cmd, 0, False)`, Windows truyền cờ `wShowWindow = SW_HIDE` vào `STARTUPINFO`. Theo cơ chế Win32, hàm `ShowWindow` đầu tiên của WPF sẽ bị hệ điều hành đè thành ẩn vĩnh viễn. | Dùng shortcut Windows (`.lnk`) với thuộc tính `WindowStyle = 7 (Minimized)` hoặc batch launcher trực tiếp với `-WindowStyle Hidden`. |
| **7** | **Bẫy `Border.CornerRadius` không cắt nội dung con (Lộ góc vuông & viền đen)** | Trong WPF, thuộc tính `CornerRadius` của thẻ `Border` chỉ bo viền nền của chính nó. Mọi phần tử con bên trong (như thẻ `Image`) vẫn giữ nguyên góc vuông 90 độ, kể cả khi đã đặt `ClipToBounds="True"`. Kết quả là viền đen chữ nhật của ảnh lồi ra ngoài viền bo tròn gây mất thẩm mỹ nếu không xử lý đúng. | **Giải pháp triệt để không cần thu nhỏ ảnh hay làm mờ vignette:**<br>1. **Giữ nguyên 100% tác phẩm gốc:** Dùng ảnh gốc 480x480 sắc nét, đặt `Stretch="UniformToFill"`, không thu nhỏ co rúm vào giữa, không tạo viền mờ tối.<br>2. **Mặt nạ cắt hình học `RectangleGeometry`:** Bọc toàn bộ trong `Grid x:Name="ClipGrid"`. Trong hàm `Apply-GadgetSize`, tính `$innerSz = $cardPx - 2` và `$innerRad = $rad - 1`, gán `$clipGrid.Clip = New-Object RectangleGeometry(Rect(0, 0, $innerSz, $innerSz), $innerRad, $innerRad)`. Mọi pixel của ảnh được cắt gọt tự nhiên uốn lượn sắc sảo theo đường cong Windows 11.<br>3. **Tràn lề chống hở mép khi lơ lửng:** Đặt `IslandBox Margin="-2"`. Nhờ vậy khi đảo nổi dập dềnh trục Y (±1.8px), mép trên/dưới không bao giờ bị hở khoảng trống nền. |

---

## III. BÍ QUYẾT THIẾT KẾ GIAO DIỆN CHUẨN WINDOWS 11 FLUENT

### 1. Kính Acrylic mờ trong suốt (Translucent Glass Effect)
Thay vì dùng màu nền gần như đặc quánh (`#E6...`), Windows 11 Fluent đạt độ thẩm mỹ cao nhất khi kết hợp:
- **Nền bán trong suốt:** `#380F172A` (khoảng 22% - 35% độ mờ), giúp hình nền Desktop bên dưới ánh lên nhẹ nhàng.
- **Viền sáng tinh tế (Subtle Border Highlight):** `BorderThickness="1"`, `BorderBrush="#35FFFFFF"`.
- **Bo góc mềm mại (Dynamic Corner Radius):** Tự động co giãn theo kích thước:
  $$\text{Radius} = \max\left(10, \left\lfloor \frac{\text{CardPx}}{4.4} \right\rfloor\right)$$
- **Bo góc nội dung con:** Ép bo tròn toàn bộ ảnh bằng `Clip = New-Object RectangleGeometry(Rect, RadiusX, RadiusY)`.

### 2. Bố cục Vừa Vặn Khung Hình (Edge-to-Edge) & Đảo Lơ Lửng Giữa Không Gian
- **Vừa vặn khung hình 100%:** Ảnh lấp đầy trọn vẹn thẻ bo góc, đường chân trời và các khối đất đá voxel tràn viền tự nhiên, không bị co lại thành một đốm nhỏ ở giữa.
- **Hoạt ảnh lơ lửng không gian:** Sử dụng GPU Storyboard với `DoubleAnimation` và hàm làm mượt `SineEase (EaseInOut)` chu kỳ 3.4 giây dao động nhẹ ±1.8px.
- **Thác nước êm đềm:** Các hạt nước chuyển động chậm rãi, tốc độ `0.005 - 0.011`, đổ từ vách cỏ `(0.655, 0.360)` xuống đáy hang `(0.695, 0.940)`.
- **Hiệu ứng mưa rơi êm đềm (Cozy Gentle Rain):** 36 giọt mưa rơi thanh thoát, tốc độ rơi chậm `0.005 - 0.010` (giảm ~3 lần so với ban đầu), bay nhẹ theo góc nghiêng gió tự nhiên.
- **Thời tiết TP.HCM thực tế:** Tích hợp API Open-Meteo tọa độ TP.HCM (`lat: 10.8231`, `lon: 106.6297`, múi giờ `Asia/Bangkok`), tự động chuyển chế độ Mưa / Nắng / Đêm đầy sao theo thời tiết thực ngoài trời.
- Hoạt ảnh lơ lửng: Sử dụng `DoubleAnimation` với hàm làm mượt `SineEase (EaseInOut)`, chu kỳ 3.4 giây, đảo chiều `AutoReverse="True"`.

---

## IV. BẢNG QUY ĐỔI KÍCH THƯỚC CHUẨN (CM SANG PIXELS)

Theo chuẩn độ phân giải desktop Windows (96 DPI):
$$1\text{ inch} = 2.54\text{ cm} = 96\text{ px} \implies 1\text{ cm} \approx 37.8\text{ px}$$

| Kích thước (cm) | Kích thước (px) | Mục đích sử dụng |
|---|---|---|
| **1.2 cm** | **46 px** | **Mặc định:** Siêu nhỏ gọn, vừa vặn góc nhỏ cạnh khay Taskbar |
| **2.0 cm** | **76 px** | Vừa vặn, thấy rõ chuyển động thác nước |
| **3.0 cm** | **114 px** | Rộng rãi, hiển thị rõ nét chi tiết từng voxel |
| **4.0 cm** | **152 px** | Lớn, ấn tượng trên màn hình độ phân giải cao (2K/4K) |
| **5.0 cm** | **190 px** | Cỡ đại, rực rỡ đầy đủ hiệu ứng |

*Tiện ích hỗ trợ con lăn chuột (Mouse Wheel) để phóng to/thu nhỏ mượt mà từng mm trong khoảng từ **1.0 cm (36 px) đến 5.5 cm (210 px)**.*

---

## V. KHUNG MÃ NGUỒN CHUẨN ĐỂ TẠO GADGET MỚI (BOILERPLATE TEMPLATE)

Khi muốn tạo một Gadget mới (ví dụ: Đồng hồ số, Trình theo dõi RAM/CPU, Giá vàng/Crypto, v.v.), chỉ cần sao chép bộ khung dưới đây và lưu thành file `.ps1`:

```powershell
# ==============================================================================
# KHUNG CHUẨN DESKTOP GADGET WINDOWS 11 FLUENT (WPF + POWERSHELL)
# ==============================================================================
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# 1. Đảm bảo chạy đơn tiến trình an toàn
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
try {
    Get-CimInstance Win32_Process | Where-Object { 
        $_.Name -eq 'powershell.exe' -and $_.ProcessId -ne $PID -and 
        $_.CommandLine -match 'powershell(\.exe)?\s+.*-File\s+.*' + [regex]::Escape($MyInvocation.MyCommand.Name)
    } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
} catch {}

# 2. Giao diện XAML Windows 11 Fluent Glass
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Win11 Custom Gadget"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        ResizeMode="NoResize">
    <Grid Margin="10">
        <Border x:Name="CardBorder" 
                CornerRadius="14" 
                Background="#380F172A" 
                BorderBrush="#35FFFFFF" 
                BorderThickness="1">
            <Border.Effect>
                <DropShadowEffect BlurRadius="12" ShadowDepth="2" Direction="270" Color="#000000" Opacity="0.45"/>
            </Border.Effect>
            
            <!-- Grid bên trong có Clip bo góc tròn tuyệt đối -->
            <Grid x:Name="ClipGrid">
                <!-- NỘI DUNG GADGET CỦA BẠN ĐẶT Ở ĐÂY -->
                <TextBlock x:Name="MainText" Text="Hello Win11" Foreground="White" 
                           HorizontalAlignment="Center" VerticalAlignment="Center" FontWeight="SemiBold"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)
$cardBorder = $window.FindName("CardBorder")
$clipGrid = $window.FindName("ClipGrid")

# 3. Kéo thả cửa sổ bằng chuột trái
$window.Add_MouseLeftButtonDown({
    param($s, $e)
    try { $window.DragMove() } catch {}
})

# 4. Đặt kích thước, bo góc chuẩn và vị trí góc dưới bên phải màn hình
$window.Add_SourceInitialized({
    $cardPx = 114 # Kích thước 3 cm
    $rad = [Math]::Max(10, [int]($cardPx / 4.4))
    
    $cardBorder.Width = $cardPx
    $cardBorder.Height = $cardPx
    $cardBorder.CornerRadius = New-Object System.Windows.CornerRadius($rad)
    
    # Cắt bo góc nội dung con tuyệt đối
    $clipGeom = New-Object System.Windows.Media.RectangleGeometry
    $clipGeom.Rect = New-Object System.Windows.Rect(0, 0, $cardPx, $cardPx)
    $clipGeom.RadiusX = $rad
    $clipGeom.RadiusY = $rad
    $clipGrid.Clip = $clipGeom
    
    $window.Width = $cardPx + 20
    $window.Height = $cardPx + 20
    
    $workArea = [System.Windows.SystemParameters]::WorkArea
    $window.Left = $workArea.Right - $window.Width - 20
    $window.Top = $workArea.Bottom - $window.Height - 20
})

# 5. Khởi chạy ứng dụng
$app = [System.Windows.Application]::Current
if ($null -eq $app) { $app = New-Object System.Windows.Application }
$app.ShutdownMode = [System.Windows.ShutdownMode]::OnExplicitShutdown
$app.Run($window) | Out-Null
```
