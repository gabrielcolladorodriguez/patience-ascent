import UIKit

enum HapticsManager {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let success = UINotificationFeedbackGenerator()
    private static let selection = UISelectionFeedbackGenerator()

    static var enabled: Bool {
        get { UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "hapticsEnabled") }
    }

    static func prepare() {
        light.prepare()
        medium.prepare()
        selection.prepare()
    }

    static func tap() {
        guard enabled else { return }
        selection.selectionChanged()
    }

    static func cardLift() {
        guard enabled else { return }
        light.impactOccurred(intensity: 0.7)
    }

    static func cardDrop() {
        guard enabled else { return }
        medium.impactOccurred(intensity: 0.85)
    }

    static func invalid() {
        guard enabled else { return }
        heavy.impactOccurred(intensity: 0.5)
    }

    static func win() {
        guard enabled else { return }
        success.notificationOccurred(.success)
    }

    static func coin() {
        guard enabled else { return }
        success.notificationOccurred(.success)
    }
}
