import SwiftUI

struct GameBoardView: View {
    @StateObject var session: GameSessionViewModel
    @Binding var route: AppRoute
    @ObservedObject var progress = ProgressStore.shared

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 8) {
                gameHUD
                GeometryReader { geo in
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        boardContent(in: geo.size)
                            .padding(8)
                    }
                }
                controlBar
            }

            if session.showWin {
                WinCelebrationOverlay(
                    coinsEarned: session.lastWinRewards.coins,
                    xpEarned: session.lastWinRewards.xp,
                    onPlayAgain: { session.newGame() },
                    onMenu: { route = .menu }
                )
                .transition(.opacity)
            }
        }
        .id(session.boardVersion)
        .onAppear {
            AudioManager.shared.playMusic("game_music.ogg")
        }
        .onDisappear {
            AudioManager.shared.playMusic("menu_music.ogg")
        }
    }

    private var gameHUD: some View {
        HStack {
            Button {
                AudioManager.shared.click()
                route = .modes
            } label: {
                BundleImage(name: "home.png", folder: "GameAssets/Icons")
                    .frame(width: 30, height: 30)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(session.mode.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                HStack(spacing: 8) {
                    Text("\(session.formattedTime) · \(session.moves) movs")
                    if session.combo > 1 {
                        Text("COMBO x\(session.combo)")
                            .foregroundStyle(.orange)
                            .fontWeight(.heavy)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                Text("Puntos: \(session.score)")
                    .font(.caption2)
                    .foregroundStyle(.yellow.opacity(0.9))
            }
            Spacer()
            CoinBar()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var controlBar: some View {
        HStack(spacing: 10) {
            smallButton(title: "Pista (\(progress.hints))", icon: "star") { session.showHint() }
            smallButton(title: "Deshacer (\(progress.undos))", icon: "play") { session.undo() }
            smallButton(title: "Nueva", icon: "play") { session.newGame() }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func smallButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            AudioManager.shared.click()
            action()
        }) {
            VStack(spacing: 4) {
                BundleImage(name: "\(icon).png", folder: "GameAssets/Icons")
                    .frame(width: 22, height: 22)
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(BundleImage(name: "panel.png", folder: "GameAssets/UI").opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func boardContent(in size: CGSize) -> some View {
        let cardW = min(size.width * 0.11, 56)
        switch session.mode {
        case .klondike, .yukon:
            klondikeLayout(cardW: cardW)
        case .freeCell:
            freeCellLayout(cardW: cardW)
        case .spider, .fortyThieves:
            wideTableauLayout(columns: session.mode == .spider ? 10 : 10, cardW: cardW * 0.85)
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

    private func pileView(_ ref: PileRef, cardW: CGFloat, stacked: Bool = false) -> some View {
        let cards = session.pileCards(for: ref)
        let highlighted = session.selectedPile == ref || session.hintPiles?.0 == ref || session.hintPiles?.1 == ref
        let lifted = session.selectedPile == ref
        let isDropTarget = session.draggingFrom.map { session.validDropTargets(from: $0).contains(ref) } ?? false

        return Button {
            session.tapPile(ref)
        } label: {
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
                        .offset(y: CGFloat(idx) * (cardW * 0.22))
                    }
                } else {
                    CardFaceView(card: cards.last, cardBackName: cardBackName(), width: cardW, highlighted: highlighted, lifted: lifted)
                }
            }
            .frame(width: cardW, height: stacked ? cardW * 1.5 + CGFloat(max(0, cards.count - 1)) * cardW * 0.22 : cardW * 1.45)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isDropTarget ? Color.cyan : .clear, lineWidth: 2)
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
            HStack(spacing: cardW * 0.3) {
                pileView(PileRef(kind: .stock, index: 0), cardW: cardW)
                pileView(PileRef(kind: .waste, index: 0), cardW: cardW)
                Spacer()
                ForEach(0..<4, id: \.self) { i in
                    pileView(PileRef(kind: .foundation, index: i), cardW: cardW)
                }
            }
            HStack(alignment: .top, spacing: cardW * 0.15) {
                ForEach(0..<7, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true)
                }
            }
        }
        .frame(minWidth: cardW * 8)
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
                let foundationCount = session.mode == .fortyThieves ? 8 : 0
                if foundationCount > 0 {
                    ForEach(0..<foundationCount, id: \.self) { i in
                        pileView(PileRef(kind: .foundation, index: i), cardW: cardW * 0.9)
                    }
                }
            }
            HStack(alignment: .top, spacing: 4) {
                ForEach(0..<columns, id: \.self) { col in
                    pileView(PileRef(kind: .tableau, index: col), cardW: cardW, stacked: true)
                }
            }
        }
        .frame(minWidth: cardW * CGFloat(columns) * 1.1)
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
                            Color.clear.frame(width: cardW, height: cardW * 1.45)
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
        return Button {
            session.tapPile(ref)
        } label: {
            CardFaceView(card: card, cardBackName: cardBackName(), width: cardW, highlighted: highlighted)
        }
        .buttonStyle(.plain)
    }
}
