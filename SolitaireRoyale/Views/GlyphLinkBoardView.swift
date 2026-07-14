import SwiftUI

struct GlyphLinkBoardView: View {
    @StateObject var session: GlyphLinkSessionViewModel
    @Binding var route: AppRoute
    @State private var showHelp = false

    private var mode: SolitaireMode { session.mode }
    private var theme: ModeTheme { session.theme }

    var body: some View {
        ZStack {
            GameBackground(theme: theme)
            VStack(spacing: 4) {
                gameHUD
                GameTableSurface(theme: theme) {
                    GeometryReader { geo in
                        let tile = DeviceLayout.fittedGlyphTileSize(boardSize: geo.size)
                        puzzleGrid(tile: tile)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding(6)
                    }
                }
                controlBar
            }

            if let msg = session.message {
                Text(msg)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.gold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppTheme.panelFillStrong))
                    .transition(.opacity)
            }

            if session.showTutorial {
                ModeTutorialOverlay(session: session, theme: theme)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(5)
            }

            if session.showWin {
                WinCelebrationOverlay(
                    time: session.formattedTime,
                    moves: session.moves,
                    score: session.mode.usesScoreLeaderboard ? session.score : nil,
                    isNewBest: session.mode.usesScoreLeaderboard ? session.isNewBestScore : session.isNewBestTime,
                    mode: mode,
                    stars: session.starsEarned,
                    xpGained: session.xpGained,
                    levelUp: session.levelUpResult,
                    theme: theme,
                    onPlayAgain: { session.newGame() },
                    onMenu: {
                        AudioManager.shared.stopMusic()
                        AudioManager.shared.startMenuMusic()
                        route = .menu
                    }
                )
            }
        }
        .id(session.boardVersion)
        .onAppear { AudioManager.shared.startGameMusic() }
        .onDisappear {
            session.flushSessionTime()
            if !session.showWin {
                AudioManager.shared.stopMusic()
                AudioManager.shared.startMenuMusic()
            }
        }
        .sheet(isPresented: $showHelp) {
            QuickHelpSheet(mode: mode, theme: theme)
        }
    }

    private var gameHUD: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                NavBackButton {
                    session.flushSessionTime()
                    if session.moves > 0 && !session.showWin {
                        ProgressStore.shared.recordAbandon()
                    }
                    AudioManager.shared.stopMusic()
                    AudioManager.shared.startMenuMusic()
                    route = .menu
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: mode.iconName)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(theme.gold)
                        Text(mode.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.textOnGreen)
                        Text(L10n.s("diff_level_fmt", session.levelConfig.level))
                            .font(.caption2.weight(.black))
                            .foregroundStyle(theme.gold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(theme.accent.opacity(0.35)))
                    }
                    HStack(spacing: 8) {
                        Label(session.formattedTime, systemImage: session.mode.usesScoreLeaderboard ? "timer" : "clock")
                        Text(session.hudSecondary)
                            .foregroundStyle(session.combo > 1 ? theme.gold : AppTheme.textMutedOnGreen)
                        if let pressure = session.pressureHUD {
                            Text(pressure)
                                .foregroundStyle(session.pressureRemaining < 30 ? AppTheme.danger : theme.accentLight)
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textMutedOnGreen)
                }
                Spacer()
                ComboMeterView(combo: session.combo, theme: theme)
                Button {
                    AudioManager.shared.click()
                    showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(theme.gold)
                        .frame(width: AppTheme.minTap, height: AppTheme.minTap)
                }
                .buttonStyle(.plain)
            }
            XPProgressBar(
                progress: ProgressStore.shared.xpProgress(for: mode),
                level: session.levelConfig.level,
                theme: theme,
                compact: true
            )
            .padding(.horizontal, 4)
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

    private func puzzleGrid(tile: CGFloat) -> some View {
        let gap: CGFloat = max(3, tile * 0.08)
        return VStack(spacing: gap) {
            ForEach(0..<GlyphLinkEngine.rows, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<GlyphLinkEngine.cols, id: \.self) { col in
                        let pos = GridPos(row: row, col: col)
                        puzzleCell(pos: pos, tile: tile)
                    }
                }
            }
        }
    }

    private func puzzleCell(pos: GridPos, tile: CGFloat) -> some View {
        let cell = session.engine.cell(at: pos)
        let highlighted = session.selected == pos
            || session.hintPair?.0 == pos
            || session.hintPair?.1 == pos
            || session.flashPair?.0 == pos
            || session.flashPair?.1 == pos
        let accent = cell?.accent.color ?? theme.accent

        return Button {
            session.tap(pos)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: tile * 0.2)
                    .fill(
                        cell == nil
                            ? AnyShapeStyle(Color.white.opacity(0.06))
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color.white, accent.opacity(0.14)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: tile * 0.2)
                            .stroke(
                                highlighted
                                    ? AnyShapeStyle(LinearGradient(colors: [theme.gold, theme.accentLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    : AnyShapeStyle(accent.opacity(0.38)),
                                lineWidth: highlighted ? 3 : 1.2
                            )
                    )
                    .shadow(color: highlighted ? theme.gold.opacity(0.45) : .black.opacity(0.1), radius: highlighted ? 8 : 3, y: 2)
                    .overlay {
                        if highlighted && session.combo > 2 {
                            RoundedRectangle(cornerRadius: tile * 0.2)
                                .stroke(theme.accentLight.opacity(0.5), lineWidth: 2)
                                .blur(radius: 4)
                        }
                    }

                if let cell {
                    cellContent(cell, tile: tile, accent: accent)
                }
            }
            .frame(width: tile, height: tile)
            .scaleEffect(highlighted ? 1.05 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: highlighted)
        }
        .buttonStyle(.plain)
        .disabled(cell == nil || (session.showTutorial && session.tutorialStep < 1))
        .opacity(cell == nil ? 0.35 : 1)
    }

    @ViewBuilder
    private func cellContent(_ cell: PuzzleCell, tile: CGFloat, accent: Color) -> some View {
        if let symbol = cell.symbolName {
            Image(systemName: symbol)
                .font(.system(size: tile * 0.44, weight: .bold))
                .foregroundStyle(accent)
                .shadow(color: accent.opacity(0.45), radius: 5)
        } else {
            Text(cell.display)
                .font(.system(size: tile * 0.46, weight: .black, design: .rounded))
                .foregroundStyle(accent)
                .shadow(color: accent.opacity(0.35), radius: 4)
        }
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
                            .stroke(theme.gold.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
