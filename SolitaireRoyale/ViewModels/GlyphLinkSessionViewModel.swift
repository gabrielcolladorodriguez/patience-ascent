import Foundation
import SwiftUI

@MainActor
final class GlyphLinkSessionViewModel: ObservableObject {
    @Published private(set) var engine: GlyphLinkEngine
    @Published var selected: GridPos?
    @Published var hintPair: (GridPos, GridPos)?
    @Published var message: String?
    @Published var showWin = false
    @Published var moves = 0
    @Published var elapsed: TimeInterval = 0
    @Published var combo = 0
    @Published var comboPeak = 0
    @Published var score = 0
    @Published var isNewBestTime = false
    @Published var isNewBestScore = false
    @Published private(set) var boardVersion = 0
    @Published var flashPair: (GridPos, GridPos)?
    @Published var rushRemaining: TimeInterval = 0
    @Published var pressureRemaining: TimeInterval = 0
    @Published var showTutorial = false
    @Published var tutorialStep = 0
    @Published var tutorialPracticeDone = false
    @Published var starsEarned = 0
    @Published var xpGained = 0
    @Published var levelUpResult: LevelUpResult?

    let mode: SolitaireMode
    let levelConfig: LevelConfig
    let dailySeed: UInt64?
    private var timer: Timer?
    private var timerStarted = false
    private var sessionTimeReported = false
    private var lastChainCells: Set<GridPos> = []
    private var boardsCleared = 0
    private let progress = ProgressStore.shared
    private let audio = AudioManager.shared
    private let defaults = UserDefaults.standard

    private var rules: GlyphLinkRules { mode.rules(level: levelConfig.level) }
    var theme: ModeTheme { mode.theme }

    init(mode: SolitaireMode = .glyphLink, dailySeed: UInt64? = nil) {
        self.mode = mode
        self.dailySeed = dailySeed
        self.levelConfig = progress.levelConfig(for: mode)
        self.engine = GlyphLinkEngine(mode: mode, levelConfig: levelConfig, seed: dailySeed)
        if let rush = rules.rushDuration {
            rushRemaining = rush
        }
        if let pressure = rules.pressureLimit {
            pressureRemaining = pressure
        }
        showTutorial = !defaults.bool(forKey: mode.tutorialStorageKey)
        audio.cardShuffle()
        HapticsManager.prepare()
        if showTutorial {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.prepareTutorialHint()
            }
        }
    }

    deinit { timer?.invalidate() }

    func flushSessionTime() {
        guard !sessionTimeReported, elapsed > 0 else { return }
        sessionTimeReported = true
        progress.addSessionTime(elapsed)
    }

    private func bumpBoard() {
        boardVersion += 1
        objectWillChange.send()
    }

    private func startTimerIfNeeded() {
        guard !timerStarted, !showTutorial else { return }
        timerStarted = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        if rules.rushDuration != nil {
            rushRemaining = max(0, rushRemaining - 1)
            if rushRemaining <= 0 {
                finishRush()
            }
        } else {
            elapsed += 1
            if rules.pressureLimit != nil {
                pressureRemaining = max(0, pressureRemaining - 1)
                if pressureRemaining <= 0 {
                    finishPressureFail()
                }
            }
        }
    }

    func newGame() {
        let config = progress.levelConfig(for: mode)
        engine = GlyphLinkEngine(
            mode: mode,
            levelConfig: config,
            seed: dailySeed == nil ? nil : dailySeed! &+ UInt64(moves)
        )
        selected = nil
        hintPair = nil
        flashPair = nil
        message = nil
        showWin = false
        isNewBestTime = false
        isNewBestScore = false
        starsEarned = 0
        xpGained = 0
        levelUpResult = nil
        moves = 0
        elapsed = 0
        combo = 0
        comboPeak = 0
        score = 0
        boardsCleared = 0
        lastChainCells = []
        sessionTimeReported = false
        timerStarted = false
        timer?.invalidate()
        timer = nil
        rushRemaining = rules.rushDuration ?? 0
        pressureRemaining = rules.pressureLimit ?? 0
        bumpBoard()
        audio.cardShuffle()
    }

    func tap(_ pos: GridPos) {
        if showTutorial, tutorialStep == 1, !tutorialPracticeDone {
            tapTutorialPractice(pos)
            return
        }
        if showTutorial, tutorialStep < 1 { return }

        HapticsManager.tap()
        audio.click()
        hintPair = nil

        switch engine.tap(pos) {
        case .ignored:
            HapticsManager.invalid()
        case .deselected:
            selected = nil
        case .selected(let pos):
            selected = pos
            HapticsManager.cardLift()
        case .matched(let a, let b, let won):
            startTimerIfNeeded()
            moves += 1
            applyCombo(for: a, b: b)
            selected = nil
            flashPair = (a, b)
            audio.cardPlace()
            HapticsManager.cardDrop()
            bumpBoard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.flashPair = nil
            }

            if rules.rushDuration != nil {
                score += 100 * max(1, combo)
                if won {
                    boardsCleared += 1
                    let config = progress.levelConfig(for: mode)
                    engine = GlyphLinkEngine(
                        mode: mode,
                        levelConfig: config,
                        seed: (dailySeed ?? UInt64.random(in: 1...UInt64.max)) &+ UInt64(boardsCleared)
                    )
                    bumpBoard()
                    audio.cardShuffle()
                }
            } else if won {
                resolveWin()
            }
        }
        bumpBoard()
    }

    private func resolveWin() {
        starsEarned = AscentProgression.computeStars(
            mode: mode,
            moves: moves,
            comboPeak: comboPeak,
            elapsed: elapsed,
            score: score
        )
        xpGained = AscentProgression.xpReward(
            mode: mode,
            level: levelConfig.level,
            stars: starsEarned,
            comboPeak: comboPeak,
            score: score
        )
        if mode.usesScoreLeaderboard {
            isNewBestScore = progress.recordRushScore(mode: mode, score: score, moves: moves)
        } else {
            isNewBestTime = progress.recordWin(mode: mode, elapsed: elapsed, moves: moves)
        }
        levelUpResult = progress.grantXP(mode: mode, stars: starsEarned, comboPeak: comboPeak, score: score)
        flushSessionTime()
        showWin = true
        audio.win()
    }

    private func tapTutorialPractice(_ pos: GridPos) {
        guard let target = hintPair else { return }
        let expected = Set([target.0, target.1])
        guard expected.contains(pos) else {
            HapticsManager.invalid()
            message = L10n.s("tutorial_tap_highlighted")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in self?.message = nil }
            return
        }

        HapticsManager.tap()
        switch engine.tap(pos) {
        case .ignored:
            break
        case .deselected:
            selected = nil
        case .selected(let p):
            selected = p
            HapticsManager.cardLift()
        case .matched(let a, let b, _):
            tutorialPracticeDone = true
            tutorialStep = 2
            selected = nil
            flashPair = (a, b)
            audio.cardPlace()
            HapticsManager.cardDrop()
            bumpBoard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.flashPair = nil
            }
        }
        bumpBoard()
    }

    func advanceTutorial() {
        if tutorialStep == 0 {
            tutorialStep = 1
            prepareTutorialHint()
        } else if tutorialStep >= mode.tutorialSteps.count - 1 || tutorialPracticeDone {
            completeTutorial()
        } else {
            tutorialStep += 1
        }
    }

    func skipTutorial() { completeTutorial() }

    private func completeTutorial() {
        defaults.set(true, forKey: mode.tutorialStorageKey)
        showTutorial = false
        tutorialStep = 0
        tutorialPracticeDone = false
        newGame()
    }

    private func prepareTutorialHint() {
        if let hint = engine.hint() {
            hintPair = hint
        }
    }

    private func applyCombo(for a: GridPos, b: GridPos) {
        if rules.requiresChain, !lastChainCells.isEmpty {
            let adjacent = isAdjacent(to: lastChainCells, pos: a) || isAdjacent(to: lastChainCells, pos: b)
            combo = adjacent ? combo + 1 : 1
        } else {
            combo += 1
        }
        comboPeak = max(comboPeak, combo)
        lastChainCells = [a, b]
    }

    private func isAdjacent(to cells: Set<GridPos>, pos: GridPos) -> Bool {
        for c in cells {
            let dr = abs(c.row - pos.row)
            let dc = abs(c.col - pos.col)
            if dr + dc == 1 { return true }
        }
        return false
    }

    private func finishRush() {
        timer?.invalidate()
        timer = nil
        starsEarned = AscentProgression.computeStars(mode: mode, moves: moves, comboPeak: comboPeak, elapsed: elapsed, score: score)
        xpGained = AscentProgression.xpReward(mode: mode, level: levelConfig.level, stars: starsEarned, comboPeak: comboPeak, score: score)
        isNewBestScore = progress.recordRushScore(mode: mode, score: score, moves: moves)
        levelUpResult = progress.grantXP(mode: mode, stars: starsEarned, comboPeak: comboPeak, score: score)
        flushSessionTime()
        showWin = true
        audio.win()
    }

    private func finishPressureFail() {
        timer?.invalidate()
        timer = nil
        message = L10n.s("pressure_failed")
        progress.recordAbandon()
        flushSessionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.newGame()
            self?.message = nil
        }
    }

    func undo() {
        if engine.undo() {
            combo = max(0, combo - 1)
            moves = max(0, moves - 1)
            selected = nil
            lastChainCells = []
            audio.cardSlide()
            bumpBoard()
        }
    }

    func showHint() {
        if let hint = engine.hint() {
            hintPair = hint
            audio.tap()
            HapticsManager.tap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.hintPair = nil
            }
        } else if rules.autoReshuffle {
            message = L10n.s("no_matches_shuffle")
            engine.reshuffleRemaining()
            bumpBoard()
        } else {
            message = L10n.s("no_matches_tap_shuffle")
            audio.tap()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.message = nil
        }
    }

    func reshuffle() {
        engine.reshuffleRemaining()
        combo = 0
        lastChainCells = []
        audio.cardShuffle()
        bumpBoard()
    }

    var formattedTime: String {
        if rules.rushDuration != nil {
            let s = Int(rushRemaining)
            return String(format: "%02d:%02d", s / 60, s % 60)
        }
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var hudSecondary: String {
        if mode.matchStyle == .sumPairs {
            return L10n.s("sum_target_fmt", rules.sumTarget)
        }
        if rules.rushDuration != nil {
            return L10n.s("score_fmt", score)
        }
        var parts = ["· \(moves)"]
        if combo > 1 { parts.append("· x\(combo)") }
        return parts.joined()
    }

    var pressureHUD: String? {
        guard rules.pressureLimit != nil else { return nil }
        let s = Int(pressureRemaining)
        return L10n.s("pressure_fmt", s / 60, s % 60)
    }
}
