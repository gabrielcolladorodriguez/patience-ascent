import SwiftUI

struct GameBoardView: View {
    @StateObject var session: GameSessionViewModel
    @Binding var route: AppRoute
    @ObservedObject var progress = ProgressStore.shared
    @State private var showHelp = false
    @State private var showTip = true

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 6) {
                gameHUD
                if showTip {
                    GameTipBanner(text: session.mode.quickRules.first ?? session.mode.controlsHint) {
                        withAnimation { showTip = false }
                    }
                }
                GameTableSurface {
                    GeometryReader { geo in
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            boardContent(in: geo.size)
                                .padding(6)
                        }
                    }
                }
                controlBar
            }

            if session.showWin {
                WinCelebrationOverlay(
                    coinsEarned: session.lastWinRewards.coins,
                    xpEarned: session.lastWinRewards.xp,
                    onPlayAgain: { session.newGame() },
                    onMenu: {
                        AudioManager.shared.stopMusic()
                        AudioManager.shared.playMusic("menu_music.wav")
                        route = .menu
                    }
                )
                .transition(.opacity)
            }
        }
        .id(session.boardVersion)
        .onAppear { AudioManager.shared.playMusic("game_music.wav") }
        .onDisappear {
            if !session.showWin {
                AudioManager.shared.stopMusic()
                AudioManager.shared.playMusic("menu_music.wav")
            }
        }
        .sheet(isPresented: $showHelp) {
            QuickHelpSheet(mode: session.mode)
        }
    }

    private var gameHUD: some View {
        HStack(spacing: 10) {
            NavBackButton { route = .menu }
            VStack(alignment: .leading, spacing: 2) {
                Text(session.mode.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.textOnGreen)
                HStack(spacing: 8) {
                    Label(session.formattedTime, systemImage: "clock")
                    Text("· \(session.moves) movs")
                    if session.combo > 1 {
                        Text("x\(session.combo)")
                            .foregroundStyle(AppTheme.gold)
                            .fontWeight(.heavy)
                    }
                }
                .font(.caption)
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
            .accessibilityLabel("Ayuda")
            CoinBar()
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
    }

    private var controlBar: some View {
        HStack(spacing: 8) {
            gameActionButton(title: "Pista", icon: "lightbulb.fill", badge: "\(progress.hints)") {
                session.showHint()
            }
            gameActionButton(title: "Deshacer", icon: "arrow.uturn.backward", badge: "\(progress.undos)") {
                session.undo()
            }
            gameActionButton(title: "Nueva", icon: "arrow.clockwise", badge: nil) {
                session.newGame()
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
    }

    private func gameActionButton(title: String, icon: String, badge: String?, action: @escaping () -> Void) -> some View {
        Button {
            AudioManager.shared.click()
            action()
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                    if let badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Circle().fill(AppTheme.accent))
                            .offset(x: 8, y: -6)
                    }
                }
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
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
    private func boardContent(in size: CGSize) -> some View {
        let cardW = cardWidth(for: session.mode, in: size)
        switch session.mode {
        case .klondike, .yukon:
            klondikeLayout(cardW: cardW)
        case .freeCell:
            freeCellLayout(cardW: cardW)
        case .spider, .fortyThieves:
            wideTableauLayout(columns: 10, cardW: cardW * 0.90)
        case .pyramid:
            pyramidLayout(cardW: cardW)
        case .triPeaks:
            triPeaksLayout(cardW: cardW)
        case .golf:
            golfLayout(cardW: cardW)
        }
    }

    private func cardBackName() -> String {
        let name = progress.selectedCardBack
        if name == "card_back_blue" || name == "card_back_green" { return name }
        return "card_back"
    }

    /// Tamaño de carta adaptado al dispositivo y al modo (más grande en iPhone).
    private func cardWidth(for mode: GameMode, in size: CGSize) -> CGFloat {
        let w = max(size.width, 280)
        let isPhone = w < 520

        switch mode {
        case .klondike, .yukon:
            return min(w * (isPhone ? 0.20 : 0.15), isPhone ? 76 : 84)
        case .freeCell, .golf:
            return min(w * (isPhone ? 0.22 : 0.17), isPhone ? 78 : 86)
        case .pyramid:
            let fit = (w - 20) / 7.0
            return min(max(fit, w * 0.16), isPhone ? 72 : 80)
        case .triPeaks:
            let fit = (w - 24) / 7.4
            return min(max(fit, w * 0.14), isPhone ? 60 : 68)
        case .spider, .fortyThieves:
            return min(w * (isPhone ? 0.12 : 0.10), isPhone ? 52 : 58)
        }
    }

    private func stackOffset(for cardW: CGFloat) -> CGFloat {
        cardW * 0.18
    }

    private func cardHeight(for cardW: CGFloat) -> CGFloat {
        cardW * 1.45
    }

    private func pileView(_ ref: PileRef, cardW: CGFloat, stacked: Bool = false) -> some View {
        let cards = session.pileCards(for: ref)
        let highlighted = session.selectedPile == ref || session.hintPiles?.0 == ref || session.hintPiles?.1 == ref
        let lifted = session.selectedPile == ref
        let isDropTarget = session.draggingFrom.map { session.validDropTargets(from: $0).contains(ref) } ?? false

        return Button { session.tapPile(ref) } label: {
            ZStack(alignment: .top) {
                if cards.isEmpty {
                    CardFaceView(card: nil, cardBackName: cardBackName(), width: cardW, highlighted: highlighted || isDropTarget)
                        .opacity(0.4)
                } else if stacked {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { idx, card in
                        CardFaceView(
                            card: card,
                            cardBackName: cardBackName(),
                            width: cardW,
                            highlighted: highlighted && idx == cards.count - 1,
                            lifted: lifted && idx == cards.count - 1
                        )
                        .offset(y: CGFloat(idx) * stackOffset(for: cardW))
                    }
                } else {
                    CardFaceView(card: cards.last, cardBackName: cardBackName(), width: cardW, highlighted: highlighted, lifted: lifted)
                }
            }
            .frame(width: cardW, height: stacked ? cardHeight(for: cardW) + CGFloat(max(0, cards.count - 1)) * stackOffset(for: cardW) : cardHeight(for: cardW))
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

    private func klondikeLayout(cardW: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: cardW * 0.25) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
                Spacer()
                ForEach(0..<4, id: \.self) { i in
                    pileView(PileRef(kind: .foundation, index: i), cardW: cardW)
                }
            }
            HStack(alignment: .top, spacing: cardW * 0.12) {
                ForEach(0..<7, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true)
                }
            }
        }
        .frame(minWidth: cardW * 7.5)
    }

    private func freeCellLayout(cardW: CGFloat) -> some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(0..<4, id: \.self) { i in
                    pileView(PileRef(kind: .freeCell, index: i), cardW: cardW)
                }
                Spacer()
                ForEach(0..<4, id: \.self) { i in
                    pileView(PileRef(kind: .foundation, index: i), cardW: cardW)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 8) {
                ForEach(0..<8, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true)
                }
            }
        }
    }

    private func wideTableauLayout(columns: Int, cardW: CGFloat) -> some View {
        VStack(spacing: 10) {
            HStack {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                if session.mode == .fortyThieves {
                    pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
                }
                Spacer()
                if session.mode == .fortyThieves {
                    ForEach(0..<8, id: \.self) { i in
                        pileView(PileRef(kind: .foundation, index: i), cardW: cardW * 0.9)
                    }
                }
            }
            HStack(alignment: .top, spacing: 3) {
                ForEach(0..<columns, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true)
                }
            }
        }
        .frame(minWidth: cardW * CGFloat(columns) * 1.05)
    }

    private func pyramidLayout(cardW: CGFloat) -> some View {
        VStack(spacing: 8) {
            pyramidRows(cardW: cardW)
            HStack(spacing: 20) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
            }
        }
    }

    private func pyramidRows(cardW: CGFloat) -> some View {
        let engine = session.engine as? PyramidEngine
        return VStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 4) {
                    let start = row * (row + 1) / 2
                    ForEach(0..<(row + 1), id: \.self) { offset in
                        let idx = start + offset
                        if let eng = engine, let card = eng.pyramid[idx] {
                            cardButton(card: card, ref: PileRef(kind: .tableau, index: idx), cardW: cardW)
                        } else {
                            Color.clear.frame(width: cardW, height: cardHeight(for: cardW))
                        }
                    }
                }
            }
        }
    }

    private func triPeaksLayout(cardW: CGFloat) -> some View {
        VStack(spacing: 10) {
            let engine = session.engine as? TriPeaksEngine
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cardW + 4), spacing: 4), count: 7), spacing: 6) {
                ForEach(0..<28, id: \.self) { idx in
                    if let eng = engine, let card = eng.peaks[idx] {
                        cardButton(card: card, ref: PileRef(kind: .tableau, index: idx), cardW: cardW)
                    } else {
                        Color.clear.frame(width: cardW, height: cardW * 1.45)
                    }
                }
            }
            .frame(maxWidth: (cardW + 4) * 7)
            HStack(spacing: 20) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
            }
        }
    }

    private func golfLayout(cardW: CGFloat) -> some View {
        VStack(spacing: 12) {
            pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
            HStack(spacing: 6) {
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
