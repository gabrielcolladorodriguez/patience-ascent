import SwiftUI

struct GameBoardView: View {
    @StateObject var session: GameSessionViewModel
    @Binding var route: AppRoute
    @State private var showHelp = false

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 4) {
                gameHUD
                GameTableSurface {
                    GeometryReader { geo in
                        let depth = session.maxTableauDepth
                        let cardW = DeviceLayout.fittedCardWidth(
                            for: session.mode,
                            boardSize: geo.size,
                            maxStackDepth: depth
                        )
                        boardContent(cardW: cardW, stackDepth: depth)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding(4)
                    }
                }
                controlBar
            }

            if session.showWin {
                WinCelebrationOverlay(
                    time: session.formattedTime,
                    moves: session.moves,
                    isNewBest: session.isNewBestTime,
                    mode: session.mode,
                    onPlayAgain: { session.newGame() },
                    onMenu: {
                        AudioManager.shared.stopMusic()
                        AudioManager.shared.startMenuMusic()
                        route = .menu
                    }
                )
                .transition(.opacity)
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
            QuickHelpSheet(mode: session.mode)
        }
    }

    private var gameHUD: some View {
        HStack(spacing: 10) {
            NavBackButton {
                session.flushSessionTime()
                progressAbandon()
                route = .menu
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(session.mode.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.textOnGreen)
                HStack(spacing: 8) {
                    Label(session.formattedTime, systemImage: "clock")
                    Text("· \(session.moves)")
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
            gameActionButton(title: L10n.s("hint"), icon: "lightbulb.fill") { session.showHint() }
            gameActionButton(title: L10n.s("undo"), icon: "arrow.uturn.backward") { session.undo() }
            gameActionButton(title: L10n.s("new_game"), icon: "arrow.clockwise") { session.newGame() }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func progressAbandon() {
        if session.moves > 0 && !session.showWin {
            ProgressStore.shared.recordAbandon()
        }
    }

    private func gameActionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            AudioManager.shared.click()
            action()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                Text(title)
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(AppTheme.textOnTable)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.tableBorder, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func boardContent(cardW: CGFloat, stackDepth: Int) -> some View {
        switch session.mode {
        case .klondike, .yukon:
            klondikeLayout(cardW: cardW, stackDepth: stackDepth)
        case .freeCell:
            freeCellLayout(cardW: cardW, stackDepth: stackDepth)
        case .spider, .fortyThieves:
            wideTableauLayout(columns: 10, cardW: cardW, stackDepth: stackDepth)
        case .pyramid:
            pyramidLayout(cardW: cardW)
        case .triPeaks:
            triPeaksLayout(cardW: cardW)
        case .golf:
            golfLayout(cardW: cardW)
        }
    }

    private func cardBackName() -> String { "card_back_green" }

    private func pileView(_ ref: PileRef, cardW: CGFloat, stacked: Bool = false, stackDepth: Int = 1) -> some View {
        let cards = session.pileCards(for: ref)
        let stackStep = DeviceLayout.stackOffset(for: cardW, depth: stackDepth)
        let highlighted = session.selectedPile == ref || session.hintPiles?.0 == ref || session.hintPiles?.1 == ref
        let lifted = session.selectedPile == ref
        let isDropTarget = session.draggingFrom.map { session.validDropTargets(from: $0).contains(ref) } ?? false

        return Button { session.tapPile(ref) } label: {
            ZStack(alignment: .top) {
                if cards.isEmpty {
                    CardFaceView(card: nil, cardBackName: cardBackName(), width: cardW, highlighted: highlighted || isDropTarget)
                        .opacity(0.35)
                } else if stacked {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { idx, card in
                        CardFaceView(
                            card: card,
                            cardBackName: cardBackName(),
                            width: cardW,
                            highlighted: highlighted && idx == cards.count - 1,
                            lifted: lifted && idx == cards.count - 1
                        )
                        .offset(y: CGFloat(idx) * stackStep)
                    }
                } else {
                    CardFaceView(card: cards.last, cardBackName: cardBackName(), width: cardW, highlighted: highlighted, lifted: lifted)
                }
            }
            .frame(
                width: cardW,
                height: stacked
                    ? DeviceLayout.cardHeight(for: cardW) + CGFloat(max(0, cards.count - 1)) * stackStep
                    : DeviceLayout.cardHeight(for: cardW)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isDropTarget ? AppTheme.accent : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .draggable(ref.code) {
            CardFaceView(card: cards.last, cardBackName: cardBackName(), width: cardW * 0.9, highlighted: true, lifted: true)
                .onAppear { session.draggingFrom = ref; HapticsManager.cardLift() }
        }
        .dropDestination(for: String.self) { items, _ in
            guard let code = items.first, let from = PileRef.decode(code) else { return false }
            session.dropCard(from: from, to: ref)
            return true
        }
    }

    private func klondikeLayout(cardW: CGFloat, stackDepth: Int) -> some View {
        let gap = DeviceLayout.columnSpacing(for: cardW, mode: .klondike)
        return VStack(spacing: gap) {
            HStack(spacing: gap) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
                Spacer(minLength: 0)
                ForEach(0..<4, id: \.self) { i in
                    pileView(PileRef(kind: .foundation, index: i), cardW: cardW)
                }
            }
            HStack(alignment: .top, spacing: gap) {
                ForEach(0..<7, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true, stackDepth: stackDepth)
                }
            }
        }
    }

    private func freeCellLayout(cardW: CGFloat, stackDepth: Int) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    pileView(PileRef(kind: .freeCell, index: i), cardW: cardW)
                }
                Spacer(minLength: 0)
                ForEach(0..<4, id: \.self) { i in
                    pileView(PileRef(kind: .foundation, index: i), cardW: cardW)
                }
            }
            HStack(alignment: .top, spacing: 6) {
                ForEach(0..<8, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true, stackDepth: stackDepth)
                }
            }
        }
    }

    private func wideTableauLayout(columns: Int, cardW: CGFloat, stackDepth: Int) -> some View {
        let gap = DeviceLayout.columnSpacing(for: cardW, mode: session.mode)
        return VStack(spacing: 6) {
            HStack(spacing: gap) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                if session.mode == .fortyThieves {
                    pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
                }
                Spacer(minLength: 0)
                if session.mode == .fortyThieves {
                    ForEach(0..<8, id: \.self) { i in
                        pileView(PileRef(kind: .foundation, index: i), cardW: cardW * 0.85)
                    }
                }
            }
            HStack(alignment: .top, spacing: gap) {
                ForEach(0..<columns, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true, stackDepth: stackDepth)
                }
            }
        }
    }

    private func pyramidLayout(cardW: CGFloat) -> some View {
        VStack(spacing: 4) {
            pyramidRows(cardW: cardW)
            HStack(spacing: 12) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
            }
        }
    }

    private func pyramidRows(cardW: CGFloat) -> some View {
        let engine = session.engine as? PyramidEngine
        return VStack(spacing: 2) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 2) {
                    let start = row * (row + 1) / 2
                    ForEach(0..<(row + 1), id: \.self) { offset in
                        let idx = start + offset
                        if let eng = engine, let card = eng.pyramid[idx] {
                            cardButton(card: card, ref: PileRef(kind: .tableau, index: idx), cardW: cardW)
                        } else {
                            Color.clear.frame(width: cardW, height: DeviceLayout.cardHeight(for: cardW))
                        }
                    }
                }
            }
        }
    }

    private func triPeaksLayout(cardW: CGFloat) -> some View {
        let engine = session.engine as? TriPeaksEngine
        let gap: CGFloat = 2
        return VStack(spacing: 6) {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cardW), spacing: gap), count: 7), spacing: gap) {
                ForEach(0..<28, id: \.self) { idx in
                    if let eng = engine, let card = eng.peaks[idx] {
                        cardButton(card: card, ref: PileRef(kind: .tableau, index: idx), cardW: cardW)
                    } else {
                        Color.clear.frame(width: cardW, height: DeviceLayout.cardHeight(for: cardW))
                    }
                }
            }
            HStack(spacing: 12) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
            }
        }
    }

    private func golfLayout(cardW: CGFloat) -> some View {
        let gap = DeviceLayout.columnSpacing(for: cardW, mode: .golf)
        return VStack(spacing: 8) {
            pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
            HStack(spacing: gap) {
                ForEach(0..<7, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW)
                }
            }
            pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
        }
    }

    private func cardButton(card: PlayingCard, ref: PileRef, cardW: CGFloat) -> some View {
        let highlighted = session.selectedPile == ref || session.hintPiles?.0 == ref || session.hintPiles?.1 == ref
        return Button { session.tapPile(ref) } label: {
            CardFaceView(card: card, cardBackName: cardBackName(), width: cardW, highlighted: highlighted)
        }
        .buttonStyle(.plain)
    }
}
