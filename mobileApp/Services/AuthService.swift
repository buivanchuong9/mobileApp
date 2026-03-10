//
//  AuthService.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//

import Foundation
import Supabase
import Combine

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    case sessionNotFound
    case deleteFailed(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email hoặc mật khẩu không đúng"
        case .networkError:
            return "Lỗi kết nối mạng"
        case .userNotFound:
            return "Không tìm thấy tài khoản"
        case .emailAlreadyExists:
            return "Email đã được sử dụng"
        case .weakPassword:
            return "Mật khẩu phải có ít nhất 6 ký tự"
        case .sessionNotFound:
            return "Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại"
        case .deleteFailed(let msg):
            return "Xóa tài khoản thất bại: \(msg)"
        case .unknown(let message):
            return message
        }
    }
}

class AuthService: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated: Bool = false
    @Published var accessToken: String?
    
    private let supabase = SupabaseManager.shared.client
    private let keychainService = KeychainService.shared
    
    init() {
        // Check if this is a fresh install
        checkFirstLaunch()
        
        // Check for existing session
        loadSavedSession()
    }
    
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            // This is a fresh install (or first time after update that adds this logic)
            // Keychain survives app deletion, so we must manually clear it
            keychainService.deleteToken()
            
            // Mark as launched
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.synchronize()
            print("🆕 Fresh install detected. Keychain cleared.")
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, fullName: String) async throws {
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )
            
            // response.user is non-optional in v2
            // response.session is optional (nil if email confirmation required)
            let user = response.user
            
            if let session = response.session {
                // Session available - email confirmation disabled
                await saveSession(session: session, user: user)
            } else {
                // No session - email confirmation required
                throw AuthError.unknown("Vui lòng kiểm tra email để xác nhận tài khoản")
            }
            
        } catch {
            throw mapError(error)
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async throws {
        do {
            // signInWithPassword returns Session directly in v2
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            // Get user from session
            let user = try await supabase.auth.user()
            
            // Save session
            await saveSession(session: session, user: user)
            
        } catch {
            throw mapError(error)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            
            // Clear local session
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                self.accessToken = nil
            }
            
            // Clear keychain
            keychainService.deleteToken()
            
        } catch {
            throw mapError(error)
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async throws {
        // 1. Lấy Supabase JWT token từ session hiện tại
        guard let token = try? await supabase.auth.session.accessToken, !token.isEmpty else {
            throw AuthError.sessionNotFound
        }
        
        // 2. Gọi API: DELETE /api/auth/account
        let url = URL(string: "https://adas-api.aiotlab.edu.vn/api/auth/account")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AuthError.deleteFailed("HTTP \(httpResponse.statusCode): \(msg)")
        }
        
        // 3. Đăng xuất local sau khi xóa thành công
        try? await supabase.auth.signOut()
        
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            self.accessToken = nil
        }
        
        // 4. Xóa credentials khỏi Keychain
        keychainService.deleteToken()
    }
    
    // MARK: - Refresh Token
    
    func refreshSession() async throws {
        do {
            // refreshSession returns Session directly in v2
            let session = try await supabase.auth.refreshSession()
            
            // Get user
            let user = try await supabase.auth.user()
            
            await saveSession(session: session, user: user)
            
        } catch {
            // If refresh fails, sign out
            try? await signOut()
            throw mapError(error)
        }
    }
    
    // MARK: - Get Current User
    
    func getCurrentUser() async throws -> UserProfile {
        do {
            let user = try await supabase.auth.user()
            
            let profile = UserProfile(
                id: user.id.uuidString,
                email: user.email ?? "",
                fullName: user.userMetadata["full_name"]?.stringValue,
                avatarUrl: user.userMetadata["avatar_url"]?.stringValue,
                createdAt: user.createdAt
            )
            
            await MainActor.run {
                self.currentUser = profile
            }
            
            return profile
            
        } catch {
            throw mapError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveSession(session: Session, user: User) async {
        let profile = UserProfile(
            id: user.id.uuidString,
            email: user.email ?? "",
            fullName: user.userMetadata["full_name"]?.stringValue,
            avatarUrl: user.userMetadata["avatar_url"]?.stringValue,
            createdAt: user.createdAt
        )
        
        await MainActor.run {
            self.currentUser = profile
            self.isAuthenticated = true
            self.accessToken = session.accessToken
        }
        
        // Save to keychain
        keychainService.saveToken(session.accessToken)
    }
    
    // MARK: - Restore Session
    
    func restoreSession() async throws {
        guard let token = keychainService.getToken() else {
            throw AuthError.userNotFound
        }
        
        // Cập nhật state tạm thời
        await MainActor.run {
            self.accessToken = token
            self.isAuthenticated = true
        }
        
        // Verify token & Get user profile
        do {
            _ = try await getCurrentUser()
        } catch {
            // Nếu token hết hạn hoặc lỗi -> Sign out để clear data
            try? await signOut()
            throw error
        }
    }
    
    private func loadSavedSession() {
        if let token = keychainService.getToken() {
            self.accessToken = token
            self.isAuthenticated = true
            
            Task {
                try? await getCurrentUser()
            }
        }
    }
    
    private func mapError(_ error: Error) -> AuthError {
        let errorMessage = error.localizedDescription.lowercased()
        
        if errorMessage.contains("invalid") || errorMessage.contains("credentials") {
            return .invalidCredentials
        } else if errorMessage.contains("network") || errorMessage.contains("connection") {
            return .networkError
        } else if errorMessage.contains("not found") {
            return .userNotFound
        } else if errorMessage.contains("already") || errorMessage.contains("exists") {
            return .emailAlreadyExists
        } else {
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Keychain Service

class KeychainService {
    static let shared = KeychainService()
    
    private let service = "com.adas.mobileApp"
    private let account = "accessToken"
    
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // Delete existing
        SecItemDelete(query as CFDictionary)
        
        // Add new
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
