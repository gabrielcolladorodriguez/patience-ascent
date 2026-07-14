import SwiftUI

struct GravityBlockGameView: View {
    @StateObject private var session: GravityBlockSessionViewModel
    @Binding var route: AppRoute
    @State private var showRankings = false
    @State private var showConfetti = false
    @State private var comboPulse = false

    init(route: Binding<AppRoute>, seed: UInt64? = nil) {
        _route = route
        _session = StateObject(wrappedValue: GravityBlockSessionViewModel(seed: seed))
    }

    private let theme = SolitaireMode.gravityBlocks.theme
    private let gridSize = GravityBlockEngine.size

    var body: some View {
        ZStack {
            GameBackground(theme: theme)

            VStack(spacing: 10) {
                header
                boardArea
                    .offset(x: session.boardShake)
                trayArea
                footer
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            if session.lastClear.total > 0 {
                lineClearBanner
            }

            if showConfetti {
                ConfettiView().ignoresSafeArea()
            }

            if session.showGameOverSheet {
                gameOverOverlay
            }
        }
        .onAppear { AudioManager.shared.startGameMusic() }
        .sheet(isPresented: $showRankings) { AscentTop100View() }
        .onChange(of: session.lastClear.total) { cleared in
            guard cleared > 0 else { return }
            comboPulse = true
            if cleared >= 2 || session.combo >= 2 {
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { showConfetti = false }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { comboPulse = false }
        }
    }

    private var header: some View {
        HStack {
            Button {
                AudioManager.shared.click()
                route = .menu
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.textOnGreen)
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.s("score_label"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textMutedOnGreen)
                Text(L10n.s("score_fmt", session.score))
                    .font(.title2.weight(.black).monospacedDigit())
                    .foregroundStyle(AppTheme.gold)
                    .contentTransition(.numericText())
            }

            Spacer()

            Text(L10n.s("wave_fmt", session.wave))
                .font(.caption.weight(.black))
                .foregroundStyle(theme.accentLight)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(AppTheme.panelFillStrong))

            if session.combo > 1 {
                Text(L10n.s("combo_fmt", session.combo))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(AppTheme.panelFillStrong))
                    .scaleEffect(comboPulse ? 1.15 : 1)
                    .animation(.spring(response: 0.25), value: comboPulse)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text(L10n.s("best_label"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textMutedOnGreen)
                Text(L10n.s("score_fmt", ProgressStore.shared.bestScore))
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppTheme.textOnGreen)
            }
        }
    }

    private var boardArea: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let cell = side / CGFloat(gridSize)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.tableSurface)
                    .shadow(color: theme.accent.opacity(0.25), radius: 12, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [theme.tableFrame, theme.tableBorder],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )

                VStack(spacing: 2) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                cellView(at: GridPos(row: row, col: col), cellSize: cell - 2)
                            }
                        }
                    }
                }
                .padding(6)
            }
            .frame(width: side, height: side)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxHeight: 380)
    }

    @ViewBuilder
    private func cellView(at pos: GridPos, cellSize: CGFloat) -> some View {
        let filled = session.grid[pos.row][pos.col]
        let isPreview = previewSet.contains(pos)

        RoundedRectangle(cornerRadius: 6)
            .fill(cellFill(filled: filled, preview: isPreview))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isPreview ? AppTheme.gold : Color.white.opacity(filled == nil ? 0.06 : 0.28),
                        lineWidth: isPreview ? 2.5 : 1
                    )
            )
            .shadow(color: filled != nil ? BlockPalette.color(for: filled!.colorIndex).opacity(0.35) : .clear, radius: 3, y: 2)
            .contentShape(Rectangle())
            .onTapGesture {
                if session.selectedTrayIndex != nil {
                    session.updatePreview(at: pos)
                    session.place(at: pos)
                }
            }
    }

    private var previewSet: Set<GridPos> {
        guard let anchor = session.previewAnchor,
              let idx = session.selectedTrayIndex,
              let piece = session.tray[idx] else { return [] }
        return session.previewCells(for: piece, anchor: anchor)
    }

    private func cellFill(filled: BlockCell?, preview: Bool) -> Color {
        if let filled {
            return BlockPalette.color(for: filled.colorIndex)
        }
        if preview {
            return AppTheme.gold.opacity(0.4)
        }
        return Color.white.opacity(0.05)
    }

    private var trayArea: some View {
        HStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { index in
                traySlot(index: index)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func traySlot(index: Int) -> some View {
        let piece = session.tray[index]
        let selected = session.selectedTrayIndex == index

        Button {
            if piece != nil { session.selectTray(index) }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(piece == nil ? 0.04 : 0.1))
                    .frame(width: 96, height: 96)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? AppTheme.gold : AppTheme.panelStroke, lineWidth: selected ? 3 : 1)
                    )
                    .shadow(color: selected ? AppTheme.gold.opacity(0.35) : .clear, radius: 8)

                if let piece {
                    pieceShapeView(piece: piece, cell: 22)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(piece == nil)
        .opacity(piece == nil ? 0.3 : 1)
        .scaleEffect(selected ? 1.06 : 1)
        .animation(.spring(response: 0.25), value: selected)
    }

    private func pieceShapeView(piece: BlockPiece, cell: CGFloat) -> some View {
        let bounds = pieceBounds(piece)
        return ZStack {
            ForEach(Array(piece.cells.enumerated()), id: \.offset) { _, c in
                RoundedRectangle(cornerRadius: 5)
                    .fill(BlockPalette.color(for: piece.colorIndex))
                    .frame(width: cell - 2, height: cell - 2)
                    .offset(
                        x: CGFloat(c.col - bounds.minCol) * cell - CGFloat(bounds.width) * cell / 2 + cell / 2,
                        y: CGFloat(c.row - bounds.minRow) * cell - CGFloat(bounds.height) * cell / 2 + cell / 2
                    )
            }
        }
        .frame(width: CGFloat(bounds.width) * cell, height: CGFloat(bounds.height) * cell)
    }

    private struct PieceBounds {
        let minRow: Int
        let minCol: Int
        let width: Int
        let height: Int
    }

    private func pieceBounds(_ piece: BlockPiece) -> PieceBounds {
        let rows = piece.cells.map(\.row)
        let cols = piece.cells.map(\.col)
        let minR = rows.min() ?? 0
        let minC = cols.min() ?? 0
        let maxR = rows.max() ?? 0
        let maxC = cols.max() ?? 0
        return PieceBounds(minRow: minR, minCol: minC, width: maxC - minC + 1, height: maxR - minR + 1)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            AppButton(title: L10n.s("undo"), systemImage: "arrow.uturn.backward", style: .secondary) {
                session.undo()
            }
            AppButton(title: L10n.s("top100_title"), systemImage: "list.number", style: .compact) {
                showRankings = true
            }
            AppButton(title: L10n.s("new_game"), systemImage: "arrow.clockwise", style: .compact) {
                session.restart()
            }
        }
    }

    private var lineClearBanner: some View {
        VStack {
            Text(clearBannerText)
                .font(.title3.weight(.black))
                .foregroundStyle(AppTheme.gold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.black.opacity(0.5)))
                .shadow(color: AppTheme.gold.opacity(0.45), radius: 14)
            Spacer()
        }
        .padding(.top, 100)
        .allowsHitTesting(false)
    }

    private var clearBannerText: String {
        let c = session.lastClear
        if c.rows > 0 && c.columns > 0 {
            return L10n.s("clear_rows_cols_fmt", c.rows, c.columns)
        }
        return L10n.s("lines_cleared_fmt", c.total)
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            if session.isNewBest { ConfettiView().ignoresSafeArea() }

            VStack(spacing: 16) {
                Text(L10n.s("game_over"))
                    .font(AppTheme.titleFont(30))
                    .foregroundStyle(AppTheme.textOnGreen)

                Text(L10n.s("score_fmt", session.score))
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.gold)

                if session.isNewBest {
                    Text(L10n.s("new_best"))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.success)
                }

                AppButton(title: L10n.s("top100_title"), systemImage: "trophy.fill", style: .secondary) {
                    showRankings = true
                }
                AppButton(title: L10n.s("play_again"), systemImage: "play.fill", style: .gold) {
                    session.restart()
                }
                AppButton(title: L10n.s("menu"), systemImage: "house.fill", style: .secondary) {
                    route = .menu
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.feltMid.opacity(0.95))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppTheme.panelStroke))
            )
            .padding(24)
        }
    }
}
