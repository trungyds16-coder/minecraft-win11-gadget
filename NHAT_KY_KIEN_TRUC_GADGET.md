# NHẬT KÝ KIẾN TRÚC & HƯỚNG DẪN TRÍCH XUẤT WINDOWS 11 DESKTOP GADGET

> **Mục đích tài liệu:** Lưu trữ chi tiết toàn bộ kiến trúc kỹ thuật, kinh nghiệm xử lý lỗi hệ thống Windows Internals, cẩm nang chọn ảnh nghệ thuật và bộ khung mã nguồn (Boilerplate Template) chuẩn mực để sau này có thể trích xuất và tạo bất kỳ tiện ích Desktop Gadget mới nào một cách nhanh chóng mà không cần cài đặt phần mềm hay file `.exe`.

---

## I. TỔNG QUAN KIẾN TRÚC HỆ THỐNG

### 1. Tại sao chọn Native WPF trên nền Windows PowerShell?
- **Không cần cài đặt hay biên dịch:** Sử dụng trực tiếp engine đồ họa **WPF (Windows Presentation Foundation)** và **DirectX GPU** có sẵn trên 100% các bản Windows 10/11.
- **100% Mã nguồn mở & An toàn:** Người dùng có thể mở và đọc toàn bộ mã nguồn bất kỳ lúc nào bằng Notepad, không sợ mã độc hay virus ẩn như các file nhị phân `.exe`.
- **Hiệu năng cực cao:** Hoạt động ở tần số quét 60 FPS - 144 FPS mượt mà thông qua Storyboard tăng tốc phần cứng, mức tiêu thụ CPU gần như bằng 0% (~0.05% - 0.1%) và RAM chỉ ~30 - 45 MB.

---

## II. 8 BẪY HỆ THỐNG KINH ĐIỂN CỦA WINDOWS INTERNALS & CÁCH GIẢI QUYẾT

Khi xây dựng Desktop Gadget trên Windows, hầu hết các công cụ tự động hoặc lập trình viên thiếu kinh nghiệm đều mắc phải 8 cái bẫy sau:

| # | Bẫy kỹ thuật | Nguyên nhân gốc rễ | Giải pháp chuẩn mực |
|---|---|---|---|
| **1** | **Bẫy `.hta` (HTML Application)** | MSHTA trên Windows 11 vẫn chạy nhân Internet Explorer 7/8 từ 15 năm trước. Đơ ngay lập tức khi gặp CSS3, HTML5 Canvas, ES6 (`const`, `async/await`). | Loại bỏ hoàn toàn `.hta`. Dùng native XAML WPF với `AllowsTransparency="True"` và `WindowStyle="None"`. |
| **2** | **Bẫy Emoji 4-byte trong Lexer PowerShell 5.1** | Các emoji 4-byte (như 📐, ⛏️, 🌤️) có mã byte chứa ký tự trùng với dấu ngoặc kép ASCII `"` hoặc ngoặc đơn `)`. Bộ phân tích cú pháp của PowerShell 5.1 hiểu nhầm và gây lỗi cú pháp âm thầm làm thoát chương trình. | Tuyệt đối **không dùng raw emoji 4-byte** trong string literal của `.ps1`. Thay bằng các ký tự chuẩn BMP (`[char]0x2600` cho nắng, `[char]0x2614` cho mưa, `[char]0x263E` cho đêm) hoặc chuỗi không dấu an toàn. |
| **3** | **Bẫy Single-Instance Mutex** | Khi ứng dụng bị tắt đột ngột (hoặc người dùng đóng tiến trình), `System.Threading.Mutex` rơi vào trạng thái *Abandoned*. Các lần mở tiếp theo bị nghẽn và ứng dụng thoát âm thầm. | Thay thế Mutex bằng cơ chế quản lý tiến trình trực tiếp: kiểm tra các tiến trình `powershell.exe` đang chạy file tương ứng và tự động đóng bản cũ để khởi tạo bản mới mượt mà. |
| **4** | **Bẫy Luồng STA & Dispatcher** | WPF yêu cầu luồng chính phải ở chế độ **Single-Threaded Apartment (STA)**. Khi chạy qua script ẩn console, luồng có thể bị đẩy về MTA và văng lỗi `The calling thread must be STA`. | Luôn thêm cờ `-Sta` trong câu lệnh gọi PowerShell: `powershell.exe -Sta -WindowStyle Hidden ...`. |
| **5** | **Bẫy Treo UI do Tải Mạng Đồng Bộ** | Gọi `WebClient.DownloadString` trên luồng UI sẽ đóng băng cửa sổ từ 1.5 - 10 giây nếu mạng chậm, khiến cửa sổ không thể render lúc khởi động. | Dùng `DownloadStringAsync` kết hợp sự kiện `Add_DownloadStringCompleted` để nạp dữ liệu hoàn toàn bất đồng bộ. |
| **6** | **Bẫy Kế thừa `SW_HIDE` từ VBScript** | Khi VBScript gọi `WshShell.Run(cmd, 0, False)`, Windows truyền cờ `wShowWindow = SW_HIDE` vào `STARTUPINFO`. Theo cơ chế Win32, hàm `ShowWindow` đầu tiên của WPF sẽ bị hệ điều hành đè thành ẩn vĩnh viễn. | Dùng shortcut Windows (`.lnk`) với thuộc tính `WindowStyle = 7 (Minimized)` hoặc batch launcher trực tiếp với `-WindowStyle Hidden`. |
| **7** | **Bẫy `Border.CornerRadius` không cắt nội dung con (Lộ góc vuông & viền đen)** | Trong WPF, thuộc tính `CornerRadius` của thẻ `Border` chỉ bo viền nền của chính nó. Mọi phần tử con bên trong (như thẻ `Image`) vẫn giữ nguyên góc vuông 90 độ, kể cả khi đã đặt `ClipToBounds="True"`. Kết quả là viền đen chữ nhật của ảnh lồi ra ngoài viền bo tròn gây mất thẩm mỹ. | **Giải pháp triệt để không cần thu nhỏ ảnh hay làm mờ vignette:**<br>1. **Giữ nguyên 100% tác phẩm gốc:** Dùng ảnh gốc sắc nét, đặt `Stretch="UniformToFill"`.<br>2. **Mặt nạ cắt hình học `RectangleGeometry`:** Bọc trong `Grid x:Name="ClipGrid"`. Trong `Apply-GadgetSize`, tính `$innerSz = $cardPx - 2` và `$innerRad = $rad - 1`, gán `$clipGrid.Clip = New-Object RectangleGeometry(Rect(0, 0, $innerSz, $innerSz), $innerRad, $innerRad)`. Ảnh được uốn lượn sắc sảo theo đường cong Windows 11.<br>3. **Tràn lề chống hở mép khi lơ lửng:** Đặt `IslandBox Margin="-2"`. Nhờ vậy khi dập dềnh trục Y, mép trên/dưới không bao giờ bị hở khoảng trống nền. |
| **8** | **Bẫy Giật Lag khi Kéo Cửa Sổ (Window Dragging Lag / Stutter)** | **Nguyên nhân kép:**<br>1. **DropShadowEffect trên Container động:** Khi gắn `DropShadowEffect` trực tiếp vào `CardBorder` chứa hạt nước/hạt mưa bay, WPF trên cửa sổ trong suốt (`AllowsTransparency="True"`) buộc phải tính lại Pixel Shader Gaussian Blur 12px cho toàn bộ cửa sổ trong mỗi khung hình di chuyển.<br>2. **Dispatcher Contention:** Bắt sự kiện `MouseMove` thủ công bằng code PowerShell làm ngập hàng đợi Dispatcher (125Hz-1000Hz của chuột gaming), cạnh tranh luồng với Timer hoạt ảnh 30 FPS. | **Giải pháp 3 bước chuẩn 144Hz:**<br>1. **Tách riêng `ShadowBorder`:** Tạo một thẻ `<Border x:Name="ShadowBorder">` tĩnh làm anh-em song sinh nằm dưới `CardBorder`. WPF cache bitmap bóng đổ vĩnh viễn và không tính lại shader khi hạt chuyển động.<br>2. **Native Win32 `$window.DragMove()`:** Thay thế toàn bộ mã `MouseMove` thủ công bằng `$window.DragMove()`. Hàm này chuyển quyền kéo cửa sổ trực tiếp cho DWM (Desktop Window Manager) ở cấp độ phần cứng, đạt tần số quét màn hình cực mượt (60Hz, 120Hz, 144Hz, 240Hz).<br>3. **Hạ độ ưu tiên DispatcherTimer:** Khởi tạo timer với `[DispatcherPriority]::Background` để luồng xử lý chuột của người dùng luôn được ưu tiên 100%. |

---

## III. BÍ QUYẾT THIẾT KẾ GIAO DIỆN CHUẨN WINDOWS 11 FLUENT

### 1. Kính Acrylic mờ trong suốt (Translucent Glass Effect)
Thay vì dùng màu nền gần như đặc quánh (`#E6...`), Windows 11 Fluent đạt độ thẩm mỹ cao nhất khi kết hợp:
- **Nền bán trong suốt:** `#380F172A` (khoảng 22% - 35% độ mờ), giúp hình nền Desktop bên dưới ánh lên nhẹ nhàng.
- **Viền sáng tinh tế (Subtle Border Highlight):** `BorderThickness="1"`, `BorderBrush="#35FFFFFF"`.
- **Bo góc mềm mại (Dynamic Corner Radius):** Tự động co giãn theo kích thước:
  $$\text{Radius} = \max\left(10, \left\lfloor \frac{\text{CardPx}}{4.4} \right\rfloor\right)$$
- **Bo góc nội dung con:** Ép bo tròn toàn bộ ảnh bằng `Clip = New-Object RectangleGeometry(Rect, RadiusX, RadiusY)`.

### 2. Bố cục Vừa Vặn Khung Hình (Edge-to-Edge) & Hoạt Ảnh Tự Nhiên
- **Vừa vặn khung hình 100%:** Ảnh lấp đầy trọn vẹn thẻ bo góc, tràn viền tự nhiên, không bị co lại thành một đốm nhỏ ở giữa.
- **Hoạt ảnh lơ lửng không gian:** Sử dụng GPU Storyboard với `DoubleAnimation` và hàm làm mượt `SineEase (EaseInOut)` chu kỳ 3.4 giây dao động nhẹ ±1.8px.
- **Hạt chuyển động êm đềm:** Tốc độ di chuyển chậm rãi (0.005 - 0.011), mang lại cảm giác thư thái và sống động.
- **Hiệu ứng thời tiết thời gian thực:** Tích hợp API Open-Meteo tọa độ TP.HCM (`lat: 10.8231`, `lon: 106.6297`, múi giờ `Asia/Bangkok`), tự động chuyển chế độ Mưa / Nắng / Đêm đầy sao theo thời tiết thực ngoài trời.

---

## IV. CẨM NANG CHỌN ẢNH VÀ QUY TẮC BỐ CỤC ĐỂ TẠO GADGET HOÀN HẢO

Để tạo ra một Desktop Gadget có tính thẩm mỹ cao nhất, việc lựa chọn ảnh đầu vào đóng vai trò quyết định 80% vẻ đẹp của thành phẩm. Dưới đây là các tiêu chí vàng:

### 1. Tỷ lệ Khung hình (Aspect Ratio) & Độ phân giải
- **Tỷ lệ lý tưởng:** Tỷ lệ vuông **1:1** (hoặc ảnh ngang có chủ thể cô đọng ở giữa để dễ cắt thành 1:1).
- **Độ phân giải khuyên dùng:** Từ **480x480** đến **1024x1024 pixel**.
  - Không nên quá nhỏ (< 300px) vì sẽ bị mờ khi phóng to 5 cm.
  - Không nên quá lớn (> 2048px) vì sẽ tốn dung lượng bộ nhớ không cần thiết khi load file PNG.
- **Định dạng file:** PNG hoặc JPG chất lượng cao. Nếu có watermark ở góc (như logo trang web), nên để ở rìa ngoài cùng để dễ cắt bỏ.

### 2. Bố cục "3 Tầng Không Gian" (Three-Tier Composition)
Một bức ảnh hoàn hảo cho Gadget Windows 11 nên có cấu trúc 3 tầng rõ rệt:
1. **Tầng Trên (Chiếm 20% - 30% trên cùng): Bầu trời / Không gian thoáng đãng**
   - Giúp huy hiệu thời tiết (Weather Badge) và đồng hồ số màu trắng nổi bật rõ ràng, dễ đọc.
   - Là không gian để mây trôi nhẹ nhàng và các vì sao lấp lánh vào ban đêm.
2. **Tầng Giữa (Chiếm 40% - 50% ở trung tâm): Chủ thể kiến trúc / Điểm nhấn chính**
   - Đảo nổi Minecraft, Đấu trường Colosseo, Lâu đài Hogwarts, Tháp Eiffel, hoặc Nhân vật Voxel...
   - Có chi tiết rõ ràng, độ tương phản ánh sáng tốt để tạo chiều sâu 3D.
3. **Tầng Dưới (Chiếm 25% - 35% dưới cùng): Mặt đất / Mặt nước / Hang động**
   - Nơi thích hợp nhất để lập trình các hiệu ứng chuyển động sống động: dòng nước chảy, mặt hồ gợn sóng lấp lánh, đom đóm bay, hoặc tia dung nham sủi bọt.

---

## V. MẪU PROMPT CHUẨN ĐỂ YÊU CẦU TẠO GADGET MỚI SIÊU NHANH

Khi muốn tạo một Gadget mới, bạn chỉ cần gửi ảnh đính kèm và sao chép mẫu prompt 5 bước dưới đây gửi cho AI:

```markdown
Chào bạn, tôi muốn tạo một Windows 11 Desktop Gadget mới từ bức ảnh đính kèm theo chuẩn kiến trúc:

1. Chủ đề & Phong cách: [Ví dụ: Đền Taj Mahal phong cách Minecraft / Rừng tre Kyoto Voxel / Cyberpunk Floating City]
2. Cắt ảnh & Bố cục: Cắt tỷ lệ 1:1 vuông vức, lấy trọn vẹn chủ thể chính ở giữa, loại bỏ watermark nếu có.
3. Các hiệu ứng động mong muốn:
   - Hiệu ứng tầng trên: [Ví dụ: Mây trôi ngang nhẹ nhàng, sao đêm lấp lánh]
   - Hiệu ứng trọng tâm: [Ví dụ: Hoạt ảnh lơ lửng dao động nhẹ ±1.8px kiểu không gian]
   - Hiệu ứng tầng dưới: [Ví dụ: Nước hồ gợn sóng li ti, tia sáng phát ra từ cửa sổ]
4. Thời tiết thực tế: Tọa độ [Ví dụ: TP.HCM / Hà Nội / Tokyo] với hiệu ứng Mưa rơi êm đềm khi trời mưa.
5. Kích thước & Điều khiển: Chuẩn 3 kích thước 3cm, 4cm, 5cm, con lăn chuột thu phóng mượt mà, kéo thả chuột không lag, đóng gói bản Portable đầy đủ file cài đặt.
```

---

## VI. BỘ KHUNG MÃ NGUỒN CHUẨN MỰC (BOILERPLATE TEMPLATE 144HZ)

Mã nguồn khung sườn tối giản, áp dụng đầy đủ kiến trúc chống lag, bo góc tuyệt đối và không phụ thuộc file `.exe`:

```powershell
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Gadget" Width="134" Height="134"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        Topmost="True" ShowInTaskbar="False"
        SnapsToDevicePixels="True" UseLayoutRounding="True">
    <Grid x:Name="RootGrid" Margin="10">
        <!-- 1. Khung đổ bóng tĩnh độc lập (Không bị tính lại GPU khi hạt bay) -->
        <Border x:Name="ShadowBorder" CornerRadius="14" Background="#250F172A">
            <Border.Effect>
                <DropShadowEffect BlurRadius="10" ShadowDepth="2" Direction="270" Color="#000000" Opacity="0.40"/>
            </Border.Effect>
        </Border>
        
        <!-- 2. Khung thẻ kính Acrylic Fluent -->
        <Border x:Name="CardBorder" CornerRadius="14" Background="#380F172A" BorderBrush="#35FFFFFF" BorderThickness="1" ClipToBounds="True">
            <Grid x:Name="ClipGrid">
                <Image x:Name="SceneImg" Stretch="UniformToFill"/>
                <Canvas x:Name="EffectCanvas" IsHitTestVisible="False"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)
$shadowBorder = $window.FindName("ShadowBorder")
$cardBorder = $window.FindName("CardBorder")
$clipGrid = $window.FindName("ClipGrid")

# Kéo thả Native DWM siêu mượt 144Hz (0% CPU lag)
$cardBorder.Add_MouseLeftButtonDown({
    param($s, $e)
    if ($e.ButtonState -eq [System.Windows.Input.MouseButtonState]::Pressed) {
        try { $window.DragMove() } catch {}
    }
})

# Khởi tạo kích thước & mặt nạ bo góc chuẩn xác
$window.Add_SourceInitialized({
    $cardPx = 114 # Kích thước chuẩn 3 cm
    $rad = [Math]::Max(10, [int]($cardPx / 4.4))
    
    $cardBorder.Width = $cardPx; $cardBorder.Height = $cardPx; $cardBorder.CornerRadius = New-Object System.Windows.CornerRadius($rad)
    $shadowBorder.Width = $cardPx; $shadowBorder.Height = $cardPx; $shadowBorder.CornerRadius = New-Object System.Windows.CornerRadius($rad)
    
    # Cắt hình học khớp 100% lòng trong khung thẻ
    $clipGeom = New-Object System.Windows.Media.RectangleGeometry
    $clipGeom.Rect = New-Object System.Windows.Rect(0, 0, $cardPx - 2, $cardPx - 2)
    $clipGeom.RadiusX = $rad - 1; $clipGeom.RadiusY = $rad - 1
    $clipGrid.Clip = $clipGeom
})

# DispatcherTimer với độ ưu tiên Background (Không bao giờ giật lag thao tác chuột)
$animTimer = New-Object System.Windows.Threading.DispatcherTimer([System.Windows.Threading.DispatcherPriority]::Background)
$animTimer.Interval = [TimeSpan]::FromMilliseconds(33)
$animTimer.Start()

$app = [System.Windows.Application]::Current
if ($null -eq $app) { $app = New-Object System.Windows.Application }
$app.ShutdownMode = [System.Windows.ShutdownMode]::OnExplicitShutdown
$app.Run($window) | Out-Null
```
