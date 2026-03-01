//
//  DriverMonitoringViewModel.swift
//  mobileApp
//
//  Created by CHUONG on 1/3/26.
//

import Foundation
import SwiftUI

@MainActor
class DriverMonitoringViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var isProcessing = false
    @Published var uploadProgress: Double = 0.0
    @Published var processingProgress: Double = 0.0
    @Published var currentJobId: String?
    @Published var monitoringResult: DriverMonitoringResult?
    @Published var errorMessage: String?
    @Published var statusMessage: String = "Chờ upload video..."
    
    private let apiService = ADASAPIService.shared
    private var pollingTask: Task<Void, Never>?
    
    // MARK: - Upload Video
    
    func uploadDriverVideo(videoURL: URL) async {
        isUploading = true
        uploadProgress = 0.0
        errorMessage = nil
        statusMessage = "Đang upload video..."
        
        do {
            // Simulate upload progress (URLSession doesn't provide real-time upload progress easily)
            uploadProgress = 0.3
            
            let response = try await apiService.uploadDriverVideo(videoURL: videoURL)
            
            uploadProgress = 1.0
            isUploading = false
            
            // Start processing
            currentJobId = response.jobId
            statusMessage = response.message
            
            // Start polling
            await startPollingStatus(jobId: response.jobId)
            
        } catch let error as APIError {
            isUploading = false
            errorMessage = error.localizedDescription
            statusMessage = "Upload thất bại"
        } catch {
            isUploading = false
            errorMessage = "Lỗi upload: \(error.localizedDescription)"
            statusMessage = "Upload thất bại"
        }
    }
    
    // MARK: - Poll Status
    
    func startPollingStatus(jobId: String) async {
        isProcessing = true
        processingProgress = 0.0
        statusMessage = "Đang phân tích video..."
        
        // Cancel previous polling if exists
        pollingTask?.cancel()
        
        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let status = try await apiService.checkDriverStatus(jobId: jobId)
                    
                    // Update progress
                    processingProgress = Double(status.progressPercent) / 100.0
                    
                    switch status.status {
                    case "completed":
                        // Success
                        await handleCompletedStatus(status)
                        return
                        
                    case "failed":
                        // Failed
                        let errorMsg = status.error?.message ?? "Xử lý video thất bại"
                        errorMessage = errorMsg
                        statusMessage = "Phân tích thất bại"
                        isProcessing = false
                        return
                        
                    case "processing":
                        statusMessage = "Đang phân tích... \(status.progressPercent)%"
                        
                    case "pending":
                        statusMessage = "Đang chờ xử lý..."
                        
                    default:
                        statusMessage = "Trạng thái: \(status.status)"
                    }
                    
                    // Wait 2 seconds before next poll
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    
                } catch {
                    if !Task.isCancelled {
                        errorMessage = "Lỗi kiểm tra trạng thái: \(error.localizedDescription)"
                        isProcessing = false
                        return
                    }
                }
            }
        }
    }
    
    private func handleCompletedStatus(_ status: DriverStatusResponse) async {
        guard let result = status.result else {
            errorMessage = "Không nhận được kết quả"
            isProcessing = false
            return
        }
        
        // Build full video URL from API response (relative path → full URL)
        // API returns: /api/mobile/driver/download/{job_id}/result.mp4
        let videoURL: URL?
        if !result.videoUrl.isEmpty {
            let fullURL = result.videoUrl.hasPrefix("http") ? result.videoUrl : "\(apiService.baseURL)\(result.videoUrl)"
            videoURL = URL(string: fullURL)
            print("🎬 [Driver] Video URL from API: \(fullURL)")
        } else if !result.downloadUrl.isEmpty {
            let fullURL = result.downloadUrl.hasPrefix("http") ? result.downloadUrl : "\(apiService.baseURL)\(result.downloadUrl)"
            videoURL = URL(string: fullURL)
            print("🎬 [Driver] Video URL from download_url: \(fullURL)")
        } else if let jobId = currentJobId {
            videoURL = apiService.getDriverResultVideoURL(jobId: jobId)
            print("🎬 [Driver] Video URL from fallback: \(videoURL?.absoluteString ?? "nil")")
        } else {
            videoURL = nil
        }
        
        guard videoURL != nil else {
            errorMessage = "Không thể tạo URL video"
            isProcessing = false
            return
        }
        
        // Calculate safety score (simple logic)
        let safetyScore = calculateSafetyScore(
            fatigueDetected: result.fatigueDetection,
            distractionDetected: result.distractionDetection
        )
        
        // Create mock issues (backend doesn't return detailed events yet)
        let issues = generateMockIssues(
            fatigueDetected: result.fatigueDetection,
            distractionDetected: result.distractionDetection
        )
        
        // Create result
        let monitoringResult = DriverMonitoringResult(
            resultVideoURL: videoURL,
            durationSeconds: result.durationSeconds ?? 0,
            processingTimeSeconds: result.processingTimeSeconds ?? 0,
            fatigueDetected: result.fatigueDetection,
            distractionDetected: result.distractionDetection,
            safetyScore: safetyScore,
            issues: issues
        )
        
        self.monitoringResult = monitoringResult
        self.isProcessing = false
        self.statusMessage = "Phân tích hoàn tất!"
        self.processingProgress = 1.0
        
        // Play voice alert with actual data
        playVoiceAlert(for: monitoringResult)
    }
    
    // MARK: - Voice Alert
    
    private func playVoiceAlert(for result: DriverMonitoringResult) {
        // Determine status based on safety score
        let status: String
        if result.safetyScore >= 80 {
            status = "An Toàn"
        } else if result.safetyScore >= 60 {
            status = "Cảnh Báo"
        } else {
            status = "Nguy Hiểm"
        }
        
        // Play comprehensive alert
        SoundManager.shared.alertDriverMonitoringResult(
            status: status,
            attentionScore: result.safetyScore
        )
        
        // Additional specific alerts for detected issues
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            if result.fatigueDetected {
                SoundManager.shared.alertDrowsiness()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            if result.distractionDetected {
                SoundManager.shared.alertDistraction()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateSafetyScore(fatigueDetected: Bool, distractionDetected: Bool) -> Int {
        var score = 100
        
        if fatigueDetected {
            score -= 30
        }
        
        if distractionDetected {
            score -= 25
        }
        
        return max(score, 0)
    }
    
    private func generateMockIssues(fatigueDetected: Bool, distractionDetected: Bool) -> [DriverIssue] {
        var issues: [DriverIssue] = []
        
        if fatigueDetected {
            issues.append(DriverIssue(
                type: .fatigue,
                timestamp: "00:00:15",
                severity: .high
            ))
            issues.append(DriverIssue(
                type: .eyesClosed,
                timestamp: "00:00:23",
                severity: .medium
            ))
        }
        
        if distractionDetected {
            issues.append(DriverIssue(
                type: .distraction,
                timestamp: "00:00:45",
                severity: .high
            ))
            issues.append(DriverIssue(
                type: .lookingAway,
                timestamp: "00:00:52",
                severity: .medium
            ))
        }
        
        return issues
    }
    
    // MARK: - Reset
    
    func reset() {
        pollingTask?.cancel()
        isUploading = false
        isProcessing = false
        uploadProgress = 0.0
        processingProgress = 0.0
        currentJobId = nil
        monitoringResult = nil
        errorMessage = nil
        statusMessage = "Chờ upload video..."
    }
}
