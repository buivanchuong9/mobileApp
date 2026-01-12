//
//  DashboardView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var viewModel: ADASViewModel
    @EnvironmentObject var theme: ThemeManager
    
    // Animation States
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Background: Solid Color (Sạch sẽ, không loang lổ)
            theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : -20)
                    
                    // Hero Card
                    heroSection
                        .scaleEffect(animateContent ? 1 : 0.95)
                        .opacity(animateContent ? 1 : 0)
                    
                    // Chart Section
                    chartSection
                        .opacity(animateContent ? 1 : 0)
                    
                    // Quick Buttons
                    quickActionsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Features Grid
                    featuresSection
                        .opacity(animateContent ? 1 : 0)
                    
                    // Alerts
                    if !viewModel.alerts.isEmpty {
                        alertsSection
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Sections (Clean Design)
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("ADAS INTELLIGENCE")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.accentOrange)
                
                Text("Dashboard")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.primaryText)
            }
            
            Spacer()
            
            // Status Badge: Solid & Sharp
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.isMonitoring ? theme.accentGreen : theme.secondaryText)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isMonitoring ? "SYSTEM ACTIVE" : "STANDBY")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(theme.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(theme.cardBackground) // Solid Color
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .overlay(
                Capsule()
                    .stroke(theme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(theme.accentOrange)
                
                Spacer()
                
                Text("v3.0")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(theme.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.backgroundColor) // Contrast against card
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("An Toàn Chủ Động")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text("Hệ thống giám sát và cảnh báo sớm sử dụng trí tuệ nhân tạo (AI Vision).")
                    .font(.system(size: 15))
                    .foregroundColor(theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(theme.cardBackground) // Solid Color
        .cornerRadius(20)
        .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.cardBorder, lineWidth: 1)
        )
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Xu Hướng An Toàn", systemImage: "chart.xyaxis.line")
                    .font(.headline)
                    .foregroundColor(theme.primaryText)
                
                Spacer()
            }
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(sampleWeeklyData) { item in
                        // Solid Line
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Score", item.score)
                        )
                        .foregroundStyle(theme.accentGreen)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol {
                            Circle()
                                .fill(theme.accentGreen)
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle().stroke(theme.cardBackground, lineWidth: 2)
                                )
                        }
                        
                        // Solid Area (Clean Gradient)
                        AreaMark(
                            x: .value("Day", item.day),
                            y: .value("Score", item.score)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.accentGreen.opacity(0.2), theme.accentGreen.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    
                    RuleMark(y: .value("Target", 80))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(theme.tertiaryText)
                }
                .frame(height: 200)
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
                            .foregroundStyle(theme.cardBorder)
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                    }
                }
            } else {
                 Text("Charts require iOS 16+")
            }
        }
        .padding(20)
        .background(theme.cardBackground) // Solid Color
        .cornerRadius(20)
        .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.cardBorder, lineWidth: 1)
        )
    }
    
    private var quickActionsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                // withAnimation not needed for simple state changes unless specific
                if viewModel.isMonitoring {
                    viewModel.stopMonitoring()
                } else {
                    viewModel.startMonitoring()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.isMonitoring ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.isMonitoring ? "DỪNG LẠI" : "KÍCH HOẠT")
                            .font(.system(size: 16, weight: .bold))
                        Text(viewModel.isMonitoring ? "Recording..." : "Start System")
                            .font(.system(size: 12))
                            .opacity(0.8)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.isMonitoring 
                    ? Color.red 
                    : theme.accentOrange
                )
                .cornerRadius(16)
                .shadow(color: (viewModel.isMonitoring ? Color.red : theme.accentOrange).opacity(0.3), radius: 8, y: 4)
            }
            
            Button(action: { viewModel.clearAlerts() }) {
                Image(systemName: "trash")
                    .font(.system(size: 20))
                    .foregroundColor(theme.secondaryText)
                    .frame(width: 56, height: 64)
                    .background(theme.cardBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tính Năng")
                    .font(.title3.bold())
                    .foregroundColor(theme.primaryText)
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.features) { feature in
                    ModernFeatureCard(feature: feature) {
                        viewModel.toggleFeature(feature)
                    }
                }
            }
        }
    }
    
    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cảnh Báo")
                    .font(.title3.bold())
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                if !viewModel.alerts.isEmpty {
                    Text("\(viewModel.alerts.count)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.red))
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.alerts.prefix(5)) { alert in
                    AlertRow(alert: alert)
                }
            }
        }
    }
}

// MARK: - Subcomponents (Clean Version)

struct ModernFeatureCard: View {
    let feature: ADASFeature
    let onToggle: () -> Void
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: feature.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(feature.isEnabled ? .white : feature.type.color)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(feature.isEnabled ? feature.type.color : theme.backgroundColor)
                    )
                
                Spacer()
                
                // Simple Toggle Visualization
                Capsule()
                    .fill(feature.isEnabled ? feature.type.color : theme.cardBorder)
                    .frame(width: 28, height: 16)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .padding(2)
                            .offset(x: feature.isEnabled ? 6 : -6)
                    )
                    .onTapGesture {
                         onToggle()
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.type.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.primaryText)
                    .lineLimit(1)
                
                Text(feature.isEnabled ? "On" : "Off")
                    .font(.caption)
                    .foregroundColor(feature.isEnabled ? feature.type.color : theme.secondaryText)
            }
        }
        .padding(16)
        .background(theme.cardBackground) // Solid Color
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(feature.isEnabled ? feature.type.color : theme.cardBorder, lineWidth: 1)
        )
    }
}

struct AlertRow: View {
    let alert: Alert
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.type.icon)
                .font(.system(size: 18))
                .foregroundColor(alert.type.color)
                .frame(width: 40, height: 40)
                .background(theme.backgroundColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.type.rawValue)
                    .font(.subheadline.bold())
                    .foregroundColor(theme.primaryText)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(timeAgo(from: alert.timestamp))
                .font(.caption2.monospaced())
                .foregroundColor(theme.tertiaryText)
        }
        .padding(12)
        .background(theme.cardBackground) // Solid Color
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.cardBorder, lineWidth: 1)
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "\(seconds)s" }
        return "\(seconds / 60)m"
    }
}

// Sample Data
struct SafetyData: Identifiable {
    let id = UUID()
    let day: String
    let score: Int
}

let sampleWeeklyData: [SafetyData] = [
    SafetyData(day: "T2", score: 85),
    SafetyData(day: "T3", score: 88),
    SafetyData(day: "T4", score: 92),
    SafetyData(day: "T5", score: 78),
    SafetyData(day: "T6", score: 95),
    SafetyData(day: "T7", score: 89),
    SafetyData(day: "CN", score: 94)
]

#Preview {
    DashboardView(viewModel: ADASViewModel())
        .environmentObject(ThemeManager())
}
