//
//  AuthenticationView.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//  Professional Authentication - Đăng Nhập & Đăng Ký
//

import SwiftUI
import LocalAuthentication

// MARK: - Password Strength
enum CleanPasswordStrength {
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

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
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
    @State private var passwordStrength: CleanPasswordStrength = .none
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        ZStack {
            // Clean white background
            Color.white
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                        .padding(.top, 60)
                    
                    // Auth Card
                    authCard
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                    
                    Spacer(minLength: 40)
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
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 28) {
            // Modern ADAS Logo
            ZStack {
                // Subtle outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.30, green: 0.52, blue: 0.95).opacity(0.15),
                                Color(red: 0.30, green: 0.52, blue: 0.95).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 140, height: 140)
                
                // ADAS Logo Image
                Image("adas_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(color: Color(red: 0.30, green: 0.52, blue: 0.95).opacity(0.15), radius: 20, x: 0, y: 8)
            }
            
            // Title
            VStack(spacing: 12) {
                Text("ADAS PLATFORM")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.5, blue: 0.9),
                                Color(red: 0.1, green: 0.3, blue: 0.7)
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
    
    // MARK: - Auth Card
    
    private var authCard: some View {
        VStack(spacing: 24) {
            // Email field
            CleanTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            // Password field
            VStack(spacing: 12) {
                CleanTextField(
                    icon: "lock.fill",
                    placeholder: "Mật khẩu",
                    text: $password,
                    isSecure: true,
                    showPassword: $showPassword
                )
                .onChange(of: password) { newValue in
                    passwordStrength = calculatePasswordStrength(newValue)
                }
                
                // Password strength (register only)
                if !password.isEmpty && !isLogin {
                    CleanPasswordStrengthBar(strength: passwordStrength)
                }
            }
            
            // Confirm password (register only)
            if !isLogin {
                CleanTextField(
                    icon: "lock.fill",
                    placeholder: "Xác nhận mật khẩu",
                    text: $confirmPassword,
                    isSecure: true,
                    showPassword: $showConfirmPassword
                )
                
                CleanTextField(
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
            
            // Toggle login/register
            VStack(spacing: 12) {
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
                
                Button(action: {
                    showPrivacyPolicy = true
                }) {
                    Text("Bằng việc tiếp tục, bạn đồng ý với Chính sách bảo mật")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.65))
                        .underline()
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
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
                .environmentObject(ThemeManager()) // Standalone or from env
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
                        // Face ID ok -> Thử login bằng Token đã lưu
                        Task {
                            isLoading = true
                            do {
                                try await authService.restoreSession()
                                isLoading = false
                            } catch {
                                isLoading = false
                                // Phân loại lỗi để thông báo rõ hơn
                                if let authErr = error as? AuthError, case .userNotFound = authErr {
                                    showErrorMessage("Vui lòng đăng nhập bằng mật khẩu lần đầu để kích hoạt Face ID")
                                } else {
                                    showErrorMessage("Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.")
                                }
                            }
                        }
                    } else {
                        let errorMsg = authenticationError?.localizedDescription ?? "Không rõ nguyên nhân"
                        showErrorMessage("Lỗi Face ID: \(errorMsg)")
                    }
                }
            }
        } else {
            showErrorMessage("Face ID/Touch ID không khả dụng trên thiết bị này")
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        HapticManager.shared.error()
    }
    
    private func calculatePasswordStrength(_ pass: String) -> CleanPasswordStrength {
        if pass.isEmpty { return .none }
        
        var strength = 0
        if pass.count >= 8 { strength += 1 }
        if pass.count >= 12 { strength += 1 }
        if pass.rangeOfCharacter(from: .decimalDigits) != nil { strength += 1 }
        if pass.rangeOfCharacter(from: .uppercaseLetters) != nil { strength += 1 }
        if pass.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil { strength += 1 }
        
        switch strength {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
}

// MARK: - Clean Text Field

struct CleanTextField: View {
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .focused($isFocused)
            }
            
            if isSecure {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 0.6, green: 0.6, blue: 0.65))
                    .frame(width: 44, height: 44) // Constant size for reliable layout
                    .contentShape(Rectangle()) // Robust hit area
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !showPassword {
                                    showPassword = true
                                    HapticManager.shared.impact(style: .light)
                                }
                            }
                            .onEnded { _ in
                                showPassword = false
                            }
                    )
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

struct CleanPasswordStrengthBar: View {
    let strength: CleanPasswordStrength
    
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

#Preview {
    AuthenticationView()
        .environmentObject(AuthService())
}
