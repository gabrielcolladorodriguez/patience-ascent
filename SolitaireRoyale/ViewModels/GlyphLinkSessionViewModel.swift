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

    let mode: SolitaireMode
    let dailySeed: UInt64?
    private var timer: Timer?
    private var timerStarted = false
    private var sessionTimeReported = false
    private var lastChainCells: Set<GridPos> = []
    private var boardsCleared = 0
    private let progress = ProgressStore.shared
    private let audio = AudioManager.shared

    private var rules: GlyphLinkRules { mode.rules }

    init(mode: SolitaireMode = .glyphLink, dailySeed: UInt64? = nil) {
        self.mode = mode
        self.dailySeed = dailySeed
        self.engine = GlyphLinkEngine(seed: dailySeed, autoReshuffle: mode.rules.autoReshuffle)
        if let rush = mode.rules.rushDuration {
            rushRemaining = rush
        }
        audio.cardShuffle()
        HapticsManager.prepare()
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
        guard !timerStarted else { return }
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
        }
    }

    func newGame() {
        engine = GlyphLinkEngine(
            seed: dailySeed == nil ? nil : dailySeed! &+ UInt64(moves),
            autoReshuffle: rules.autoReshuffle
        )
        selected = nil
        hintPair = nil
        flashPair = nil
        message = nil
        showWin = false
        isNewBestTime = false
        isNewBestScore = false
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
        bumpBoard()
        audio.cardShuffle()
    }

    func tap(_ pos: GridPos) {
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
                    engine = GlyphLinkEngine(
                        seed: (dailySeed ?? UInt64.random(in: 1...UInt64.max)) &+ UInt64(boardsCleared),
                        autoReshuffle: true
                    )
                    bumpBoard()
                    audio.cardShuffle()
                }
            } else if won {
                isNewBestTime = progress.recordWin(mode: mode, elapsed: elapsed, moves: moves)
                flushSessionTime()
                showWin = true
                audio.win()
            }
        }
        bumpBoard()
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
        isNewBestScore = progress.recordRushScore(mode: mode, score: score, moves: moves)
        flushSessionTime()
        showWin = true
        audio.win()
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
        if mode.rules.rushDuration != nil {
            return L10n.s("score_fmt", score)
        }
        var parts = ["· \(moves)"]
        if combo > 1 { parts.append("· x\(combo)") }
        return parts.joined()
    }
}
