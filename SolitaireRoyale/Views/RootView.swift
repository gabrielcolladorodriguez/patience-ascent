import SwiftUI

enum AppRoute: Equatable {
    case menu
    case game
}

struct RootView: View {
    @State private var route: AppRoute = .menu
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            Group {
                switch route {
                case .menu:
                    MainMenuView(route: $route)
                case .game:
                    GravityBlockGameView(route: $route)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: route)

            if !hasSeenOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
    }
}
