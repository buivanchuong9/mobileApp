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
    var mainViewModel: ADASViewModel? = nil
    @StateObject private var driverViewModel = DriverMonitoringViewModel()
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var showAlert = false
    
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
                    
                    // Upload Progress
                    if driverViewModel.isUploading {
                        uploadProgressSection
                    }
                    
                    // Analysis Progress
                    if driverViewModel.isProcessing {
                        analysisProgressSection
                    }
                    
                    // Results
                    if let results = driverViewModel.monitoringResult {
                        resultsSection(results: results)
                    }
                }
                .padding()
            }
        }
        .alert("Lỗi", isPresented: $showAlert) {
            Button("Đóng", role: .cancel) {
                driverViewModel.errorMessage = nil
            }
        } message: {
            Text(driverViewModel.errorMessage ?? "Đã xảy ra lỗi")
        }
        .onChange(of: driverViewModel.errorMessage) { newValue in
            if newValue != nil {
                showAlert = true
            }
        }
        .onChange(of: driverViewModel.monitoringResult) { result in
            if let result = result {
                mainViewModel?.addDriverResultToHistory(result)
            }
        }        .onChange(of: selectedVideo) { newValue in
            Task {
                await loadVideo(from: newValue)
            }
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // Premium monitoring icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.58, green: 0.35, blue: 0.92),
                                Color(red: 0.42, green: 0.2, blue: 0.78)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color(red: 0.58, green: 0.35, blue: 0.92).opacity(0.4), radius: 10, x: 0, y: 5)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                VStack(spacing: 2) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "waveform")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("GIÁM SÁT TÀI XẼ")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.58, green: 0.35, blue: 0.92))
                
                Text("Upload Video Giám Sát")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text("Hệ thống AI sẽ phân tích hành vi tài xế, phát hiện buồn ngủ, mất tập trung và đánh giá mức độ an toàn.")
                    .font(.system(size: 13))
                    .foregroundColor(theme.secondaryText)
                    .lineSpacing(3)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var uploadSection: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedVideo, matching: .videos) {
                VStack(spacing: 16) {
                    Image(systemName: videoURL == nil ? "person.crop.circle.badge.plus" : "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0.58, green: 0.35, blue: 0.92))
                    
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
                        .fill(theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    Color(red: 0.58, green: 0.35, blue: 0.92).opacity(0.3),
                                    style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                                )
                        )
                        .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 4)
                )
            }
            .disabled(driverViewModel.isUploading || driverViewModel.isProcessing)
            
            if videoURL != nil {
                Button(action: {
                    Task {
                        await startAnalysis()
                    }
                }) {
                    HStack {
                        if driverViewModel.isUploading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                        }
                        
                        Text(driverViewModel.isUploading ? "ĐANG UPLOAD..." : "BẮT ĐẦU GIÁM SÁT")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.58, green: 0.35, blue: 0.92),
                                Color(red: 0.48, green: 0.25, blue: 0.82)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                }
                .disabled(driverViewModel.isUploading || driverViewModel.isProcessing)
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
                        .stroke(theme.borderColor, lineWidth: 0.5)
                )
        }
    }
    
    private var uploadProgressSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ProgressView()
                    .tint(Color(red: 0.58, green: 0.35, blue: 0.92))
                
                Text("Đang upload video...")
                    .font(.system(size: 14))
                    .foregroundColor(theme.primaryText)
            }
            
            ProgressView(value: driverViewModel.uploadProgress)
                .tint(Color(red: 0.58, green: 0.35, blue: 0.92))
            
            Text("\(Int(driverViewModel.uploadProgress * 100))%")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.58, green: 0.35, blue: 0.92))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.cardBorder, lineWidth: 0.5)
                )
        )
    }
    
    private var analysisProgressSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ProgressView()
                    .tint(Color(red: 0.58, green: 0.35, blue: 0.92))
                
                Text(driverViewModel.statusMessage)
                    .font(.system(size: 14))
                    .foregroundColor(theme.primaryText)
            }
            
            ProgressView(value: driverViewModel.processingProgress)
                .tint(Color(red: 0.58, green: 0.35, blue: 0.92))
            
            Text("\(Int(driverViewModel.processingProgress * 100))%")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.58, green: 0.35, blue: 0.92))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.cardBorder, lineWidth: 0.5)
                )
        )
    }
    
    private func resultsSection(results: DriverMonitoringResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kết Quả Giám Sát")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            // Result Video Player - stream directly (faststart + baseline)
            if let videoURL = results.resultVideoURL {
                resultVideoSection(url: videoURL)
            }
            
            // Safety Score
            safetyScoreCard(score: results.safetyScore)
            
            // Detection Status
            detectionStatusGrid(
                fatigueDetected: results.fatigueDetected,
                distractionDetected: results.distractionDetected
            )
            
            // Processing Info
            processingInfoCard(
                duration: results.durationSeconds,
                processingTime: results.processingTimeSeconds
            )
            
            // Issues Timeline
            if !results.issues.isEmpty {
                issuesTimelineSection(issues: results.issues)
            }
            
            // Reset Button
            Button(action: resetAnalysis) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                    
                    Text("PHÂN TÍCH VIDEO MỚI")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.58, green: 0.35, blue: 0.92),
                            Color(red: 0.48, green: 0.25, blue: 0.82)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            }
        }
    }
    
    private func resultVideoSection(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Video Kết Quả")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            let player = AVPlayer(url: url)
            VideoPlayer(player: player)
                .frame(height: 250)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.58, green: 0.35, blue: 0.92), lineWidth: 1)
                )
                .onAppear { player.play() }
        }
    }
    
    private func safetyScoreCard(score: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Điểm An Toàn")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                Text("\(score)/100")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(scoreColor(score))
            }
            
            ProgressView(value: Double(score) / 100.0)
                .tint(scoreColor(score))
            
            HStack {
                Image(systemName: scoreIcon(score))
                    .foregroundColor(scoreColor(score))
                
                Text(scoreDescription(score))
                    .font(.system(size: 13))
                    .foregroundColor(theme.secondaryText)
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(scoreColor(score).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func detectionStatusGrid(fatigueDetected: Bool, distractionDetected: Bool) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            DetectionStatusCard(
                icon: "bed.double.fill",
                label: "Phát hiện mệt mỏi",
                detected: fatigueDetected,
                color: .red
            )
            
            DetectionStatusCard(
                icon: "eye.slash.fill",
                label: "Mất tập trung",
                detected: distractionDetected,
                color: .orange
            )
        }
    }
    
    private func processingInfoCard(duration: Double, processingTime: Double) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Thời lượng video")
                    .font(.system(size: 12))
                    .foregroundColor(theme.secondaryText)
                
                Text(formatDuration(duration))
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.primaryText)
            }
            
            Spacer()
            
            Divider()
                .frame(height: 40)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Thời gian xử lý")
                    .font(.system(size: 12))
                    .foregroundColor(theme.secondaryText)
                
                Text(formatDuration(processingTime))
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.primaryText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 6, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.cardBorder, lineWidth: 0.5)
                )
        )
    }
    
    private func issuesTimelineSection(issues: [DriverIssue]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dòng Thời Gian Sự Kiện")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            ForEach(issues) { issue in
                DriverIssueRow(issue: issue)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadVideo(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("driver_video_\(UUID().uuidString).mov")
                try data.write(to: tempURL)
                await MainActor.run {
                    self.videoURL = tempURL
                }
            }
        } catch {
            await MainActor.run {
                driverViewModel.errorMessage = "Không thể load video: \(error.localizedDescription)"
            }
        }
    }
    
    private func startAnalysis() async {
        guard let videoURL = videoURL else { return }
        
        SoundManager.shared.playStartSound()
        await driverViewModel.uploadDriverVideo(videoURL: videoURL)
        
        // Voice alert is automatically played by ViewModel when result is ready
    }
    
    private func resetAnalysis() {
        driverViewModel.reset()
        videoURL = nil
        selectedVideo = nil
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
    
    private func scoreIcon(_ score: Int) -> String {
        if score >= 80 {
            return "checkmark.shield.fill"
        } else if score >= 60 {
            return "exclamationmark.triangle.fill"
        } else {
            return "xmark.shield.fill"
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
    
    private func formatDuration(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Supporting Views

struct DetectionStatusCard: View {
    let icon: String
    let label: String
    let detected: Bool
    let color: Color
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(detected ? color : theme.secondaryText)
            
            Text(detected ? "Phát hiện" : "Không phát hiện")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(theme.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            detected ? color.opacity(0.3) : theme.cardBorder,
                            lineWidth: detected ? 1.5 : 0.5
                        )
                )
        )
    }
}

struct DriverIssueRow: View {
    let issue: DriverIssue
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: issue.type.icon)
                .foregroundColor(issue.severity.color)
                .font(.system(size: 16))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(issue.severity.color.opacity(0.12))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(issue.type.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.primaryText)
                
                Text("⏱ \(issue.timestamp)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(theme.secondaryText)
            }
            
            Spacer()
            
            // Severity badge
            Text(severityText(issue.severity))
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(issue.severity.color)
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 6, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(theme.cardBorder, lineWidth: 0.5)
                )
        )
    }
    
    private func severityText(_ severity: DriverIssue.IssueSeverity) -> String {
        switch severity {
        case .low: return "THẤP"
        case .medium: return "TRUNG BÌNH"
        case .high: return "CAO"
        }
    }
}

#Preview {
    DriverMonitoringView()
        .environmentObject(ThemeManager())
}
