//
//  GlassCard.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    @EnvironmentObject var theme: ThemeManager
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardBackground)
                    .shadow(color: theme.shadowColor, radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.cardBorder, lineWidth: 0.5)
                    )
            )
    }
}

struct GlassCardWithPadding<Content: View>: View {
    let content: Content
    @EnvironmentObject var theme: ThemeManager
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardBackground)
                    .shadow(color: theme.shadowColor, radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.cardBorder, lineWidth: 0.5)
                    )
            )
    }
}

struct AnimatedGlassCard<Content: View>: View {
    let content: Content
    @EnvironmentObject var theme: ThemeManager
    @State private var isVisible = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardBackground)
                    .shadow(color: theme.shadowColor, radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.cardBorder, lineWidth: 0.5)
                    )
            )
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                    isVisible = true
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        GlassCardWithPadding {
            VStack(alignment: .leading, spacing: 8) {
                Text("Glass Card")
                    .font(.headline)
                Text("Beautiful glassmorphism effect")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        
        AnimatedGlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Animated Card")
                    .font(.headline)
                Text("With smooth entrance animation")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    .padding()
    .background(Color(red: 0.05, green: 0.08, blue: 0.15))
    .environmentObject(ThemeManager())
}
