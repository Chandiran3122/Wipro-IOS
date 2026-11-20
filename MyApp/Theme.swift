import SwiftUI

enum SwiggyColors {
    static let orange = Color(red: 252/255, green: 128/255, blue: 25/255) // #FC8019
    static let darkOrange = Color(red: 228/255, green: 104/255, blue: 5/255)
    static let lightOrange = Color(red: 254/255, green: 242/255, blue: 232/255)
    static let deepNavy = Color(red: 24/255, green: 30/255, blue: 42/255)
    static let cardBackground = Color(red: 32/255, green: 40/255, blue: 54/255)
    static let cardLight = Color(red: 40/255, green: 50/255, blue: 66/255)
    static let emeraldGreen = Color(red: 34/255, green: 197/255, blue: 94/255)
    static let lightGreen = Color(red: 236/255, green: 253/255, blue: 245/255)
    static let alertRed = Color(red: 239/255, green: 68/255, blue: 68/255)
    static let warningAmber = Color(red: 245/255, green: 158/255, blue: 11/255)
    static let mutedText = Color(red: 148/255, green: 163/255, blue: 184/255)
}

struct HapticManager {
    static func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
        #endif
    }
    
    static func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
}
