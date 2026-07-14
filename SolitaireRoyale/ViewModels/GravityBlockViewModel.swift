import Foundation
import SwiftUI

@MainActor
final class GravityBlockSessionViewModel: ObservableObject {
    @Published private(set) var grid: [[BlockCell?]]
    @Published private(set) var tray: [BlockPiece?]
    @Published private(set) var score = 0
    @Published private(set) var combo = 0
    @Published private(set) var wave = 1
    @Published private(set) var isGameOver = false
    @Published private(set) var lastClear = LineClearResult(rows: 0, columns: 0, points: 0)
    @Published private(set) var boardShake: CGFloat = 0
    @Published var selectedTrayIndex: Int?
    @Published var previewAnchor: GridPos?
    @Published var showGameOverSheet = false
    @Published var isNewBest = false

    private var engine: GravityBlockEngine
    private var sessionStart = Date()
    private let theme = SolitaireMode.gravityBlocks.theme

    init(seed: UInt64? = nil) {
        let created = GravityBlockEngine(seed: seed)
        engine = created
        grid = created.grid
        tray = created.tray
        score = created.score
        combo = created.combo
        wave = created.wave
        isGameOver = created.isGameOver
        lastClear = created.lastClear
    }

    var themeMode: ModeTheme { theme }
    var lastLinesCleared: Int { lastClear.total }

    func syncFromEngine() {
        grid = engine.grid
        tray = engine.tray
        score = engine.score
        combo = engine.combo
        wave = engine.wave
        isGameOver = engine.isGameOver
        lastClear = engine.lastClear
    }

    func selectTray(_ index: Int) {
        guard index >= 0, index < tray.count, tray[index] != nil else { return }
        selectedTrayIndex = selectedTrayIndex == index ? nil : index
        previewAnchor = nil
        AudioManager.shared.tap()
        HapticsManager.tap()
    }

    func updatePreview(at anchor: GridPos) {
        guard let idx = selectedTrayIndex, let piece = tray[idx] else {
            previewAnchor = nil
            return
        }
        previewAnchor = engine.canPlace(piece, at: anchor) ? anchor : nil
    }

    func place(at anchor: GridPos) {
        guard let idx = selectedTrayIndex else { return }
        guard engine.place(idx, at: anchor) else {
            HapticsManager.invalid()
            return
        }

        syncFromEngine()
        selectedTrayIndex = nil
        previewAnchor = nil

        if lastClear.total > 0 {
            AudioManager.shared.cardPlace()
            HapticsManager.cardDrop()
            triggerShake()
            if combo > 1 { HapticsManager.coin() }
        } else {
            AudioManager.shared.tap()
            HapticsManager.tap()
        }

        if isGameOver {
            finishSession()
        }
    }

    func undo() {
        guard engine.undo() else { return }
        syncFromEngine()
        isGameOver = false
        showGameOverSheet = false
        AudioManager.shared.cardSlide()
    }

    func restart() {
        engine = GravityBlockEngine()
        syncFromEngine()
        selectedTrayIndex = nil
        previewAnchor = nil
        showGameOverSheet = false
        isNewBest = false
        sessionStart = Date()
        AudioManager.shared.startGameMusic()
        HapticsManager.tap()
    }

    func previewCells(for piece: BlockPiece, anchor: GridPos) -> Set<GridPos> {
        Set(piece.cells.map { GridPos(row: anchor.row + $0.row, col: anchor.col + $0.col) })
    }

    private func triggerShake() {
        withAnimation(.default) { boardShake = 8 }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 80_000_000)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                boardShake = 0
            }
        }
    }

    func previewIsValid(at anchor: GridPos) -> Bool {
        guard let idx = selectedTrayIndex, let piece = tray[idx] else { return false }
        return engine.canPlace(piece, at: anchor)
    }

    private func finishSession() {
        let elapsed = Date().timeIntervalSince(sessionStart)
        isNewBest = ProgressStore.shared.recordGameOver(score: score, elapsed: elapsed)
        showGameOverSheet = true
        if isNewBest {
            AudioManager.shared.win()
        } else {
            AudioManager.shared.playSFX("switch.wav")
        }
        HapticsManager.invalid()
    }
}
