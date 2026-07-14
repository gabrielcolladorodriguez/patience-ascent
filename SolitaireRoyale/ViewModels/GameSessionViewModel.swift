import Foundation
import SwiftUI

@MainActor
final class GameSessionViewModel: ObservableObject {
    @Published private(set) var engine: SolitaireEngine
    @Published var selectedPile: PileRef?
    @Published var hintPiles: (PileRef, PileRef)?
    @Published var message: String?
    @Published var showWin = false
    @Published var moves = 0
    @Published var elapsed: TimeInterval = 0
    @Published var combo = 0
    @Published var comboPeak = 0
    @Published private(set) var boardVersion = 0
    @Published var isNewBestTime = false
    @Published var draggingFrom: PileRef?

    let mode: SolitaireMode
    let dailySeed: UInt64?
    private var timer: Timer?
    private var timerStarted = false
    private var sessionTimeReported = false
    private let progress = ProgressStore.shared
    private let audio = AudioManager.shared

    init(mode: SolitaireMode, dailySeed: UInt64? = nil) {
        self.mode = mode
        self.dailySeed = dailySeed
        self.engine = EngineFactory.make(for: mode)
        self.engine.reset()
        audio.cardShuffle()
        HapticsManager.prepare()
    }

    deinit {
        timer?.invalidate()
    }

    func flushSessionTime() {
        guard !sessionTimeReported, elapsed > 0 else { return }
        sessionTimeReported = true
        progress.addSessionTime(elapsed)
    }

    var maxTableauDepth: Int {
        engine.allPileRefs()
            .filter { $0.kind == .tableau }
            .map { pileCards(for: $0).count }
            .max() ?? 1
    }

    private func bumpBoard() {
        boardVersion += 1
        objectWillChange.send()
    }

    private func startTimerIfNeeded() {
        guard !timerStarted else { return }
        timerStarted = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.elapsed += 1 }
        }
    }

    func newGame() {
        engine.reset()
        selectedPile = nil
        hintPiles = nil
        message = nil
        showWin = false
        isNewBestTime = false
        moves = 0
        elapsed = 0
        combo = 0
        comboPeak = 0
        sessionTimeReported = false
        timerStarted = false
        timer?.invalidate()
        timer = nil
        bumpBoard()
        audio.cardShuffle()
    }

    func pileCards(for ref: PileRef) -> [PlayingCard] {
        if let pyramid = engine as? PyramidEngine, ref.kind == .tableau {
            if let card = pyramid.pyramid[ref.index] { return [card] }
            return []
        }
        if let tri = engine as? TriPeaksEngine, ref.kind == .tableau {
            if let card = tri.peaks[ref.index] { return [card] }
            return []
        }
        return engine.pile(ref).cards
    }

    func tapPile(_ ref: PileRef) {
        HapticsManager.tap()
        audio.click()

        if ref.kind == .stock {
            if engine.drawFromStock() {
                startTimerIfNeeded()
                registerMove(success: true, stockDraw: true)
                tryAutoComplete()
            } else {
                HapticsManager.invalid()
            }
            return
        }

        if let selected = selectedPile {
            if selected == ref {
                selectedPile = nil
                return
            }
            attemptMove(from: selected, to: ref)
            return
        }

        if canSelect(ref) {
            selectedPile = ref
            HapticsManager.cardLift()
        }
    }

    func dropCard(from: PileRef, to: PileRef) {
        attemptMove(from: from, to: to)
        draggingFrom = nil
    }

    private func attemptMove(from: PileRef, to: PileRef) {
        if engine.move(from: from, to: to) {
            startTimerIfNeeded()
            registerMove(success: true)
            selectedPile = nil
            hintPiles = nil
            bumpBoard()
            tryAutoComplete()
            checkWin()
        } else if canSelect(to) && from != to {
            selectedPile = to
            HapticsManager.tap()
        } else {
            message = L10n.s("invalid_move")
            combo = 0
            HapticsManager.invalid()
        }
    }

    func canSelect(_ ref: PileRef) -> Bool {
        if ref.kind == .stock { return true }
        return !pileCards(for: ref).isEmpty
    }

    private func registerMove(success: Bool, stockDraw: Bool = false) {
        moves += 1
        if success {
            combo += 1
            comboPeak = max(comboPeak, combo)
            audio.cardPlace()
            HapticsManager.cardDrop()
        }
        bumpBoard()
    }

    func undo() {
        if engine.undo() {
            combo = 0
            moves = max(0, moves - 1)
            audio.cardSlide()
            bumpBoard()
        }
    }

    func showHint() {
        if let hint = engine.hint() {
            hintPiles = hint
            audio.tap()
            HapticsManager.tap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.hintPiles = nil
            }
        } else {
            message = L10n.s("no_moves")
        }
    }

    func tryAutoComplete() {
        guard UserDefaults.standard.object(forKey: "autoComplete") as? Bool ?? true else { return }
        guard let klondike = engine as? KlondikeEngine else { return }

        let stockEmpty = klondike.stock.isEmpty && klondike.waste.isEmpty
        let allFaceUp = klondike.tableau.allSatisfy { pile in
            pile.cards.allSatisfy(\.faceUp) || pile.isEmpty
        }
        guard stockEmpty && allFaceUp else { return }

        var moved = true
        while moved {
            moved = false
            for col in 0..<7 {
                guard klondike.tableau[col].top != nil else { continue }
                for f in 0..<4 {
                    let from = PileRef(kind: .tableau, index: col)
                    let to = PileRef(kind: .foundation, index: f)
                    if engine.move(from: from, to: to) {
                        moved = true
                        registerMove(success: true)
                        bumpBoard()
                        break
                    }
                }
            }
        }
        checkWin()
    }

    private func checkWin() {
        if engine.isWon {
            isNewBestTime = progress.recordWin(mode: mode, elapsed: elapsed, moves: moves)
            flushSessionTime()
            showWin = true
            audio.win()
        }
    }

    var formattedTime: String {
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        return String(format: "%02d:%02d", m, s)
    }

    func validDropTargets(from: PileRef) -> [PileRef] {
        engine.allPileRefs().filter { engine.canMove(from: from, to: $0) && $0 != from }
    }
}
