//
//  StatCard.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let trend: String?
    let trendUp: Bool
    
    @EnvironmentObject var theme: ThemeManager
    @State private var isVisible = false
    
    init(icon: String, title: String, value: String, color: Color, trend: String? = nil, trendUp: Bool = true) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
        self.trend = trend
        self.trendUp = trendUp
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        
                        Text(trend)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(trendUp ? theme.accentGreen : theme.accentRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((trendUp ? theme.accentGreen : theme.accentRed).opacity(0.2))
                    )
                }
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(theme.secondaryText)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.cardBorder, lineWidth: 0.5)
                )
        )
        .scaleEffect(isVisible ? 1 : 0.9)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                isVisible = true
            }
        }
    }
}

struct MiniStatCard: View {
    let label: String
    let value: String
    let icon: String?
    let color: Color
    
    @EnvironmentObject var theme: ThemeManager
    
    init(label: String, value: String, icon: String? = nil, color: Color = .orange) {
        self.label = label
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if let icon = icon {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(theme.cardBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        StatCard(
            icon: "car.fill",
            title: "Xe Phát Hiện",
            value: "42",
            color: .blue,
            trend: "+19%",
            trendUp: true
        )
        
        HStack(spacing: 12) {
            MiniStatCard(
                label: "FPS",
                value: "30",
                icon: "speedometer",
                color: .green
            )
            
            MiniStatCard(
                label: "Alerts",
                value: "5",
                icon: "exclamationmark.triangle.fill",
                color: .orange
            )
        }
    }
    .padding()
    .background(Color.white)
    .environmentObject(ThemeManager())
}
