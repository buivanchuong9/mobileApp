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
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.cardBackground)
                        .shadow(color: theme.shadowColor, radius: 10, y: 5)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.cardBorder, lineWidth: 1)
                }
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
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.cardBackground)
                        .shadow(color: theme.shadowColor, radius: 10, y: 5)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.cardBorder, lineWidth: 1)
                }
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
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.cardBackground)
                        .shadow(color: theme.shadowColor, radius: 10, y: 5)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.cardBorder, lineWidth: 1)
                }
            )
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
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
