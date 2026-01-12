//
//  LoadingView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    let color: Color
    
    init(color: Color = .orange) {
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 4)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct PulsingDot: View {
    @State private var isPulsing = false
    let color: Color
    let delay: Double
    
    init(color: Color = .orange, delay: Double = 0) {
        self.color = color
        self.delay = delay
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .scaleEffect(isPulsing ? 1.2 : 0.8)
            .opacity(isPulsing ? 1.0 : 0.5)
            .animation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct ThreeDotsLoading: View {
    let color: Color
    
    init(color: Color = .orange) {
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            PulsingDot(color: color, delay: 0)
            PulsingDot(color: color, delay: 0.2)
            PulsingDot(color: color, delay: 0.4)
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    init(progress: Double, color: Color = .orange, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()
        
        ThreeDotsLoading()
        
        ProgressRing(progress: 0.65)
            .frame(width: 100, height: 100)
    }
    .padding()
    .background(Color(red: 0.05, green: 0.08, blue: 0.15))
}
