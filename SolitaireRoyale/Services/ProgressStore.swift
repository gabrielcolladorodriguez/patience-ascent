import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var bestScore: Int
    @Published private(set) var gamesPlayed: Int
    @Published private(set) var totalTimePlayed: TimeInterval

    private let defaults = UserDefaults.standard

    private init() {
        bestScore = defaults.integer(forKey: "bestScore")
        gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        totalTimePlayed = defaults.double(forKey: "totalTimePlayed")
    }

    private func save() {
        defaults.set(bestScore, forKey: "bestScore")
        defaults.set(gamesPlayed, forKey: "gamesPlayed")
        defaults.set(totalTimePlayed, forKey: "totalTimePlayed")
    }

    func addSessionTime(_ seconds: TimeInterval) {
        guard seconds > 0 else { return }
        totalTimePlayed += seconds
        save()
        GameCenterManager.shared.submitTotalPlayTime(totalTimePlayed)
    }

    @discardableResult
    func recordGameOver(score: Int, elapsed: TimeInterval) -> Bool {
        gamesPlayed += 1
        totalTimePlayed += max(0, elapsed)

        var isNewBest = false
        if score > bestScore {
            bestScore = score
            isNewBest = true
        }

        save()
        GameCenterManager.shared.submitHighScore(score)
        GameCenterManager.shared.submitTotalPlayTime(totalTimePlayed)
        return isNewBest
    }

    func resetAllProgress() {
        bestScore = 0
        gamesPlayed = 0
        totalTimePlayed = 0
        save()
    }
}
