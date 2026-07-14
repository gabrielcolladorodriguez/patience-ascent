import SwiftUI

@main
struct SolitaireRoyaleApp: App {
    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
                .onAppear {
                    GameCenterManager.shared.authenticate()
                }
        }
    }
}
