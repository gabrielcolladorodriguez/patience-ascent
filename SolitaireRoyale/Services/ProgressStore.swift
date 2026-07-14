import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var wins: [String: Int]
    @Published private(set) var streak: Int
    @Published private(set) var bestStreak: Int
    @Published private(set) var bestTimes: [String: TimeInterval]
    @Published private(set) var bestScores: [String: Int]
    @Published private(set) var totalTimePlayed: TimeInterval
    @Published private(set) var gamesPlayed: Int
    @Published private(set) var dailyChallenge: DailyChallenge

    private let defaults = UserDefaults.standard

    private init() {
        wins = defaults.dictionary(forKey: "wins") as? [String: Int] ?? [:]
        streak = defaults.integer(forKey: "streak")
        bestStreak = defaults.integer(forKey: "bestStreak")
        bestTimes = defaults.dictionary(forKey: "bestTimes") as? [String: TimeInterval] ?? [:]
        bestScores = defaults.dictionary(forKey: "bestScores") as? [String: Int] ?? [:]
        totalTimePlayed = defaults.double(forKey: "totalTimePlayed")
        gamesPlayed = defaults.integer(forKey: "gamesPlayed")

        if let data = defaults.data(forKey: "dailyChallenge"),
           let decoded = try? JSONDecoder().decode(DailyChallenge.self, from: data),
           decoded.dateKey == DailyChallenge.today().dateKey {
            dailyChallenge = DailyChallenge.normalize(decoded)
        } else {
            dailyChallenge = DailyChallenge.today()
        }
    }

    private func save() {
        defaults.set(wins, forKey: "wins")
        defaults.set(streak, forKey: "streak")
        defaults.set(bestStreak, forKey: "bestStreak")
        defaults.set(bestTimes, forKey: "bestTimes")
        defaults.set(bestScores, forKey: "bestScores")
        defaults.set(totalTimePlayed, forKey: "totalTimePlayed")
        defaults.set(gamesPlayed, forKey: "gamesPlayed")
        if let data = try? JSONEncoder().encode(dailyChallenge) {
            defaults.set(data, forKey: "dailyChallenge")
        }
    }

    func addSessionTime(_ seconds: TimeInterval) {
        guard seconds > 0 else { return }
        totalTimePlayed += seconds
        save()
        GameCenterManager.shared.submitTotalPlayTime(totalTimePlayed)
    }

    @discardableResult
    func recordWin(mode: SolitaireMode, elapsed: TimeInterval, moves: Int) -> Bool {
        let key = mode.rawValue
        wins[key, default: 0] += 1
        streak += 1
        bestStreak = max(bestStreak, streak)
        gamesPlayed += 1

        var isNewBest = false
        if let best = bestTimes[key] {
            if elapsed < best {
                bestTimes[key] = elapsed
                isNewBest = true
            }
        } else {
            bestTimes[key] = elapsed
            isNewBest = true
        }

        if mode == dailyChallenge.mode && !dailyChallenge.completed {
            dailyChallenge.completed = true
        }

        save()
        GameCenterManager.shared.submitBestTime(elapsed, mode: mode)
        return isNewBest
    }

    @discardableResult
    func recordRushScore(mode: SolitaireMode, score: Int, moves: Int) -> Bool {
        let key = mode.rawValue
        wins[key, default: 0] += 1
        streak += 1
        bestStreak = max(bestStreak, streak)
        gamesPlayed += 1

        var isNewBest = false
        if let best = bestScores[key] {
            if score > best {
                bestScores[key] = score
                isNewBest = true
            }
        } else {
            bestScores[key] = score
            isNewBest = true
        }

        if mode == dailyChallenge.mode && !dailyChallenge.completed {
            dailyChallenge.completed = true
        }

        save()
        GameCenterManager.shared.submitHighScore(score, mode: mode)
        return isNewBest
    }

    func recordAbandon() {
        streak = 0
        save()
    }

    var totalWins: Int { wins.values.reduce(0, +) }
}
