import SwiftUI

@main
struct SolitaireRoyaleApp: App {
    init() {
        UITabBar.appearance().isHidden = true
        AdManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
