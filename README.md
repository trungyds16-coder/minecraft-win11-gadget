# Minecraft Windows 11 Mini Desktop Gadget 🧊✨

[![Platform: Windows 10/11](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D4?logo=windows&logoColor=white)](#)
[![Tech: Native WPF + PowerShell 5.1](https://img.shields.io/badge/Engine-Native%20WPF%20%2B%20PowerShell%205.1-5391FE?logo=powershell&logoColor=white)](#)
[![Zero EXE](https://img.shields.io/badge/Security-Zero%20EXE%20%7C%20100%25%20Open%20Source-2EA44F)](#)
[![GPU Accelerated: 60 FPS](https://img.shields.io/badge/Performance-60%20FPS%20GPU%20%7C%20~0%25%20CPU-FF9900)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Một tiện ích màn hình Desktop (Gadget) phong cách **Windows 11 Fluent Acrylic** siêu nhỏ gọn và thư giãn, tái hiện hòn đảo lập phương Voxel Minecraft lơ lửng giữa không gian sâu thẳm với dòng thác nước êm đềm, hiệu ứng mưa rơi thanh thoát và bầu trời đêm đầy sao lấp lánh.

Được xây dựng **100% bằng engine đồ họa WPF (Windows Presentation Foundation) và DirectX GPU** có sẵn trên Windows thông qua PowerShell 5.1. **Tuyệt đối không dùng file `.exe` hay bộ cài độc hại**, an toàn và minh bạch tuyệt đối.

---

## ✨ Tính Năng Nổi Bật

- 🎨 **Chuẩn phong cách Windows 11 Fluent**: Kính Acrylic bán trong suốt (`#380F172A`) làm nổi bật hình nền Desktop bên dưới, viền sáng tinh tế và bo góc mềm mại tự động co giãn theo kích thước.
- 📐 **Bo góc hoàn hảo (Edge-to-Edge)**: Ứng dụng mặt nạ hình học `RectangleGeometry` bo tròn toàn bộ tác phẩm nghệ thuật 480x480 sắc nét, không bị lộ viền đen hay góc vuông ra ngoài.
- 🏝️ **Đảo lơ lửng không gian**: Hoạt ảnh GPU Storyboard 60 FPS nhịp nhàng với thuật toán làm mượt `SineEase (EaseInOut)`.
- 💧 **Thác nước & Tia lửa dung nham**: Dòng nước voxel trôi nhẹ nhàng từ đỉnh đảo đổ xuống đáy hang kết hợp các đốm lửa bập bùng ấm cúng.
- 🌧️ **Hiệu ứng mưa rơi êm đềm (Cozy Gentle Rain)**: 36 hạt mưa rơi thanh thoát với tốc độ chậm rãi và góc nghiêng gió tự nhiên.
- 🌌 **Bầu trời đêm 32 vì sao**: 3 tầng sao đêm lung linh tự động tỏa sáng khi màn đêm buông xuống.
- ⛅ **Thời tiết thực tế TP.HCM**: Tích hợp API Open-Meteo cập nhật nhiệt độ thời gian thực (mặc định TP.HCM: `lat: 10.8231`, `lon: 106.6297`), tự động đồng bộ trạng thái Nắng / Mưa / Đêm theo thời tiết thực tế.
- 🔍 **Thu phóng cực mượt từ 1.0 cm đến 5.5 cm**:
  - Hỗ trợ **con lăn chuột (Mouse Wheel)** để phóng to/thu nhỏ từng milimet.
  - 5 nấc kích thước cài sẵn trong Menu chuột phải: **1.2 cm (46 px)**, **2.0 cm (76 px)**, **3.0 cm (114 px)**, **4.0 cm (152 px)**, **5.0 cm (190 px)**.
- 🧊 **Icon 3D Isometric Minecraft Cube**: Bộ icon khối cỏ lập phương 3D đa độ phân giải (`gadget.ico` từ 16px đến 256px) tạo điểm nhấn cao cấp ngoài Desktop và Menu Start.
- ⚡ **Siêu nhẹ & Tiết kiệm tài nguyên**: Tiêu thụ CPU xấp xỉ ~0% và RAM chỉ ~35 - 45 MB.

---

## 🚀 Hướng Dẫn Cài Đặt & Sử Dụng

### Cách 1: Cài đặt tự động vào máy (Khuyên dùng)
1. Tải bản phát hành mới nhất từ mục **Releases** (`Minecraft_Win11_Gadget_v2.0_Setup.zip`) và giải nén.
2. Nhấp đúp vào **`Cai_Dat_Gadget.bat`**:
   - Tự động cài đặt vào `%LOCALAPPDATA%\Programs\Minecraft_Win11_Gadget` (không yêu cầu quyền Admin).
   - Tạo biểu tượng khối lập phương Minecraft ngoài **Desktop** và trong **Menu Start**.
   - Tùy chọn bật **Tự khởi động cùng Windows** (Startup).
3. Gadget sẽ xuất hiện ngay lập tức ở góc dưới màn hình!

### Cách 2: Sử dụng Portable (Không cần cài đặt)
- Giải nén và nhấp đúp vào **`Khoi_Chay_Gadget.lnk`** hoặc **`Chay_Gadget_Win11.bat`** để chạy ngay ở bất kỳ thư mục nào.

### 🗑️ Gỡ cài đặt sạch sẽ
- Nhấp đúp vào **`Go_Cai_Dat_Gadget.bat`** (hoặc chọn trong Menu Start): Toàn bộ phím tắt và tệp cài đặt sẽ được dọn dẹp sạch sẽ, không để lại bất kỳ rác hệ thống nào.

---

## 🎮 Thao Tác & Tương Tác

| Thao tác | Hành động |
|---|---|
| **Kéo thả chuột trái** | Di chuyển Gadget đến bất kỳ vị trí nào trên màn hình (vị trí sẽ tự động được ghi nhớ). |
| **Lăn con lăn chuột (Wheel)** | Thu phóng mượt mà kích thước từ **1.0 cm** đến **5.5 cm**. |
| **Nhấp đúp chuột trái** | Bùng nổ hiệu ứng bắn tia lửa dung nham rực rỡ! |
| **Nhấp chuột vào huy hiệu trên đỉnh** | Đổi nhanh giữa hiển thị **Thời tiết / Nhiệt độ** và **Đồng hồ số (HH:mm)**. |
| **Nhấn chuột phải** | Mở Menu ngữ cảnh chuẩn Windows 11: Chọn kích thước nhanh, đổi hiệu ứng thời tiết, ghim lên trên cùng, v.v. |

---

## 📂 Cấu Trúc Thư Mục

```text
Minecraft_Win11_Gadget/
├── Cai_Dat_Gadget.bat                # Trình cài đặt tự động 1-Click
├── Go_Cai_Dat_Gadget.bat             # Trình gỡ cài đặt sạch sẽ
├── Chay_Gadget_Win11.bat             # Khởi chạy Portable trực tiếp
├── Chay_Gadget_Win11.vbs             # Khởi chạy ngầm không chớp màn hình
├── Dung_Gadget.bat                   # Dừng Gadget nhanh
├── Khoi_Chay_Gadget.lnk              # Phím tắt với Icon khối lập phương 3D
├── Cai_Dat_Khoi_Dong_Cung_Windows.bat # Bật/Tắt tự khởi động cùng Windows
├── Minecraft_Gadget_Win11.ps1        # Mã nguồn lõi (Native WPF / PowerShell)
├── island_clean.png                  # Tác phẩm voxel 480x480 gốc sắc nét
├── gadget.ico                        # Icon khối lập phương Minecraft 3D (16-256px)
├── minecraft_cube.png                # Ảnh icon 3D trong suốt 512x512
├── settings.json                     # Cấu hình lưu trữ tọa độ, kích cỡ & chế độ
├── HUONG_DAN_MINI_1_2CM.txt          # Tài liệu hướng dẫn sử dụng tiếng Việt
├── NHAT_KY_KIEN_TRUC_GADGET.md       # Nhật ký kiến trúc & 7 bẫy Windows Internals
├── Dong_Goi_Release.bat              # Script đóng gói bản nén phát hành GitHub
├── README.md                         # Tài liệu giới thiệu dự án
└── LICENSE                           # Giấy phép mã nguồn mở MIT
```

---

## 🛠️ Kiến Trúc Kỹ Thuật

Xem chi tiết phân tích chuyên sâu về **7 cái bẫy kỹ thuật kinh điển của Windows Internals** và bộ khung mẫu tạo Gadget mới tại [NHAT_KY_KIEN_TRUC_GADGET.md](NHAT_KY_KIEN_TRUC_GADGET.md):
1. Khắc phục bẫy `.hta` lỗi thời bằng Native XAML WPF.
2. Xử lý triệt để bẫy Parser Lexer của PowerShell 5.1 với chuỗi ký tự UTF-16 BMP.
3. Cơ chế quản lý Single-Instance trực tiếp thay thế Mutex bị deadlock.
4. Đảm bảo luồng Single-Threaded Apartment (STA) cho WPF Dispatcher.
5. Tải dữ liệu mạng bất đồng bộ (`DownloadStringAsync`) chống treo giao diện.
6. Ngăn chặn kế thừa cờ `SW_HIDE` làm ẩn cửa sổ.
7. Giải pháp mặt nạ cắt hình học `RectangleGeometry` ép bo góc mượt mà cho phần tử con.

---

## 📄 Bản Quyền & Giấy Phép

Dự án được phát hành theo giấy phép mã nguồn mở **[MIT License](LICENSE)**. Bạn hoàn toàn tự do sử dụng, chỉnh sửa, trích xuất và phát triển thêm.
