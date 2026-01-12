//
//  ContentView.swift
//  mobileApp
//
//  Created by CHUONG on 12/1/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ADASViewModel()
    @StateObject private var theme = ThemeManager()
    @State private var selectedTab = 0
    
    // Persistent State
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    
    var body: some View {
        ZStack {
//            if !isOnboardingComplete {
//                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
//                    .environmentObject(theme)
//            } else if !isAuthenticated {
//                AuthView(isAuthenticated: $isAuthenticated)
//                    .environmentObject(theme)
//            } else {
                // Main App Flow
                ZStack {
                    // Background
                    theme.backgroundColor
                        .ignoresSafeArea()
                    
                    TabView(selection: $selectedTab) {
                        DashboardView(viewModel: viewModel)
                            .tabItem {
                                Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
                            }
                            .tag(0)
                        
                        MonitoringView(viewModel: viewModel)
                            .tabItem {
                                Label("Monitor", systemImage: "video.fill")
                            }
                            .tag(1)
                        
                        DrivingAnalysisView(viewModel: viewModel)
                            .tabItem {
                                Label("Lái Xe", systemImage: "car.fill")
                            }
                            .tag(2)
                        
                        DriverMonitoringView(viewModel: viewModel)
                            .tabItem {
                                Label("Tài Xế", systemImage: "eye.fill")
                            }
                            .tag(3)
                        
                        SettingsView(viewModel: viewModel)
                            .tabItem {
                                Label("Settings", systemImage: "gearshape.fill")
                            }
                            .tag(4)
                    }
                    .accentColor(theme.accentOrange)
                }
                .environmentObject(theme)
                .onAppear {
                    setupTabBarAppearance()
                }
                .onChange(of: theme.isDarkMode) { _ in
                    setupTabBarAppearance()
                }
//            }
        }
        .animation(.spring(), value: isOnboardingComplete)
        .animation(.spring(), value: isAuthenticated)
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if theme.isDarkMode {
            appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 0.95)
        } else {
            appearance.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 0.95) // Match light bg
        }
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
