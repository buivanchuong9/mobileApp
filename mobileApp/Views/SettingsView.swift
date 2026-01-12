//
//  SettingsView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ADASViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var alertSensitivity: Double = 0.7
    @State private var enableSoundAlerts = true
    @State private var enableHapticFeedback = true
    @State private var autoStartMonitoring = false
    
    var body: some View {
        ZStack {
            // Background with theme
            theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header with theme toggle
                    headerSection
                    
                    // Theme Settings
                    themeSection
                    
                    // Features Configuration
                    featuresSection
                    
                    // Alert Settings
                    alertSettingsSection
                    
                    // System Settings
                    systemSettingsSection
                    
                    // About
                    aboutSection
                }
                .padding()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CÀI ĐẶT")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    
                    Text("Cấu hình hệ thống ADAS của bạn")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryText)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Giao Diện")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            Button(action: {
                theme.toggleTheme()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: theme.isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                        .foregroundColor(theme.isDarkMode ? theme.accentPurple : theme.accentOrange)
                        .font(.system(size: 24))
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill((theme.isDarkMode ? theme.accentPurple : theme.accentOrange).opacity(0.2))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(theme.isDarkMode ? "Chế Độ Tối" : "Chế Độ Sáng")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.primaryText)
                        
                        Text("Nhấn để chuyển sang \(theme.isDarkMode ? "sáng" : "tối")")
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(theme.secondaryText)
                        .font(.system(size: 14))
                }
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.cardBackground)
                            .shadow(color: theme.shadowColor, radius: 8, y: 4)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke((theme.isDarkMode ? theme.accentPurple : theme.accentOrange).opacity(0.3), lineWidth: 1)
                    }
                )
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardBackground)
                    .shadow(color: theme.shadowColor, radius: 10, y: 5)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.cardBorder, lineWidth: 1)
            }
        )
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tính Năng ADAS")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            VStack(spacing: 12) {
                ForEach(viewModel.features) { feature in
                    FeatureToggleRow(feature: feature) {
                        viewModel.toggleFeature(feature)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var alertSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cài Đặt Cảnh Báo")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            VStack(spacing: 20) {
                // Sensitivity Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Độ Nhạy Cảnh Báo")
                            .font(.system(size: 14))
                            .foregroundColor(theme.primaryText)
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", alertSensitivity * 100))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.accentOrange)
                    }
                    
                    Slider(value: $alertSensitivity, in: 0...1)
                        .tint(theme.accentOrange)
                    
                    HStack {
                        Text("Thấp")
                            .font(.system(size: 11))
                            .foregroundColor(theme.secondaryText)
                        
                        Spacer()
                        
                        Text("Cao")
                            .font(.system(size: 11))
                            .foregroundColor(theme.secondaryText)
                    }
                }
                
                Divider()
                    .background(theme.borderColor)
                
                // Sound Alerts Toggle
                Toggle(isOn: $enableSoundAlerts) {
                    HStack(spacing: 12) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(theme.accentOrange)
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cảnh Báo Âm Thanh")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryText)
                            
                            Text("Phát âm thanh khi có cảnh báo")
                                .font(.system(size: 11))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                }
                .tint(theme.accentOrange)
                
                // Haptic Feedback Toggle
                Toggle(isOn: $enableHapticFeedback) {
                    HStack(spacing: 12) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundColor(theme.accentGreen)
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Rung Phản Hồi")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryText)
                            
                            Text("Rung khi có cảnh báo quan trọng")
                                .font(.system(size: 11))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                }
                .tint(theme.accentGreen)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.02))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var systemSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hệ Thống")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            VStack(spacing: 12) {
                // Auto Start
                Toggle(isOn: $autoStartMonitoring) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tự Động Bắt Đầu")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryText)
                            
                            Text("Bắt đầu giám sát khi mở ứng dụng")
                                .font(.system(size: 11))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                }
                .tint(Color(red: 0.2, green: 0.8, blue: 0.4))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackground.opacity(0.5))
                )
                
                // Clear Alerts Button
                Button(action: {
                    viewModel.clearAlerts()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Xóa Tất Cả Cảnh Báo")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryText)
                            
                            Text("Xóa lịch sử cảnh báo")
                                .font(.system(size: 11))
                                .foregroundColor(theme.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(theme.secondaryText)
                            .font(.system(size: 12))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackground.opacity(0.5))
                    )
                }
                
                // Clear Logs Button
                Button(action: {
                    viewModel.clearLogs()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Xóa Nhật Ký Hệ Thống")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryText)
                            
                            Text("Xóa terminal logs")
                                .font(.system(size: 11))
                                .foregroundColor(theme.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(theme.secondaryText)
                            .font(.system(size: 12))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackground.opacity(0.5))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.borderColor, lineWidth: 1)
                )
        )
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thông Tin")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            VStack(spacing: 12) {
                InfoRow(label: "Phiên Bản", value: "v2.0-beta")
                InfoRow(label: "Model", value: viewModel.vehicleStatus.modelVersion)
                InfoRow(label: "Nền Tảng", value: "iOS 17.0+")
                InfoRow(label: "Device", value: viewModel.vehicleStatus.device)
                
                Divider()
                    .background(theme.borderColor)
                
                Link(destination: URL(string: "https://adas.aiotlab.edu.vn")!) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(theme.accentOrange)
                            .font(.system(size: 18))
                        
                        Text("Truy Cập Website ADAS")
                            .font(.system(size: 14))
                            .foregroundColor(theme.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(theme.secondaryText)
                            .font(.system(size: 12))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.cardBackground.opacity(0.5))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.borderColor, lineWidth: 1)
                )
        )
    }
}

struct FeatureToggleRow: View {
    let feature: ADASFeature
    let onToggle: () -> Void
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feature.type.icon)
                .foregroundColor(feature.type.color)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(feature.type.color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.type.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.primaryText)
                
                Text(feature.type.description)
                    .font(.system(size: 11))
                    .foregroundColor(theme.secondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(feature.isEnabled))
                .labelsHidden()
                .tint(feature.type.color)
                .onChange(of: feature.isEnabled) { _ in
                    onToggle()
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(feature.type.color.opacity(feature.isEnabled ? 0.3 : 0.1), lineWidth: 1)
                )
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(theme.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(theme.primaryText)
        }
    }
}

#Preview {
    SettingsView(viewModel: ADASViewModel())
        .environmentObject(ThemeManager())
}
