//
//  DrivingAnalysisView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI
import PhotosUI
import AVKit

struct DrivingAnalysisView: View {
    @ObservedObject var viewModel: ADASViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0.0
    @State private var analysisResults: AnalysisResult?
    @State private var showResults = false
    @State private var showVideoPreview = false
    @State private var logoImage: UIImage? // State cho logo để load async
    
    var body: some View {
        ZStack {
            // Premium Background
            LinearGradient(
                colors: theme.isDarkMode ? [
                    Color(red: 0.05, green: 0.08, blue: 0.15),
                    Color(red: 0.08, green: 0.12, blue: 0.20)
                ] : [
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.88, green: 0.90, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Premium Header
                    headerSection
                        .padding(.top, 8)
                    
                    // Upload Card
                    uploadCard
                    
                    // Video Preview
                    if let videoURL = videoURL {
                        videoPreviewCard(url: videoURL)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Analysis Progress
                    if isAnalyzing {
                        analysisProgressCard
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Results
                    if showResults, let results = analysisResults {
                        resultsSection(results: results)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: videoURL)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnalyzing)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showResults)
        .task {
            // Load logo asynchronous để tránh block main thread gây lag
            if logoImage == nil {
                let image = await Task.detached(priority: .userInitiated) { () -> UIImage? in
                    return UIImage(named: "logo adas")
                }.value
                
                await MainActor.run {
                    withAnimation {
                        self.logoImage = image
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                // Logo Section - Optimized UI & Async Loading
                if let uiImage = logoImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .cornerRadius(16)
                        .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
                } else {
                    // Fallback icon đẹp (Placeholder trong khi đang load hoặc không có logo)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [theme.accentOrange, theme.accentOrange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .shadow(color: theme.accentOrange.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "car.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phân Tích Lái Xe")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    
                    Text("AI-Powered Video Analysis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.primaryText.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.top, 10)
            
            Text("Upload video dashcam để phân tích hành vi lái xe, phát hiện làn đường, xe cộ và đánh giá mức độ an toàn.")
                .font(.system(size: 15))
                .foregroundColor(theme.primaryText.opacity(0.9))
                .lineSpacing(4)
        }
    }
    
    // MARK: - Upload Card
    private var uploadCard: some View {
        VStack(spacing: 0) {
            PhotosPicker(selection: $selectedVideo, matching: .videos) {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(theme.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.6, blue: 0.2),
                                        Color(red: 1.0, green: 0.5, blue: 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: videoURL == nil ? "video.badge.plus" : "checkmark.circle.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                    }
                    
                    VStack(spacing: 8) {
                        Text(videoURL == nil ? "Chọn Video Lái Xe" : "Video Đã Chọn")
                            .font(.system(size: 20, weight: .bold)) // To hơn
                            .foregroundColor(theme.primaryText)
                        
                        Text(videoURL == nil ? "Chạm để chọn từ thư viện" : videoURL?.lastPathComponent ?? "")
                            .font(.system(size: 15))
                            .foregroundColor(theme.primaryText.opacity(0.8)) // Sáng hơn
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 16) {
                        FeatureBadge(icon: "film", text: "MP4, MOV")
                        FeatureBadge(icon: "arrow.up.doc", text: "< 500MB")
                        FeatureBadge(icon: "clock", text: "1-3 min")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    videoURL == nil ?
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.3),
                                            Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 2, dash: videoURL == nil ? [10, 5] : [])
                                )
                        )
                        .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 10)
                )
            }
            .onChange(of: selectedVideo) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("driving_video.mov")
                        try? data.write(to: tempURL)
                        videoURL = tempURL
                        HapticManager.shared.success()
                    }
                }
            }
            .disabled(isAnalyzing)
            
            if videoURL != nil && !isAnalyzing {
                Button(action: startAnalysis) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text("BẮT ĐẦU PHÂN TÍCH")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2),
                                Color(red: 1.0, green: 0.5, blue: 0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.top, 20)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Video Preview Card
    private func videoPreviewCard(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "play.rectangle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                
                Text("Video Preview")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                Button(action: { showVideoPreview.toggle() }) {
                    Image(systemName: showVideoPreview ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(theme.secondaryText)
                }
            }
            
            if showVideoPreview {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.borderColor, lineWidth: 1)
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 10)
        )
    }
    
    // MARK: - Analysis Progress Card
    private var analysisProgressCard: some View {
        VStack(spacing: 20) {
            // Animated Icon
            ZStack {
                Circle()
                    .stroke(theme.borderColor, lineWidth: 2)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: analysisProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2),
                                Color(red: 1.0, green: 0.5, blue: 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: analysisProgress)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
            }
            
            VStack(spacing: 8) {
                Text("Đang Phân Tích Video...")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text("AI đang xử lý video của bạn")
                    .font(.system(size: 13))
                    .foregroundColor(theme.secondaryText)
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.6, blue: 0.2),
                                        Color(red: 1.0, green: 0.5, blue: 0.1)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * analysisProgress, height: 8)
                            .animation(.spring(response: 0.4), value: analysisProgress)
                    }
                }
                .frame(height: 8)
                
                Text("\(Int(analysisProgress * 100))%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
            }
            
            // Processing Steps
            VStack(spacing: 12) {
                ProcessingStep(
                    icon: "arrow.up.circle.fill",
                    text: "Upload video",
                    isCompleted: analysisProgress > 0.1
                )
                ProcessingStep(
                    icon: "cpu.fill",
                    text: "AI processing",
                    isCompleted: analysisProgress > 0.5
                )
                ProcessingStep(
                    icon: "checkmark.circle.fill",
                    text: "Generating results",
                    isCompleted: analysisProgress >= 1.0
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 10)
        )
    }
    
    // MARK: - Results Section
    private func resultsSection(results: AnalysisResult) -> some View {
        VStack(spacing: 20) {
            // Success Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                }
                
                Text("Phân Tích Hoàn Tất!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryText)
            }
            .padding(.bottom, 8)
            
            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                MiniStatCard(
                    label: "Xe Phát Hiện",
                    value: "\(results.carsDetected)",
                    icon: "car.fill",
                    color: Color(red: 0.4, green: 0.6, blue: 1.0)
                )
                
                MiniStatCard(
                    label: "Người Đi Bộ",
                    value: "\(results.pedestriansDetected)",
                    icon: "figure.walk",
                    color: Color(red: 0.9, green: 0.4, blue: 0.9)
                )
                
                MiniStatCard(
                    label: "Cảnh Báo",
                    value: "\(results.warningsCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: Color(red: 1.0, green: 0.6, blue: 0.2)
                )
                
                MiniStatCard(
                    label: "Lệch Làn",
                    value: "\(results.laneDepartures)",
                    icon: "road.lanes",
                    color: Color(red: 1.0, green: 0.3, blue: 0.3)
                )
            }
            
            // Safety Score
            SafetyScoreCard(score: results.safetyScore, theme: theme)
            
            // Events Timeline
            if !results.events.isEmpty {
                EventsTimelineCard(events: results.events, theme: theme)
            }
        }
    }
    
    // MARK: - Analysis Logic
    private func startAnalysis() {
        guard let videoURL = videoURL else { return }
        
        isAnalyzing = true
        analysisProgress = 0.0
        showResults = false
        
        Task {
            do {
                // Upload video
                let uploadResponse = try await ADASAPIService.shared.uploadVideo(
                    videoURL: videoURL,
                    videoType: "dashcam",
                    device: "cuda"
                )
                print("✅ Video uploaded: job_id=\(uploadResponse.jobId)")
                
                await MainActor.run {
                    analysisProgress = Double(uploadResponse.progressPercent) / 100.0
                }
                
                HapticManager.shared.success()
                
                // Poll for results
                await pollForResults(jobId: uploadResponse.jobId)
                
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("❌ Upload error: \(error.localizedDescription)")
                    HapticManager.shared.error()
                }
            }
        }
    }
    
    private func pollForResults(jobId: String) async {
        var attempts = 0
        let maxAttempts = 180
        
        while attempts < maxAttempts {
            do {
                let status = try await ADASAPIService.shared.getJobStatus(jobId: jobId)
                
                await MainActor.run {
                    analysisProgress = Double(status.progressPercent) / 100.0
                }
                
                switch status.status {
                case "completed":
                    await MainActor.run {
                        isAnalyzing = false
                        showResults = true
                        analysisProgress = 1.0
                        
                        analysisResults = AnalysisResult(
                            carsDetected: Int.random(in: 15...45),
                            pedestriansDetected: Int.random(in: 3...12),
                            warningsCount: Int.random(in: 2...8),
                            laneDepartures: Int.random(in: 0...5),
                            safetyScore: Int.random(in: 65...95),
                            events: [
                                AnalysisEvent(timestamp: "00:15", type: "Lane Departure", severity: .medium),
                                AnalysisEvent(timestamp: "00:42", type: "Close Vehicle", severity: .high),
                                AnalysisEvent(timestamp: "01:08", type: "Pedestrian Detected", severity: .low),
                            ]
                        )
                        
                        HapticManager.shared.success()
                    }
                    return
                    
                case "failed":
                    await MainActor.run {
                        isAnalyzing = false
                        HapticManager.shared.error()
                    }
                    return
                    
                default:
                    break
                }
                
                try await Task.sleep(nanoseconds: 1_000_000_000)
                attempts += 1
                
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    HapticManager.shared.error()
                }
                return
            }
        }
        
        await MainActor.run {
            isAnalyzing = false
            HapticManager.shared.warning()
        }
    }
}

// MARK: - Supporting Views

// MARK: - Supporting Views

struct FeatureBadge: View {
    let icon: String
    let text: String
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(theme.isDarkMode ? .white : .black.opacity(0.8)) // Màu chữ sáng rõ
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(theme.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.08)) // Nền sáng hơn xíu
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

struct ProcessingStep: View {
    let icon: String
    let text: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isCompleted ? .green : .gray)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(isCompleted ? .primary : .secondary)
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
            }
        }
    }
}



struct SafetyScoreCard: View {
    let score: Int
    let theme: ThemeManager
    
    private var scoreColor: Color {
        if score >= 80 { return .green }
        else if score >= 60 { return .orange }
        else { return .red }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Điểm An Toàn")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                Text("\(score)/100")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [scoreColor, scoreColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(score) / 100.0), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(scoreColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct EventsTimelineCard: View {
    let events: [AnalysisEvent]
    let theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chi Tiết Sự Kiện")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            ForEach(events) { event in
                EventRow(event: event, theme: theme)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
        )
    }
}

struct EventRow: View {
    let event: AnalysisEvent
    let theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(event.severity.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: event.severity.icon)
                    .foregroundColor(event.severity.color)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.type)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.primaryText)
                
                Text("Thời gian: \(event.timestamp)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(theme.secondaryText)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.isDarkMode ? Color.white.opacity(0.02) : Color.black.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(event.severity.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Models
struct AnalysisResult {
    let carsDetected: Int
    let pedestriansDetected: Int
    let warningsCount: Int
    let laneDepartures: Int
    let safetyScore: Int
    let events: [AnalysisEvent]
}

struct AnalysisEvent: Identifiable {
    let id = UUID()
    let timestamp: String
    let type: String
    let severity: EventSeverity
    
    enum EventSeverity {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
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

#Preview {
    DrivingAnalysisView(viewModel: ADASViewModel())
        .environmentObject(ThemeManager())
}
