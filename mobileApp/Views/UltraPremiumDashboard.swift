//
//  UltraPremiumDashboard.swift
//  mobileApp
//
//  Created by CHUONG on 13/1/26.
//  Senior-Level Commercial Design
//

import SwiftUI
import Charts

struct UltraPremiumDashboard: View {
    @ObservedObject var viewModel: ADASViewModel
    @EnvironmentObject var theme: ThemeManager
    
    @State private var animateIn = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Header Section
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                
                // Hero Performance Card
                heroPerformanceCard
                    .padding(.horizontal, 24)
                
                // Live Metrics Grid
                liveMetricsGrid
                    .padding(.horizontal, 24)
                
                // Safety Trend Chart
                safetyTrendCard
                    .padding(.horizontal, 24)
                
                // AI Features Section
                aiFeaturesSection
                    .padding(.horizontal, 24)
                
                // Recent Alerts
                if !viewModel.alerts.isEmpty {
                    recentAlertsSection
                        .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 16)
            .padding(.bottom, 100)
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Logo/Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.accentOrange, theme.accentOrange.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("HỆ THỐNG ADAS")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(theme.accentOrange)
                    .tracking(1.2)
                
                Spacer()
                
                // Status Indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(viewModel.isMonitoring ? Color.green : theme.secondaryText)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.isMonitoring ? "Sẵn sàng" : "CHỜ")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(theme.cardBackground)
                .clipShape(Capsule())
            }
            
            // Main Title
            Text("Bảng Điều\nKhiển")
                .font(.system(size: 48, weight: .black))
                .foregroundColor(theme.primaryText)
                .lineSpacing(4)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
        }
    }
    
    // MARK: - Hero Performance Card
    
    private var heroPerformanceCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hiệu Suất Hệ Thống")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                        .tracking(0.5)
                    
                    Text("Thị Giác AI Thời Gian Thực")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.primaryText)
                }
                
                Spacer()
                
                // Version Badge
                Text("v3.0 CAO CẤP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(theme.accentOrange)
                    )
            }
            
            // Metrics Row
            HStack(spacing: 0) {
                // FPS
                MetricColumn(
                    icon: "video.fill",
                    value: "\(viewModel.vehicleStatus.fps)",
                    label: "FPS",
                    color: Color.green,
                    isFirst: true
                )
                
                Divider()
                    .frame(height: 60)
                    .overlay(theme.cardBorder.opacity(0.3))
                
                // Speed
                MetricColumn(
                    icon: "speedometer",
                    value: String(format: "%.0f", viewModel.vehicleStatus.speed),
                    label: "km/h",
                    color: theme.accentOrange,
                    isFirst: false
                )
                
                Divider()
                    .frame(height: 60)
                    .overlay(theme.cardBorder.opacity(0.3))
                
                // Objects
                MetricColumn(
                    icon: "scope",
                    value: "\(viewModel.detectedObjects.count)",
                    label: "Đối tượng",
                    color: Color.blue,
                    isFirst: false
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(theme.cardBorder.opacity(0.5), lineWidth: 1)
        )
    }
    
    // MARK: - Live Metrics Grid
    
    private var liveMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chỉ Số Trực Tiếp")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            HStack(spacing: 16) {
                // FPS Card
                LiveMetricCard(
                    icon: "brain.head.profile",
                    value: "\(viewModel.vehicleStatus.fps)",
                    label: "FPS",
                    color: Color(red: 0.9, green: 0.4, blue: 0.9),
                    progress: Double(viewModel.vehicleStatus.fps) / 32.0
                )
                
                // Speed Card
                LiveMetricCard(
                    icon: "gauge.high",
                    value: String(format: "%.0f", viewModel.vehicleStatus.speed),
                    label: "Tốc độ",
                    color: theme.accentOrange,
                    progress: min(viewModel.vehicleStatus.speed / 120.0, 1.0)
                )
                
                // Active Features
                LiveMetricCard(
                    icon: "shield.checkered",
                    value: "\(viewModel.features.filter { $0.isEnabled }.count)",
                    label: "Kích hoạt",
                    color: Color.blue,
                    progress: Double(viewModel.features.filter { $0.isEnabled }.count) / Double(viewModel.features.count)
                )
            }
        }
    }
    
    // MARK: - Safety Trend Card
    
    private var safetyTrendCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 16))
                        .foregroundColor(theme.accentGreen)
                    
                    Text("Xu Hướng An Toàn")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(theme.primaryText)
                }
                
                Spacer()
                
                Text("7 Ngày Qua")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.secondaryText)
            }
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(sampleWeeklyData) { item in
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Score", item.score)
                        )
                        .foregroundStyle(theme.accentGreen)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        
                        AreaMark(
                            x: .value("Day", item.day),
                            y: .value("Score", item.score)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    theme.accentGreen.opacity(0.2),
                                    theme.accentGreen.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 180)
                .chartYScale(domain: 40...100)
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisValueLabel()
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(theme.secondaryText)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [40, 60, 80, 100]) { value in
                        AxisGridLine()
                            .foregroundStyle(theme.cardBorder.opacity(0.3))
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(theme.cardBorder.opacity(0.5), lineWidth: 1)
        )
    }
    
    // MARK: - AI Features Section
    
    private var aiFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tính Năng AI")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                // Main Control Button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        if viewModel.isMonitoring {
                            viewModel.stopMonitoring()
                        } else {
                            viewModel.startMonitoring()
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isMonitoring ? "stop.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                        
                        Text(viewModel.isMonitoring ? "DỪNG" : "BẮT ĐẦU")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                viewModel.isMonitoring
                                    ? Color.red
                                    : theme.accentOrange
                            )
                    )
                    .shadow(
                        color: (viewModel.isMonitoring ? Color.red : theme.accentOrange).opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
            }
            
            // Features Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.features) { feature in
                    CleanFeatureCard(feature: feature) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleFeature(feature)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Alerts
    
    private var recentAlertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cảnh Báo Gần Đây")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                Text("\(viewModel.alerts.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.red))
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.alerts.prefix(3)) { alert in
                    CleanAlertRow(alert: alert)
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct MetricColumn: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let isFirst: Bool
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.secondaryText)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LiveMetricCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let progress: Double
    
    @EnvironmentObject var theme: ThemeManager
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            // Label
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.secondaryText)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.cardBorder.opacity(0.3))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * animatedProgress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.cardBorder.opacity(0.5), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

struct CleanFeatureCard: View {
    let feature: ADASFeature
    let onToggle: () -> Void
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(feature.isEnabled ? feature.type.color.opacity(0.15) : theme.cardBorder.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: feature.type.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(feature.isEnabled ? feature.type.color : theme.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Toggle
                    ZStack {
                        Capsule()
                            .fill(feature.isEnabled ? feature.type.color : theme.cardBorder)
                            .frame(width: 44, height: 26)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 22, height: 22)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(x: feature.isEnabled ? 9 : -9)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.type.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    
                    Text(feature.isEnabled ? "Hoạt động" : "Tắt")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(feature.isEnabled ? feature.type.color : theme.secondaryText)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardBackground)
                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        feature.isEnabled ? feature.type.color.opacity(0.3) : theme.cardBorder.opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CleanAlertRow: View {
    let alert: Alert
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(alert.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: alert.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(alert.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.type.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text(alert.message)
                    .font(.system(size: 12))
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(timeAgo(from: alert.timestamp))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(theme.tertiaryText)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.cardBorder.opacity(0.5), lineWidth: 1)
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "\(seconds)s" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        return "\(seconds / 3600)h"
    }
}

#Preview {
    UltraPremiumDashboard(viewModel: ADASViewModel())
        .environmentObject(ThemeManager())
}
