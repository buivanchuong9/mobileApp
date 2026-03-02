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
    @State private var showSettings = false
    @State private var showProfile = false
    
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
        .sheet(isPresented: $showSettings) {
             SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(viewModel: viewModel)
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
                
                // Profile Button
                Button {
                    showProfile = true
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.accentOrange)
                        .padding(8)
                        .background(theme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: theme.shadowColor.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                
                // Settings Button
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primaryText)
                        .padding(10)
                        .background(theme.cardBackground)
                        .clipShape(Circle())
                }
            }
            
            // Main Title
            Text("Bảng Điều Khiển")
                .font(.system(size: 38, weight: .black))
                .foregroundColor(theme.primaryText)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
        }
    }
    
    // MARK: - Hero Performance Card
    
    private var heroPerformanceCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Thị Giác AI Thời Gian Thực")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Metrics Row
            HStack(spacing: 0) {
                let score = viewModel.lastAnalysisResult?.safetyScore ?? 0
                MetricColumn(
                    icon: "checkmark.shield.fill",
                    value: score > 0 ? "\(score)" : "--",
                    label: "Điểm An Toàn",
                    color: .white,
                    isFirst: true
                )
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 60)
                
                let cars = viewModel.lastAnalysisResult?.carsDetected ?? 0
                MetricColumn(
                    icon: "car.fill",
                    value: "\(cars)",
                    label: "Xe Đã Gặp",
                    color: .white,
                    isFirst: false
                )
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 60)
                
                let lanes = viewModel.lastAnalysisResult?.laneDepartures ?? 0
                MetricColumn(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(lanes)",
                    label: "Lệch Làn",
                    color: .white,
                    isFirst: false
                )
            }
        }
        .padding(28)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(theme.heroGradient)
                
                // Subtle pattern overlay
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .shadow(color: theme.accentOrange.opacity(0.25), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Live Metrics Grid
    
    private var liveMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Chỉ Số Lái Xe")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.primaryText)
                Spacer()
                if viewModel.lastAnalysisResult != nil {
                    Text("Kết quả mới nhất")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.accentGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.accentGreen.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            HStack(spacing: 16) {
                // Safety Score
                let score = viewModel.lastAnalysisResult?.safetyScore ?? 0
                LiveMetricCard(
                    icon: "shield.fill",
                    value: viewModel.lastAnalysisResult != nil ? "\(score)" : "--",
                    label: "An Toàn",
                    color: score >= 80 ? Color.green : score >= 60 ? theme.accentOrange : Color.red,
                    progress: Double(score) / 100.0
                )
                
                // Cars Detected
                let cars = viewModel.lastAnalysisResult?.carsDetected ?? 0
                LiveMetricCard(
                    icon: "car.fill",
                    value: viewModel.lastAnalysisResult != nil ? "\(cars)" : "--",
                    label: "Xe gặp",
                    color: theme.accentOrange,
                    progress: min(Double(cars) / 20.0, 1.0)
                )
                
                // Lane Departures
                let lanes = viewModel.lastAnalysisResult?.laneDepartures ?? 0
                LiveMetricCard(
                    icon: "road.lanes",
                    value: viewModel.lastAnalysisResult != nil ? "\(lanes)" : "--",
                    label: "Lệch làn",
                    color: lanes == 0 ? Color.green : Color.red,
                    progress: min(Double(lanes) / 5.0, 1.0)
                )
            }
            
            // Driver monitoring row (show if last analysis was driver type)
            let driverEntries = viewModel.analysisHistory.filter { $0.type == .driver }
            if !driverEntries.isEmpty, let last = driverEntries.last {
                HStack(spacing: 16) {
                    LiveMetricCard(
                        icon: "person.fill",
                        value: "\(last.safetyScore)",
                        label: "Tài xế",
                        color: Color.blue,
                        progress: Double(last.safetyScore) / 100.0
                    )
                    
                    LiveMetricCard(
                        icon: "bed.double.fill",
                        value: last.fatigueDetected ? "Có" : "Không",
                        label: "Mệt mỏi",
                        color: last.fatigueDetected ? Color.red : Color.green,
                        progress: last.fatigueDetected ? 1.0 : 0.0
                    )
                    
                    LiveMetricCard(
                        icon: "eye.slash.fill",
                        value: last.distractionDetected ? "Có" : "Không",
                        label: "Mất tập trung",
                        color: last.distractionDetected ? Color.red : Color.green,
                        progress: last.distractionDetected ? 1.0 : 0.0
                    )
                }
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
                
                Text("\(viewModel.analysisHistory.count) lần phân tích")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.secondaryText)
            }
            
            if #available(iOS 16.0, *) {
                if viewModel.analysisHistory.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 32))
                                .foregroundColor(theme.tertiaryText)
                            Text("Chưa có dữ liệu")
                                .font(.system(size: 14))
                                .foregroundColor(theme.secondaryText)
                            Text("Phân tích video lái xe hoặc tài xế để xem biểu đồ")
                                .font(.system(size: 11))
                                .foregroundColor(theme.tertiaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                        Spacer()
                    }
                } else {
                    Chart {
                        ForEach(viewModel.analysisHistory) { entry in
                            let entryColor = entry.type == .dashcam ? theme.accentGreen : Color.blue
                            
                            LineMark(
                                x: .value("Thời gian", entry.shortLabel),
                                y: .value("Điểm", entry.safetyScore)
                            )
                            .foregroundStyle(entryColor)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                            
                            PointMark(
                                x: .value("Thời gian", entry.shortLabel),
                                y: .value("Điểm", entry.safetyScore)
                            )
                            .foregroundStyle(entryColor)
                            .symbolSize(50)
                            
                            AreaMark(
                                x: .value("Thời gian", entry.shortLabel),
                                y: .value("Điểm", entry.safetyScore)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [entryColor.opacity(0.2), entryColor.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                        
                        RuleMark(y: .value("Mục tiêu", 80))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .foregroundStyle(theme.tertiaryText)
                    }
                    .frame(height: 200)
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisValueLabel()
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
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
                    
                    // Legend
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Circle().fill(theme.accentGreen).frame(width: 8, height: 8)
                            Text("Lái xe")
                                .font(.system(size: 11))
                                .foregroundColor(theme.secondaryText)
                        }
                        HStack(spacing: 6) {
                            Circle().fill(Color.blue).frame(width: 8, height: 8)
                            Text("Tài xế")
                                .font(.system(size: 11))
                                .foregroundColor(theme.secondaryText)
                        }
                        Spacer()
                        // Last score summary
                        if let last = viewModel.analysisHistory.last {
                            Text("Điểm mới nhất: \(last.safetyScore)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(last.safetyScore >= 80 ? theme.accentGreen : theme.accentOrange)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 16, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(theme.cardBorder, lineWidth: 1)
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
                ForEach(viewModel.features.indices, id: \.self) { index in
                    CleanFeatureCard(feature: viewModel.features[index]) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleFeature(at: index)
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
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color.opacity(0.7))
                .tracking(0.3)
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
        VStack(spacing: 14) {
            // Icon with colored background
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.12))
                    .frame(width: 52, height: 52)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            // Label
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.secondaryText)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.12))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 16, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(theme.cardBorder, lineWidth: 1)
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
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(feature.isEnabled ? feature.type.color.opacity(0.12) : theme.elevatedBackground)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: feature.type.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(feature.isEnabled ? feature.type.color : theme.tertiaryText)
                    }
                    
                    Spacer()
                    
                    // Premium Toggle
                    ZStack {
                        Capsule()
                            .fill(feature.isEnabled ? feature.type.color : theme.cardBorder)
                            .frame(width: 48, height: 28)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)
                            .offset(x: feature.isEnabled ? 10 : -10)
                            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: feature.isEnabled)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(feature.type.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    
                    Text(feature.isEnabled ? "Hoạt động" : "Tắt")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(feature.isEnabled ? feature.type.color : theme.tertiaryText)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(theme.cardBackground)
                    .shadow(color: feature.isEnabled ? theme.accentShadow(feature.type.color) : theme.shadowColor, radius: feature.isEnabled ? 16 : 10, x: 0, y: feature.isEnabled ? 6 : 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        feature.isEnabled ? feature.type.color.opacity(0.25) : theme.cardBorder,
                        lineWidth: feature.isEnabled ? 1.5 : 0.5
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
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.cardBorder, lineWidth: 0.5)
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
