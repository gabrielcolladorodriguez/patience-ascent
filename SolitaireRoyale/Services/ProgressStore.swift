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
    @Published private(set) var modeLevels: [String: Int]
    @Published private(set) var modeXP: [String: Int]

    private let defaults = UserDefaults.standard

    private init() {
        wins = defaults.dictionary(forKey: "wins") as? [String: Int] ?? [:]
        streak = defaults.integer(forKey: "streak")
        bestStreak = defaults.integer(forKey: "bestStreak")
        bestTimes = defaults.dictionary(forKey: "bestTimes") as? [String: TimeInterval] ?? [:]
        bestScores = defaults.dictionary(forKey: "bestScores") as? [String: Int] ?? [:]
        totalTimePlayed = defaults.double(forKey: "totalTimePlayed")
        gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        modeLevels = defaults.dictionary(forKey: "modeLevels") as? [String: Int] ?? [:]
        modeXP = defaults.dictionary(forKey: "modeXP") as? [String: Int] ?? [:]

        if let data = defaults.data(forKey: "dailyChallenge"),
           let decoded = try? JSONDecoder().decode(DailyChallenge.self, from: data),
           decoded.dateKey == DailyChallenge.today().dateKey {
            dailyChallenge = DailyChallenge.normalize(decoded)
        } else {
            dailyChallenge = DailyChallenge.today()
        }

        for mode in SolitaireMode.puzzleModes where modeLevels[mode.rawValue] == nil {
            modeLevels[mode.rawValue] = 1
            modeXP[mode.rawValue] = 0
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
        defaults.set(modeLevels, forKey: "modeLevels")
        defaults.set(modeXP, forKey: "modeXP")
        if let data = try? JSONEncoder().encode(dailyChallenge) {
            defaults.set(data, forKey: "dailyChallenge")
        }
    }

    func level(for mode: SolitaireMode) -> Int {
        max(1, modeLevels[mode.rawValue] ?? 1)
    }

    func xp(for mode: SolitaireMode) -> Int {
        max(0, modeXP[mode.rawValue] ?? 0)
    }

    func xpProgress(for mode: SolitaireMode) -> Double {
        AscentProgression.xpProgress(level: level(for: mode), xp: xp(for: mode))
    }

    var globalAscentRank: Int {
        AscentProgression.globalRank(levels: modeLevels)
    }

    var globalRankTitle: String {
        AscentProgression.globalRankTitle(globalAscentRank)
    }

    func levelConfig(for mode: SolitaireMode) -> LevelConfig {
        LevelConfig.forMode(mode, level: level(for: mode))
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

    @discardableResult
    func grantXP(mode: SolitaireMode, stars: Int, comboPeak: Int, score: Int) -> LevelUpResult? {
        let key = mode.rawValue
        let oldLevel = level(for: mode)
        let gained = AscentProgression.xpReward(mode: mode, level: oldLevel, stars: stars, comboPeak: comboPeak, score: score)
        var xp = xp(for: mode) + gained
        var level = oldLevel

        while level < AscentProgression.maxLevel {
            let need = AscentProgression.xpRequired(forLevel: level)
            if xp < need { break }
            xp -= need
            level += 1
        }

        modeXP[key] = xp
        modeLevels[key] = level
        save()

        guard level > oldLevel else { return nil }
        return LevelUpResult(mode: mode, oldLevel: oldLevel, newLevel: level, xpGained: gained, stars: stars)
    }

    func recordAbandon() {
        streak = 0
        save()
    }

    func resetAllProgress() {
        wins = [:]
        streak = 0
        bestStreak = 0
        bestTimes = [:]
        bestScores = [:]
        totalTimePlayed = 0
        gamesPlayed = 0
        modeLevels = [:]
        modeXP = [:]
        dailyChallenge = DailyChallenge.today()

        for mode in SolitaireMode.puzzleModes {
            modeLevels[mode.rawValue] = 1
            modeXP[mode.rawValue] = 0
            defaults.removeObject(forKey: mode.tutorialStorageKey)
        }

        save()
    }

    var totalWins: Int { wins.values.reduce(0, +) }
}
