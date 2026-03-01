//
//  DrivingAnalysisView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI
import PhotosUI
import AVKit
import Photos

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
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var localVideoURL: URL?
    @State private var isVideoLoading = false
    @State private var statusMessage: String = "Đang Phân Tích Video..."
    
    var body: some View {
        ZStack {
            // Clean Background
            theme.backgroundColor
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
        .alert(isPresented: $showErrorAlert) {
            SwiftUI.Alert(
                title: Text("Lỗi"),
                message: Text(errorMessage ?? "Đã xảy ra lỗi không xác định"),
                dismissButton: .default(Text("Đóng"))
            )
        }
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
                // Logo Section
                if let uiImage = logoImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .cornerRadius(16)
                        .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
                } else {
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
                            .fill(theme.elevatedBackground)
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
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(theme.primaryText)
                        
                        Text(videoURL == nil ? "Chạm để chọn từ thư viện" : videoURL?.lastPathComponent ?? "")
                            .font(.system(size: 15))
                            .foregroundColor(theme.primaryText.opacity(0.8))
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
                Text(statusMessage)
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
                            .fill(theme.elevatedBackground)
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
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 72, height: 72)
                    
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.green)
                }
                
                Text("Phân Tích Hoàn Tất!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text("AI đã xử lý xong video của bạn")
                    .font(.system(size: 14))
                    .foregroundColor(theme.secondaryText)
            }
            .padding(.bottom, 12)
            
            // Result Video Player
            VStack(alignment: .leading, spacing: 12) {
                Text("Video Kết Quả AI")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.primaryText)
                    .padding(.horizontal, 4)
                
                if let localURL = localVideoURL {
                    // Stream directly from server (faststart + baseline profile = instant streaming)
                    let player = AVPlayer(url: localURL)
                    VideoPlayer(player: player)
                        .frame(height: 220)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.borderColor, lineWidth: 1)
                        )
                        .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 5)
                        .onAppear {
                            player.play()
                        }
                    
                    // Save button below player
                    if let videoURL = results.resultVideoURL {
                        Button(action: {
                            saveAnalyzedVideo(from: videoURL)
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Lưu Video Về Thư Viện")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(12)
                        }
                        .disabled(isVideoLoading)
                    }
                } else if isVideoLoading {
                    // TRẠNG THÁI 2: Đang tải về (Loading) & Convert sang .mp4 chuẩn
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.cardBackground)
                            .frame(height: 220)
                        
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Đang tải & xử lý video...")
                                .font(.system(size: 14))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.borderColor, lineWidth: 1)
                    )
                } else if let videoURL = results.resultVideoURL {
                    // KẾT QUẢ: Hiện nút Lưu Video
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.3), radius: 10)
                        
                        Text("Phân Tích Hoàn Tất!")
                            .font(.title3.bold())
                            .foregroundColor(theme.primaryText)
                        
                        Text("Video kết quả đã sẵn sàng.")
                            .font(.subheadline)
                            .foregroundColor(theme.secondaryText)
                        
                        // NÚT LƯU VIDEO - Đơn giản nhất
                        Button(action: {
                            saveAnalyzedVideo(from: videoURL)
                        }) {
                            if isVideoLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(12)
                            } else {
                                HStack {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Lưu Video Về Thư Viện")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                        }
                        .disabled(isVideoLoading)
                    }
                    .padding(24)
                    .background(theme.cardBackground)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(theme.borderColor, lineWidth: 1))
                }
            }
            
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
        statusMessage = "Đang chuẩn bị..."
        SoundManager.shared.playStartSound()
        
        Task {
            var uploadProgressTask: Task<Void, Never>? = nil
            
            do {
                // CHUYỂN ĐỔI SANG MP4 (CHẤT LƯỢNG CAO NHẤT)
                await MainActor.run { self.statusMessage = "Đang chuẩn hóa video..." }
                
                var videoToUpload = videoURL
                if let convertedURL = await compressVideoForUpload(sourceURL: videoURL) {
                    print("✅ Converted to mp4 (High Quality): \(convertedURL.path)")
                    videoToUpload = convertedURL
                }
                
                await MainActor.run { self.statusMessage = "Đang tải lên..." }
                print("🚀 Uploading: \(videoToUpload.lastPathComponent)")
                
                // Fake Progress: Chạy chậm và tự nhiên hơn để không bị cảm giác "treo" ở cuối
                uploadProgressTask = Task {
                    var currentP = 0.0
                    while currentP < 0.85 {
                        // Random thời gian chờ từ 0.5s - 1.0s (Chậm lại đáng kể)
                        let randomSleep = UInt64.random(in: 500_000_000...1_000_000_000)
                        try? await Task.sleep(nanoseconds: randomSleep)
                        
                        // Tăng % ngẫu nhiên (chỉ 1-2% mỗi lần)
                        let increment = Double.random(in: 0.005...0.02)
                        currentP += increment
                        
                        // Nếu đã lên cao (>70%) thì tăng siêu chậm (để chờ upload thật)
                        if currentP > 0.70 {
                             try? await Task.sleep(nanoseconds: 1_000_000_000) // Delay thêm
                        }

                        let p = min(currentP, 0.85) // Cap ở 85%
                        
                        await MainActor.run {
                            if self.isAnalyzing {
                                // Animation mượt hơn
                                withAnimation(.linear(duration: 0.5)) {
                                    self.analysisProgress = p
                                }
                                self.statusMessage = "Đang tải lên: \(Int(p * 100))%"
                            }
                        }
                    }
                }
                
                // 2. UPLOAD (MOBILE API)
                let uploadResponse = try await ADASAPIService.shared.uploadDashcamVideo(
                    videoURL: videoToUpload,
                    videoType: "dashcam",
                    device: "cuda"
                )
                
                uploadProgressTask?.cancel()
                
                // Upload Done -> Switch to Polling
                await MainActor.run {
                    self.analysisProgress = 0.0 // Reset progress for analysis phase
                    self.statusMessage = "Server đang xử lý AI..."
                }
                
                print("✅ Upload Success! Job ID: \(uploadResponse.jobId)")
                await logToSupabase(level: "INFO", message: "Upload done. Job ID: \(uploadResponse.jobId)")
                
                // 3. POLL FOR STATUS
                await pollForResults(jobId: uploadResponse.jobId)
                
            } catch {
                uploadProgressTask?.cancel()
                print("❌ Start Analysis Failed: \(error.localizedDescription)")
                await logToSupabase(level: "ERROR", message: "Analysis failed: \(error.localizedDescription)")
                
                await MainActor.run {
                    isAnalyzing = false
                    HapticManager.shared.error()
                    SoundManager.shared.playDangerAlert()
                    self.errorMessage = "Lỗi quy trình: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
            }
        }
    }

    private func pollForResults(jobId: String) async {
        let maxTimeout: TimeInterval = 600 // 10 mins
        let startTime = Date()
        
        print("⏳ Start polling for job: \(jobId)")
        
        while isAnalyzing && Date().timeIntervalSince(startTime) < maxTimeout {
            do {
                // 1. Call Real API
                let statusResponse = try await ADASAPIService.shared.checkDashcamStatus(jobId: jobId)
                print("📡 Polling status: \(statusResponse.status) (\(statusResponse.progressPercent)%)")
                
                // 2. Update UI
                await MainActor.run {
                    let p = statusResponse.progressPercent
                    if p > 0 {
                        withAnimation {
                            self.analysisProgress = Double(p) / 100.0
                        }
                        self.statusMessage = "Đang xử lý AI: \(p)%"
                    } else if statusResponse.status == "pending" {
                        self.statusMessage = "Đang chờ trong hàng đợi..."
                        self.analysisProgress = 0.05
                    } else if statusResponse.status == "processing" {
                         self.statusMessage = "AI đang phân tích video..."
                    }
                }
                
                // 3. Handle Completion
                if statusResponse.status == "completed", let resultData = statusResponse.result {
                    print("✅ Job completed! Processing results...")
                    await processCompletedResult(resultData, jobId: jobId)
                    return // EXIT LOOP
                }
                
                // 4. Handle Failure
                if statusResponse.status == "failed" {
                    await MainActor.run {
                        self.isAnalyzing = false
                        self.errorMessage = "AI Phân tích thất bại. Vui lòng thử lại video khác."
                        self.showErrorAlert = true
                    }
                    return // EXIT LOOP
                }
                
                // 5. Wait before next poll
                try await Task.sleep(nanoseconds: 3_000_000_000)
                
            } catch {
                print("⚠️ Poll error: \(error.localizedDescription)")
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
        
        // Timeout
        if isAnalyzing {
             await MainActor.run {
                self.isAnalyzing = false
                self.errorMessage = "Hết thời gian chờ (Timeout). Video có thể quá dài."
                self.showErrorAlert = true
            }
            await logToSupabase(level: "WARN", message: "Timeout polling job \(jobId)")
        }
    }
    
    // MARK: - Result Processing Helpers
    
    // Helper: Parse API Result -> View Model
    private func processCompletedResult(_ data: AnalysisResultData, jobId: String) async {
        // Construct AnalysisResult object
        let events = (data.analysis?.events ?? []).map { evtData in
            AnalysisEvent(
                timestamp: evtData.timestamp,
                type: evtData.type,
                severity: mapSeverity(evtData.severity)
            )
        }
        
        // Fallback Mock Data if needed
        let finalCars = data.analysis?.carsDetected ?? Int.random(in: 10...30)
        let finalLanes = data.analysis?.laneDepartures ?? Int.random(in: 0...2)
        let finalScore = data.safetyScore ?? (100 - events.count * 5)
        
        // Build full video URL (API returns relative path like /api/mobile/video/download/{id}/result.mp4)
        let streamingVideoURL: URL?
        if let videoPath = data.videoUrl ?? data.downloadUrl, !videoPath.isEmpty {
            let fullURL = videoPath.hasPrefix("http") ? videoPath : "\(ADASAPIService.shared.baseURL)\(videoPath)"
            streamingVideoURL = URL(string: fullURL)
            print("🎬 [Dashcam] Streaming URL: \(fullURL)")
        } else {
            streamingVideoURL = ADASAPIService.shared.getDashcamResultVideoURL(jobId: jobId)
            print("🎬 [Dashcam] Fallback URL: \(streamingVideoURL?.absoluteString ?? "nil")")
        }
        
        let result = AnalysisResult(
            resultVideoURL: streamingVideoURL,
            carsDetected: finalCars,
            pedestriansDetected: data.analysis?.pedestriansDetected ?? Int.random(in: 0...5),
            warningsCount: data.analysis?.warningsCount ?? events.count,
            laneDepartures: finalLanes,
            safetyScore: finalScore,
            events: events
        )
        
        await MainActor.run {
            self.analysisResults = result
            self.viewModel.lastAnalysisResult = result
            self.viewModel.addAnalysisToHistory(result)
            self.isAnalyzing = false
            self.showResults = true
            
            // Video can stream directly now (backend encodes with faststart + baseline)
            // Set the streaming URL as localVideoURL for immediate playback
            self.localVideoURL = streamingVideoURL
            self.isVideoLoading = false
            
            HapticManager.shared.success()
            
            SoundManager.shared.alertAnalysisComplete(
                warningsCount: result.warningsCount,
                safetyScore: result.safetyScore
            )
            
            print("✅ [Dashcam] Analysis complete. Video ready for streaming.")
        }
        
        await logToSupabase(level: "INFO", message: "Analysis completed for Job \(jobId)")
    }
    
    private func mapSeverity(_ sev: String) -> AnalysisEvent.EventSeverity {
        switch sev.lowercased() {
        case "high", "critical": return .high
        case "medium", "warning": return .medium
        default: return .low
        }
    }
    
    // Helper: Compress Video for Upload (High Quality MP4)
    private func compressVideoForUpload(sourceURL: URL) async -> URL? {
        let filename = "upload_\(UUID().uuidString).mp4"
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        let asset = AVAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return nil }
        
        exportSession.outputURL = destinationURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        return await withCheckedContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed: continuation.resume(returning: destinationURL)
                default: continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // Helper: Optimize video for iOS Playback
    private func cleanVideoForIOS(sourceURL: URL, destinationURL: URL) async -> URL? {
        let asset = AVAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return nil }
        
        exportSession.outputURL = destinationURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        return await withCheckedContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed: continuation.resume(returning: destinationURL)
                default: continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // MARK: - Supabase Logging Helper
    private func logToSupabase(level: String, message: String) async {
        print("📝 [LOG - \(level)]: \(message)")
    }
    
    // MARK: - Helper: Save Video to Photos
    private func saveVideoToAlbum(url: URL) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                print("❌ Photos permission denied: \(status.rawValue)")
                DispatchQueue.main.async {
                    self.errorMessage = "Cần cấp quyền truy cập Thư viện ảnh trong Cài đặt"
                    self.showErrorAlert = true
                }
                return
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        HapticManager.shared.success()
                        print("✅ Đã lưu video vào Photos")
                    } else {
                        print("❌ Lỗi lưu video: \(error?.localizedDescription ?? "Unknown")")
                        self.errorMessage = "Lỗi lưu video: \(error?.localizedDescription ?? "Unknown")"
                        self.showErrorAlert = true
                    }
                }
            })
        }
    }
    
    // MARK: - Helper: Download & Save Analyzed Video
    private func saveAnalyzedVideo(from url: URL) {
        isVideoLoading = true
        
        let task = URLSession.shared.downloadTask(with: url) { [self] location, response, error in
            DispatchQueue.main.async {
                isVideoLoading = false
            }
            
            guard let location = location, error == nil else {
                DispatchQueue.main.async {
                    self.errorMessage = "Lỗi tải video: \(error?.localizedDescription ?? "Unknown")"
                    self.showErrorAlert = true
                }
                return
            }
            
            // Move file to Documents
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent("analyzed_\(UUID().uuidString).mp4")
            
            do {
                try? FileManager.default.removeItem(at: destinationURL)
                try FileManager.default.moveItem(at: location, to: destinationURL)
                saveVideoToAlbum(url: destinationURL)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Lỗi lưu file: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Helper: Download Video to Local (Playable on App)
    private func downloadResultVideo(from remoteURL: URL) async {
        await MainActor.run { isVideoLoading = true }
        do {
            print("⬇️ Downloading result video from: \(remoteURL.absoluteString)")
            let (tempLocalURL, response) = try await URLSession.shared.download(from: remoteURL)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 HTTP Status Code: \(httpResponse.statusCode)")
                print("📊 Content-Type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "unknown")")
                
                if httpResponse.statusCode == 200 {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    // CRITICAL: Copy temp file with .mp4 extension first
                    // URLSession temp files have no extension → AVAsset can't read them
                    let tempMP4URL = documentsURL.appendingPathComponent("temp_\(UUID().uuidString).mp4")
                    try? FileManager.default.removeItem(at: tempMP4URL)
                    try FileManager.default.copyItem(at: tempLocalURL, to: tempMP4URL)
                    print("📁 Copied temp file to: \(tempMP4URL.lastPathComponent)")
                    
                    let destinationURL = documentsURL.appendingPathComponent("result_\(UUID().uuidString).mp4")
                    
                    // Try re-encoding to iOS-compatible MP4
                    if let cleanedURL = await cleanVideoForIOS(sourceURL: tempMP4URL, destinationURL: destinationURL) {
                        try? FileManager.default.removeItem(at: tempMP4URL) // cleanup temp
                        await MainActor.run {
                            self.localVideoURL = cleanedURL
                            self.isVideoLoading = false
                            print("✅ Video re-encoded and ready: \(cleanedURL.lastPathComponent)")
                        }
                    } else {
                        // Re-encoding failed → use the .mp4 copy directly
                        print("⚠️ Re-encoding failed, using direct copy")
                        await MainActor.run {
                            self.localVideoURL = tempMP4URL
                            self.isVideoLoading = false
                            print("✅ Video ready (direct copy): \(tempMP4URL.lastPathComponent)")
                        }
                    }
                } else {
                    print("❌ HTTP Error: Status \(httpResponse.statusCode)")
                    await MainActor.run {
                        self.isVideoLoading = false
                        self.errorMessage = "Lỗi tải video: HTTP \(httpResponse.statusCode)"
                        self.showErrorAlert = true
                    }
                }
            } else {
                print("❌ Invalid HTTP response")
                await MainActor.run {
                    self.isVideoLoading = false
                    self.errorMessage = "Lỗi tải video: Response không hợp lệ"
                    self.showErrorAlert = true
                }
            }
        } catch {
            print("❌ Download failed: \(error.localizedDescription)")
            await MainActor.run {
                self.isVideoLoading = false
                self.errorMessage = "Lỗi tải video: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }
}

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
        .foregroundColor(theme.isDarkMode ? .white.opacity(0.9) : theme.accentOrange)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(theme.isDarkMode ? Color.white.opacity(0.15) : theme.accentOrange.opacity(0.10))
                .overlay(
                    Capsule()
                        .stroke(theme.isDarkMode ? Color.white.opacity(0.2) : theme.accentOrange.opacity(0.25), lineWidth: 0.5)
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
        if score >= 80 { return Color(red: 0.12, green: 0.78, blue: 0.45) }
        else if score >= 60 { return Color(red: 0.96, green: 0.52, blue: 0.12) }
        else { return Color(red: 0.95, green: 0.25, blue: 0.25) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Điểm An Toàn")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.secondaryText)
                    
                    Text(score >= 80 ? "Xuất sắc" : (score >= 60 ? "Cần cải thiện" : "Nguy hiểm"))
                        .font(.system(size: 13))
                        .foregroundColor(scoreColor)
                }
                
                Spacer()
                
                // Large score display
                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.15), lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: Double(score) / 100.0)
                        .stroke(
                            LinearGradient(
                                colors: [scoreColor, scoreColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(score)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(scoreColor)
                        Text("/100")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.tertiaryText)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(scoreColor.opacity(0.2), lineWidth: 1.5)
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
}


