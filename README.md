# ADAS Mobile App - Hệ Thống Hỗ Trợ Lái Xe

Ứng dụng iOS cho hệ thống ADAS (Advanced Driver Assistance System) - Hỗ trợ lái xe an toàn bằng AI.

## 🎯 Tính Năng Chính

### 1. 📊 Dashboard
- Tổng quan hệ thống ADAS
- Hiển thị trạng thái các tính năng
- Quản lý cảnh báo gần đây
- Bật/tắt giám sát nhanh

### 2. 📹 Monitor (Giám Sát Thời Gian Thực)
- Camera feed với overlay phát hiện
- Phát hiện làn đường (Lane Detection)
- Phát hiện vật thể (Object Detection)
- Cảnh báo va chạm (Collision Warning)
- Hiển thị metrics hệ thống (FPS, Model, Resolution)
- Terminal logs thời gian thực

### 3. 🚗 Phân Tích Lái Xe
- Upload video lái xe để phân tích
- Phát hiện xe cộ, người đi bộ
- Cảnh báo lệch làn
- Đánh giá điểm an toàn
- Timeline chi tiết các sự kiện

### 4. 👁️ Giám Sát Tài Xế
- Upload video giám sát tài xế
- Phát hiện buồn ngủ (Drowsiness Detection)
- Phát hiện mất tập trung (Distraction Detection)
- Phát hiện sử dụng điện thoại
- Đánh giá điểm tập trung
- Timeline hành vi tài xế

### 5. ⚙️ Settings
- Cấu hình các tính năng ADAS
- Điều chỉnh độ nhạy cảnh báo
- Bật/tắt âm thanh và rung
- Xóa lịch sử cảnh báo và logs
- Thông tin hệ thống

## 🎨 Thiết Kế

- **Dark Theme**: Giao diện tối hiện đại, dễ nhìn
- **Color Scheme**: 
  - Primary: Orange (#FF9933) - Accent color
  - Success: Green (#33CC66) - Safe status
  - Warning: Yellow (#FFCC33) - Caution
  - Danger: Red (#FF5555) - Critical alerts
  - Info: Blue (#6699FF) - Information
  - Purple: (#E666E6) - Driver monitoring

- **Typography**: SF Pro (System font)
- **Animations**: Smooth transitions và micro-interactions
- **Responsive**: Tối ưu cho mọi kích thước iPhone

## 🛠️ Công Nghệ

- **Framework**: SwiftUI
- **Platform**: iOS 17.0+
- **Architecture**: MVVM (Model-View-ViewModel)
- **AI Model**: YOLOv11-Nano (simulated)
- **Video Processing**: AVKit, PhotosUI

## 📱 Cấu Trúc Dự Án

```
mobileApp/
├── Models/
│   ├── ADASFeature.swift       # ADAS feature models
│   └── VehicleStatus.swift     # Vehicle and alert models
├── ViewModels/
│   └── ADASViewModel.swift     # Main view model
├── Views/
│   ├── DashboardView.swift     # Dashboard screen
│   ├── MonitoringView.swift    # Real-time monitoring
│   ├── DrivingAnalysisView.swift   # Video analysis
│   ├── DriverMonitoringView.swift  # Driver monitoring
│   └── SettingsView.swift      # Settings screen
├── ContentView.swift           # Main tab view
└── mobileAppApp.swift         # App entry point
```

## 🚀 Cách Chạy

1. Mở project trong Xcode:
```bash
open mobileApp.xcodeproj
```

2. Chọn simulator hoặc device

3. Build và run (⌘R)

## 📋 Yêu Cầu

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## 🎯 Tính Năng Đặc Biệt

### Simulated AI Processing
- Mô phỏng phát hiện vật thể thời gian thực
- Tính toán TTC (Time To Collision)
- Phân tích hành vi lái xe
- Đánh giá trạng thái tài xế

### Real-time Updates
- FPS counter
- Live object detection
- Dynamic alerts
- System logs streaming

### Video Analysis
- Support MP4, MOV, AVI
- Progress tracking
- Detailed results with metrics
- Event timeline

## 🔗 Liên Kết

- Website: [https://adas.aiotlab.edu.vn](https://adas.aiotlab.edu.vn)
- Model: YOLOv11-Nano
- Team: ADAS Team @ AIOT Lab

## 📝 License

Copyright © 2026 ADAS Team. All rights reserved.

---

**Made with ❤️ by ADAS Team**
