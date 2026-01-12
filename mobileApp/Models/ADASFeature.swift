//
//  ADASFeature.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import Foundation
import SwiftUI

enum ADASFeatureType: String, CaseIterable, Identifiable {
    case laneDetection = "Lane Departure Warning"
    case collisionWarning = "Forward Collision Warning"
    case objectDetection = "Object Detection"
    case driverMonitoring = "Driver Monitoring"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .laneDetection:
            return "road.lanes"
        case .collisionWarning:
            return "exclamationmark.triangle.fill"
        case .objectDetection:
            return "viewfinder"
        case .driverMonitoring:
            return "eye.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .laneDetection:
            return Color(red: 0.2, green: 0.8, blue: 0.4) // Green like website
        case .collisionWarning:
            return Color(red: 1.0, green: 0.6, blue: 0.2) // Orange accent
        case .objectDetection:
            return Color(red: 0.4, green: 0.6, blue: 1.0) // Blue
        case .driverMonitoring:
            return Color(red: 0.9, green: 0.4, blue: 0.9) // Purple
        }
    }
    
    var description: String {
        switch self {
        case .laneDetection:
            return "Cảnh báo khi xe lệch làn đường"
        case .collisionWarning:
            return "Cảnh báo va chạm phía trước"
        case .objectDetection:
            return "Phát hiện xe, người, vật thể"
        case .driverMonitoring:
            return "Giám sát trạng thái lái xe"
        }
    }
}

enum CollisionStatus: String {
    case safe = "SAFE"
    case caution = "CAUTION"
    case danger = "DANGER"
    
    var color: Color {
        switch self {
        case .safe:
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .caution:
            return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .danger:
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        }
    }
}

struct DetectedObject: Identifiable {
    let id = UUID()
    let type: String // "car", "motorbike", "person"
    let distance: Double // meters
    let confidence: Double
    var frame: CGRect
}

struct ADASFeature: Identifiable {
    let id = UUID()
    let type: ADASFeatureType
    var isEnabled: Bool
    var lastTriggered: Date?
    var confidence: Double // 0.0 to 1.0
    
    init(type: ADASFeatureType, isEnabled: Bool = true, lastTriggered: Date? = nil, confidence: Double = 0.0) {
        self.type = type
        self.isEnabled = isEnabled
        self.lastTriggered = lastTriggered
        self.confidence = confidence
    }
}
