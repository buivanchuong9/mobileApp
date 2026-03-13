import Foundation
import AVFoundation
import Photos
import UserNotifications

class PermissionManager: NSObject {
    static let shared = PermissionManager()
    
    private override init() {
        super.init()
    }
    
    @available(*, deprecated, message: "Use individual request methods Just-In-Time instead.")
    func requestAllPermissions() {
        // Sequentially request all required permissions
        // Use a slight delay to ensure the app is fully active
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.requestNotificationPermission {
                self.requestCameraPermission {
                    self.requestMicrophonePermission {
                        self.requestPhotoLibraryPermission {
                            print("✅ All permission requests completed")
                        }
                    }
                }
            }
        }
    }
    
    func requestNotificationPermission(completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Notification access: \(granted)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    func requestCameraPermission(completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera access: \(granted)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    func requestMicrophonePermission(completion: @escaping () -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("Microphone access: \(granted)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    func requestPhotoLibraryPermission(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            print("Photo Library status: \(status)")
            DispatchQueue.main.async { completion() }
        }
    }
}
