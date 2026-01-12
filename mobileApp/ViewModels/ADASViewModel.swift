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
    @Published var vehicleStatus: VehicleStatus = .sample
    @Published var alerts: [Alert] = []
    @Published var systemLogs: [SystemLog] = []
    @Published var isMonitoring: Bool = false
    @Published var detectedObjects: [DetectedObject] = []
    
    private var timer: Timer?
    private var logTimer: Timer?
    
    init() {
        setupFeatures()
        addInitialLogs()
    }
    
    private func setupFeatures() {
        features = ADASFeatureType.allCases.map { type in
            ADASFeature(type: type, isEnabled: true, confidence: Double.random(in: 0.85...0.98))
        }
    }
    
    private func addInitialLogs() {
        systemLogs = [
            SystemLog(timestamp: Date(), level: .success, message: "Model loaded successfully in 0.4s"),
            SystemLog(timestamp: Date().addingTimeInterval(-1), level: .info, message: "Connecting to Camera Input..."),
            SystemLog(timestamp: Date().addingTimeInterval(-2), level: .info, message: "Using YOLOv11-Nano"),
            SystemLog(timestamp: Date().addingTimeInterval(-3), level: .info, message: "Starting Inference Loop..."),
            SystemLog(timestamp: Date().addingTimeInterval(-4), level: .success, message: "System Initialized"),
        ]
    }
    
    func toggleFeature(_ feature: ADASFeature) {
        if let index = features.firstIndex(where: { $0.id == feature.id }) {
            features[index].isEnabled.toggle()
            addLog(level: .info, message: "\(feature.type.rawValue) \(features[index].isEnabled ? "enabled" : "disabled")")
        }
    }
    
    func startMonitoring() {
        isMonitoring = true
        addLog(level: .success, message: "Monitoring started")
        
        // Update detection simulation
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.simulateDetection()
        }
        
        // Add system logs periodically
        logTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.addRandomLog()
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        logTimer?.invalidate()
        logTimer = nil
        detectedObjects.removeAll()
        addLog(level: .warn, message: "Monitoring stopped")
    }
    
    private func simulateDetection() {
        // Update FPS
        vehicleStatus.fps = Int.random(in: 28...32)
        
        // Update speed
        vehicleStatus.speed = max(0, vehicleStatus.speed + Double.random(in: -3...3))
        
        // Simulate object detection
        if features.first(where: { $0.type == .objectDetection })?.isEnabled == true {
            updateDetectedObjects()
        }
        
        // Simulate collision warning
        if features.first(where: { $0.type == .collisionWarning })?.isEnabled == true {
            updateCollisionStatus()
        }
        
        // Simulate lane detection
        if features.first(where: { $0.type == .laneDetection })?.isEnabled == true {
            if Double.random(in: 0...1) > 0.9 {
                triggerLaneWarning()
            }
        }
    }
    
    private func updateDetectedObjects() {
        // Randomly add/remove objects
        if Double.random(in: 0...1) > 0.7 && detectedObjects.count < 5 {
            let types = ["car", "motorbike", "person"]
            let newObject = DetectedObject(
                type: types.randomElement()!,
                distance: Double.random(in: 5...50),
                confidence: Double.random(in: 0.85...0.98),
                frame: CGRect(
                    x: Double.random(in: 50...300),
                    y: Double.random(in: 100...250),
                    width: Double.random(in: 60...120),
                    height: Double.random(in: 80...150)
                )
            )
            detectedObjects.append(newObject)
            vehicleStatus.detectedObjects = detectedObjects
        } else if !detectedObjects.isEmpty && Double.random(in: 0...1) > 0.8 {
            detectedObjects.removeFirst()
            vehicleStatus.detectedObjects = detectedObjects
        }
    }
    
    private func updateCollisionStatus() {
        if let closestObject = detectedObjects.filter({ $0.type == "car" }).min(by: { $0.distance < $1.distance }) {
            let ttc = closestObject.distance / max(vehicleStatus.speed / 3.6, 1.0)
            vehicleStatus.ttc = ttc
            
            if ttc < 2.0 {
                vehicleStatus.collisionStatus = .danger
                if Double.random(in: 0...1) > 0.8 {
                    addAlert(type: .collisionWarning, severity: .critical, message: "DANGER: Collision imminent!")
                }
            } else if ttc < 4.0 {
                vehicleStatus.collisionStatus = .caution
            } else {
                vehicleStatus.collisionStatus = .safe
            }
        } else {
            vehicleStatus.collisionStatus = .safe
            vehicleStatus.ttc = nil
        }
    }
    
    private func triggerLaneWarning() {
        if let index = features.firstIndex(where: { $0.type == .laneDetection }) {
            features[index].lastTriggered = Date()
            addAlert(type: .laneDetection, severity: .medium, message: "Lane Departure Detected")
            addLog(level: .warn, message: "Lane Departure Warning triggered")
        }
    }
    
    private func addAlert(type: ADASFeatureType, severity: Alert.AlertSeverity, message: String) {
        let alert = Alert(
            type: type,
            severity: severity,
            message: message,
            timestamp: Date()
        )
        
        alerts.insert(alert, at: 0)
        
        // Keep only last 20 alerts
        if alerts.count > 20 {
            alerts = Array(alerts.prefix(20))
        }
    }
    
    private func addLog(level: SystemLog.LogLevel, message: String) {
        let log = SystemLog(timestamp: Date(), level: level, message: message)
        systemLogs.insert(log, at: 0)
        
        // Keep only last 50 logs
        if systemLogs.count > 50 {
            systemLogs = Array(systemLogs.prefix(50))
        }
    }
    
    private func addRandomLog() {
        let messages = [
            "Processing frame...",
            "Object detection complete",
            "Analyzing lane markers",
            "TTC calculation updated",
            "Driver attention: Normal",
            "Inference time: \(Int.random(in: 15...35))ms"
        ]
        
        addLog(level: .info, message: messages.randomElement()!)
    }
    
    func clearAlerts() {
        alerts.removeAll()
        addLog(level: .info, message: "Alerts cleared")
    }
    
    func clearLogs() {
        systemLogs.removeAll()
        addInitialLogs()
    }
}
