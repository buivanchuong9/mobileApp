//
//  LiveLogsView.swift
//  mobileApp
//
//  Created by CHUONG on 18/1/26.
//  Ultra-Premium Live Log Streaming Interface
//

import SwiftUI

struct LiveLogsView: View {
    @StateObject private var viewModel = LogStreamViewModel()
    @EnvironmentObject var theme: ThemeManager
    @State private var animateIn = false
    @State private var showExportSheet = false
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Background
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Stats Card
                if let stats = viewModel.stats {
                    statsCard(stats)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }
                
                // Filter Pills
                filterSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Logs Container
                logsContainer
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Bottom Controls
                controlsSection
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateIn = true
            }
            
            // Fetch initial data
            Task {
                await viewModel.fetchStats()
                await viewModel.fetchRecentLogs(lines: 50)
            }
        }
        .onDisappear {
            viewModel.disconnect()
        }
        .sheet(isPresented: $showExportSheet) {
            exportSheet
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.6, blue: 1.0),
                                    Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("BACKEND LOGS")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                    .tracking(1.2)
                
                Spacer()
                
                // Connection Status
                connectionStatusBadge
            }
            
            // Title
            Text("Live Log Streaming")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(theme.primaryText)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
        }
    }
    
    private var connectionStatusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(viewModel.connectionStatus.isConnected ? Color.green : theme.secondaryText)
                .frame(width: 8, height: 8)
            
            Text(viewModel.connectionStatus.displayText)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(theme.cardBackground)
        .clipShape(Capsule())
    }
    
    // MARK: - Stats Card
    
    private func statsCard(_ stats: LogStats) -> some View {
        HStack(spacing: 20) {
            LogStatItem(
                icon: "doc.text.fill",
                value: String(format: "%.1f MB", stats.fileSizeMB),
                label: "Kích thước",
                color: Color(red: 0.4, green: 0.6, blue: 1.0)
            )
            
            Divider()
                .frame(height: 50)
                .overlay(theme.cardBorder.opacity(0.3))
            
            LogStatItem(
                icon: "person.2.fill",
                value: "\(stats.activeConnections)",
                label: "Kết nối",
                color: Color(red: 0.2, green: 0.8, blue: 0.4)
            )
            
            Divider()
                .frame(height: 50)
                .overlay(theme.cardBorder.opacity(0.3))
            
            LogStatItem(
                icon: "number",
                value: "\(viewModel.logs.count)",
                label: "Logs",
                color: theme.accentOrange
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.cardBorder, lineWidth: 0.5)
        )
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterPill(
                    title: "Tất cả",
                    isSelected: viewModel.filterLevel == nil,
                    color: theme.secondaryText
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.filterLevel = nil
                    }
                }
                
                ForEach([LogLevel.info, .warning, .error, .critical], id: \.self) { level in
                    FilterPill(
                        title: level.rawValue,
                        isSelected: viewModel.filterLevel == level,
                        color: level.color
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.filterLevel = level
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Logs Container
    
    private var logsContainer: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.filteredLogs) { log in
                        LogRow(log: log)
                            .id(log.id)
                    }
                    
                    if viewModel.filteredLogs.isEmpty {
                        emptyState
                    }
                }
                .padding(.vertical, 16)
            }
            .frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.terminalBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.30, green: 0.52, blue: 0.95).opacity(0.2),
                                        theme.cardBorder
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
            .onChange(of: viewModel.logs.count) { _ in
                if viewModel.autoScroll, let firstLog = viewModel.filteredLogs.first {
                    withAnimation {
                        proxy.scrollTo(firstLog.id, anchor: .top)
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundColor(theme.secondaryText.opacity(0.5))
            
            Text("Chưa có logs")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.secondaryText)
            
            Text("Kết nối WebSocket để xem logs real-time")
                .font(.system(size: 13))
                .foregroundColor(theme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Main action buttons
            HStack(spacing: 12) {
                // Connect/Disconnect Button
                Button(action: {
                    HapticManager.shared.medium()
                    if viewModel.connectionStatus.isConnected {
                        viewModel.disconnect()
                    } else {
                        viewModel.connect()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.connectionStatus.isConnected ? "stop.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                        
                        Text(viewModel.connectionStatus.isConnected ? "NGẮT" : "KẾT NỐI")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(
                                viewModel.connectionStatus.isConnected
                                    ? Color.red
                                    : Color(red: 0.4, green: 0.6, blue: 1.0)
                            )
                    )
                    .shadow(
                        color: (viewModel.connectionStatus.isConnected ? Color.red : Color(red: 0.4, green: 0.6, blue: 1.0)).opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                
                // Clear Button
                Button(action: {
                    HapticManager.shared.light()
                    withAnimation {
                        viewModel.clearLogs()
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.primaryText)
                        .frame(width: 50, height: 50)
                        .background(theme.cardBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(theme.cardBorder, lineWidth: 1)
                        )
                }
            }
            
            // Secondary buttons
            HStack(spacing: 12) {
                // Auto-scroll toggle
                Button(action: {
                    HapticManager.shared.light()
                    viewModel.autoScroll.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.autoScroll ? "arrow.down.circle.fill" : "arrow.down.circle")
                            .font(.system(size: 12))
                        
                        Text("Tự cuộn")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(viewModel.autoScroll ? Color(red: 0.4, green: 0.6, blue: 1.0) : theme.secondaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(theme.cardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                viewModel.autoScroll ? Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.5) : theme.cardBorder,
                                lineWidth: 1
                            )
                    )
                }
                
                // Export button
                Button(action: {
                    HapticManager.shared.light()
                    showExportSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12))
                        
                        Text("Xuất")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(theme.secondaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(theme.cardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
                }
                
                // Refresh stats
                Button(action: {
                    HapticManager.shared.light()
                    Task {
                        await viewModel.fetchStats()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                        
                        Text("Làm mới")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(theme.secondaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(theme.cardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Export Sheet
    
    private var exportSheet: some View {
        NavigationView {
            VStack {
                Text("Logs đã được sao chép!")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    Text(viewModel.exportLogs())
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                }
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
                .padding()
            }
            .navigationTitle("Xuất Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") {
                        showExportSheet = false
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct LogStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(theme.secondaryText)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .white : theme.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : theme.cardBackground)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color.opacity(0.5) : theme.cardBorder, lineWidth: 1)
                )
        }
    }
}

struct LogRow: View {
    let log: LogEntry
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Level indicator
            ZStack {
                Circle()
                    .fill(log.level.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: log.level.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(log.level.color)
            }
            
            // Log content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(log.level.rawValue)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(log.level.color)
                    
                    Spacer()
                    
                    Text(log.formattedTime)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.tertiaryText)
                }
                
                Text(log.message)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(log.level.color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    LiveLogsView()
        .environmentObject(ThemeManager())
}
