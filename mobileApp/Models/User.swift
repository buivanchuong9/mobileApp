//
//  User.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String?
    let avatarUrl: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

struct AuthSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: UserProfile
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }
}
