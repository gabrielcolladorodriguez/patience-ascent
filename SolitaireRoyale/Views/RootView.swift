import SwiftUI

enum AppRoute: Equatable {
    case menu
    case playPicker
    case modes
    case rankings
    case game(SolitaireMode, daily: Bool)
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
                case .playPicker:
                    PlayModePickerView(route: $route)
                case .modes:
                    ModeSelectView(route: $route)
                case .rankings:
                    RankingsView(route: $route)
                case .game(let mode, let daily):
                    GlyphLinkBoardView(
                        session: GlyphLinkSessionViewModel(
                            mode: mode,
                            dailySeed: daily ? ProgressStore.shared.dailyChallenge.seed : nil
                        ),
                        route: $route
                    )
                }
            }
            .animation(.easeInOut(duration: 0.22), value: routeKey)

            if !hasSeenOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
    }

    private var routeKey: String {
        switch route {
        case .menu: return "menu"
        case .playPicker: return "playPicker"
        case .modes: return "modes"
        case .rankings: return "rankings"
        case .game(let m, let d): return "game-\(m.rawValue)-\(d)"
        }
    }
}
