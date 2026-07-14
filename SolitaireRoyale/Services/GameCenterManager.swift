import GameKit
import SwiftUI

enum LeaderboardID {
    static let totalPlayTime = "patience_total_time"
    /// Global high score — Top 100 Ascent (configure in App Store Connect).
    static let top100 = "patience_ascent_top100"
    static let displayName = "Top 100 Ascent"
}

struct LeaderboardRow: Identifiable, Equatable {
    let id: String
    let rank: Int
    let playerName: String
    let score: Int
    let isLocalPlayer: Bool
}

@MainActor
final class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()

    @Published private(set) var isAuthenticated = false
    @Published private(set) var playerName = ""
    @Published private(set) var top100: [LeaderboardRow] = []
    @Published private(set) var localRank: Int?
    @Published private(set) var localScore: Int = 0
    @Published private(set) var isLoadingLeaderboard = false
    @Published private(set) var leaderboardError: String?

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

    func submitHighScore(_ score: Int) {
        guard isAuthenticated, score > 0 else { return }
        localScore = max(localScore, score)
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [LeaderboardID.top100]
        ) { [weak self] error in
            Task { @MainActor in
                if error == nil {
                    await self?.refreshTop100()
                }
            }
        }
    }

    func refreshTop100() async {
        guard isAuthenticated else {
            leaderboardError = L10n.s("gc_sign_in_required")
            top100 = []
            localRank = nil
            return
        }

        isLoadingLeaderboard = true
        leaderboardError = nil
        defer { isLoadingLeaderboard = false }

        do {
            let boards = try await GKLeaderboard.loadLeaderboards(IDs: [LeaderboardID.top100])
            guard let board = boards.first else {
                leaderboardError = L10n.s("gc_leaderboard_missing")
                return
            }

            let (localEntry, entries, _) = try await board.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 100)
            )

            top100 = entries.enumerated().map { index, entry in
                LeaderboardRow(
                    id: entry.player.gamePlayerID,
                    rank: index + 1,
                    playerName: entry.player.displayName,
                    score: entry.score,
                    isLocalPlayer: entry.player.gamePlayerID == GKLocalPlayer.local.gamePlayerID
                )
            }

            if let local = localEntry {
                localRank = local.rank
                localScore = local.score
            } else {
                localRank = nil
            }
        } catch {
            leaderboardError = error.localizedDescription
        }
    }

    func showNativeLeaderboards() {
        guard isAuthenticated else {
            authenticate()
            return
        }
        let vc = GKGameCenterViewController(
            leaderboardID: LeaderboardID.top100,
            playerScope: .global,
            timeScope: .allTime
        )
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
        Task { @MainActor in
            gameCenterViewController.dismiss(animated: true)
        }
    }
}
