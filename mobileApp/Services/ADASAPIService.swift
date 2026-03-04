//
//  ADASAPIService.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import Foundation

class ADASAPIService {
    static let shared = ADASAPIService()
    
    let baseURL = "https://adas-api.aiotlab.edu.vn"
    private let videoApiPath = "/api/mobile/video"     // Dashcam API
    private let driverApiPath = "/api/mobile/driver"   // Driver Monitoring API
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 240 // 4 minutes
        config.timeoutIntervalForResource = 240 // 4 minutes
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Helper Methods
    
    // Get Dashcam result video URL
    func getDashcamResultVideoURL(jobId: String) -> URL? {
        return URL(string: "\(baseURL)\(videoApiPath)/download/\(jobId)/result.mp4")
    }
    
    // Get Driver Monitoring result video URL
    func getDriverResultVideoURL(jobId: String) -> URL? {
        return URL(string: "\(baseURL)\(driverApiPath)/download/\(jobId)/result.mp4")
    }
    
    // MARK: - Driver Monitoring API
    
    /// Upload driver video (in-cabin camera)
    func uploadDriverVideo(videoURL: URL) async throws -> DriverUploadResponse {
        let endpoint = "\(baseURL)\(driverApiPath)/upload"
        
        print("🔵 [Driver] Starting upload to: \(endpoint)")
        print("🔵 [Driver] Video file: \(videoURL.lastPathComponent)")
        
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add Auth Token if available
        if let token = try? await SupabaseManager.shared.client.auth.session.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let videoData = try Data(contentsOf: videoURL)
        
        var body = Data()
        let fileExtension = videoURL.pathExtension.lowercased()
        let mimeType = (fileExtension == "mov") ? "video/quicktime" : "video/mp4"
        
        // Add video file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(videoURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Upload
        let (data, response) = try await session.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("❌ [Driver] Server error: \(httpResponse.statusCode)")
            throw APIError.serverError(message: "Error \(httpResponse.statusCode)")
        }
        
        // Decode response
        let decoder = JSONDecoder()
        do {
            let uploadResponse = try decoder.decode(DriverUploadResponse.self, from: data)
            print("✅ [Driver] Upload successful! jobId: \(uploadResponse.jobId)")
            return uploadResponse
        } catch {
            print("❌ [Driver] Decoding failed: \(error)")
            throw APIError.decodingError
        }
    }
    
    /// Check driver video processing status
    func checkDriverStatus(jobId: String) async throws -> DriverStatusResponse {
        let endpoint = "\(baseURL)\(driverApiPath)/status/\(jobId)"
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = try? await SupabaseManager.shared.client.auth.session.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(message: "Status check failed")
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(DriverStatusResponse.self, from: data)
        } catch {
            print("❌ [Driver] Decoding status failed: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: - Dashcam Video API (Driving Analysis)
    
    /// Upload dashcam video (front-facing camera)
    func uploadDashcamVideo(videoURL: URL, videoType: String = "dashcam", device: String = "cuda") async throws -> UploadResponse {
        let endpoint = "\(baseURL)\(videoApiPath)/upload"
        
        print("🔵 [Dashcam] Starting upload to: \(endpoint)")
        print("🔵 [Dashcam] Video file: \(videoURL.lastPathComponent)")
        
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add Auth Token if available
        if let token = try? await SupabaseManager.shared.client.auth.session.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let videoData = try Data(contentsOf: videoURL)
        
        var body = Data()
        let fileExtension = videoURL.pathExtension.lowercased()
        let mimeType = (fileExtension == "mov") ? "video/quicktime" : "video/mp4"
        
        // 1. Add video file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(videoURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n".data(using: .utf8)!)
        
        // 2. Add video_type
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video_type\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(videoType)\r\n".data(using: .utf8)!)
        
        // 3. Add device
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"device\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(device)\r\n".data(using: .utf8)!)
        
        // Closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Upload
        let (data, response) = try await session.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("❌ [Dashcam] Server error: \(httpResponse.statusCode)")
            throw APIError.serverError(message: "Error \(httpResponse.statusCode)")
        }
        
        // Decode new UploadResponse
        let decoder = JSONDecoder()
        do {
            let uploadResponse = try decoder.decode(UploadResponse.self, from: data)
            print("✅ [Dashcam] Upload successful! jobId: \(uploadResponse.jobId)")
            return uploadResponse
        } catch {
             print("❌ [Dashcam] Decoding UploadResponse failed: \(error)")
             throw APIError.decodingError
        }
    }
    
    /// Check dashcam video processing status
    func checkDashcamStatus(jobId: String) async throws -> JobStatusResponse {
        let endpoint = "\(baseURL)\(videoApiPath)/status/\(jobId)"
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = try? await SupabaseManager.shared.client.auth.session.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(message: "Status check failed")
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(JobStatusResponse.self, from: data)
        } catch {
            print("❌ [Dashcam] Decoding JobStatusResponse failed: \(error)")
            throw APIError.decodingError
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(message: String)
    case decodingError
    case jobNotFound
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "URL không hợp lệ"
        case .invalidResponse: return "Phản hồi từ server không hợp lệ"
        case .serverError(let message): return "Lỗi Server: \(message)"
        case .decodingError: return "Lỗi xử lý dữ liệu"
        case .jobNotFound: return "Không tìm thấy job phân tích"
        }
    }
}
