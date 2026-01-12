//
//  ThemeManager.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    
    // MARK: - Background Colors
    var backgroundColor: Color {
        isDarkMode 
            ? Color(red: 0.05, green: 0.08, blue: 0.15)  // Deep dark blue
            : Color(red: 0.92, green: 0.94, blue: 0.96)  // Darker gray-blue for better contrast with white cards
    }
    
    var secondaryBackground: Color {
        isDarkMode 
            ? Color(red: 0.08, green: 0.12, blue: 0.20)  // Slightly lighter dark
            : Color(red: 0.98, green: 0.99, blue: 1.0)   // Almost white
    }
    
    var cardBackground: Color {
        isDarkMode 
            ? Color(red: 0.11, green: 0.14, blue: 0.22) // Solid Dark Blue-Gray (Clean & Sharp)
            : Color.white                               // Solid White
    }
    
    var cardBorder: Color {
        isDarkMode 
            ? Color.white.opacity(0.12)                   // Visible border in dark
            : Color.black.opacity(0.15)                   // Stronger border in light (was 0.08)
    }

    var borderColor: Color {
        isDarkMode 
            ? Color.white.opacity(0.15)
            : Color.black.opacity(0.1)
    }
    
    // MARK: - Text Colors (High Contrast)
    var primaryText: Color {
        isDarkMode 
            ? Color.white                                 // Pure white for dark mode
            : Color.black                                 // Pure black for maximum sharpness in light mode
    }
    
    var secondaryText: Color {
        isDarkMode 
            ? Color(red: 0.8, green: 0.82, blue: 0.85)   // Lighter gray for dark mode
            : Color(red: 0.15, green: 0.15, blue: 0.2)   // Almost black (85% black) for sharp readability
    }
    
    var tertiaryText: Color {
        isDarkMode 
            ? Color(red: 0.6, green: 0.62, blue: 0.65)   // Dimmer gray
            : Color(red: 0.5, green: 0.5, blue: 0.55)    // Medium-dark gray
    }
    
    // MARK: - Accent Colors (Vibrant & Consistent)
    let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.2)      // #FF9933
    let accentGreen = Color(red: 0.2, green: 0.8, blue: 0.4)       // #33CC66
    let accentBlue = Color(red: 0.4, green: 0.6, blue: 1.0)        // #6699FF
    let accentPurple = Color(red: 0.9, green: 0.4, blue: 0.9)      // #E666E6
    let accentRed = Color(red: 1.0, green: 0.3, blue: 0.3)         // #FF4D4D
    let accentYellow = Color(red: 1.0, green: 0.8, blue: 0.2)      // #FFCC33
    
    // MARK: - Status Colors
    var successColor: Color {
        isDarkMode 
            ? Color(red: 0.2, green: 0.8, blue: 0.4)
            : Color(red: 0.15, green: 0.7, blue: 0.35)
    }
    
    var warningColor: Color {
        isDarkMode 
            ? Color(red: 1.0, green: 0.8, blue: 0.2)
            : Color(red: 0.95, green: 0.7, blue: 0.1)
    }
    
    var errorColor: Color {
        isDarkMode 
            ? Color(red: 1.0, green: 0.3, blue: 0.3)
            : Color(red: 0.9, green: 0.2, blue: 0.2)
    }
    
    // MARK: - Gradients
    var orangeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.6, blue: 0.2),
                Color(red: 1.0, green: 0.5, blue: 0.1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var purpleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.9, green: 0.4, blue: 0.9),
                Color(red: 0.8, green: 0.3, blue: 0.8)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var greenGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.8, blue: 0.4),
                Color(red: 0.1, green: 0.7, blue: 0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var blueGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.6, blue: 1.0),
                Color(red: 0.3, green: 0.5, blue: 0.9)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Shadow & Effects
    var shadowColor: Color {
        isDarkMode 
            ? Color.black.opacity(0.4)
            : Color.black.opacity(0.15)
    }
    
    var overlayColor: Color {
        isDarkMode 
            ? Color.black.opacity(0.3)
            : Color.white.opacity(0.7)
    }
    
    // MARK: - Interactive States
    var pressedOverlay: Color {
        isDarkMode 
            ? Color.white.opacity(0.1)
            : Color.black.opacity(0.05)
    }
    
    var hoverOverlay: Color {
        isDarkMode 
            ? Color.white.opacity(0.05)
            : Color.black.opacity(0.03)
    }
    
    // MARK: - Methods
    func toggleTheme() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isDarkMode.toggle()
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Save preference
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    init() {
        // Load saved preference
        if let saved = UserDefaults.standard.value(forKey: "isDarkMode") as? Bool {
            self.isDarkMode = saved
        }
    }
}
