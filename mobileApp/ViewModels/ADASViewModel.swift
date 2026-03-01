//
//  ADASViewModel.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import Foundation
import Combine

class ADASViewModel: ObservableObject {
    @Published var features: [ADASFeature] = []
    @Published var vehicleStatus: VehicleStatus = VehicleStatus(
        speed: 0,
        fps: 0,
        resolution: "1280x720",
        modelVersion: "YOLOv11-Nano",
        device: "iPhone",
        ttc: nil,
        collisionStatus: .safe,
        detectedObjects: []
    )
    @Published var alerts: [Alert] = []
    @Published var systemLogs: [SystemLog] = []
    @Published var isMonitoring: Bool = false
    @Published var detectedObjects: [DetectedObject] = []
    
    // Lưu kết quả phân tích cuối cùng (Từ Backend)
    @Published var lastAnalysisResult: AnalysisResult?
    
    // Lịch sử phân tích (cho biểu đồ trên Dashboard)
    @Published var analysisHistory: [AnalysisHistoryEntry] = []
    
    private var timer: Timer?
    private var logTimer: Timer?
    
    init() {
        setupFeatures()
        // Không tạo log rác ban đầu nữa
        // addInitialLogs()
    }
    
    private func setupFeatures() {
        features = ADASFeatureType.allCases.map { type in
            ADASFeature(type: type, isEnabled: true, confidence: 0.0) // Reset confidence
        }
    }
    
    
    func toggleFeature(at index: Int) {
        guard index >= 0 && index < features.count else { return }
        features[index].isEnabled.toggle()
        
        let featureType = features[index].type
        let status = features[index].isEnabled ? "enabled" : "disabled"
        addLog(level: .info, message: "\(featureType.rawValue) \(status)")
    }
    
    
    func startMonitoring() {
        isMonitoring = true
        addLog(level: .success, message: "Monitoring started")
        
        // Chỉ chạy simulation nếu KHÔNG CÓ kết quả thật (hoặc để test)
        // Hiện tại tạm tắt simulation random để Dashboard sạch
        /*
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.simulateDetection()
        }
        */
        
        // Add system logs periodically
        /*
        logTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.addRandomLog()
        }
        */
    }
    
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        logTimer?.invalidate()
        logTimer = nil
        detectedObjects.removeAll()
        
        // Reset về 0 khi dừng
        vehicleStatus.fps = 0
        vehicleStatus.speed = 0
        
        addLog(level: .warn, message: "Monitoring stopped")
    }
    
    // ... (Simulation code commented out or ignored)
    private func simulateDetection() {
        // ... (Giữ code cũ nhưng không gọi)
    }
    
    // ... (Cập nhật helper logs)
    private func addLog(level: SystemLog.LogLevel, message: String) {
        let log = SystemLog(timestamp: Date(), level: level, message: message)
        systemLogs.insert(log, at: 0)
        if systemLogs.count > 50 { systemLogs = Array(systemLogs.prefix(50)) }
    }
    
    private func addAlert(type: ADASFeatureType, severity: Alert.AlertSeverity, message: String) {
        let alert = Alert(type: type, severity: severity, message: message, timestamp: Date())
        alerts.insert(alert, at: 0)
        if alerts.count > 20 { alerts = Array(alerts.prefix(20)) }
    }
    
    func clearAlerts() { alerts.removeAll() }
    func clearLogs() { systemLogs.removeAll() }
    
    // MARK: - Analysis History
    
    func addAnalysisToHistory(_ result: AnalysisResult) {
        let entry = AnalysisHistoryEntry(
            date: Date(),
            type: .dashcam,
            safetyScore: result.safetyScore,
            carsDetected: result.carsDetected,
            laneDepartures: result.laneDepartures,
            fatigueDetected: false,
            distractionDetected: false
        )
        analysisHistory.append(entry)
    }
    
    func addDriverResultToHistory(_ result: DriverMonitoringResult) {
        let entry = AnalysisHistoryEntry(
            date: Date(),
            type: .driver,
            safetyScore: result.safetyScore,
            carsDetected: 0,
            laneDepartures: 0,
            fatigueDetected: result.fatigueDetected,
            distractionDetected: result.distractionDetected
        )
        analysisHistory.append(entry)
    }
}

// MARK: - Analysis History Entry

struct AnalysisHistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let type: EntryType
    let safetyScore: Int
    let carsDetected: Int
    let laneDepartures: Int
    let fatigueDetected: Bool
    let distractionDetected: Bool
    
    enum EntryType {
        case dashcam, driver
    }
    
    var shortLabel: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
    
    var dayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM"
        return f.string(from: date)
    }
}
