//
//  AnimatedButton.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct AnimatedButton: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.medium()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(gradient)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: isPressed ? 2 : 8, y: isPressed ? 1 : 4)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = newValue
                }
            }
    }
}

struct GlassButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @EnvironmentObject var theme: ThemeManager
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(theme.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackground)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.cardBorder, lineWidth: 1)
                }
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

#Preview {
    VStack(spacing: 16) {
        AnimatedButton(
            title: "BẮT ĐẦU",
            icon: "play.fill",
            gradient: LinearGradient(
                colors: [Color.orange, Color.red],
                startPoint: .leading,
                endPoint: .trailing
            ),
            action: {}
        )
        
        GlassButton(
            title: "XÓA",
            icon: "trash.fill",
            action: {}
        )
        .environmentObject(ThemeManager())
    }
    .padding()
    .background(Color(red: 0.05, green: 0.08, blue: 0.15))
}
