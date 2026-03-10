import Foundation
import AppTrackingTransparency
import AdSupport

class TrackingManager {
    static func requestTrackingPermission() {
        // Delay a bit to ensure the app is fully active and the UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("✅ Tracking Authorized")
                    // IDFA is accessible
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied:
                    print("❌ Tracking Denied")
                case .notDetermined:
                    print("❓ Tracking Not Determined")
                case .restricted:
                    print("🚫 Tracking Restricted")
                @unknown default:
                    print("⚠️ Unknown Tracking Status")
                }
            }
        }
    }
}
