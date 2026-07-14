import GameKit
import SwiftUI

/// Leaderboards (crear en App Store Connect → Game Center con estos IDs).
enum LeaderboardID {
    static let totalPlayTime = "patience_total_time"
    static func bestTime(_ mode: SolitaireMode) -> String { "patience_best_\(mode.rawValue)" }
}

@MainActor
final class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()

    @Published private(set) var isAuthenticated = false
    @Published private(set) var playerName = ""

    private override init() {
        super.init()
    }

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                if let viewController {
                    Self.presentAuth(viewController)
                    return
                }
                if error != nil {
                    self?.isAuthenticated = false
                    return
                }
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self?.playerName = GKLocalPlayer.local.displayName
            }
        }
    }

    func submitTotalPlayTime(_ seconds: TimeInterval) {
        guard isAuthenticated else { return }
        let score = max(1, Int(seconds))
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [LeaderboardID.totalPlayTime]
        ) { _ in }
    }

    func submitBestTime(_ seconds: TimeInterval, mode: SolitaireMode) {
        guard isAuthenticated, seconds > 0 else { return }
        let score = max(1, Int(seconds.rounded()))
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [LeaderboardID.bestTime(mode)]
        ) { _ in }
    }

    func showLeaderboards() {
        guard isAuthenticated else {
            authenticate()
            return
        }
        let vc = GKGameCenterViewController(state: .leaderboards)
        vc.gameCenterDelegate = self
        Self.present(vc)
    }

    private static func presentAuth(_ vc: UIViewController) {
        guard let root = topViewController() else { return }
        root.present(vc, animated: true)
    }

    private static func present(_ vc: UIViewController) {
        guard let root = topViewController() else { return }
        root.present(vc, animated: true)
    }

    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
        if let nav = root as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(base: presented)
        }
        return root
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
