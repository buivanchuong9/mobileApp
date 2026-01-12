//
//  AuthView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct AuthView: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var theme: ThemeManager
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var showFaceID = false
    
    var body: some View {
        ZStack {
            // Background
            theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Logo Header
                    VStack(spacing: 16) {
                        Image(systemName: "car.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(theme.accentOrange)
                        
                        Text("ADAS Mobile")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(theme.primaryText)
                        
                        Text(isLogin ? "Chào mừng trở lại!" : "Tạo tài khoản mới")
                            .font(.system(size: 16))
                            .foregroundColor(theme.secondaryText)
                    }
                    .padding(.top, 60)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email, theme: theme)
                        
                        CustomTextField(icon: "lock.fill", placeholder: "Mật khẩu", text: $password, isSecure: true, theme: theme)
                        
                        if !isLogin {
                            CustomTextField(icon: "lock.fill", placeholder: "Xác nhận mật khẩu", text: .constant(""), isSecure: true, theme: theme)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Button
                    Button(action: {
                        withAnimation {
                            isAuthenticated = true
                        }
                    }) {
                        Text(isLogin ? "Đăng Nhập" : "Đăng Ký")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [theme.accentOrange, theme.accentOrange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: theme.accentOrange.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    
                    // Face ID
                    if isLogin {
                        Button(action: {
                            withAnimation {
                                isAuthenticated = true
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 32))
                                    .foregroundColor(theme.accentOrange)
                                
                                Text("Đăng nhập bằng Face ID")
                                    .font(.system(size: 14))
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // Toggle Mode
                    HStack {
                        Text(isLogin ? "Chưa có tài khoản?" : "Đã có tài khoản?")
                            .foregroundColor(theme.secondaryText)
                        
                        Button(action: {
                            withAnimation {
                                isLogin.toggle()
                            }
                        }) {
                            Text(isLogin ? "Đăng ký ngay" : "Đăng nhập")
                                .fontWeight(.bold)
                                .foregroundColor(theme.accentOrange)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .transition(.opacity)
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    let theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(theme.secondaryText)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(theme.primaryText)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(theme.primaryText)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.cardBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    AuthView(isAuthenticated: .constant(false))
        .environmentObject(ThemeManager())
}
