# ADAS Mobile - Hệ Thống Hỗ Trợ Lái Xe An Toàn

## 📱 Thông Tin Ứng Dụng

**Tên Ứng Dụng:** ADAS Mobile
**Phiên Bản:** 1.0.0
**Nền Tảng:** iOS 17.0+
**Ngôn Ngữ:** Swift, SwiftUI
**Team:** ADAS Team @ AIOT Lab

---

## 🎯 Mô Tả Ứng Dụng

ADAS Mobile là ứng dụng iOS tiên tiến sử dụng công nghệ AI Vision để hỗ trợ lái xe an toàn. Ứng dụng cung cấp các tính năng phân tích video thời gian thực và hậu kỳ để:

### Tính Năng Chính:

#### 1. 📊 Dashboard (Bảng Điều Khiển)
- Tổng quan hệ thống ADAS
- Quản lý các tính năng AI:
  - Lane Departure Warning (Cảnh báo lệch làn)
  - Forward Collision Warning (Cảnh báo va chạm)
  - Object Detection (Phát hiện vật thể)
  - Driver Monitoring (Giám sát tài xế)
- Hiển thị cảnh báo gần đây
- Bật/tắt giám sát nhanh
- Thống kê độ tin cậy của từng tính năng

#### 2. 📹 Monitor (Giám Sát Thời Gian Thực)
- Camera feed với overlay phát hiện
- Phát hiện làn đường trực quan
- Phát hiện vật thể với bounding boxes
- Cảnh báo va chạm với TTC (Time To Collision)
- Hiển thị metrics hệ thống:
  - FPS (Frames Per Second)
  - Model version (YOLOv11-Nano)
  - Resolution
  - Device info
- Terminal logs thời gian thực
- Chỉ báo LIVE khi đang giám sát

#### 3. 🚗 Phân Tích Lái Xe (Driving Analysis)
- Upload video lái xe từ thư viện
- Phân tích AI tự động:
  - Số xe phát hiện
  - Số người đi bộ
  - Số lần lệch làn
  - Số cảnh báo
- Tính điểm an toàn (Safety Score 0-100)
- Timeline chi tiết các sự kiện:
  - Lane Departure
  - Close Vehicle
  - Pedestrian Detected
  - Hard Braking
- Hiển thị progress bar upload và phân tích
- Kết quả chi tiết với biểu đồ

#### 4. 👁️ Giám Sát Tài Xế (Driver Monitoring)
- Upload video giám sát tài xế
- Phân tích hành vi tài xế:
  - Buồn ngủ (Drowsiness Detection)
  - Mất tập trung (Distraction Detection)
  - Sử dụng điện thoại
  - Tỷ lệ tập trung
- Tính điểm tập trung (Attention Score 0-100)
- Đánh giá trạng thái tổng quan:
  - An Toàn (Safe)
  - Cảnh Báo (Warning)
  - Nguy Hiểm (Danger)
- Timeline hành vi chi tiết với thời gian và độ dài

#### 5. ⚙️ Settings (Cài Đặt)
- **Giao Diện:**
  - Chuyển đổi Dark/Light mode
  - Lưu preference tự động
  - Smooth animations
- **Tính Năng ADAS:**
  - Bật/tắt từng tính năng
  - Hiển thị độ tin cậy
- **Cài Đặt Cảnh Báo:**
  - Điều chỉnh độ nhạy (0-100%)
  - Bật/tắt âm thanh cảnh báo
  - Bật/tắt rung phản hồi (Haptic)
- **Hệ Thống:**
  - Tự động bắt đầu giám sát
  - Xóa tất cả cảnh báo
  - Xóa nhật ký hệ thống
- **Thông Tin:**
  - Phiên bản app
  - Model version
  - Device info
  - Link website ADAS

---

## 🎨 Thiết Kế & Trải Nghiệm

### Theme System (Hệ Thống Giao Diện)

#### Dark Mode (Chế Độ Tối) - Mặc Định
- **Background:** Deep dark blue (#0D1426)
- **Text:** Pure white (#FFFFFF) - Độ tương phản cao
- **Secondary Text:** Light gray (#B3B8BF) - Dễ đọc
- **Cards:** Subtle white overlay với glassmorphism
- **Shadows:** Deep shadows cho chiều sâu

#### Light Mode (Chế Độ Sáng)
- **Background:** Light gray-blue (#F5F7F9)
- **Text:** Almost black (#141417) - Rõ ràng
- **Secondary Text:** Medium gray (#73777F)
- **Cards:** Pure white với subtle shadows
- **Shadows:** Elegant elevation

### Color Palette (Bảng Màu)
- **Orange (#FF9933):** Primary accent, actions
- **Green (#33CC66):** Success, safe status
- **Blue (#6699FF):** Information, cars
- **Purple (#E666E6):** Driver monitoring
- **Red (#FF4D4D):** Danger, critical alerts
- **Yellow (#FFCC33):** Warning, caution

### Animations & Effects
- Smooth spring animations (0.4s response)
- Haptic feedback cho mọi interaction
- Glassmorphism effects
- Gradient backgrounds
- Shadow depth system
- Scale effects on press
- Entrance animations

---

## 🔧 Công Nghệ Sử Dụng

### Frontend
- **SwiftUI:** Modern declarative UI
- **Combine:** Reactive programming
- **AVKit:** Video playback
- **PhotosUI:** Photo picker
- **Charts:** Data visualization

### Backend Integration
- **API:** RESTful API (https://adas-api.aiotlab.edu.vn)
- **Upload:** Multipart/form-data
- **Polling:** 1-second intervals
- **Timeout:** 2 minutes max

### AI Model
- **YOLOv11-Nano:** Object detection
- **Real-time processing:** 30+ FPS
- **Edge computing optimized**

### Architecture
- **MVVM Pattern:** Clean separation
- **Environment Objects:** Dependency injection
- **Async/Await:** Modern concurrency
- **Error Handling:** Comprehensive try-catch

---

## 📋 Hướng Dẫn Test Ứng Dụng

### Chuẩn Bị

#### Yêu Cầu Hệ Thống:
- macOS Sonoma 14.0+
- Xcode 15.0+
- iPhone chạy iOS 17.0+ (hoặc Simulator)
- Apple Developer Account (miễn phí)
- Cáp USB-C/Lightning

#### Cài Đặt:
1. Clone hoặc mở project:
   ```bash
   cd /Users/chuong/Desktop/mobileApp
   open mobileApp.xcodeproj
   ```

2. Cài đặt dependencies (nếu có):
   - Project này không dùng CocoaPods/SPM
   - Tất cả dependencies đều built-in

---

### Test Case 1: Dashboard & Theme

**Mục Tiêu:** Kiểm tra Dashboard và chuyển đổi theme

**Các Bước:**
1. Mở app → Màn hình Dashboard hiển thị
2. Kiểm tra các thành phần:
   - ✅ Header "ADAS SYSTEM" + "Dashboard"
   - ✅ Status indicator (Active/Inactive)
   - ✅ Hero section với mô tả
   - ✅ Quick actions (BẮT ĐẦU/DỪNG, XÓA)
   - ✅ 4 Feature cards (Lane, Collision, Object, Driver)
   - ✅ Recent Alerts (nếu có)

3. Test Theme Toggle:
   - Chuyển sang tab Settings
   - Nhấn vào "Chế Độ Tối/Sáng"
   - ✅ Kiểm tra animation mượt
   - ✅ Kiểm tra haptic feedback
   - ✅ Kiểm tra màu sắc thay đổi toàn app
   - ✅ Preference được lưu (tắt app mở lại)

4. Test Quick Actions:
   - Nhấn "BẮT ĐẦU" → Status chuyển "Active"
   - Nhấn "DỪNG" → Status chuyển "Inactive"
   - Nhấn "XÓA" → Alerts bị xóa

**Kết Quả Mong Đợi:**
- UI hiển thị đúng, rõ ràng
- Theme chuyển đổi mượt mà
- Haptic feedback hoạt động
- Colors dễ đọc ở cả 2 modes

---

### Test Case 2: Monitor (Giám Sát Thời Gian Thực)

**Mục Tiêu:** Kiểm tra tính năng giám sát real-time

**Các Bước:**
1. Chuyển sang tab "Monitor"
2. Kiểm tra UI:
   - ✅ Header với version info
   - ✅ Camera feed placeholder
   - ✅ System metrics (Model, Resolution, FPS, Device)
   - ✅ Terminal logs section

3. Test Monitoring:
   - Nhấn "TRUY CẬP HỆ THỐNG"
   - ✅ LIVE indicator xuất hiện
   - ✅ Lane detection overlay hiển thị
   - ✅ Objects được detect (simulated)
   - ✅ Collision warning hiển thị
   - ✅ FPS counter cập nhật
   - ✅ Logs stream real-time

4. Test Stop:
   - Nhấn "DỪNG HỆ THỐNG"
   - ✅ LIVE indicator biến mất
   - ✅ Detections dừng lại
   - ✅ Logs ngừng stream

**Kết Quả Mong Đợi:**
- Animations mượt mà
- Overlays hiển thị đúng
- Metrics cập nhật real-time
- Logs dễ đọc

---

### Test Case 3: Upload & Phân Tích Video Lái Xe

**Mục Tiêu:** Test upload video và nhận kết quả phân tích

**Chuẩn Bị:**
- Chuẩn bị 1 video lái xe (MP4, MOV) < 500MB
- Hoặc dùng sample video từ thư viện

**Các Bước:**

1. **Chọn Video:**
   - Chuyển sang tab "Lái Xe"
   - Nhấn vào khu vực "Chọn Video Lái Xe"
   - Chọn video từ Photos
   - ✅ Video preview hiển thị

2. **Upload & Phân Tích:**
   - Nhấn "BẮT ĐẦU PHÂN TÍCH"
   - ✅ Progress bar xuất hiện
   - ✅ Text "Đang phân tích video..."
   - ✅ Percentage cập nhật (0% → 100%)
   - ✅ Haptic feedback khi upload thành công

3. **Kiểm Tra Kết Quả:**
   - Sau khi hoàn thành:
   - ✅ 4 Result cards hiển thị:
     - Xe Phát Hiện (số lượng)
     - Người Đi Bộ (số lượng)
     - Cảnh Báo (số lượng)
     - Lệch Làn (số lượng)
   - ✅ Safety Score (0-100) với progress bar
   - ✅ Timeline sự kiện chi tiết
   - ✅ Màu sắc phù hợp với severity

4. **Test Error Handling:**
   - Thử upload file quá lớn
   - ✅ Error message hiển thị
   - ✅ Error haptic feedback
   - Thử với network offline
   - ✅ Timeout handling

**Kết Quả Mong Đợi:**
- Upload thành công lên server
- Progress bar chính xác
- Kết quả hiển thị đầy đủ
- Error handling tốt

---

### Test Case 4: Giám Sát Tài Xế

**Mục Tiêu:** Test upload video tài xế và phân tích hành vi

**Chuẩn Bị:**
- Video quay tài xế (selfie camera) < 500MB

**Các Bước:**

1. **Upload Video:**
   - Chuyển sang tab "Tài Xế"
   - Chọn video tài xế
   - Nhấn "BẮT ĐẦU GIÁM SÁT"
   - ✅ Upload progress

2. **Kiểm Tra Kết Quả:**
   - ✅ Overall Status (An Toàn/Cảnh Báo/Nguy Hiểm)
   - ✅ 4 Metric cards:
     - Buồn Ngủ (count + %)
     - Mất Tập Trung (count + %)
     - Dùng Điện Thoại (count + %)
     - Tập Trung (%)
   - ✅ Attention Score với progress bar
   - ✅ Timeline events với duration

3. **Verify Data:**
   - Kiểm tra số liệu hợp lý
   - Kiểm tra màu sắc status
   - Kiểm tra timeline format

**Kết Quả Mong Đợi:**
- Upload thành công
- Metrics chính xác
- UI hiển thị đẹp
- Data visualization rõ ràng

---

### Test Case 5: Settings & Configuration

**Mục Tiêu:** Test tất cả settings

**Các Bước:**

1. **Theme Settings:**
   - Toggle Dark/Light mode
   - ✅ Smooth animation
   - ✅ Haptic feedback
   - ✅ Preference saved

2. **ADAS Features:**
   - Toggle từng feature ON/OFF
   - ✅ Visual feedback
   - ✅ Border color changes
   - ✅ Confidence display

3. **Alert Settings:**
   - Điều chỉnh sensitivity slider
   - ✅ Value updates real-time
   - Toggle sound alerts
   - Toggle haptic feedback
   - ✅ All toggles work

4. **System Settings:**
   - Toggle auto-start
   - Nhấn "Xóa Tất Cả Cảnh Báo"
   - ✅ Alerts cleared
   - Nhấn "Xóa Nhật Ký Hệ Thống"
   - ✅ Logs cleared

5. **About Section:**
   - Kiểm tra version info
   - Nhấn "Truy Cập Website ADAS"
   - ✅ Safari mở đúng URL

**Kết Quả Mong Đợi:**
- Tất cả settings hoạt động
- Changes được lưu
- Links hoạt động
- UI responsive

---

### Test Case 6: Performance & Stability

**Mục Tiêu:** Kiểm tra hiệu năng và ổn định

**Các Bước:**

1. **Memory Test:**
   - Mở Xcode → Debug Navigator → Memory
   - Sử dụng app bình thường
   - ✅ Memory không leak
   - ✅ Memory usage hợp lý (<100MB)

2. **Battery Test:**
   - Sử dụng app 10 phút
   - Kiểm tra battery drain
   - ✅ Không drain quá nhanh

3. **Network Test:**
   - Upload video với WiFi
   - Upload video với 4G/5G
   - ✅ Cả 2 đều hoạt động
   - Test offline mode
   - ✅ Error handling tốt

4. **Rotation Test:**
   - Xoay device landscape/portrait
   - ✅ UI adapt đúng
   - ✅ Không crash

5. **Background Test:**
   - Đang upload, home app
   - ✅ Upload tiếp tục
   - Quay lại app
   - ✅ State preserved

**Kết Quả Mong Đợi:**
- App mượt mà, không lag
- Memory stable
- Network handling tốt
- No crashes

---

### Test Case 7: Edge Cases

**Mục Tiêu:** Test các trường hợp đặc biệt

**Các Bước:**

1. **Large File:**
   - Upload video >500MB
   - ✅ Error message hoặc warning

2. **Invalid Format:**
   - Thử upload ảnh thay vì video
   - ✅ Error handling

3. **Network Timeout:**
   - Upload với network chậm
   - ✅ Timeout sau 2 phút
   - ✅ Error message rõ ràng

4. **Rapid Switching:**
   - Nhanh chóng switch giữa các tabs
   - ✅ Không crash
   - ✅ State preserved

5. **Multiple Uploads:**
   - Upload nhiều video liên tiếp
   - ✅ Queue handling
   - ✅ Progress tracking

**Kết Quả Mong Đợi:**
- Tất cả edge cases được handle
- Không crash
- Error messages hữu ích

---

## 🐛 Bug Report Template

Nếu phát hiện bug, báo cáo theo format:

```
**Bug Title:** [Mô tả ngắn gọn]

**Steps to Reproduce:**
1. [Bước 1]
2. [Bước 2]
3. [Bước 3]

**Expected Result:**
[Kết quả mong đợi]

**Actual Result:**
[Kết quả thực tế]

**Environment:**
- Device: [iPhone model]
- iOS Version: [17.x]
- App Version: [1.0.0]
- Network: [WiFi/4G/5G]

**Screenshots/Videos:**
[Đính kèm nếu có]

**Additional Notes:**
[Thông tin thêm]
```

---

## ✅ Checklist Trước Khi Release

### Functionality
- [ ] Tất cả 5 tabs hoạt động
- [ ] Theme toggle hoạt động
- [ ] Upload video thành công
- [ ] Kết quả hiển thị đúng
- [ ] Settings lưu được
- [ ] Haptic feedback hoạt động

### UI/UX
- [ ] Dark mode đẹp, dễ đọc
- [ ] Light mode đẹp, dễ đọc
- [ ] Animations mượt mà
- [ ] Colors contrast tốt
- [ ] Typography rõ ràng
- [ ] Icons phù hợp

### Performance
- [ ] App launch < 2s
- [ ] Tab switching instant
- [ ] Upload progress accurate
- [ ] Memory usage < 100MB
- [ ] No memory leaks
- [ ] Battery drain hợp lý

### Stability
- [ ] No crashes
- [ ] Error handling tốt
- [ ] Network timeout handling
- [ ] Offline mode handling
- [ ] Background mode stable

### Compliance
- [ ] Privacy policy (nếu cần)
- [ ] Terms of service (nếu cần)
- [ ] App Store guidelines
- [ ] Icon & screenshots ready

---

## 📞 Support & Contact

**Team:** ADAS Team @ AIOT Lab
**Website:** https://adas.aiotlab.edu.vn
**API:** https://adas-api.aiotlab.edu.vn

---

## 📝 Version History

### Version 1.0.0 (Current)
- ✅ Dashboard với theme toggle
- ✅ Real-time monitoring
- ✅ Driving analysis với API
- ✅ Driver monitoring với API
- ✅ Settings với full customization
- ✅ Dark/Light mode support
- ✅ Haptic feedback system
- ✅ Professional UI/UX

---

**Ngày Tạo:** 12/01/2026
**Người Tạo:** ADAS Development Team
**Status:** Ready for Testing ✅
