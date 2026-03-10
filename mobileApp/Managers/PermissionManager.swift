import Foundation
import AVFoundation
import Photos
import AppTrackingTransparency
import AdSupport
import CoreLocation
import UserNotifications

class PermissionManager: NSObject, CLLocationManagerDelegate {
    static let shared = PermissionManager()
    
    private let locationManager = CLLocationManager()
    private var locationCompletion: (() -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAllPermissions() {
        // Sequentially request all required permissions
        // Use a slight delay to ensure the app is fully active
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.requestTrackingPermission {
                self.requestNotificationPermission {
                    self.requestCameraPermission {
                        self.requestMicrophonePermission {
                            self.requestPhotoLibraryPermission {
                                self.requestLocationPermission {
                                    print("✅ All permission requests completed")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func requestTrackingPermission(completion: @escaping () -> Void) {
        ATTrackingManager.requestTrackingAuthorization { status in
            print("Tracking status: \(status)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    private func requestNotificationPermission(completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Notification access: \(granted)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    private func requestCameraPermission(completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera access: \(granted)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    private func requestMicrophonePermission(completion: @escaping () -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("Microphone access: \(granted)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    private func requestPhotoLibraryPermission(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            print("Photo Library status: \(status)")
            DispatchQueue.main.async { completion() }
        }
    }
    
    private func requestLocationPermission(completion: @escaping () -> Void) {
        self.locationCompletion = completion
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        default:
            if let completion = locationCompletion {
                locationCompletion = nil
                DispatchQueue.main.async { completion() }
            }
        }
    }
}
