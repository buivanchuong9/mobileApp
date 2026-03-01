//
//  ModernAuthView.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//  Modern, Clean, Professional Authentication
//

import SwiftUI
import LocalAuthentication

// MARK: - Password Strength
enum PasswordStrength {
    case none, weak, medium, strong
    
    var color: Color {
        switch self {
        case .none: return .clear
        case .weak: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .medium: return Color(red: 1.0, green: 0.7, blue: 0.0)
        case .strong: return Color(red: 0.2, green: 0.8, blue: 0.4)
        }
    }
    
    var text: String {
        switch self {
        case .none: return ""
        case .weak: return "Yếu"
        case .medium: return "Trung bình"
        case .strong: return "Mạnh"
        }
    }
    
    var progress: CGFloat {
        switch self {
        case .none: return 0
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
}

struct ModernAuthView: View {
    @StateObject private var authService = AuthService()
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var passwordStrength: PasswordStrength = .none
    
    var body: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero illustration
                    heroSection
                        .padding(.top, 60)
                    
                    // Auth form
                    authFormSection
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                    
                    Spacer(minLength: 40)
                }
            }
            
            // Loading overlay
            if isLoading {
                loadingOverlay
            }
        }
        .alert("Lỗi", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 32) {
            // Logo with modern design
            ZStack {
                // Outer glow circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.65, blue: 0.3),
                                Color(red: 1.0, green: 0.55, blue: 0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.4), radius: 20, x: 0, y: 10)
                
                // Car icon
                Image(systemName: "car.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            // Title
            VStack(spacing: 12) {
                Text("ADAS Platform")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2),
                                Color(red: 1.0, green: 0.5, blue: 0.15)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .tracking(2)
                
                Text(isLogin ? "Chào mừng trở lại!" : "Tạo tài khoản mới")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                
                Text(isLogin ? "Đăng nhập để tiếp tục" : "Bắt đầu hành trình an toàn")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            }
        }
    }
    
    // MARK: - Auth Form Section
    
    private var authFormSection: some View {
        VStack(spacing: 24) {
            // Email field
            ModernTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            // Password field
            VStack(spacing: 12) {
                ModernTextField(
                    icon: "lock.fill",
                    placeholder: "Mật khẩu",
                    text: $password,
                    isSecure: !showPassword,
                    showPassword: $showPassword
                )
                
                // Password strength (register only)
                if !password.isEmpty && !isLogin {
                    PasswordStrengthBar(strength: passwordStrength)
                }
            }
            
            // Confirm password (register only)
            if !isLogin {
                ModernTextField(
                    icon: "lock.fill",
                    placeholder: "Xác nhận mật khẩu",
                    text: $confirmPassword,
                    isSecure: !showConfirmPassword,
                    showPassword: $showConfirmPassword
                )
                
                ModernTextField(
                    icon: "person.fill",
                    placeholder: "Họ và tên",
                    text: $fullName
                )
            }
            
            // Forgot password (login only)
            if isLogin {
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("Quên mật khẩu?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                    }
                }
            }
            
            // Submit button
            Button(action: handleSubmit) {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: isLogin ? "arrow.right.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text(isLogin ? "Đăng nhập" : "Đăng ký")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.65, blue: 0.3),
                            Color(red: 1.0, green: 0.55, blue: 0.15)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .disabled(isLoading)
            
            // Divider
            HStack(spacing: 16) {
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.85, blue: 0.88))
                    .frame(height: 1)
                
                Text("hoặc")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.85, blue: 0.88))
                    .frame(height: 1)
            }
            .padding(.vertical, 8)
            
            // Face ID button (login only)
            if isLogin {
                Button(action: authenticateWithBiometrics) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.system(size: 24, weight: .medium))
                        
                        Text("Đăng nhập bằng Face ID")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.88), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
            }
            
            // Social login
            HStack(spacing: 12) {
                SocialButton(icon: "g.circle.fill", color: Color(red: 0.92, green: 0.26, blue: 0.21)) {}
                SocialButton(icon: "f.circle.fill", color: Color(red: 0.23, green: 0.35, blue: 0.60)) {}
                SocialButton(icon: "apple.logo", color: Color(red: 0.1, green: 0.1, blue: 0.15)) {}
            }
            
            // Toggle login/register
            HStack(spacing: 6) {
                Text(isLogin ? "Chưa có tài khoản?" : "Đã có tài khoản?")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isLogin.toggle()
                        email = ""
                        password = ""
                        confirmPassword = ""
                        fullName = ""
                        passwordStrength = .none
                    }
                }) {
                    Text(isLogin ? "Đăng ký ngay" : "Đăng nhập")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                }
            }
            .padding(.top, 8)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.6, blue: 0.2)))
                    .scaleEffect(1.5)
                
                Text(isLogin ? "Đang đăng nhập..." : "Đang tạo tài khoản...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 30)
            )
        }
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
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
            
            guard passwordStrength != .weak else {
                showErrorMessage("Mật khẩu quá yếu")
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
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Đăng nhập vào ADAS Platform"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        authService.isAuthenticated = true
                    } else {
                        showErrorMessage("Xác thực thất bại")
                    }
                }
            }
        } else {
            showErrorMessage("Face ID/Touch ID không khả dụng")
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        HapticManager.shared.error()
    }
    
    private func calculatePasswordStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty { return .none }
        
        var strength = 0
        if password.count >= 8 { strength += 1 }
        if password.count >= 12 { strength += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { strength += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil { strength += 1 }
        
        switch strength {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
}

// MARK: - Modern Text Field

struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    @Binding var showPassword: Bool
    
    @FocusState private var isFocused: Bool
    
    init(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false, keyboardType: UIKeyboardType = .default, showPassword: Binding<Bool> = .constant(false)) {
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self._showPassword = showPassword
    }
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 0.5, green: 0.5, blue: 0.55))
                .frame(width: 24)
            
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .focused($isFocused)
            }
            
            if isSecure {
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - Password Strength Bar

struct PasswordStrengthBar: View {
    let strength: PasswordStrength
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Độ mạnh:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                
                Text(strength.text)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(strength.color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.92))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(strength.color)
                        .frame(width: geometry.size.width * strength.progress, height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: strength)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Social Button

struct SocialButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.88), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    ModernAuthView()
}
