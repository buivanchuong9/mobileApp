//
//  OnboardingView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @EnvironmentObject var theme: ThemeManager
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "ADAS AI",
            description: "Hệ thống hỗ trợ lái xe tiên tiến sử dụng Trí Tuệ Nhân Tạo.",
            imageName: "car.fill",
            color: Color(red: 1.0, green: 0.6, blue: 0.2)
        ),
        OnboardingPage(
            title: "Phân Tích Real-time",
            description: "Phát hiện làn đường, xe cộ và cảnh báo va chạm trong thời gian thực.",
            imageName: "video.fill",
            color: Color(red: 0.4, green: 0.6, blue: 1.0)
        ),
        OnboardingPage(
            title: "Giám Sát Tài Xế",
            description: "Cảnh báo buồn ngủ và mất tập trung để đảm bảo an toàn tuyệt đối.",
            imageName: "eye.fill",
            color: Color(red: 0.9, green: 0.4, blue: 0.9)
        ),
        OnboardingPage(
            title: "Sẵn Sàng?",
            description: "Bắt đầu hành trình lái xe an toàn của bạn ngay bây giờ.",
            imageName: "checkmark.circle.fill",
            color: Color(red: 0.2, green: 0.8, blue: 0.4)
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                // Skip Button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage = pages.count - 1
                            }
                        }) {
                            Text("Bỏ qua")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.secondaryText)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                }
                
                // Tab View
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], theme: theme)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Controls
                HStack {
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? pages[index].color : pages[index].color.opacity(0.3))
                                .frame(width: currentPage == index ? 20 : 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    Spacer()
                    
                    // Next/Start Button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            withAnimation {
                                isOnboardingComplete = true
                            }
                        }
                    }) {
                        HStack {
                            Text(currentPage == pages.count - 1 ? "Bắt Đầu" : "Tiếp Theo")
                                .font(.system(size: 16, weight: .bold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            pages[currentPage].color
                        )
                        .cornerRadius(30)
                        .shadow(color: pages[currentPage].color.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(30)
            }
        }
        .transition(.move(edge: .bottom))
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 250, height: 250)
                
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Image(systemName: page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(page.color)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text(page.description)
                    .font(.system(size: 18))
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .environmentObject(ThemeManager())
}
