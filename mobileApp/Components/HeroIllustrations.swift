//
//  HeroIllustrations.swift
//  mobileApp
//
//  Created by CHUONG on 13/1/26.
//

import SwiftUI

/// Animated Car Dashboard Illustration
struct CarDashboardIllustration: View {
    let isActive: Bool
    let size: CGFloat
    
    @State private var enginePulse = false
    @State private var wheelRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Car body
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.3, blue: 0.4),
                            Color(red: 0.1, green: 0.2, blue: 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size * 0.6)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Windshield
            Path { path in
                let w = size
                let h = size * 0.6
                path.move(to: CGPoint(x: w * 0.3, y: h * 0.1))
                path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.1))
                path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.5))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size * 0.6)
            
            // Wheels
            HStack(spacing: size * 0.4) {
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 3)
                    )
                    .rotationEffect(.degrees(wheelRotation))
                
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 3)
                    )
                    .rotationEffect(.degrees(wheelRotation))
            }
            .offset(y: size * 0.35)
            
            // Engine indicator
            if isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: -size * 0.35, y: -size * 0.2)
                    .opacity(enginePulse ? 1.0 : 0.3)
            }
            
            // AI Vision rays
            if isActive {
                ForEach(0..<3) { i in
                    Path { path in
                        let startX = size * 0.4
                        let startY = -size * 0.1
                        let angle = Double(i - 1) * 20
                        let length = size * 0.8
                        
                        path.move(to: CGPoint(x: startX, y: startY))
                        path.addLine(to: CGPoint(
                            x: startX + cos(angle * .pi / 180) * length,
                            y: startY + sin(angle * .pi / 180) * length
                        ))
                    }
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan, Color.cyan.opacity(0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .opacity(0.6)
                }
            }
        }
        .onAppear {
            if isActive {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    enginePulse = true
                }
                
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    wheelRotation = 360
                }
            }
        }
    }
}

/// Animated Network Nodes Illustration
struct NetworkNodesIllustration: View {
    let isActive: Bool
    let size: CGFloat
    
    @State private var nodePulse: [Bool] = Array(repeating: false, count: 6)
    @State private var connectionOpacity: [Double] = Array(repeating: 0.3, count: 6)
    
    var body: some View {
        ZStack {
            connectionLines
            centerNode
            outerNodes
        }
        .onAppear {
            if isActive {
                animateNodes()
            }
        }
    }
    
    private var connectionLines: some View {
        ForEach(0..<6) { i in
            connectionPath(for: i)
                .stroke(connectionGradient, lineWidth: 2)
                .opacity(connectionOpacity[i])
        }
    }
    
    private var connectionGradient: LinearGradient {
        LinearGradient(
            colors: [Color.cyan, Color.purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private func connectionPath(for index: Int) -> Path {
        Path { path in
            let angle1 = Double(index) * 60
            let angle2 = Double((index + 1) % 6) * 60
            
            let point1 = CGPoint(
                x: cos(angle1 * .pi / 180) * size * 0.4,
                y: sin(angle1 * .pi / 180) * size * 0.4
            )
            let point2 = CGPoint(
                x: cos(angle2 * .pi / 180) * size * 0.4,
                y: sin(angle2 * .pi / 180) * size * 0.4
            )
            
            path.move(to: point1)
            path.addLine(to: point2)
        }
    }
    
    private var centerNode: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple, Color.purple.opacity(0.5)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.15
                    )
                )
                .frame(width: size * 0.3, height: size * 0.3)
                .shadow(color: Color.purple.opacity(0.6), radius: 15, x: 0, y: 0)
            
            Image(systemName: "cpu")
                .font(.system(size: size * 0.15, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var outerNodes: some View {
        ForEach(0..<6) { i in
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.15, height: size * 0.15)
                .shadow(color: Color.cyan.opacity(0.5), radius: 8, x: 0, y: 0)
                .scaleEffect(nodePulse[i] ? 1.2 : 1.0)
                .offset(
                    x: cos(Double(i) * 60 * .pi / 180) * size * 0.4,
                    y: sin(Double(i) * 60 * .pi / 180) * size * 0.4
                )
        }
    }
    
    private func animateNodes() {
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    nodePulse[i] = true
                }
                
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    connectionOpacity[i] = 1.0
                }
            }
        }
    }
}

/// Animated Eye Tracking Illustration
struct EyeTrackingIllustration: View {
    let isActive: Bool
    let size: CGFloat
    
    @State private var pupilOffset: CGSize = .zero
    @State private var blinkScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Eye outline
            Ellipse()
                .stroke(
                    LinearGradient(
                        colors: [Color.blue, Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 3
                )
                .frame(width: size * 0.8, height: size * 0.5)
                .scaleEffect(y: blinkScale)
            
            // Iris
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyan, Color.blue, Color.blue.opacity(0.8)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.15
                    )
                )
                .frame(width: size * 0.3, height: size * 0.3)
                .offset(pupilOffset)
                .scaleEffect(y: blinkScale)
            
            // Pupil
            Circle()
                .fill(Color.black)
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(pupilOffset)
                .scaleEffect(y: blinkScale)
            
            // Highlight
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(x: pupilOffset.width - size * 0.03, y: pupilOffset.height - size * 0.03)
                .scaleEffect(y: blinkScale)
            
            // Scan lines
            if isActive {
                ForEach(0..<3) { i in
                    Rectangle()
                        .fill(Color.cyan.opacity(0.3))
                        .frame(width: size * 0.8, height: 2)
                        .offset(y: CGFloat(i - 1) * size * 0.15)
                }
            }
        }
        .onAppear {
            if isActive {
                // Pupil movement
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        pupilOffset = CGSize(
                            width: CGFloat.random(in: -size * 0.1...size * 0.1),
                            height: CGFloat.random(in: -size * 0.08...size * 0.08)
                        )
                    }
                }
                
                // Blinking
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        blinkScale = 0.1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            blinkScale = 1.0
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            CarDashboardIllustration(isActive: true, size: 200)
            
            HStack(spacing: 30) {
                NetworkNodesIllustration(isActive: true, size: 150)
                EyeTrackingIllustration(isActive: true, size: 150)
            }
        }
    }
}
