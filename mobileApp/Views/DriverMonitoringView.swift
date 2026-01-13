//
//  DriverMonitoringView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI
import PhotosUI
import AVKit

struct DriverMonitoringView: View {
    @ObservedObject var viewModel: ADASViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0.0
    @State private var monitoringResults: DriverMonitoringResult?
    @State private var showResults = false
    
    var body: some View {
        ZStack {
            // Background using theme
            theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Upload Section
                    uploadSection
                    
                    // Video Preview
                    if let videoURL = videoURL {
                        videoPreviewSection(url: videoURL)
                    }
                    
                    // Analysis Progress
                    if isAnalyzing {
                        analysisProgressSection
                    }
                    
                    // Results
                    if showResults, let results = monitoringResults {
                        resultsSection(results: results)
                    }
                }
                .padding()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.9))
                    .font(.system(size: 14))
                
                Text("GIÁM SÁT TÀI XẾ")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.9))
            }
            
            Text("Upload Video Giám Sát")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            Text("Hệ thống AI sẽ phân tích hành vi tài xế, phát hiện buồn ngủ, mất tập trung và đánh giá mức độ an toàn.")
                .font(.system(size: 14))
                .foregroundColor(theme.secondaryText)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var uploadSection: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedVideo, matching: .videos) {
                VStack(spacing: 16) {
                    Image(systemName: videoURL == nil ? "person.crop.circle.badge.plus" : "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.9))
                    
                    VStack(spacing: 8) {
                        Text(videoURL == nil ? "Chọn Video Tài Xế" : "Đổi Video")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.primaryText)
                        
                        Text("Hỗ trợ MP4, MOV, AVI (tối đa 500MB)")
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    Color(red: 0.9, green: 0.4, blue: 0.9).opacity(0.3),
                                    style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                                )
                        )
                )
            }
            .onChange(of: selectedVideo) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("driver_video.mov")
                        try? data.write(to: tempURL)
                        videoURL = tempURL
                    }
                }
            }
            
            if videoURL != nil {
                Button(action: startAnalysis) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                        
                        Text("BẮT ĐẦU GIÁM SÁT")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.4, blue: 0.9),
                                Color(red: 0.8, green: 0.3, blue: 0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                }
                .disabled(isAnalyzing)
            }
        }
    }
    
    private func videoPreviewSection(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Video Preview")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            VideoPlayer(player: AVPlayer(url: url))
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    private var analysisProgressSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ProgressView()
                    .tint(Color(red: 0.9, green: 0.4, blue: 0.9))
                
                Text("Đang phân tích hành vi tài xế...")
                    .font(.system(size: 14))
                    .foregroundColor(theme.primaryText)
            }
            
            ProgressView(value: analysisProgress)
                .tint(Color(red: 0.9, green: 0.4, blue: 0.9))
            
            Text("\(Int(analysisProgress * 100))%")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.9))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func resultsSection(results: DriverMonitoringResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kết Quả Giám Sát")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            // Status Overview
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trạng Thái Tổng Quan")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(results.overallStatus)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(statusColor(results.overallStatus))
                }
                
                Spacer()
                
                Image(systemName: statusIcon(results.overallStatus))
                    .font(.system(size: 48))
                    .foregroundColor(statusColor(results.overallStatus))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(statusColor(results.overallStatus).opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Metrics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MonitoringMetricCard(
                    icon: "eye.slash.fill",
                    label: "Buồn Ngủ",
                    value: "\(results.drowsinessCount)",
                    percentage: results.drowsinessPercentage,
                    color: Color(red: 1.0, green: 0.3, blue: 0.3)
                )
                
                MonitoringMetricCard(
                    icon: "eye.trianglebadge.exclamationmark.fill",
                    label: "Mất Tập Trung",
                    value: "\(results.distractionCount)",
                    percentage: results.distractionPercentage,
                    color: Color(red: 1.0, green: 0.8, blue: 0.2)
                )
                
                MonitoringMetricCard(
                    icon: "phone.fill",
                    label: "Dùng Điện Thoại",
                    value: "\(results.phoneUsageCount)",
                    percentage: results.phoneUsagePercentage,
                    color: Color(red: 1.0, green: 0.6, blue: 0.2)
                )
                
                MonitoringMetricCard(
                    icon: "checkmark.circle.fill",
                    label: "Tập Trung",
                    value: "\(results.focusedPercentage)%",
                    percentage: Double(results.focusedPercentage) / 100.0,
                    color: Color(red: 0.2, green: 0.8, blue: 0.4)
                )
            }
            
            // Attention Score
            VStack(spacing: 12) {
                HStack {
                    Text("Điểm Tập Trung")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    
                    Spacer()
                    
                    Text("\(results.attentionScore)/100")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(scoreColor(results.attentionScore))
                }
                
                ProgressView(value: Double(results.attentionScore) / 100.0)
                    .tint(scoreColor(results.attentionScore))
                
                Text(scoreDescription(results.attentionScore))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Timeline Events
            VStack(alignment: .leading, spacing: 12) {
                Text("Dòng Thời Gian Sự Kiện")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                ForEach(results.events) { event in
                    DriverEventRow(event: event)
                }
            }
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "An Toàn": return Color(red: 0.2, green: 0.8, blue: 0.4)
        case "Cảnh Báo": return Color(red: 1.0, green: 0.8, blue: 0.2)
        case "Nguy Hiểm": return Color(red: 1.0, green: 0.3, blue: 0.3)
        default: return .gray
        }
    }
    
    private func statusIcon(_ status: String) -> String {
        switch status {
        case "An Toàn": return "checkmark.shield.fill"
        case "Cảnh Báo": return "exclamationmark.triangle.fill"
        case "Nguy Hiểm": return "xmark.shield.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 {
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        } else if score >= 60 {
            return Color(red: 1.0, green: 0.8, blue: 0.2)
        } else {
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        }
    }
    
    private func scoreDescription(_ score: Int) -> String {
        if score >= 80 {
            return "Tài xế rất tập trung và an toàn"
        } else if score >= 60 {
            return "Tài xế cần chú ý hơn"
        } else {
            return "Tài xế có dấu hiệu nguy hiểm"
        }
    }
    
    private func startAnalysis() {
        isAnalyzing = true
        analysisProgress = 0.0
        showResults = false
        
        // Simulate analysis
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            analysisProgress += 0.05
            
            if analysisProgress >= 1.0 {
                timer.invalidate()
                isAnalyzing = false
                
                // Generate mock results
                let attentionScore = Int.random(in: 60...95)
                monitoringResults = DriverMonitoringResult(
                    overallStatus: attentionScore >= 80 ? "An Toàn" : (attentionScore >= 60 ? "Cảnh Báo" : "Nguy Hiểm"),
                    drowsinessCount: Int.random(in: 0...5),
                    drowsinessPercentage: Double.random(in: 0...0.15),
                    distractionCount: Int.random(in: 1...8),
                    distractionPercentage: Double.random(in: 0.05...0.25),
                    phoneUsageCount: Int.random(in: 0...3),
                    phoneUsagePercentage: Double.random(in: 0...0.1),
                    focusedPercentage: Int.random(in: 70...90),
                    attentionScore: attentionScore,
                    events: [
                        DriverEvent(timestamp: "00:23", type: "Buồn Ngủ", severity: .high, duration: "3s"),
                        DriverEvent(timestamp: "00:45", type: "Nhìn Sang Bên", severity: .medium, duration: "2s"),
                        DriverEvent(timestamp: "01:12", type: "Dùng Điện Thoại", severity: .high, duration: "5s"),
                        DriverEvent(timestamp: "01:38", type: "Mất Tập Trung", severity: .medium, duration: "4s"),
                        DriverEvent(timestamp: "02:05", type: "Buồn Ngủ", severity: .high, duration: "6s"),
                    ]
                )
                showResults = true
            }
        }
    }
}

struct DriverMonitoringResult {
    let overallStatus: String
    let drowsinessCount: Int
    let drowsinessPercentage: Double
    let distractionCount: Int
    let distractionPercentage: Double
    let phoneUsageCount: Int
    let phoneUsagePercentage: Double
    let focusedPercentage: Int
    let attentionScore: Int
    let events: [DriverEvent]
}

struct DriverEvent: Identifiable {
    let id = UUID()
    let timestamp: String
    let type: String
    let severity: EventSeverity
    let duration: String
    
    enum EventSeverity {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return Color(red: 0.2, green: 0.8, blue: 0.4)
            case .medium: return Color(red: 1.0, green: 0.8, blue: 0.2)
            case .high: return Color(red: 1.0, green: 0.3, blue: 0.3)
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "info.circle.fill"
            case .medium: return "exclamationmark.triangle.fill"
            case .high: return "exclamationmark.octagon.fill"
            }
        }
    }
}

struct MonitoringMetricCard: View {
    let icon: String
    let label: String
    let value: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Color.white)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .lineLimit(1)
            
            ProgressView(value: percentage)
                .tint(color)
                .scaleEffect(x: 1, y: 0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DriverEventRow: View {
    let event: DriverEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.severity.icon)
                .foregroundColor(event.severity.color)
                .font(.system(size: 16))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(event.severity.color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.type)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.white)
                
                HStack(spacing: 8) {
                    Text("⏱ \(event.timestamp)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("⏳ \(event.duration)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(event.severity.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    DriverMonitoringView(viewModel: ADASViewModel())
        .environmentObject(ThemeManager())
}
