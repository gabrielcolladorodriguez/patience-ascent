import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var coins: Int
    @Published private(set) var hints: Int
    @Published private(set) var undos: Int
    @Published private(set) var unlockedModes: Set<SolitaireMode>
    @Published private(set) var ownedCardBacks: Set<String>
    @Published private(set) var selectedCardBack: String
    @Published private(set) var wins: [String: Int]
    @Published private(set) var streak: Int
    @Published private(set) var bestStreak: Int
    @Published private(set) var lastDailyClaim: Date?
    @Published var dailyBoostActive: Bool
    @Published private(set) var xp: Int
    @Published private(set) var level: Int
    @Published private(set) var achievements: [Achievement]
    @Published private(set) var dailyChallenge: DailyChallenge
    @Published private(set) var dailyStreakDays: Int
    @Published private(set) var bestTimes: [String: TimeInterval]
    @Published private(set) var totalMoves: Int
    @Published private(set) var maxCombo: Int

    private let defaults = UserDefaults.standard

    var xpForNextLevel: Int { level * 120 + 80 }
    var xpProgress: Double { Double(xp % xpForNextLevel) / Double(xpForNextLevel) }

    private init() {
        coins = defaults.integer(forKey: "coins")
        if coins == 0 && !defaults.bool(forKey: "initialized") {
            coins = 250
            defaults.set(true, forKey: "initialized")
        }
        hints = defaults.object(forKey: "hints") == nil ? 8 : max(3, defaults.integer(forKey: "hints"))
        undos = defaults.object(forKey: "undos") == nil ? 15 : max(5, defaults.integer(forKey: "undos"))
        let unlocked = defaults.stringArray(forKey: "unlockedModes") ?? [SolitaireMode.klondike.rawValue]
        unlockedModes = Set(unlocked.compactMap(SolitaireMode.init(rawValue:)))
        ownedCardBacks = Set(defaults.stringArray(forKey: "ownedCardBacks") ?? ["card_back"])
        selectedCardBack = defaults.string(forKey: "selectedCardBack") ?? "card_back"
        wins = defaults.dictionary(forKey: "wins") as? [String: Int] ?? [:]
        streak = defaults.integer(forKey: "streak")
        bestStreak = defaults.integer(forKey: "bestStreak")
        lastDailyClaim = defaults.object(forKey: "lastDailyClaim") as? Date
        dailyBoostActive = defaults.bool(forKey: "dailyBoostActive")
        xp = defaults.integer(forKey: "xp")
        level = max(1, defaults.integer(forKey: "level"))
        if level == 0 { level = 1 }
        dailyStreakDays = defaults.integer(forKey: "dailyStreakDays")
        totalMoves = defaults.integer(forKey: "totalMoves")
        maxCombo = defaults.integer(forKey: "maxCombo")
        bestTimes = defaults.dictionary(forKey: "bestTimes") as? [String: TimeInterval] ?? [:]

        if let data = defaults.data(forKey: "achievements"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = AchievementCatalog.all
        }

        if let data = defaults.data(forKey: "dailyChallenge"),
           let decoded = try? JSONDecoder().decode(DailyChallenge.self, from: data),
           decoded.dateKey == DailyChallenge.today().dateKey {
            dailyChallenge = decoded
        } else {
            dailyChallenge = DailyChallenge.today()
        }
    }

    private func save() {
        defaults.set(coins, forKey: "coins")
        defaults.set(hints, forKey: "hints")
        defaults.set(undos, forKey: "undos")
        defaults.set(unlockedModes.map(\.rawValue), forKey: "unlockedModes")
        defaults.set(Array(ownedCardBacks), forKey: "ownedCardBacks")
        defaults.set(selectedCardBack, forKey: "selectedCardBack")
        defaults.set(wins, forKey: "wins")
        defaults.set(streak, forKey: "streak")
        defaults.set(bestStreak, forKey: "bestStreak")
        defaults.set(lastDailyClaim, forKey: "lastDailyClaim")
        defaults.set(dailyBoostActive, forKey: "dailyBoostActive")
        defaults.set(xp, forKey: "xp")
        defaults.set(level, forKey: "level")
        defaults.set(dailyStreakDays, forKey: "dailyStreakDays")
        defaults.set(totalMoves, forKey: "totalMoves")
        defaults.set(maxCombo, forKey: "maxCombo")
        defaults.set(bestTimes, forKey: "bestTimes")
        if let data = try? JSONEncoder().encode(achievements) {
            defaults.set(data, forKey: "achievements")
        }
        if let data = try? JSONEncoder().encode(dailyChallenge) {
            defaults.set(data, forKey: "dailyChallenge")
        }
    }

    func isUnlocked(_ mode: SolitaireMode) -> Bool {
        mode.isFree || unlockedModes.contains(mode)
    }

    func unlockMode(_ mode: SolitaireMode) -> Bool {
        guard !isUnlocked(mode), coins >= mode.unlockCost else { return false }
        coins -= mode.unlockCost
        unlockedModes.insert(mode)
        refreshAchievements()
        save()
        return true
    }

    func purchase(_ item: ShopItemKind) -> Bool {
        switch item {
        case .hintPack:
            guard coins >= item.price else { return false }
            coins -= item.price; hints += 5
        case .undoPack:
            guard coins >= item.price else { return false }
            coins -= item.price; undos += 10
        case .cardBackBlue:
            guard coins >= item.price else { return false }
            coins -= item.price
            ownedCardBacks.insert("card_back_blue")
            selectedCardBack = "card_back_blue"
        case .cardBackGreen:
            guard coins >= item.price else { return false }
            coins -= item.price
            ownedCardBacks.insert("card_back_green")
            selectedCardBack = "card_back_green"
        case .dailyBoost:
            guard coins >= item.price else { return false }
            coins -= item.price; dailyBoostActive = true
        case .coinBundleSmall, .coinBundleLarge:
            return false
        }
        save()
        return true
    }

    func selectCardBack(_ name: String) {
        guard ownedCardBacks.contains(name) else { return }
        selectedCardBack = name
        save()
    }

    func useHint() -> Bool {
        guard hints > 0 else { return false }
        hints -= 1; save(); return true
    }

    func useUndo() -> Bool {
        guard undos > 0 else { return false }
        undos -= 1; save(); return true
    }

    func refundUndo() { undos += 1; save() }

    @discardableResult
    func recordWin(mode: SolitaireMode, elapsed: TimeInterval, moves: Int, comboPeak: Int) -> (coins: Int, xp: Int) {
        let key = mode.rawValue
        wins[key, default: 0] += 1
        streak += 1
        bestStreak = max(bestStreak, streak)
        totalMoves += moves
        maxCombo = max(maxCombo, comboPeak)

        if let best = bestTimes[key] {
            if elapsed < best { bestTimes[key] = elapsed }
        } else {
            bestTimes[key] = elapsed
        }

        var reward = mode.winReward
        if dailyBoostActive { reward *= 2 }
        reward += min(streak, 12) * 8
        if elapsed < 180 && mode == .klondike { reward += 30 }

        let xpGain = 40 + mode.winReward / 2 + min(comboPeak, 15) * 3
        addXP(xpGain)
        coins += reward

        if mode == dailyChallenge.mode && !dailyChallenge.completed {
            dailyChallenge.completed = true
            coins += 150
            addXP(60)
        }

        refreshAchievements(elapsed: elapsed, comboPeak: comboPeak)
        save()
        return (reward, xpGain)
    }

    func recordLoss() {
        streak = 0
        save()
    }

    func addXP(_ amount: Int) {
        xp += amount
        while xp >= xpForNextLevel {
            xp -= xpForNextLevel
            level += 1
            coins += 25 + level * 5
            hints += 1
            HapticsManager.coin()
        }
    }

    var canClaimDaily: Bool {
        guard let last = lastDailyClaim else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    func claimDailyReward() -> Int {
        guard canClaimDaily else { return 0 }
        if let last = lastDailyClaim, Calendar.current.isDateInYesterday(last) {
            dailyStreakDays += 1
        } else if lastDailyClaim == nil {
            dailyStreakDays = 1
        } else {
            dailyStreakDays = 1
        }
        let reward = 120 + dailyStreakDays * 25 + min(wins.values.reduce(0, +), 40) * 2
        coins += reward
        addXP(30 + dailyStreakDays * 5)
        lastDailyClaim = Date()
        refreshAchievements()
        save()
        return reward
    }

    func claimAchievement(_ id: String) -> Int? {
        guard let idx = achievements.firstIndex(where: { $0.id == id }),
              achievements[idx].isComplete, !achievements[idx].claimed else { return nil }
        achievements[idx].claimed = true
        let reward = achievements[idx].coinReward
        coins += reward
        addXP(reward / 2)
        save()
        return reward
    }

    private func refreshAchievements(elapsed: TimeInterval = 9999, comboPeak: Int = 0) {
        let totalWins = wins.values.reduce(0, +)
        let unlockedCount = unlockedModes.count + 1

        for i in achievements.indices {
            switch achievements[i].id {
            case "first_win": achievements[i].progress = min(totalWins, achievements[i].goal)
            case "wins_10", "wins_50": achievements[i].progress = min(totalWins, achievements[i].goal)
            case "streak_5", "streak_15": achievements[i].progress = min(bestStreak, achievements[i].goal)
            case "modes_3", "modes_all": achievements[i].progress = min(unlockedCount, achievements[i].goal)
            case "daily_7": achievements[i].progress = min(dailyStreakDays, achievements[i].goal)
            case "klondike_speed":
                if elapsed < 180 && wins[SolitaireMode.klondike.rawValue, default: 0] > 0 {
                    achievements[i].progress = 1
                }
            case "combo_10": achievements[i].progress = min(max(maxCombo, comboPeak), achievements[i].goal)
            default: break
            }
        }
    }

    var claimableAchievements: [Achievement] {
        achievements.filter { $0.isComplete && !$0.claimed }
    }
}
