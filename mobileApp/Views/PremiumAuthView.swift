//
//  PremiumAuthView.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//  Ultra-Premium Authentication with Supabase
//

import SwiftUI

struct PremiumAuthView: View {
    @StateObject private var authService = AuthService()
    @EnvironmentObject var theme: ThemeManager
    
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            // Background with particles
            theme.backgroundColor.ignoresSafeArea()
            
            FloatingParticles()
                .opacity(0.2)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // Logo & Title
                    headerSection
                        .padding(.top, 60)
                    
                    // Form Card
                    formCard
                        .padding(.horizontal, 24)
                    
                    // Toggle Login/Register
                    toggleSection
                        .padding(.bottom, 40)
                }
            }
            
            // Loading Overlay
            if isLoading {
                loadingOverlay
            }
        }
        .alert("Lỗi", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Logo with glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                theme.accentOrange.opacity(0.3),
                                theme.accentOrange.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.accentOrange, theme.accentOrange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: theme.accentOrange.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Image(systemName: "car.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(animateIn ? 1 : 0.8)
            .opacity(animateIn ? 1 : 0)
            
            VStack(spacing: 8) {
                Text("ADAS SYSTEM")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(theme.accentOrange)
                    .tracking(2)
                
                Text(isLogin ? "Chào mừng\ntrở lại!" : "Tạo tài khoản\nmới")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(theme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 20)
        }
    }
    
    // MARK: - Form Card
    
    private var formCard: some View {
        VStack(spacing: 24) {
            // Email Field
            PremiumTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            // Password Field
            PremiumTextField(
                icon: "lock.fill",
                placeholder: "Mật khẩu",
                text: $password,
                isSecure: true
            )
            
            // Confirm Password (Register only)
            if !isLogin {
                PremiumTextField(
                    icon: "lock.fill",
                    placeholder: "Xác nhận mật khẩu",
                    text: $confirmPassword,
                    isSecure: true
                )
                
                PremiumTextField(
                    icon: "person.fill",
                    placeholder: "Họ và tên",
                    text: $fullName
                )
            }
            
            // Forgot Password (Login only)
            if isLogin {
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: Implement forgot password
                    }) {
                        Text("Quên mật khẩu?")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.secondaryText)
                    }
                }
            }
            
            // Submit Button
            Button(action: handleSubmit) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: isLogin ? "arrow.right.circle.fill" : "person.badge.plus.fill")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text(isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ")
                            .font(.system(size: 16, weight: .bold))
                            .tracking(1)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [theme.accentOrange, theme.accentOrange.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: theme.accentOrange.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .disabled(isLoading)
            .padding(.top, 8)
            
            // Biometric Login (Login only)
            if isLogin {
                Button(action: {
                    // TODO: Implement Face ID/Touch ID
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                            .font(.system(size: 20))
                        
                        Text("Đăng nhập bằng Face ID")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(theme.secondaryText)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(theme.cardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
                }
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.accentOrange.opacity(0.3),
                            theme.cardBorder
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
    
    // MARK: - Toggle Section
    
    private var toggleSection: some View {
        HStack(spacing: 8) {
            Text(isLogin ? "Chưa có tài khoản?" : "Đã có tài khoản?")
                .font(.system(size: 14))
                .foregroundColor(theme.secondaryText)
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isLogin.toggle()
                    // Clear fields
                    email = ""
                    password = ""
                    confirmPassword = ""
                    fullName = ""
                    errorMessage = ""
                }
            }) {
                Text(isLogin ? "Đăng ký ngay" : "Đăng nhập")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.accentOrange)
            }
        }
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.accentOrange))
                    .scaleEffect(1.5)
                
                Text(isLogin ? "Đang đăng nhập..." : "Đang tạo tài khoản...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.primaryText)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardBackground)
                    .shadow(radius: 30)
            )
        }
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        // Validate
        guard !email.isEmpty, !password.isEmpty else {
            showErrorMessage("Vui lòng điền đầy đủ thông tin")
            return
        }
        
        if !isLogin {
            guard password == confirmPassword else {
                showErrorMessage("Mật khẩu xác nhận không khớp")
                return
            }
            
            guard !fullName.isEmpty else {
                showErrorMessage("Vui lòng nhập họ tên")
                return
            }
        }
        
        isLoading = true
        
        Task {
            do {
                if isLogin {
                    try await authService.signIn(email: email, password: password)
                } else {
                    try await authService.signUp(email: email, password: password, fullName: fullName)
                }
                
                await MainActor.run {
                    isLoading = false
                    // Success - AuthService will update isAuthenticated
                }
                
            } catch let error as AuthError {
                await MainActor.run {
                    isLoading = false
                    showErrorMessage(error.errorDescription ?? "Đã xảy ra lỗi")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        HapticManager.shared.error()
    }
}

// MARK: - Premium Text Field

struct PremiumTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    @EnvironmentObject var theme: ThemeManager
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isFocused ? theme.accentOrange.opacity(0.15) : theme.cardBorder.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isFocused ? theme.accentOrange : theme.secondaryText)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(theme.primaryText)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(theme.primaryText)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .focused($isFocused)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isFocused ? theme.accentOrange.opacity(0.5) : theme.cardBorder,
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

#Preview {
    PremiumAuthView()
        .environmentObject(ThemeManager())
}
