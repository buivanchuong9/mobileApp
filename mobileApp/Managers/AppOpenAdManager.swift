
import GoogleMobileAds
import UIKit

class AppOpenAdManager: NSObject, FullScreenContentDelegate {
    static let shared = AppOpenAdManager()
    
    // Real Ad Unit ID (User requested)
    private let adUnitID = "ca-app-pub-4587554780506701/7492974338"
    
    private var appOpenAd: AppOpenAd?
    private var loadTime: Date?
    private var isLoadingAd = false
    
    private override init() {}
    
    // MARK: - Load Ad
    func loadAd() {
        // Do not load ad if already loading or if one is currently available and valid
        if isLoadingAd || isAdAvailable() {
            return
        }
        
        isLoadingAd = true
        print("🚀 [AppOpenAdManager] Start loading ad...")
        
        let request = Request()
        // Updated: withAdUnitID -> with
        AppOpenAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoadingAd = false
            
            if let error = error {
                print("❌ [AppOpenAdManager] Failed to load ad: \(error.localizedDescription)")
                return
            }
            
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            print("✅ [AppOpenAdManager] Ad loaded successfully.")
        }
    }
    
    // MARK: - Check Availability
    private func isAdAvailable() -> Bool {
        return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(threshold: 4)
    }
    
    private func wasLoadTimeLessThanNHoursAgo(threshold: Int) -> Bool {
        guard let loadTime = loadTime else { return false }
        let timeIntervalBetweenNowAndLoadTime = Date().timeIntervalSince(loadTime)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(threshold)
    }
    
    // MARK: - Show Ad
    func showAdIfAvailable() {
        // If ad is not available, try to load one for next time
        if !isAdAvailable() {
            print("⚠️ [AppOpenAdManager] Ad not available or expired. Loading new one.")
            loadAd()
            return
        }
        
        guard let rootViewController = getRootViewController() else {
            print("⚠️ [AppOpenAdManager] Can't find RootViewController.")
            return
        }
        
        if let ad = appOpenAd {
            print("📺 [AppOpenAdManager] Showing Ad...")
            // Updated: present(fromRootViewController:) -> present(from:)
            ad.present(from: rootViewController)
        }
    }
    
    // MARK: - Helper: Get Root View Controller
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController
    }
    
    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("👋 [AppOpenAdManager] Ad dismissed.")
        appOpenAd = nil
        loadAd() // Load the next ad immediately
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ [AppOpenAdManager] Ad failed to present: \(error.localizedDescription)")
        appOpenAd = nil
        loadAd()
    }
}
