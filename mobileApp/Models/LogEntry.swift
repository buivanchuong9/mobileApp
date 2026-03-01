//
//  LogEntry.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//

import Foundation
import SwiftUI

enum LogLevel: String, Codable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    
    var color: Color {
        switch self {
        case .debug:
            return Color(red: 0.5, green: 0.5, blue: 0.5) // Gray
        case .info:
            return Color(red: 0.2, green: 0.8, blue: 0.4) // Green
        case .warning:
            return Color(red: 1.0, green: 0.8, blue: 0.2) // Yellow
        case .error:
            return Color(red: 1.0, green: 0.3, blue: 0.3) // Red
        case .critical:
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Dark Red
        }
    }
    
    var icon: String {
        switch self {
        case .debug:
            return "ant.fill"
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.octagon.fill"
        case .critical:
            return "flame.fill"
        }
    }
}

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let level: LogLevel
    let message: String
    let source: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp = "created_at"
        case level
        case message
        case source
    }
    
    init(id: UUID = UUID(), timestamp: Date = Date(), level: LogLevel, message: String, source: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.source = source
    }
    
    // Custom Decode to handle flexible ID types and Date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 1. Decode ID (Handle Int, String, or UUID)
        if let intID = try? container.decode(Int64.self, forKey: .id) {
            // Convert Int ID to UUID deterministically or use random
            self.id = UUID() // Use random for UI uniqueness if Int is used
        } else if let strID = try? container.decode(String.self, forKey: .id), let uuid = UUID(uuidString: strID) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        
        // 2. Decode Message
        self.message = try container.decode(String.self, forKey: .message)
        
        // 3. Decode Level (Handle lowercase/uppercase)
        let levelString = try container.decode(String.self, forKey: .level)
        self.level = LogLevel(rawValue: levelString.uppercased()) ?? .info
        
        // 4. Decode Timestamp (Handle ISO8601 safely)
        if let dateStr = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateStr) {
                self.timestamp = date
            } else {
                // Try without fractional seconds
                formatter.formatOptions = [.withInternetDateTime]
                self.timestamp = formatter.date(from: dateStr) ?? Date()
            }
        } else {
            self.timestamp = Date()
        }
        
        self.source = try? container.decodeIfPresent(String.self, forKey: .source)
    }
    
    // Keep helper for formatted time UI
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    // Legacy parse (can keep or remove, keeping for safety)
    static func parse(from line: String) -> LogEntry? {
        // Fallback for raw text parsing
        return LogEntry(level: .info, message: line)
    }
}

struct LogStats: Codable {
    let success: Bool
    let filePath: String
    let fileSizeMB: Double
    let modifiedAt: String
    let activeConnections: Int
    
    enum CodingKeys: String, CodingKey {
        case success
        case filePath = "file_path"
        case fileSizeMB = "file_size_mb"
        case modifiedAt = "modified_at"
        case activeConnections = "active_connections"
    }
}

struct LogsResponse: Codable {
    let success: Bool
    let totalLines: Int
    let returnedLines: Int
    let logs: [String]
    
    enum CodingKeys: String, CodingKey {
        case success
        case totalLines = "total_lines"
        case returnedLines = "returned_lines"
        case logs
    }
}
