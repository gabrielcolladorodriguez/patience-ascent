import SwiftUI

struct GlyphLinkBoardView: View {
    @StateObject var session: GlyphLinkSessionViewModel
    @Binding var route: AppRoute
    @State private var showHelp = false

    private var mode: SolitaireMode { session.mode }

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 4) {
                gameHUD
                GameTableSurface {
                    GeometryReader { geo in
                        let tile = DeviceLayout.fittedGlyphTileSize(boardSize: geo.size)
                        glyphGrid(tile: tile)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding(6)
                    }
                }
                controlBar
            }

            if let msg = session.message {
                Text(msg)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppTheme.panelFillStrong))
                    .transition(.opacity)
            }

            if session.showWin {
                WinCelebrationOverlay(
                    time: session.formattedTime,
                    moves: session.moves,
                    score: session.mode.usesScoreLeaderboard ? session.score : nil,
                    isNewBest: session.mode.usesScoreLeaderboard ? session.isNewBestScore : session.isNewBestTime,
                    mode: mode,
                    onPlayAgain: { session.newGame() },
                    onMenu: {
                        AudioManager.shared.stopMusic()
                        AudioManager.shared.playMusic("menu_music.wav")
                        route = .menu
                    }
                )
            }
        }
        .id(session.boardVersion)
        .onAppear { AudioManager.shared.playMusic("game_music.wav") }
        .onDisappear {
            session.flushSessionTime()
            if !session.showWin {
                AudioManager.shared.stopMusic()
                AudioManager.shared.playMusic("menu_music.wav")
            }
        }
        .sheet(isPresented: $showHelp) {
            QuickHelpSheet(mode: mode)
        }
    }

    private var gameHUD: some View {
        HStack(spacing: 10) {
            NavBackButton {
                session.flushSessionTime()
                if session.moves > 0 && !session.showWin {
                    ProgressStore.shared.recordAbandon()
                }
                route = .menu
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(mode.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    if mode == .glyphLink { NewBadge() }
                }
                HStack(spacing: 8) {
                    Label(session.formattedTime, systemImage: session.mode.usesScoreLeaderboard ? "timer" : "clock")
                    Text(session.hudSecondary)
                        .foregroundStyle(session.combo > 1 ? AppTheme.gold : AppTheme.textMutedOnGreen)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textMutedOnGreen)
            }
            Spacer()
            Button {
                AudioManager.shared.click()
                showHelp = true
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: AppTheme.minTap, height: AppTheme.minTap)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }

    private var controlBar: some View {
        HStack(spacing: 8) {
            actionButton(title: L10n.s("hint"), icon: "lightbulb.fill") { session.showHint() }
            actionButton(title: L10n.s("undo"), icon: "arrow.uturn.backward") { session.undo() }
            actionButton(title: L10n.s("shuffle"), icon: "shuffle") { session.reshuffle() }
            actionButton(title: L10n.s("new_game"), icon: "arrow.clockwise") { session.newGame() }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func glyphGrid(tile: CGFloat) -> some View {
        let gap: CGFloat = max(3, tile * 0.08)
        return VStack(spacing: gap) {
            ForEach(0..<GlyphLinkEngine.rows, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<GlyphLinkEngine.cols, id: \.self) { col in
                        let pos = GridPos(row: row, col: col)
                        glyphCell(pos: pos, tile: tile)
                    }
                }
            }
        }
    }

    private func glyphCell(pos: GridPos, tile: CGFloat) -> some View {
        let kind = session.engine.glyph(at: pos)
        let highlighted = session.selected == pos
            || session.hintPair?.0 == pos
            || session.hintPair?.1 == pos
            || session.flashPair?.0 == pos
            || session.flashPair?.1 == pos

        return Button {
            session.tap(pos)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: tile * 0.2)
                    .fill(
                        kind == nil
                            ? AnyShapeStyle(Color.white.opacity(0.06))
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color.white, kind!.color.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: tile * 0.2)
                            .stroke(
                                highlighted
                                    ? AnyShapeStyle(AppTheme.goldShineGradient)
                                    : AnyShapeStyle(kind?.color.opacity(0.35) ?? Color.white.opacity(0.15)),
                                lineWidth: highlighted ? 3 : 1.2
                            )
                    )
                    .shadow(color: highlighted ? AppTheme.gold.opacity(0.4) : .black.opacity(0.1), radius: highlighted ? 8 : 3, y: 2)

                if let kind {
                    Image(systemName: kind.symbol)
                        .font(.system(size: tile * 0.44, weight: .bold))
                        .foregroundStyle(kind.color)
                        .shadow(color: kind.color.opacity(0.45), radius: 5)
                }
            }
            .frame(width: tile, height: tile)
            .scaleEffect(highlighted ? 1.04 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: highlighted)
        }
        .buttonStyle(.plain)
        .disabled(kind == nil)
        .opacity(kind == nil ? 0.35 : 1)
    }

    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            AudioManager.shared.click()
            action()
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(AppTheme.textOnGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.gold.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
