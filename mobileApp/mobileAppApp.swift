
import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

@main
struct mobileAppApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestDataPermission()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("📱 App is active, checking for Ad...")
                AppOpenAdManager.shared.showAdIfAvailable()
            }
        }
    }

    private func requestDataPermission() {
        // Delay slightly to ensure app is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Start Google Mobile Ads SDK
                MobileAds.shared.start(completionHandler: nil)
                
                // Load ad after permission response
                switch status {
                case .authorized:
                    print("✅ Tracking Authorized")
                case .denied:
                    print("❌ Tracking Denied")
                case .notDetermined:
                    print("❓ Tracking Not Determined")
                case .restricted:
                    print("🔒 Tracking Restricted")
                @unknown default:
                    break
                }
                
                // Execute loadAd on main thread if needed
                DispatchQueue.main.async {
                    AppOpenAdManager.shared.loadAd()
                }
            }
        }
    }
}
