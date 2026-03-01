//
//  ContentView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @StateObject private var viewModel = ADASViewModel()
    @StateObject private var theme = ThemeManager()
    @StateObject private var authService = AuthService()
    @State private var selectedTab = 0
    
    // Security Lock State
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastBackgroundDate: Date?
    @State private var isLocked = false
    
    var body: some View {
        ZStack {
            if !authService.isAuthenticated {
                AuthenticationView()
                    .environmentObject(theme)
                    .environmentObject(authService)
                    .transition(.opacity)
            } else {
                // Main App Flow
                ZStack {
                    if isLocked {
                        // Màn hình khóa bảo mật
                        SecurityLockView(isLocked: $isLocked)
                            .zIndex(999)
                            .transition(.opacity)
                    }
                    
                    // Background
                    theme.backgroundColor
                        .ignoresSafeArea()
                    
                    TabView(selection: $selectedTab) {
                        UltraPremiumDashboard(viewModel: viewModel)
                            .tabItem {
                                Label("Trang Chủ", systemImage: "gauge.with.dots.needle.67percent")
                            }
                            .tag(0)
                        
                        DrivingAnalysisView(viewModel: viewModel)
                            .tabItem {
                                Label("Lái Xe", systemImage: "car.fill")
                            }
                            .tag(1)
                        
                        DriverMonitoringView(mainViewModel: viewModel)
                            .tabItem {
                                Label("Tài Xế", systemImage: "eye.fill")
                            }
                            .tag(2)
                            .toolbarBackground(.visible, for: .tabBar)
                        
                        LiveLogsView()
                            .tabItem {
                                Label("Logs", systemImage: "terminal.fill")
                            }
                            .tag(3)
                    }
                    .accentColor(theme.accentOrange)
                }
                .environmentObject(theme)
                .environmentObject(authService)
                .onAppear { setupTabBarAppearance() }
                .onChange(of: theme.isDarkMode) { _ in setupTabBarAppearance() }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authService.isAuthenticated)
        // Lắng nghe trạng thái App để khóa tự động
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // App bị ẩn -> Lưu thời gian
            lastBackgroundDate = Date()
            
        case .active:
            // App hiện lại -> Kiểm tra thời gian
            if let lastDate = lastBackgroundDate {
                let timeDiff = Date().timeIntervalSince(lastDate)
                print("⏳ App in background for: \(timeDiff) seconds")
                
                if timeDiff > 30 && authService.isAuthenticated {
                    // Quá 30s -> Khóa App ngay
                    isLocked = true
                    print("🔒 App Locked due to inactivity")
                }
            }
            // Reset timer
            lastBackgroundDate = nil
            
        default:
            break
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if theme.isDarkMode {
            appearance.backgroundColor = UIColor(red: 0.06, green: 0.07, blue: 0.11, alpha: 1.0)
        } else {
            appearance.backgroundColor = UIColor.white
        }
        
        // Clean separator - subtle shadow line
        appearance.shadowColor = theme.isDarkMode ? UIColor.clear : UIColor(white: 0.88, alpha: 1.0)
        
        // Tab item colors
        let normalColor = theme.isDarkMode ? UIColor(white: 0.5, alpha: 1.0) : UIColor(red: 0.55, green: 0.57, blue: 0.62, alpha: 1.0)
        let selectedColor = UIColor(red: 0.96, green: 0.52, blue: 0.12, alpha: 1.0)
        
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Security Lock View (Màn hình khóa)
struct SecurityLockView: View {
    @Binding var isLocked: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Background mờ
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
            } else {
                Color.white.ignoresSafeArea()
            }
            
            VStack(spacing: 30) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.5), radius: 20)
                
                VStack(spacing: 10) {
                    Text("Đã khóa bảo mật")
                        .font(.title2.bold())
                    
                    Text("Vui lòng xác thực để tiếp tục")
                        .foregroundColor(.secondary)
                }
                
                Button(action: authenticate) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Mở khóa bằng Face ID")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 250)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.top, 20)
                
                if showError {
                    Text("Không thể xác thực. Vui lòng thử lại.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .onAppear {
            // Tự động quét Face ID khi hiện lên
            authenticate()
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Mở khóa ADAS App") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            isLocked = false
                        }
                    } else {
                        showError = true
                    }
                }
            }
        } else {
            // Fallback nếu không có Face ID (cho nhập passcode máy)
             context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Nhập mật khẩu máy để mở khóa") { success, _ in
                 DispatchQueue.main.async {
                     if success {
                         withAnimation { isLocked = false }
                     }
                 }
             }
        }
    }
}

#Preview {
    ContentView()
}
