import SwiftUI

enum AppRoute: Equatable {
    case menu
    case modes
    case shop
    case stats
    case settings
    case achievements
    case howToPlay
    case game(SolitaireMode, daily: Bool)
}

struct RootView: View {
    @State private var route: AppRoute = .menu
    @State private var previousRouteKey = "menu"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Group {
                switch route {
                case .menu:
                    MainMenuView(route: $route)
                case .modes:
                    ModeSelectView(route: $route)
                case .shop:
                    ShopView(route: $route)
                case .stats:
                    StatsView(route: $route)
                case .settings:
                    SettingsView(route: $route)
                case .achievements:
                    AchievementsView(route: $route)
                case .howToPlay:
                    HowToPlayView(route: $route)
                case .game(let mode, let daily):
                    GameBoardView(
                        session: GameSessionViewModel(
                            mode: mode,
                            dailySeed: daily ? ProgressStore.shared.dailyChallenge.seed : nil
                        ),
                        route: $route
                    )
                }
            }
            .animation(.easeInOut(duration: 0.25), value: routeKey)

            if !hasSeenOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .onAppear {
            updateAdContext(for: routeKey)
        }
        .onChange(of: routeKey) { newKey in
            let wasInGame = previousRouteKey.hasPrefix("game-")
            previousRouteKey = newKey
            updateAdContext(for: newKey)
            if newKey == "menu", wasInGame, hasSeenOnboarding {
                AdManager.shared.notifyReturnedToMenu()
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                AdManager.shared.resumeChecks()
            case .background, .inactive:
                AdManager.shared.pauseChecks()
            @unknown default:
                break
            }
        }
    }

    private func updateAdContext(for key: String) {
        AdManager.shared.setUserOnMenu(key == "menu")
    }

    private var routeKey: String {
        switch route {
        case .menu: return "menu"
        case .modes: return "modes"
        case .shop: return "shop"
        case .stats: return "stats"
        case .settings: return "settings"
        case .achievements: return "achievements"
        case .howToPlay: return "howToPlay"
        case .game(let m, let d): return "game-\(m.rawValue)-\(d)"
        }
    }
}
