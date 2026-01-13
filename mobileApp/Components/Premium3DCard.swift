//
//  Premium3DCard.swift
//  mobileApp
//
//  Created by CHUONG on 13/1/26.
//

import SwiftUI

/// Premium 3D Card with depth, parallax, and glassmorphism
struct Premium3DCard<Content: View>: View {
    let content: Content
    @EnvironmentObject var theme: ThemeManager
    
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var isPressed = false
    
    let enableInteraction: Bool
    let glowColor: Color?
    
    init(
        enableInteraction: Bool = true,
        glowColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.enableInteraction = enableInteraction
        self.glowColor = glowColor
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    // Base glass layer with blur
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            theme.cardBackground.opacity(0.8),
                                            theme.cardBackground.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    
                    // Shimmer overlay
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border gradient
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    theme.accentOrange.opacity(0.3),
                                    theme.cardBorder,
                                    theme.accentOrange.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: (glowColor ?? theme.accentOrange).opacity(0.2), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .rotation3DEffect(
                .degrees(rotationX),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(rotationY),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .scaleEffect(scale)
            .gesture(
                enableInteraction ? DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPressed = true
                            scale = 0.98
                            
                            // Calculate rotation based on drag position
                            let cardWidth: CGFloat = 350
                            let cardHeight: CGFloat = 200
                            
                            let xOffset = value.location.x - cardWidth / 2
                            let yOffset = value.location.y - cardHeight / 2
                            
                            rotationY = Double(xOffset / cardWidth) * 15
                            rotationX = Double(-yOffset / cardHeight) * 15
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isPressed = false
                            scale = 1.0
                            rotationX = 0
                            rotationY = 0
                        }
                    }
                : nil
            )
    }
}

/// Animated Counter for statistics
struct AnimatedCounter: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    @State private var displayValue: Int = 0
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("\(displayValue)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.caption)
                .foregroundColor(theme.secondaryText)
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                displayValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                displayValue = newValue
            }
        }
    }
}

/// Circular Progress Ring with 3D effect
struct CircularProgressRing: View {
    let progress: Double
    let color: Color
    let label: String
    let value: String
    
    @State private var animatedProgress: Double = 0
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    theme.cardBorder,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 0)
            
            // Center content
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(theme.primaryText)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(theme.secondaryText)
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

/// Floating Particles Background
struct FloatingParticles: View {
    @State private var particles: [Particle] = []
    @EnvironmentObject var theme: ThemeManager
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(theme.accentOrange.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .blur(radius: particle.size / 2)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                startAnimation(in: geometry.size)
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<15).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 20...60),
                opacity: Double.random(in: 0.05...0.15),
                speed: Double.random(in: 30...60)
            )
        }
    }
    
    private func startAnimation(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y -= particles[i].speed * 0.05
                
                if particles[i].y < -particles[i].size {
                    particles[i].y = size.height + particles[i].size
                    particles[i].x = CGFloat.random(in: 0...size.width)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.15)
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            Premium3DCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Premium 3D Card")
                        .font(.title2.bold())
                    Text("With glassmorphism and depth")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(24)
            }
            
            HStack(spacing: 20) {
                CircularProgressRing(
                    progress: 0.85,
                    color: .green,
                    label: "Safety",
                    value: "85%"
                )
                
                AnimatedCounter(
                    value: 42,
                    label: "Alerts",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
            }
        }
        .padding()
    }
    .environmentObject(ThemeManager())
}
