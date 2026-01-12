//
//  ChartView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI
import Charts

struct ADASChartData: Identifiable {
    let id = UUID()
    let time: String
    let value: Double
    let category: String
}

struct SimpleLineChart: View {
    let data: [ADASChartData]
    let color: Color
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart(data) { item in
                LineMark(
                    x: .value("Time", item.time),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(color)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Time", item.time),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .frame(height: 200)
        }
    }
}

struct BarChartView: View {
    let data: [ADASChartData]
    let color: Color
    
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Category", item.category),
                y: .value("Value", item.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(8)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .frame(height: 200)
    }
}

struct DonutChart: View {
    let segments: [(String, Double, Color)]
    @State private var selectedSegment: String?
    
    @EnvironmentObject var theme: ThemeManager
    
    var total: Double {
        segments.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                    let startAngle = calculateStartAngle(for: index)
                    let endAngle = startAngle + Angle(degrees: (segment.1 / total) * 360)
                    
                    Circle()
                        .trim(from: startAngle.degrees / 360, to: endAngle.degrees / 360)
                        .stroke(segment.2, lineWidth: 30)
                        .frame(width: 150, height: 150)
                        .rotationEffect(Angle(degrees: -90))
                        .opacity(selectedSegment == nil || selectedSegment == segment.0 ? 1.0 : 0.3)
                        .animation(.spring(response: 0.3), value: selectedSegment)
                }
                
                VStack(spacing: 4) {
                    if let selected = selectedSegment,
                       let segment = segments.first(where: { $0.0 == selected }) {
                        Text(String(format: "%.0f%%", (segment.1 / total) * 100))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryText)
                        
                        Text(selected)
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryText)
                    } else {
                        Text("100%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryText)
                        
                        Text("Total")
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryText)
                    }
                }
            }
            
            // Legend
            VStack(spacing: 8) {
                ForEach(segments, id: \.0) { segment in
                    Button(action: {
                        withAnimation {
                            selectedSegment = selectedSegment == segment.0 ? nil : segment.0
                        }
                        HapticManager.shared.selection()
                    }) {
                        HStack {
                            Circle()
                                .fill(segment.2)
                                .frame(width: 12, height: 12)
                            
                            Text(segment.0)
                                .font(.system(size: 13))
                                .foregroundColor(theme.primaryText)
                            
                            Spacer()
                            
                            Text(String(format: "%.0f%%", (segment.1 / total) * 100))
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(theme.secondaryText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedSegment == segment.0 ? segment.2.opacity(0.2) : Color.clear)
                        )
                    }
                }
            }
        }
    }
    
    private func calculateStartAngle(for index: Int) -> Angle {
        let previousTotal = segments.prefix(index).reduce(0) { $0 + $1.1 }
        return Angle(degrees: (previousTotal / total) * 360)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Detection Over Time")
                    .font(.headline)
                
                SimpleLineChart(
                    data: [
                        ADASChartData(time: "10:00", value: 12, category: ""),
                        ADASChartData(time: "10:15", value: 18, category: ""),
                        ADASChartData(time: "10:30", value: 15, category: ""),
                        ADASChartData(time: "10:45", value: 22, category: ""),
                        ADASChartData(time: "11:00", value: 28, category: ""),
                    ],
                    color: .orange
                )
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Detection Distribution")
                    .font(.headline)
                
                DonutChart(segments: [
                    ("Cars", 45, .blue),
                    ("Pedestrians", 25, .purple),
                    ("Motorcycles", 20, .orange),
                    ("Others", 10, .green)
                ])
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .padding()
    }
    .background(Color(red: 0.05, green: 0.08, blue: 0.15))
    .environmentObject(ThemeManager())
}
