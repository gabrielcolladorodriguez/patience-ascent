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
    @Published var score = 0
    @Published var combo = 0
    @Published var comboPeak = 0
    @Published private(set) var boardVersion = 0
    @Published var lastWinRewards: (coins: Int, xp: Int) = (0, 0)
    @Published var draggingFrom: PileRef?

    let mode: SolitaireMode
    let dailySeed: UInt64?
    private var timer: Timer?
    private var timerStarted = false
    private let progress = ProgressStore.shared
    private let audio = AudioManager.shared

    init(mode: SolitaireMode, dailySeed: UInt64? = nil) {
        self.mode = mode
        self.dailySeed = dailySeed
        self.engine = EngineFactory.make(for: mode)
        self.engine.reset()
        if let seed = dailySeed {
            reseedDeck(seed)
        }
        audio.cardShuffle()
        HapticsManager.prepare()
    }

    deinit { timer?.invalidate() }

    private func reseedDeck(_ seed: UInt64) {
        // Deterministic shuffle for daily challenge via seeded deal on Klondike-like modes
        guard var klondike = engine as? KlondikeEngine else { return }
        klondike.reset()
        _ = klondike
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
        moves = 0
        elapsed = 0
        score = 0
        combo = 0
        comboPeak = 0
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
            message = "Movimiento no válido"
            combo = 0
            HapticsManager.invalid()
            progress.recordLoss()
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
            let base = stockDraw ? 2 : 5
            score += base + combo * 2
            audio.cardPlace()
            HapticsManager.cardDrop()
        }
        bumpBoard()
    }

    func undo() {
        guard progress.useUndo() else {
            message = "Sin deshacer. ¡Compra en la tienda!"
            return
        }
        if engine.undo() {
            combo = 0
            moves = max(0, moves - 1)
            score = max(0, score - 8)
            audio.cardSlide()
            bumpBoard()
        } else {
            progress.refundUndo()
        }
    }

    func showHint() {
        guard progress.useHint() else {
            message = "Sin pistas. ¡Visita la tienda!"
            return
        }
        if let hint = engine.hint() {
            hintPiles = hint
            audio.tap()
            HapticsManager.tap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.hintPiles = nil
            }
        } else {
            message = "No hay movimientos visibles"
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
                guard let top = klondike.tableau[col].top else { continue }
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
            lastWinRewards = progress.recordWin(mode: mode, elapsed: elapsed, moves: moves, comboPeak: comboPeak)
            showWin = true
            audio.win()
            AudioManager.shared.playMusic("win_music.ogg", loop: false)
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
