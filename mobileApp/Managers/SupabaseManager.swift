//
//  SupabaseManager.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        let supabaseURL = URL(string: "https://kijdjdtuyeywmthhuoac.supabase.co")!
        let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpamRqZHR1eWV5d210aGh1b2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczMzY0MTUsImV4cCI6MjA4MjkxMjQxNX0.T2UOrxb53Op_xfMMoaTvQIUs0c_PJbPdlezz4B1-9Lg"
        
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )
    }
}
