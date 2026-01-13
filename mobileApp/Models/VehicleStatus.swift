//
//  VehicleStatus.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import Foundation
import SwiftUI

struct VehicleStatus {
    var speed: Double // km/h
    var fps: Int
    var resolution: String
    var modelVersion: String
    var device: String
    var ttc: Double? // Time to collision in seconds
    var collisionStatus: CollisionStatus
    var detectedObjects: [DetectedObject]
    
    static var sample: VehicleStatus {
        VehicleStatus(
            speed: 65.5,
            fps: 30,
            resolution: "1920x1080",
            modelVersion: "YOLOv11-Nano",
            device: "iPhone Simulator",
            ttc: 4.5,
            collisionStatus: .safe,
            detectedObjects: []
        )
    }
}

struct SystemLog: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String
    
    enum LogLevel: String {
        case info = "INFO"
        case warn = "WARN"
        case error = "ERROR"
        case success = "OK"
        
        var color: String {
            switch self {
            case .info:
                return "blue"
            case .warn:
                return "yellow"
            case .error:
                return "red"
            case .success:
                return "green"
            }
        }
    }
    
    var formattedMessage: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return "[\(level.rawValue)] \(message)"
    }
}

struct Alert: Identifiable {
    let id = UUID()
    let type: ADASFeatureType
    let severity: AlertSeverity
    let message: String
    let timestamp: Date
    
    enum AlertSeverity {
        case low, medium, high, critical
        
        var colorName: String {
            switch self {
            case .low: return "green"
            case .medium: return "yellow"
            case .high: return "orange"
            case .critical: return "red"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
}
