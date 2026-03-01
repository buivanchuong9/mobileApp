//
//  ProfileView.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Hồ sơ cá nhân")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                    .padding(20)
                    .background(theme.backgroundColor) // Ensure background for scrolling
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // User Info Card
                            userInfoCard
                            
                            // Menu Options
                            VStack(spacing: 16) {
                                NavigationLink(destination: AccountInfoView()) {
                                    MenuRow(icon: "person.circle", title: "Thông tin tài khoản", theme: theme)
                                }
                                
                                NavigationLink(destination: NotificationSettingsView()) {
                                    MenuRow(icon: "bell.circle", title: "Cấu hình thông báo", theme: theme)
                                }
                                
                                NavigationLink(destination: SecuritySettingsView()) {
                                    MenuRow(icon: "shield.checkerboard", title: "Bảo mật & Face ID", theme: theme)
                                }
                                
                                NavigationLink(destination: TripHistoryView()) {
                                    MenuRow(icon: "clock.arrow.circlepath", title: "Lịch sử chuyến đi", theme: theme)
                                }
                                
                                NavigationLink(destination: AppSettingsSubView()) {
                                    MenuRow(icon: "gearshape", title: "Cài đặt ứng dụng", theme: theme)
                                }
                            }
                            .padding(20)
                            
                            // Logout Button
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Đăng xuất")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            
                            // Version Info
                            Text("Phiên bản 1.0.1 (Build 20260118)")
                                .font(.system(size: 12))
                                .foregroundColor(theme.secondaryText)
                                .padding(.top, 20)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .alert("Đăng xuất", isPresented: $showLogoutAlert) {
                Button("Hủy", role: .cancel) {}
                Button("Đăng xuất", role: .destructive) {
                    Task {
                        try? await authService.signOut()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?")
            }
        }
    }
    
    private var userInfoCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [theme.accentOrange, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .shadow(color: theme.accentOrange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text(getInitials(name: authService.currentUser?.fullName ?? "User"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(authService.currentUser?.fullName ?? "Người dùng ADAS")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text(authService.currentUser?.email ?? "email@example.com")
                    .font(.system(size: 14))
                    .foregroundColor(theme.secondaryText)
            }
            
            HStack {
                StatusBadge(text: "Premium", color: .purple)
                StatusBadge(text: "Verified", color: .blue)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .cornerRadius(20)
        .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    // ... existing helpers ...
}

// MARK: - Sub Views

    private func getInitials(name: String) -> String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return String(name.prefix(1))
    }

// MARK: - Sub Views

struct AccountInfoView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var authService: AuthService
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Thông tin cơ bản")) {
                TextField("Họ và tên", text: $name)
                TextField("Email", text: .constant(authService.currentUser?.email ?? ""))
                    .disabled(true)
                    .foregroundColor(.gray)
                TextField("Số điện thoại", text: $phone)
            }
            
            Section(header: Text("Địa chỉ")) {
                TextField("Địa chỉ liên hệ", text: $address)
            }
            
            Section {
                Button("Lưu thay đổi") {
                    // Mock save action
                }
                .foregroundColor(theme.accentOrange)
            }
        }
        .navigationTitle("Thông tin tài khoản")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = authService.currentUser?.fullName ?? ""
            phone = "0909 123 456" // Mock
            address = "TP. Hà Nội" // Mock
        }
    }
}

struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var promoEnabled = true
    
    var body: some View {
        Form {
            Section(header: Text("Cảnh báo an toàn")) {
                Toggle("Thông báo đẩy (Push)", isOn: $pushEnabled)
                Toggle("Cảnh báo âm thanh", isOn: .constant(true))
            }
            
            Section(header: Text("Tin tức & Cập nhật")) {
                Toggle("Email thông báo", isOn: $emailEnabled)
                Toggle("Tin tức khuyến mãi", isOn: $promoEnabled)
            }
        }
        .navigationTitle("Cấu hình thông báo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SecuritySettingsView: View {
    @AppStorage("useFaceID") private var useFaceID = false
    
    var body: some View {
        Form {
            Section(header: Text("Đăng nhập")) {
                Toggle(isOn: $useFaceID) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Sử dụng Face ID")
                    }
                }
                
                Button("Đổi mật khẩu") {
                    // Action đổi pass
                }
            }
            
            Section(header: Text("Thiết bị")) {
                HStack {
                    Text("Thiết bị hiện tại")
                    Spacer()
                    Text("iPhone 17 Pro Max")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Bảo mật")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TripHistoryView: View {
    @State private var trips: [TripMock] = [
        TripMock(id: 1, date: "18/01/2026 14:30", duration: "45p", score: 85, status: "Hoàn thành"),
        TripMock(id: 2, date: "17/01/2026 09:15", duration: "1h 20p", score: 92, status: "Hoàn thành"),
        TripMock(id: 3, date: "16/01/2026 18:45", duration: "30p", score: 78, status: "Cảnh báo cao")
    ]
    
    var body: some View {
        List(trips) { trip in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.date)
                        .font(.headline)
                    Text("Thời gian: \(trip.duration)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(trip.score) điểm")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(trip.score > 80 ? .green : .orange)
                    
                    Text(trip.status)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .navigationTitle("Lịch sử chuyến đi")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppSettingsSubView: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        Form {
            Section(header: Text("Giao diện")) {
                Toggle("Chế độ tối (Dark Mode)", isOn: $theme.isDarkMode)
            }
            
            Section(header: Text("Ngôn ngữ")) {
                HStack {
                    Text("Ngôn ngữ")
                    Spacer()
                    Text("Tiếng Việt")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Cài đặt ứng dụng")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TripMock: Identifiable {
    let id: Int
    let date: String
    let duration: String
    let score: Int
    let status: String
}

struct MenuRow: View {
    let icon: String
    let title: String
    let theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(theme.primaryText)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(theme.secondaryText)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor.opacity(0.5), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(20)
    }
}
