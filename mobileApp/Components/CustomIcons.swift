//
//  CustomIcons.swift
//  mobileApp
//
//  Created by CHUONG on 13/1/26.
//

import SwiftUI

/// Animated 3D Icon với gradient và glow
struct AnimatedIcon3D: View {
    let type: IconType
    let size: CGFloat
    let isActive: Bool
    
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    
    enum IconType {
        case speed, camera, warning, shield, brain, radar
        
        var colors: [Color] {
            switch self {
            case .speed:
                return [Color(red: 1.0, green: 0.42, blue: 0.21), Color(red: 1.0, green: 0.6, blue: 0.3)]
            case .camera:
                return [Color(red: 0.3, green: 0.69, blue: 0.31), Color(red: 0.4, green: 0.8, blue: 0.5)]
            case .warning:
                return [Color(red: 1.0, green: 0.8, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.0)]
            case .shield:
                return [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.4, green: 0.7, blue: 1.0)]
            case .brain:
                return [Color(red: 0.9, green: 0.4, blue: 0.9), Color(red: 0.7, green: 0.3, blue: 0.8)]
            case .radar:
                return [Color(red: 0.0, green: 0.8, blue: 0.8), Color(red: 0.2, green: 0.9, blue: 0.9)]
            }
        }
        
        var sfSymbol: String {
            switch self {
            case .speed: return "speedometer"
            case .camera: return "video.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .shield: return "shield.checkered"
            case .brain: return "brain.head.profile"
            case .radar: return "dot.radiowaves.left.and.right"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Outer glow ring
            if isActive {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: type.colors.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: size * 1.3, height: size * 1.3)
                    .scaleEffect(pulseScale)
                    .opacity(2 - pulseScale)
            }
            
            // Main circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: type.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: type.colors[0].opacity(0.5), radius: 15, x: 0, y: 8)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: size * 0.7
                            )
                        )
                )
            
            // Icon
            Image(systemName: type.sfSymbol)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
        }
        .rotation3DEffect(
            .degrees(isAnimating ? 5 : 0),
            axis: (x: 1, y: 1, z: 0)
        )
        .onAppear {
            if isActive {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
                
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    pulseScale = 1.5
                }
            }
        }
    }
}

/// Car Dashboard Speedometer Animation
struct SpeedometerIcon: View {
    let speed: Double // 0-120
    let size: CGFloat
    
    @State private var needleAngle: Double = -90
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.42, blue: 0.21),
                            Color(red: 1.0, green: 0.6, blue: 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.08
                )
                .frame(width: size, height: size)
            
            // Speed marks
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: size * 0.1)
                    .offset(y: -size * 0.35)
                    .rotationEffect(.degrees(Double(i) * 30 - 90))
            }
            
            // Center circle
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.15, height: size * 0.15)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Needle
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [Color.red, Color.orange],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 3, height: size * 0.35)
                .offset(y: -size * 0.175)
                .rotationEffect(.degrees(needleAngle))
                .shadow(color: Color.red.opacity(0.5), radius: 4, x: 0, y: 0)
            
            // Speed text
            Text("\(Int(speed))")
                .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .offset(y: size * 0.15)
        }
        .onAppear {
            let targetAngle = (speed / 120.0) * 180 - 90
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                needleAngle = targetAngle
            }
        }
        .onChange(of: speed) { newSpeed in
            let targetAngle = (newSpeed / 120.0) * 180 - 90
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                needleAngle = targetAngle
            }
        }
    }
}

/// Camera Recording Animation
struct CameraRecordingIcon: View {
    let isRecording: Bool
    let size: CGFloat
    
    @State private var recordingPulse = false
    
    var body: some View {
        ZStack {
            // Camera body
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.69, blue: 0.31),
                            Color(red: 0.2, green: 0.6, blue: 0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.7, height: size * 0.5)
                .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 5)
            
            // Lens
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.black.opacity(0.8)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.35, height: size * 0.35)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
            
            // Recording indicator
            if isRecording {
                Circle()
                    .fill(Color.red)
                    .frame(width: size * 0.15, height: size * 0.15)
                    .offset(x: size * 0.3, y: -size * 0.2)
                    .scaleEffect(recordingPulse ? 1.2 : 1.0)
                    .opacity(recordingPulse ? 0.6 : 1.0)
            }
        }
        .onAppear {
            if isRecording {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    recordingPulse = true
                }
            }
        }
    }
}

/// AI Brain Processing Animation
struct AIBrainIcon: View {
    let isProcessing: Bool
    let size: CGFloat
    
    @State private var neuronPulse: [Bool] = Array(repeating: false, count: 8)
    
    var body: some View {
        ZStack {
            // Brain outline
            Image(systemName: "brain.head.profile")
                .font(.system(size: size * 0.6, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.4, blue: 0.9),
                            Color(red: 0.7, green: 0.3, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // Neural network nodes
            if isProcessing {
                ForEach(0..<8) { i in
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: size * 0.08, height: size * 0.08)
                        .offset(
                            x: cos(Double(i) * .pi / 4) * size * 0.35,
                            y: sin(Double(i) * .pi / 4) * size * 0.35
                        )
                        .opacity(neuronPulse[i] ? 1.0 : 0.3)
                        .scaleEffect(neuronPulse[i] ? 1.3 : 1.0)
                }
            }
        }
        .onAppear {
            if isProcessing {
                for i in 0..<8 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                            neuronPulse[i] = true
                        }
                    }
                }
            }
        }
    }
}

/// Shield Protection Animation
struct ShieldProtectionIcon: View {
    let protectionLevel: Double // 0-1
    let size: CGFloat
    
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        ZStack {
            // Shield shape
            ShieldShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.6, blue: 1.0),
                            Color(red: 0.1, green: 0.4, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.7, height: size * 0.8)
                .shadow(color: Color.blue.opacity(0.5), radius: 12, x: 0, y: 6)
            
            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
            
            // Shimmer effect
            ShieldShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.6),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size * 0.7, height: size * 0.8)
                .offset(x: shimmerOffset * size)
                .mask(
                    ShieldShape()
                        .frame(width: size * 0.7, height: size * 0.8)
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 1
            }
        }
    }
}

/// Custom Shield Shape
struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.2))
        path.addLine(to: CGPoint(x: width, y: height * 0.6))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control: CGPoint(x: width, y: height * 0.9)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height * 0.6),
            control: CGPoint(x: 0, y: height * 0.9)
        )
        path.addLine(to: CGPoint(x: 0, y: height * 0.2))
        path.closeSubpath()
        
        return path
    }
}

/// Radar Scanning Animation
struct RadarScanIcon: View {
    let isScanning: Bool
    let size: CGFloat
    
    @State private var scanAngle: Double = 0
    @State private var blipOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Radar circles
            ForEach(1..<4) { i in
                Circle()
                    .stroke(
                        Color.cyan.opacity(0.3),
                        lineWidth: 1
                    )
                    .frame(width: size * CGFloat(i) * 0.3, height: size * CGFloat(i) * 0.3)
            }
            
            // Scanning beam
            if isScanning {
                Path { path in
                    path.move(to: CGPoint(x: size * 0.5, y: size * 0.5))
                    path.addArc(
                        center: CGPoint(x: size * 0.5, y: size * 0.5),
                        radius: size * 0.45,
                        startAngle: .degrees(scanAngle),
                        endAngle: .degrees(scanAngle + 45),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .fill(
                    AngularGradient(
                        colors: [
                            Color.cyan.opacity(0.0),
                            Color.cyan.opacity(0.6)
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(45)
                    )
                )
                .rotationEffect(.degrees(scanAngle))
                .frame(width: size, height: size)
            }
            
            // Center dot
            Circle()
                .fill(Color.cyan)
                .frame(width: size * 0.1, height: size * 0.1)
            
            // Detection blips
            if isScanning {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.green)
                        .frame(width: size * 0.08, height: size * 0.08)
                        .offset(
                            x: cos(Double(i) * 2.0) * size * 0.3,
                            y: sin(Double(i) * 2.0) * size * 0.3
                        )
                        .opacity(blipOpacity)
                }
            }
        }
        .onAppear {
            if isScanning {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    scanAngle = 360
                }
                
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    blipOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                AnimatedIcon3D(type: .speed, size: 80, isActive: true)
                AnimatedIcon3D(type: .camera, size: 80, isActive: true)
                AnimatedIcon3D(type: .warning, size: 80, isActive: false)
            }
            
            HStack(spacing: 20) {
                SpeedometerIcon(speed: 75, size: 100)
                CameraRecordingIcon(isRecording: true, size: 100)
            }
            
            HStack(spacing: 20) {
                AIBrainIcon(isProcessing: true, size: 100)
                ShieldProtectionIcon(protectionLevel: 0.85, size: 100)
                RadarScanIcon(isScanning: true, size: 100)
            }
        }
    }
}
