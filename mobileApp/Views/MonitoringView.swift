//
//  MonitoringView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct MonitoringView: View {
    @ObservedObject var viewModel: ADASViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var showLogs = true
    
    var body: some View {
        ZStack {
            // Background using theme
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Main content
                ScrollView {
                    VStack(spacing: 16) {
                        // Camera Feed with overlays
                        cameraFeedSection
                        
                        // System Metrics
                        systemMetricsSection
                        
                        // Terminal Logs
                        if showLogs {
                            terminalLogsSection
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("ADAS SYSTEM")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            Text("v3.0-production")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(theme.secondaryText)
            
            // Theme toggle (placeholder)
            Button(action: {}) {
                Image(systemName: "moon.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 8)
            
            // Access system button
            Button(action: {
                if viewModel.isMonitoring {
                    viewModel.stopMonitoring()
                } else {
                    viewModel.startMonitoring()
                }
            }) {
                Text(viewModel.isMonitoring ? "DỪNG HỆ THỐNG" : "TRUY CẬP HỆ THỐNG")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2),
                                Color(red: 1.0, green: 0.5, blue: 0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(theme.cardBackground)
    }
    
    private var cameraFeedSection: some View {
        ZStack {
            // Camera feed background (simulated)
            Rectangle()
                .fill(Color.black)
                .aspectRatio(16/9, contentMode: .fit)
            
            // Simulated road image
            GeometryReader { geometry in
                ZStack {
                    // Grid overlay for perspective
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        // Horizon line
                        path.move(to: CGPoint(x: 0, y: height * 0.4))
                        path.addLine(to: CGPoint(x: width, y: height * 0.4))
                    }
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    
                    // Lane detection overlay (green safe zone)
                    if viewModel.features.first(where: { $0.type == .laneDetection })?.isEnabled == true {
                        LaneDetectionOverlay()
                            .opacity(viewModel.isMonitoring ? 1.0 : 0.3)
                    }
                    
                    // Detected objects
                    if viewModel.isMonitoring {
                        ForEach(viewModel.detectedObjects) { object in
                            DetectionBox(object: object)
                        }
                    }
                    
                    // Collision warning overlay
                    if viewModel.isMonitoring {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                CollisionWarningDisplay(status: viewModel.vehicleStatus)
                                    .padding()
                            }
                        }
                    }
                    
                    // Recording indicator
                    if viewModel.isMonitoring {
                        VStack {
                            HStack {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 8, height: 8)
                                    
                                    Text("LIVE")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(4)
                                .shadow(color: Color.red.opacity(0.5), radius: 8, x: 0, y: 0)
                                .padding()
                                
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var systemMetricsSection: some View {
        HStack(spacing: 12) {
            MetricCard(label: "MODEL", value: viewModel.vehicleStatus.modelVersion)
            MetricCard(label: "RESOLUTION", value: viewModel.vehicleStatus.resolution)
            MetricCard(label: "FPS", value: "\(viewModel.vehicleStatus.fps)")
            MetricCard(label: "DEVICE", value: viewModel.vehicleStatus.device)
        }
    }
    
    private var terminalLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "terminal.fill")
                        .foregroundColor(Color.green)
                        .font(.system(size: 14))
                    
                    Text("SẢN PHẨM CỦA ADAS TEAM")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.primaryText)
                }
                
                Spacer()
                
                Button(action: {
                    showLogs.toggle()
                }) {
                    Image(systemName: showLogs ? "chevron.up" : "chevron.down")
                        .foregroundColor(theme.secondaryText)
                        .font(.system(size: 12))
                }
            }
            
            // Terminal window
            VStack(alignment: .leading, spacing: 4) {
                ForEach(viewModel.systemLogs.prefix(10)) { log in
                    HStack(alignment: .top, spacing: 8) {
                        Text(">")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.green)
                        
                        Text(log.formattedMessage)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(logColor(for: log.level))
                            .lineLimit(2)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.isDarkMode ? Color.black.opacity(0.5) : Color.gray.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
        )
    }
    
    private func logColor(for level: SystemLog.LogLevel) -> Color {
        switch level {
        case .info:
            return Color.blue
        case .warn:
            return Color.orange
        case .error:
            return Color.red
        case .success:
            return Color.green
        }
    }
}

struct LaneDetectionOverlay: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Create trapezoid for safe lane
                let topWidth = width * 0.3
                let bottomWidth = width * 0.7
                
                let topLeft = CGPoint(x: (width - topWidth) / 2, y: height * 0.3)
                let topRight = CGPoint(x: (width + topWidth) / 2, y: height * 0.3)
                let bottomRight = CGPoint(x: (width + bottomWidth) / 2, y: height)
                let bottomLeft = CGPoint(x: (width - bottomWidth) / 2, y: height)
                
                path.move(to: topLeft)
                path.addLine(to: topRight)
                path.addLine(to: bottomRight)
                path.addLine(to: bottomLeft)
                path.closeSubpath()
            }
            .fill(Color.green.opacity(0.2))
            
            // Lane borders
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                let topWidth = width * 0.3
                let bottomWidth = width * 0.7
                
                // Left lane
                path.move(to: CGPoint(x: (width - topWidth) / 2, y: height * 0.3))
                path.addLine(to: CGPoint(x: (width - bottomWidth) / 2, y: height))
                
                // Right lane
                path.move(to: CGPoint(x: (width + topWidth) / 2, y: height * 0.3))
                path.addLine(to: CGPoint(x: (width + bottomWidth) / 2, y: height))
            }
            .stroke(Color.green, lineWidth: 3)
        }
    }
}

struct DetectionBox: View {
    let object: DetectedObject
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(boxColor, lineWidth: 2)
                .frame(width: object.frame.width, height: object.frame.height)
                .position(x: object.frame.midX, y: object.frame.midY)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(object.type.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                Text(String(format: "%.1fm", object.distance))
                    .font(.system(size: 9, design: .monospaced))
                Text(String(format: "%.0f%%", object.confidence * 100))
                    .font(.system(size: 9, design: .monospaced))
            }
            .padding(4)
            .background(boxColor)
            .foregroundColor(.white)
            .cornerRadius(4)
            .position(x: object.frame.minX + 40, y: object.frame.minY - 25)
        }
    }
    
    private var boxColor: Color {
        switch object.type {
        case "car":
            return Color.blue
        case "motorbike":
            return Color.orange
        case "person":
            return Color.purple
        default:
            return Color.cyan
        }
    }
}

struct CollisionWarningDisplay: View {
    let status: VehicleStatus
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Distance and TTC
            if let ttc = status.ttc {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1fm", ttc * status.speed / 3.6))
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("TTC: \(String(format: "%.1fs", ttc))")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
            }
            
            // Status indicator
            Text(status.collisionStatus.rawValue)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(status.collisionStatus.color)
                .cornerRadius(8)
        }
    }
}

struct MetricCard: View {
    let label: String
    let value: String
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(theme.secondaryText)
            
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(theme.cardBackground.opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    MonitoringView(viewModel: ADASViewModel())
        .environmentObject(ThemeManager())
}
