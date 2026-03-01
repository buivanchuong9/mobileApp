//
//  DrivingAnalysisViewModel.swift
//  mobileApp
//
//  Created by CHUONG on 1/3/26.
//

import Foundation
import SwiftUI

@MainActor
class DrivingAnalysisViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var isProcessing = false
    @Published var uploadProgress: Double = 0.0
    @Published var processingProgress: Double = 0.0
    @Published var currentJobId: String?
    @Published var analysisResult: AnalysisResult?
    @Published var errorMessage: String?
    @Published var statusMessage: String = "Chờ upload video..."
    
    private let apiService = ADASAPIService.shared
    private var pollingTask: Task<Void, Never>?
    
    // MARK: - Upload Video
    
    func uploadDashcamVideo(videoURL: URL) async {
        isUploading = true
        uploadProgress = 0.0
        errorMessage = nil
        statusMessage = "Đang upload video..."
        
        do {
            // Simulate upload progress
            uploadProgress = 0.3
            
            let response = try await apiService.uploadDashcamVideo(videoURL: videoURL)
            
            uploadProgress = 1.0
            isUploading = false
            
            // Start processing
            currentJobId = response.jobId
            statusMessage = response.message ?? "Video đã upload thành công"
            
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
        statusMessage = "Đang phân tích video dashcam..."
        
        // Cancel previous polling if exists
        pollingTask?.cancel()
        
        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let status = try await apiService.checkDashcamStatus(jobId: jobId)
                    
                    // Update progress
                    processingProgress = Double(status.progressPercent) / 100.0
                    
                    switch status.status {
                    case "completed":
                        // Success
                        await handleCompletedStatus(status)
                        return
                        
                    case "failed":
                        // Failed
                        errorMessage = "Xử lý video thất bại"
                        statusMessage = "Phân tích thất bại"
                        isProcessing = false
                        return
                        
                    case "processing":
                        statusMessage = "Đang phân tích... \(status.progressPercent)%"
                        
                    case "pending", "queued":
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
    
    private func handleCompletedStatus(_ status: JobStatusResponse) async {
        guard let result = status.result else {
            errorMessage = "Không nhận được kết quả"
            isProcessing = false
            return
        }
        
        // Get full video URL
        guard let jobId = currentJobId,
              let videoURL = apiService.getDashcamResultVideoURL(jobId: jobId) else {
            errorMessage = "Không thể tạo URL video"
            isProcessing = false
            return
        }
        
        // Parse events from analysis
        let events = parseEvents(from: result.analysis)
        
        // Create analysis result
        let analysisResult = AnalysisResult(
            resultVideoURL: videoURL,
            carsDetected: result.analysis?.carsDetected ?? 0,
            pedestriansDetected: result.analysis?.pedestriansDetected ?? 0,
            warningsCount: result.analysis?.warningsCount ?? 0,
            laneDepartures: result.analysis?.laneDepartures ?? 0,
            safetyScore: result.safetyScore ?? 0,
            events: events
        )
        
        self.analysisResult = analysisResult
        self.isProcessing = false
        self.statusMessage = "Phân tích hoàn tất!"
        self.processingProgress = 1.0
        
        // Play voice alert with actual data
        playVoiceAlert(for: analysisResult)
    }
    
    // MARK: - Voice Alert
    
    private func playVoiceAlert(for result: AnalysisResult) {
        SoundManager.shared.alertAnalysisComplete(
            warningsCount: result.warningsCount,
            safetyScore: result.safetyScore
        )
    }
    
    // MARK: - Helper Methods
    
    private func parseEvents(from metrics: AnalysisMetrics?) -> [AnalysisEvent] {
        guard let eventData = metrics?.events else {
            // Generate mock events if backend doesn't return any
            return generateMockEvents(
                cars: metrics?.carsDetected ?? 0,
                pedestrians: metrics?.pedestriansDetected ?? 0,
                laneDepartures: metrics?.laneDepartures ?? 0
            )
        }
        
        return eventData.map { event in
            let severity: AnalysisEvent.EventSeverity
            switch event.severity.lowercased() {
            case "high":
                severity = .high
            case "medium":
                severity = .medium
            default:
                severity = .low
            }
            
            return AnalysisEvent(
                timestamp: event.timestamp,
                type: event.type,
                severity: severity
            )
        }
    }
    
    private func generateMockEvents(cars: Int, pedestrians: Int, laneDepartures: Int) -> [AnalysisEvent] {
        var events: [AnalysisEvent] = []
        
        if cars > 0 {
            events.append(AnalysisEvent(
                timestamp: "00:00:15",
                type: "Phát hiện xe",
                severity: .low
            ))
        }
        
        if pedestrians > 0 {
            events.append(AnalysisEvent(
                timestamp: "00:00:30",
                type: "Phát hiện người đi bộ",
                severity: .medium
            ))
        }
        
        if laneDepartures > 0 {
            events.append(AnalysisEvent(
                timestamp: "00:00:45",
                type: "Lệch làn đường",
                severity: .high
            ))
        }
        
        return events
    }
    
    // MARK: - Reset
    
    func reset() {
        pollingTask?.cancel()
        isUploading = false
        isProcessing = false
        uploadProgress = 0.0
        processingProgress = 0.0
        currentJobId = nil
        analysisResult = nil
        errorMessage = nil
        statusMessage = "Chờ upload video..."
    }
}
