import SwiftUI

enum AppRoute: Equatable {
    case menu
    case modes
    case shop
    case stats
    case settings
    case achievements
    case game(SolitaireMode, daily: Bool)
}

struct RootView: View {
    @State private var route: AppRoute = .menu

    var body: some View {
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
    }

    private var routeKey: String {
        switch route {
        case .menu: return "menu"
        case .modes: return "modes"
        case .shop: return "shop"
        case .stats: return "stats"
        case .settings: return "settings"
        case .achievements: return "achievements"
        case .game(let m, let d): return "game-\(m.rawValue)-\(d)"
        }
    }
}
