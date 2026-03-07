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
    var viewModel: ADASViewModel? = nil
    
    @State private var isDeletingAccount = false
    @State private var showPrivacyPolicy = false
    
    // Consolidated Alert System
    enum ProfileAlert: Identifiable {
        case logout
        case deleteConfirmation
        case error(String)
        
        var id: String {
            switch self {
            case .logout: return "logout"
            case .deleteConfirmation: return "delete"
            case .error(let msg): return msg
            }
        }
    }
    @State private var activeAlert: ProfileAlert?
    
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
                                
                                NavigationLink(destination: TripHistoryView(history: viewModel?.analysisHistory ?? [])) {
                                    MenuRow(icon: "clock.arrow.circlepath", title: "Lịch sử chuyến đi", theme: theme)
                                }
                                
                                NavigationLink(destination: AppSettingsSubView()) {
                                    MenuRow(icon: "gearshape", title: "Cài đặt ứng dụng", theme: theme)
                                }
                                
                                Button(action: {
                                    showPrivacyPolicy = true
                                }) {
                                    MenuRow(icon: "doc.text.shield", title: "Chính sách bảo mật", theme: theme)
                                }
                            }
                            .padding(20)
                            
                            // Logout Button
                            Button(action: {
                                hapticFeedback(.medium)
                                activeAlert = .logout
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
                            
                            // Delete Account Button
                            Button(action: {
                                hapticFeedback(.heavy)
                                activeAlert = .deleteConfirmation
                            }) {
                                HStack {
                                    if isDeletingAccount {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "trash.fill")
                                    }
                                    Text(isDeletingAccount ? "Đang xóa..." : "Xóa tài khoản")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 20)
                            .disabled(isDeletingAccount)
                            
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
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .logout:
                    return SwiftUI.Alert(
                        title: Text("Đăng xuất"),
                        message: Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?"),
                        primaryButton: .destructive(Text("Đăng xuất")) {
                            Task {
                                try? await authService.signOut()
                                presentationMode.wrappedValue.dismiss()
                            }
                        },
                        secondaryButton: .cancel(Text("Hủy"))
                    )
                case .deleteConfirmation:
                    return SwiftUI.Alert(
                        title: Text("Xóa tài khoản"),
                        message: Text("⚠️ Hành động này không thể hoàn tác. Toàn bộ dữ liệu tài khoản của bạn sẽ bị xóa vĩnh viễn."),
                        primaryButton: .destructive(Text("Xóa vĩnh viễn")) {
                            performDeleteAccount()
                        },
                        secondaryButton: .cancel(Text("Hủy"))
                    )
                case .error(let message):
                    return SwiftUI.Alert(
                        title: Text("Lỗi"),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
                    .environmentObject(theme)
            }
        }
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func performDeleteAccount() {
        isDeletingAccount = true
        Task {
            do {
                try await authService.deleteAccount()
                await MainActor.run {
                    isDeletingAccount = false
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    isDeletingAccount = false
                    activeAlert = .error(error.localizedDescription)
                }
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
        .background(theme   .cardBackground)
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
    let history: [AnalysisHistoryEntry]
    
    @Environment(\.presentationMode) var presentationMode
    
    private var sortedHistory: [AnalysisHistoryEntry] {
        history.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            if sortedHistory.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedHistory) { entry in
                            TripHistoryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle("Lịch sử chuyến đi")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 56))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Chưa có dữ liệu")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text("Hãy phân tích video lái xe hoặc giám sát tài xế để xem lịch sử tại đây")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct TripHistoryCard: View {
    let entry: AnalysisHistoryEntry
    
    private var scoreColor: Color {
        if entry.safetyScore >= 80 { return .green }
        if entry.safetyScore >= 60 { return .orange }
        return .red
    }
    
    private var statusText: String {
        if entry.type == .driver {
            if entry.fatigueDetected || entry.distractionDetected { return "Cảnh báo" }
            return "An toàn"
        } else {
            if entry.laneDepartures > 0 { return "Lệch làn" }
            return "Hoàn thành"
        }
    }
    
    private var statusColor: Color {
        if entry.type == .driver {
            return (entry.fatigueDetected || entry.distractionDetected) ? .orange : .green
        } else {
            return entry.laneDepartures > 0 ? .orange : .green
        }
    }
    
    private var typeIcon: String {
        entry.type == .dashcam ? "car.2.fill" : "person.crop.circle.badge.checkmark"
    }
    
    private var typeLabel: String {
        entry.type == .dashcam ? "Phân tích lái xe" : "Giám sát tài xế"
    }
    
    private var typeColor: Color {
        entry.type == .dashcam ? Color(red: 1.0, green: 0.55, blue: 0.1) : Color(red: 0.58, green: 0.35, blue: 0.92)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Type icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(typeColor.opacity(0.12))
                    .frame(width: 50, height: 50)
                
                Image(systemName: typeIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(typeColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(formattedDate)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(typeLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(typeColor)
                
                // Extra details
                if entry.type == .dashcam {
                    Text("Xe gặp: \(entry.carsDetected) | Lệch làn: \(entry.laneDepartures)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                } else {
                    HStack(spacing: 8) {
                        if entry.fatigueDetected {
                            Label("Mệt mỏi", systemImage: "bed.double.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                        }
                        if entry.distractionDetected {
                            Label("Mất tập trung", systemImage: "eye.slash.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                        if !entry.fatigueDetected && !entry.distractionDetected {
                            Label("Tốt", systemImage: "checkmark.shield.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.safetyScore)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
                
                Text("điểm")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(statusText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(statusColor))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
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
