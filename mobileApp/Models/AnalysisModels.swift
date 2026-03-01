import Foundation
import SwiftUI

// MARK: - API Response Models (Mobile API)

struct MobileAPIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let error: APIErrorDetail?
    let data: T? // Generic data payload
    
    // Support flattening for job_id/status at root level
    let jobId: String?
    let status: String?
    let progressPercent: Int?
    let result: T? // Sometimes data is in 'result' key
    
    enum CodingKeys: String, CodingKey {
        case success, message, error, data, result
        case jobId = "job_id"
        case status
        case progressPercent = "progress_percent"
    }
}

struct APIErrorDetail: Codable {
    let code: String?
    let message: String
}

// 1. Upload Response (Dashcam)
struct UploadResponse: Codable {
    let success: Bool?
    let jobId: String
    let status: String
    let message: String?
    let videoType: String?
    let estimatedTimeSeconds: Int?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case jobId = "job_id"
        case status, message
        case videoType = "video_type"
        case estimatedTimeSeconds = "estimated_time_seconds"
        case createdAt = "created_at"
    }
}

// 2. Status Response (Dashcam)
struct JobStatusResponse: Codable {
    let success: Bool?
    let jobId: String
    let status: String // pending, processing, completed, failed
    let progressPercent: Int
    let videoType: String?
    let result: AnalysisResultData?
    let error: APIErrorDetail?
    
    enum CodingKeys: String, CodingKey {
        case success
        case jobId = "job_id"
        case status
        case progressPercent = "progress_percent"
        case videoType = "video_type"
        case result
        case error
    }
}

// 3. Result Data (Nested in Status)
struct AnalysisResultData: Codable {
    let videoUrl: String?       // Relative: /api/mobile/video/download/{id}/result.mp4
    let downloadUrl: String?    // Same as videoUrl
    let thumbnailUrl: String?
    let safetyScore: Int?
    let durationSeconds: Double?
    let processingTimeSeconds: Double?
    let analysis: AnalysisMetrics?
    
    enum CodingKeys: String, CodingKey {
        case videoUrl = "video_url"
        case downloadUrl = "download_url"
        case thumbnailUrl = "thumbnail_url"
        case safetyScore = "safety_score"
        case durationSeconds = "duration_seconds"
        case processingTimeSeconds = "processing_time_seconds"
        case analysis
    }
}

struct AnalysisMetrics: Codable {
    let carsDetected: Int?
    let pedestriansDetected: Int?
    let laneDepartures: Int?
    let warningsCount: Int?
    let events: [AnalysisEventData]?
    
    enum CodingKeys: String, CodingKey {
        case carsDetected = "cars_detected"
        case pedestriansDetected = "pedestrians_detected"
        case laneDepartures = "lane_departures"
        case warningsCount = "warnings_count"
        case events
    }
}

struct AnalysisEventData: Codable {
    let type: String
    let timestamp: String
    let severity: String
}


// MARK: - App Domain Models (Used in Views)

struct AnalysisResult {
    var resultVideoURL: URL?
    let carsDetected: Int
    let pedestriansDetected: Int
    let warningsCount: Int
    let laneDepartures: Int
    let safetyScore: Int
    let events: [AnalysisEvent]
}

struct AnalysisEvent: Identifiable {
    let id: UUID
    let timestamp: String
    let type: String
    let severity: EventSeverity
    
    init(id: UUID = UUID(), timestamp: String, type: String, severity: EventSeverity) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.severity = severity
    }
    
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

// MARK: - Driver Monitoring API Models

// Driver Upload Response
struct DriverUploadResponse: Codable {
    let success: Bool
    let jobId: String
    let status: String
    let message: String
    let videoType: String
    let estimatedTimeSeconds: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case jobId = "job_id"
        case status, message
        case videoType = "video_type"
        case estimatedTimeSeconds = "estimated_time_seconds"
        case createdAt = "created_at"
    }
}

// Driver Status Response
struct DriverStatusResponse: Codable {
    let success: Bool
    let jobId: String
    let status: String
    let progressPercent: Int
    let videoType: String
    let result: DriverResultData?
    let error: APIErrorDetail?
    
    enum CodingKeys: String, CodingKey {
        case success
        case jobId = "job_id"
        case status
        case progressPercent = "progress_percent"
        case videoType = "video_type"
        case result
        case error
    }
}

// Driver Result Data
struct DriverResultData: Codable {
    let downloadUrl: String
    let videoUrl: String
    let durationSeconds: Double?
    let processingTimeSeconds: Double?
    let fatigueDetection: Bool
    let distractionDetection: Bool
    
    enum CodingKeys: String, CodingKey {
        case downloadUrl = "download_url"
        case videoUrl = "video_url"
        case durationSeconds = "duration_seconds"
        case processingTimeSeconds = "processing_time_seconds"
        case fatigueDetection = "fatigue_detection"
        case distractionDetection = "distraction_detection"
    }
}

// Driver Monitoring Result (App Domain Model)
struct DriverMonitoringResult: Equatable {
    var resultVideoURL: URL?
    let durationSeconds: Double
    let processingTimeSeconds: Double
    let fatigueDetected: Bool
    let distractionDetected: Bool
    let safetyScore: Int
    let issues: [DriverIssue]
    
    static func == (lhs: DriverMonitoringResult, rhs: DriverMonitoringResult) -> Bool {
        lhs.safetyScore == rhs.safetyScore &&
        lhs.fatigueDetected == rhs.fatigueDetected &&
        lhs.distractionDetected == rhs.distractionDetected &&
        lhs.durationSeconds == rhs.durationSeconds &&
        lhs.resultVideoURL == rhs.resultVideoURL
    }
}

struct DriverIssue: Identifiable {
    let id: UUID
    let type: IssueType
    let timestamp: String
    let severity: IssueSeverity
    
    init(id: UUID = UUID(), type: IssueType, timestamp: String, severity: IssueSeverity) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.severity = severity
    }
    
    enum IssueType: String {
        case fatigue = "Mệt mỏi"
        case distraction = "Mất tập trung"
        case eyesClosed = "Nhắm mắt"
        case phoneUsage = "Dùng điện thoại"
        case lookingAway = "Nhìn ra ngoài"
        case headPose = "Tư thế đầu nguy hiểm"
        
        var icon: String {
            switch self {
            case .fatigue: return "bed.double.fill"
            case .distraction: return "eye.slash.fill"
            case .eyesClosed: return "eye.fill"
            case .phoneUsage: return "phone.fill"
            case .lookingAway: return "arrow.turn.up.right"
            case .headPose: return "face.dashed.fill"
            }
        }
    }
    
    enum IssueSeverity {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .yellow
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
}
