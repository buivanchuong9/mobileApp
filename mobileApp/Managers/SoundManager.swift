//
//  SoundManager.swift
//  mobileApp
//
//  Sound alert manager for ADAS warnings
//  Plays audio alerts through phone speaker when dangers are detected
//

import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var synthesizer = AVSpeechSynthesizer()
    
    private init() {
        configureAudioSession()
    }
    
    // MARK: - Audio Session Configuration
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ SoundManager: Audio session configuration failed: \(error)")
        }
    }
    
    // MARK: - System Sound Alerts
    
    /// Critical danger alert - collision, drowsiness detected
    func playDangerAlert() {
        // Play system alert sound + vibration
        AudioServicesPlayAlertSound(1005) // Repeated alert tone
        
        // Additional haptic
        HapticManager.shared.error()
        
        // Repeat for urgency
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AudioServicesPlayAlertSound(1005)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AudioServicesPlayAlertSound(1005)
        }
    }
    
    /// Warning alert - lane departure, distraction
    func playWarningAlert() {
        AudioServicesPlayAlertSound(1116) // Warning tone
        HapticManager.shared.warning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            AudioServicesPlayAlertSound(1116)
        }
    }
    
    /// Info/Low severity alert
    func playInfoAlert() {
        AudioServicesPlayAlertSound(1057) // Subtle notification
        HapticManager.shared.light()
    }
    
    /// Success completion sound
    func playSuccessSound() {
        AudioServicesPlayAlertSound(1025) // Success chime
        HapticManager.shared.success()
    }
    
    /// Analysis started sound
    func playStartSound() {
        AudioServicesPlayAlertSound(1113) // Begin processing tone
    }
    
    // MARK: - Voice Alerts (Text-to-Speech)
    
    /// Speak a warning message through the phone speaker
    func speakAlert(_ message: String, urgency: AlertUrgency = .medium) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "vi-VN") // Vietnamese
        
        switch urgency {
        case .critical:
            utterance.rate = 0.55 // Slightly fast for urgency
            utterance.volume = 1.0
            utterance.pitchMultiplier = 1.2
        case .medium:
            utterance.rate = 0.50
            utterance.volume = 0.9
            utterance.pitchMultiplier = 1.0
        case .low:
            utterance.rate = 0.45
            utterance.volume = 0.7
            utterance.pitchMultiplier = 0.9
        }
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - Combined Alert Methods (Sound + Voice)
    
    /// Collision warning: sound + voice
    func alertCollisionWarning() {
        playDangerAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.speakAlert("Cảnh báo va chạm! Hãy chú ý phía trước!", urgency: .critical)
        }
    }
    
    /// Lane departure: sound + voice
    func alertLaneDeparture() {
        playWarningAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.speakAlert("Cảnh báo lệch làn đường!", urgency: .medium)
        }
    }
    
    /// Drowsiness detected: sound + voice
    func alertDrowsiness() {
        playDangerAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.speakAlert("Phát hiện buồn ngủ! Hãy nghỉ ngơi ngay!", urgency: .critical)
        }
    }
    
    /// Distraction detected: sound + voice
    func alertDistraction() {
        playWarningAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.speakAlert("Bạn đang mất tập trung! Hãy nhìn đường!", urgency: .medium)
        }
    }
    
    /// Phone usage detected: sound + voice
    func alertPhoneUsage() {
        playWarningAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.speakAlert("Không sử dụng điện thoại khi lái xe!", urgency: .medium)
        }
    }
    
    /// Analysis complete with warnings
    func alertAnalysisComplete(warningsCount: Int, safetyScore: Int) {
        if warningsCount > 0 && safetyScore < 60 {
            playDangerAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.speakAlert("Phân tích hoàn tất. Phát hiện \(warningsCount) cảnh báo. Điểm an toàn \(safetyScore) trên 100. Cần chú ý lái xe an toàn hơn!", urgency: .critical)
            }
        } else if warningsCount > 0 {
            playWarningAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.speakAlert("Phân tích hoàn tất. Phát hiện \(warningsCount) cảnh báo. Điểm an toàn \(safetyScore) trên 100.", urgency: .medium)
            }
        } else {
            playSuccessSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.speakAlert("Phân tích hoàn tất. Lái xe an toàn! Điểm an toàn \(safetyScore) trên 100.", urgency: .low)
            }
        }
    }
    
    /// Driver monitoring result alert
    func alertDriverMonitoringResult(status: String, attentionScore: Int) {
        switch status {
        case "Nguy Hiểm":
            playDangerAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.speakAlert("Cảnh báo nguy hiểm! Điểm tập trung \(attentionScore). Tài xế cần nghỉ ngơi ngay!", urgency: .critical)
            }
        case "Cảnh Báo":
            playWarningAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.speakAlert("Cảnh báo! Điểm tập trung \(attentionScore). Tài xế cần chú ý hơn.", urgency: .medium)
            }
        default:
            playSuccessSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.speakAlert("Giám sát hoàn tất. Tài xế lái xe an toàn. Điểm tập trung \(attentionScore).", urgency: .low)
            }
        }
    }
    
    /// Stop all sounds and speech
    func stopAll() {
        audioPlayer?.stop()
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - Alert Urgency
    enum AlertUrgency {
        case low, medium, critical
    }
}
