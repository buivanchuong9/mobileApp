//
//  PremiumDashboardView.swift
//  mobileApp
//
//  Created by CHUONG on 13/1/26.
//

import SwiftUI
import Charts

struct PremiumDashboardView: View {
    @ObservedObject var viewModel: ADASViewModel
    @EnvironmentObject var theme: ThemeManager
    
    @State private var animateContent = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showStats = false
    
    var body: some View {
        ZStack {
            // Animated Background
            backgroundLayer
            
            // Floating Particles
            FloatingParticles()
                .opacity(0.6)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                VStack(spacing: 28) {
                    // Dynamic Header
                    premiumHeader
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : -30)
                        .offset(y: -scrollOffset * 0.3) // Parallax effect
                    
                    // Hero Stats Card
                    heroStatsCard
                        .scaleEffect(animateContent ? 1 : 0.9)
                        .opacity(animateContent ? 1 : 0)
                        .rotation3DEffect(
                            .degrees(scrollOffset * 0.02),
                            axis: (x: 1, y: 0, z: 0)
                        )
                    
                    // Live Metrics
                    liveMetricsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(x: animateContent ? 0 : -50)
                    
                    // Performance Chart
                    premiumChartSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(x: animateContent ? 0 : 50)
                    
                    // Quick Actions
                    quickActionsGrid
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                    
                    // Features Grid
                    premiumFeaturesGrid
                        .opacity(animateContent ? 1 : 0)
                    
                    // Alerts Section
                    if !viewModel.alerts.isEmpty {
                        alertsSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.bottom, 100)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showStats = true
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            // Animated mesh gradient
            LinearGradient(
                colors: [
                    theme.accentOrange.opacity(0.1),
                    Color.clear,
                    theme.accentGreen.opacity(0.08),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(scrollOffset * 0.1))
        }
    }
    
    // MARK: - Header
    
    private var premiumHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    AnimatedIcon3D(type: .brain, size: 28, isActive: viewModel.isMonitoring)
                    
                    Text("HỆ THỐNG ADAS")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.accentOrange, theme.accentOrange.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Text("Bảng Điều Khiển")
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(theme.primaryText)
            }
            
            Spacer()
            
            // Animated Status Badge
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(viewModel.isMonitoring ? theme.accentGreen : theme.secondaryText)
                        .frame(width: 10, height: 10)
                    
                    if viewModel.isMonitoring {
                        Circle()
                            .stroke(theme.accentGreen.opacity(0.5), lineWidth: 2)
                            .frame(width: 18, height: 18)
                            .scaleEffect(animateContent ? 1.5 : 1.0)
                            .opacity(animateContent ? 0 : 1)
                            .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: animateContent)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isMonitoring ? "HOẠT ĐỘNG" : "CHỜ")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    
                    Text(viewModel.isMonitoring ? "Đang giám sát" : "Sẵn sàng")
                        .font(.system(size: 9))
                        .foregroundColor(theme.secondaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                viewModel.isMonitoring ? theme.accentGreen.opacity(0.5) : theme.cardBorder,
                                theme.cardBorder
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: viewModel.isMonitoring ? theme.accentGreen.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Hero Stats Card
    
    private var heroStatsCard: some View {
        Premium3DCard(glowColor: theme.accentOrange) {
            VStack(spacing: 24) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hiệu Suất Hệ Thống")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.secondaryText)
                        
                        Text("Thị Giác AI Thời Gian Thực")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(theme.primaryText)
                    }
                    
                    Spacer()
                    
                    // Animated Car Illustration
                    CarDashboardIllustration(isActive: viewModel.isMonitoring, size: 100)
                }
                
                // Version Badge
                HStack {
                    Text("v3.0 CAO CẤP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.accentOrange, theme.accentOrange.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: theme.accentOrange.opacity(0.5), radius: 8, x: 0, y: 4)
                    
                    Spacer()
                }
                
                // Stats Grid with Custom Animated Icons
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        AnimatedIcon3D(type: .camera, size: 48, isActive: viewModel.isMonitoring)
                        
                        Text("\(viewModel.vehicleStatus.fps)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryText)
                        
                        Text("FPS")
                            .font(.caption2)
                            .foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(height: 80)
                        .overlay(theme.cardBorder)
                    
                    VStack(spacing: 8) {
                        SpeedometerIcon(speed: viewModel.vehicleStatus.speed, size: 48)
                        
                        Text(String(format: "%.0f", viewModel.vehicleStatus.speed))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryText)
                        
                        Text("km/h")
                            .font(.caption2)
                            .foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(height: 80)
                        .overlay(theme.cardBorder)
                    
                    VStack(spacing: 8) {
                        RadarScanIcon(isScanning: viewModel.isMonitoring, size: 48)
                        
                        Text("\(viewModel.detectedObjects.count)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryText)
                        
                        Text("Đối tượng")
                            .font(.caption2)
                            .foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - Live Metrics
    
    private var liveMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chỉ Số Trực Tiếp")
                .font(.title3.bold())
                .foregroundColor(theme.primaryText)
            
            HStack(spacing: 16) {
                VStack(spacing: 12) {
                    AIBrainIcon(isProcessing: viewModel.isMonitoring, size: 90)
                    
                    Text("\(viewModel.vehicleStatus.fps)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primaryText)
                    
                    Text("FPS")
                        .font(.caption)
                        .foregroundColor(theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 12) {
                    SpeedometerIcon(speed: viewModel.vehicleStatus.speed, size: 90)
                    
                    Text(String(format: "%.0f", viewModel.vehicleStatus.speed))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primaryText)
                    
                    Text("Tốc độ")
                        .font(.caption)
                        .foregroundColor(theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 12) {
                    ShieldProtectionIcon(protectionLevel: Double(viewModel.features.filter { $0.isEnabled }.count) / Double(viewModel.features.count), size: 90)
                    
                    Text("\(viewModel.features.filter { $0.isEnabled }.count)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.primaryText)
                    
                    Text("Kích hoạt")
                        .font(.caption)
                        .foregroundColor(theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Chart Section
    
    private var premiumChartSection: some View {
        Premium3DCard(glowColor: theme.accentGreen) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Label("Xu Hướng An Toàn", systemImage: "chart.xyaxis.line")
                        .font(.headline)
                        .foregroundColor(theme.primaryText)
                    
                    Spacer()
                    
                    Text("7 Ngày Qua")
                        .font(.caption)
                        .foregroundColor(theme.secondaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(theme.backgroundColor)
                        .clipShape(Capsule())
                }
                
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(sampleWeeklyData) { item in
                            LineMark(
                                x: .value("Day", item.day),
                                y: .value("Score", item.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [theme.accentGreen, theme.accentGreen.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                            .symbol {
                                Circle()
                                    .fill(theme.accentGreen)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(color: theme.accentGreen.opacity(0.5), radius: 4, x: 0, y: 2)
                            }
                            
                            AreaMark(
                                x: .value("Day", item.day),
                                y: .value("Score", item.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        theme.accentGreen.opacity(0.3),
                                        theme.accentGreen.opacity(0.1),
                                        theme.accentGreen.opacity(0.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                        
                        RuleMark(y: .value("Target", 80))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [8, 4]))
                            .foregroundStyle(theme.accentOrange.opacity(0.5))
                    }
                    .frame(height: 220)
                    .chartYScale(domain: 40...100)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisValueLabel()
                                .font(.caption.bold())
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                                .foregroundStyle(theme.cardBorder.opacity(0.5))
                            AxisValueLabel {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue)")
                                        .font(.caption)
                                        .foregroundColor(theme.secondaryText)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thao Tác Nhanh")
                .font(.title3.bold())
                .foregroundColor(theme.primaryText)
            
            HStack(spacing: 16) {
                // Main Action Button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        if viewModel.isMonitoring {
                            viewModel.stopMonitoring()
                        } else {
                            viewModel.startMonitoring()
                        }
                    }
                }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: viewModel.isMonitoring ? "stop.fill" : "play.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.isMonitoring ? "DỪNG" : "BẮT ĐẦU")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(viewModel.isMonitoring ? "Đang ghi..." : "Bắt đầu giám sát")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: viewModel.isMonitoring
                                ? [Color.red, Color.red.opacity(0.8)]
                                : [theme.accentOrange, theme.accentOrange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(
                        color: (viewModel.isMonitoring ? Color.red : theme.accentOrange).opacity(0.4),
                        radius: 15,
                        x: 0,
                        y: 8
                    )
                }
                
                // Clear Button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    viewModel.clearAlerts()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.secondaryText)
                        
                        Text("Xóa")
                            .font(.caption.bold())
                            .foregroundColor(theme.secondaryText)
                    }
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Features Grid
    
    private var premiumFeaturesGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tính Năng AI")
                .font(.title3.bold())
                .foregroundColor(theme.primaryText)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.features) { feature in
                    Premium3DFeatureCard(feature: feature) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.toggleFeature(feature)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Alerts
    
    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cảnh Báo Gần Đây")
                    .font(.title3.bold())
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                Text("\(viewModel.alerts.count)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.alerts.prefix(5)) { alert in
                    PremiumAlertRow(alert: alert)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct Premium3DFeatureCard: View {
    let feature: ADASFeature
    let onToggle: () -> Void
    
    @EnvironmentObject var theme: ThemeManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                feature.isEnabled
                                    ? LinearGradient(
                                        colors: [feature.type.color, feature.type.color.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [theme.cardBorder, theme.cardBorder],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: feature.type.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(feature.isEnabled ? .white : theme.secondaryText)
                    }
                    .shadow(
                        color: feature.isEnabled ? feature.type.color.opacity(0.4) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    
                    Spacer()
                    
                    // Toggle
                    ZStack {
                        Capsule()
                            .fill(feature.isEnabled ? feature.type.color : theme.cardBorder)
                            .frame(width: 44, height: 24)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 20, height: 20)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            .offset(x: feature.isEnabled ? 10 : -10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.type.rawValue)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(theme.primaryText)
                        .lineLimit(1)
                    
                    Text(feature.isEnabled ? "Hoạt động" : "Tắt")
                        .font(.caption)
                        .foregroundColor(feature.isEnabled ? feature.type.color : theme.secondaryText)
                    
                    // Confidence Bar
                    if feature.isEnabled {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(theme.cardBorder)
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [feature.type.color, feature.type.color.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * feature.confidence, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        feature.isEnabled
                            ? LinearGradient(
                                colors: [feature.type.color.opacity(0.5), feature.type.color.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [theme.cardBorder, theme.cardBorder],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: feature.isEnabled ? feature.type.color.opacity(0.2) : Color.black.opacity(0.05),
                radius: feature.isEnabled ? 12 : 6,
                x: 0,
                y: feature.isEnabled ? 6 : 3
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PremiumAlertRow: View {
    let alert: Alert
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [alert.type.color, alert.type.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: alert.type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .shadow(color: alert.type.color.opacity(0.4), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.type.rawValue)
                    .font(.subheadline.bold())
                    .foregroundColor(theme.primaryText)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeAgo(from: alert.timestamp))
                    .font(.caption2.monospaced())
                    .foregroundColor(theme.tertiaryText)
                
                Circle()
                    .fill(alert.severity.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [alert.type.color.opacity(0.3), theme.cardBorder],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "\(seconds)s" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        return "\(seconds / 3600)h"
    }
}

// Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    PremiumDashboardView(viewModel: ADASViewModel())
        .environmentObject(ThemeManager())
}
