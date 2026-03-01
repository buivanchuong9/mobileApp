//
//  ThemeManager.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    // MARK: - Background Colors (Pure White Light Mode)
    var backgroundColor: Color {
        isDarkMode 
            ? Color(red: 0.06, green: 0.07, blue: 0.11)
            : Color(red: 0.965, green: 0.97, blue: 0.98)   // Subtle warm off-white
    }
    
    var secondaryBackground: Color {
        isDarkMode 
            ? Color(red: 0.09, green: 0.10, blue: 0.15)
            : Color(red: 0.95, green: 0.955, blue: 0.965)
    }
    
    var cardBackground: Color {
        isDarkMode 
            ? Color(red: 0.11, green: 0.12, blue: 0.18)
            : Color.white
    }
    
    var cardBorder: Color {
        isDarkMode 
            ? Color.white.opacity(0.08)
            : Color(red: 0.90, green: 0.91, blue: 0.93)
    }

    var borderColor: Color {
        isDarkMode 
            ? Color.white.opacity(0.10)
            : Color(red: 0.88, green: 0.89, blue: 0.91)
    }
    
    var elevatedBackground: Color {
        isDarkMode
            ? Color(red: 0.14, green: 0.15, blue: 0.21)
            : Color(red: 0.96, green: 0.965, blue: 0.975)
    }
    
    // MARK: - Text Colors
    var primaryText: Color {
        isDarkMode 
            ? Color.white
            : Color(red: 0.08, green: 0.08, blue: 0.12)
    }
    
    var secondaryText: Color {
        isDarkMode 
            ? Color(red: 0.72, green: 0.74, blue: 0.78)
            : Color(red: 0.38, green: 0.40, blue: 0.46)
    }
    
    var tertiaryText: Color {
        isDarkMode 
            ? Color(red: 0.50, green: 0.52, blue: 0.56)
            : Color(red: 0.58, green: 0.60, blue: 0.64)
    }
    
    // MARK: - Accent Colors (Rich & Vibrant)
    let accentOrange = Color(red: 0.96, green: 0.52, blue: 0.12)
    let accentGreen = Color(red: 0.12, green: 0.78, blue: 0.45)
    let accentBlue = Color(red: 0.25, green: 0.48, blue: 0.98)
    let accentPurple = Color(red: 0.55, green: 0.30, blue: 0.95)
    let accentRed = Color(red: 0.95, green: 0.25, blue: 0.25)
    let accentYellow = Color(red: 0.98, green: 0.78, blue: 0.12)
    let accentCyan = Color(red: 0.15, green: 0.72, blue: 0.88)
    
    // MARK: - Status Colors
    var successColor: Color {
        isDarkMode ? Color(red: 0.12, green: 0.78, blue: 0.45) : Color(red: 0.10, green: 0.72, blue: 0.40)
    }
    
    var warningColor: Color {
        isDarkMode ? Color(red: 0.98, green: 0.78, blue: 0.12) : Color(red: 0.92, green: 0.70, blue: 0.08)
    }
    
    var errorColor: Color {
        isDarkMode ? Color(red: 0.95, green: 0.25, blue: 0.25) : Color(red: 0.88, green: 0.20, blue: 0.20)
    }
    
    // MARK: - Premium Gradients
    var orangeGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 1.0, green: 0.58, blue: 0.18), Color(red: 0.96, green: 0.40, blue: 0.08)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    
    var purpleGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.60, green: 0.35, blue: 0.98), Color(red: 0.45, green: 0.20, blue: 0.88)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    
    var greenGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.15, green: 0.82, blue: 0.50), Color(red: 0.08, green: 0.68, blue: 0.38)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    
    var blueGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.30, green: 0.55, blue: 0.98), Color(red: 0.18, green: 0.40, blue: 0.92)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    
    /// Premium hero gradient for feature cards
    var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.52, blue: 0.12),
                Color(red: 0.95, green: 0.35, blue: 0.18),
                Color(red: 0.88, green: 0.28, blue: 0.25)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Shadow & Effects
    var shadowColor: Color {
        isDarkMode 
            ? Color.black.opacity(0.35)
            : Color(red: 0.0, green: 0.0, blue: 0.15).opacity(0.06)
    }
    
    var elevatedShadow: Color {
        isDarkMode
            ? Color.black.opacity(0.45)
            : Color(red: 0.0, green: 0.0, blue: 0.15).opacity(0.10)
    }
    
    /// Colored shadow for accent elements
    func accentShadow(_ color: Color) -> Color {
        isDarkMode
            ? color.opacity(0.20)
            : color.opacity(0.18)
    }
    
    var overlayColor: Color {
        isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.7)
    }
    
    // MARK: - Interactive States
    var pressedOverlay: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.04)
    }
    
    var hoverOverlay: Color {
        isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.02)
    }
    
    // MARK: - Terminal
    var terminalBackground: Color {
        isDarkMode
            ? Color(red: 0.08, green: 0.09, blue: 0.13)
            : Color(red: 0.14, green: 0.15, blue: 0.19)
    }
    
    // MARK: - Methods
    func toggleTheme() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isDarkMode.toggle()
        }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    init() {
        if let saved = UserDefaults.standard.value(forKey: "isDarkMode") as? Bool {
            self.isDarkMode = saved
        }
    }
}
