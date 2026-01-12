//
//  ADASAPIService.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import Foundation

class ADASAPIService {
    static let shared = ADASAPIService()
    
    private let baseURL = "https://adas-api.aiotlab.edu.vn"
    private let apiPath = "/api/video"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300 // 5 minutes for upload
        config.timeoutIntervalForResource = 600 // 10 minutes total
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Upload Video
    func uploadVideo(videoURL: URL, videoType: String = "dashcam", device: String = "cuda") async throws -> VideoJobResponse {
        let endpoint = "\(baseURL)\(apiPath)/upload"
        
        print("🔵 Starting upload to: \(endpoint)")
        print("🔵 Video file: \(videoURL.lastPathComponent)")
        
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid URL: \(endpoint)")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        print("🔵 Reading video data...")
        let videoData = try Data(contentsOf: videoURL)
        print("🔵 Video size: \(videoData.count) bytes (\(Double(videoData.count) / 1024 / 1024) MB)")
        
        // Build multipart body
        var body = Data()
        
        // Add video file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(videoURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add video_type
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video_type\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(videoType)\r\n".data(using: .utf8)!)
        
        // Add device
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"device\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(device)\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        print("🔵 Request body size: \(body.count) bytes")
        
        print("🔵 Uploading...")
        
        // Add timeout handling
        let task = Task {
            return try await session.data(for: request)
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await task.value
        } catch {
            print("❌ Upload failed: \(error.localizedDescription)")
            if error.localizedDescription.contains("timed out") {
                throw APIError.uploadFailed
            }
            throw error
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw APIError.invalidResponse
        }
        
        print("🔵 Response status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔵 Response body: \(responseString)")
        } else {
            print("⚠️ Could not decode response body as UTF-8")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Server error: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Error details: \(responseString)")
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        print("🔵 Decoding response...")
        do {
            let decoder = JSONDecoder()
            let uploadResponse = try decoder.decode(VideoJobResponse.self, from: data)
            print("✅ Upload successful! job_id: \(uploadResponse.jobId)")
            return uploadResponse
        } catch {
            print("❌ Decoding error: \(error)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Raw response: \(responseString)")
            }
            throw APIError.decodingError
        }
    }
    
    // MARK: - Get Job Status
    func getJobStatus(jobId: String) async throws -> VideoJobResponse {
        let endpoint = "\(baseURL)\(apiPath)/result/\(jobId)"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 404 {
                throw APIError.jobNotFound
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(VideoJobResponse.self, from: data)
    }
    
    // MARK: - Download Result Video
    func downloadResult(jobId: String, filename: String = "result.mp4") async throws -> URL {
        let endpoint = "\(baseURL)\(apiPath)/download/\(jobId)/\(filename)"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (localURL, response) = try await session.download(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Move to permanent location
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("result_\(jobId).mp4")
        
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: localURL, to: destinationURL)
        
        return destinationURL
    }
}

// MARK: - Models
struct VideoJobResponse: Codable {
    let id: Int
    let jobId: String
    let videoFilename: String
    let videoPath: String
    let videoSizeMb: Double?
    let durationSeconds: Int?
    let fps: Double?
    let resolution: String?
    let status: String
    let progressPercent: Int
    let resultPath: String?
    let errorMessage: String?
    let processingTimeSeconds: Int?
    let tripId: Int?
    let createdAt: String
    let updatedAt: String
    let startedAt: String?
    let completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobId = "job_id"
        case videoFilename = "video_filename"
        case videoPath = "video_path"
        case videoSizeMb = "video_size_mb"
        case durationSeconds = "duration_seconds"
        case fps
        case resolution
        case status
        case progressPercent = "progress_percent"
        case resultPath = "result_path"
        case errorMessage = "error_message"
        case processingTimeSeconds = "processing_time_seconds"
        case tripId = "trip_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

// MARK: - Errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case jobNotFound
    case decodingError
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error: \(code)"
        case .jobNotFound:
            return "Job not found"
        case .decodingError:
            return "Failed to decode response"
        case .uploadFailed:
            return "Upload failed"
        }
    }
}
