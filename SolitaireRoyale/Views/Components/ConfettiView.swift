import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var color: Color
    var size: CGFloat
    var velocityY: CGFloat
    var velocityX: CGFloat
    var spin: Double
}

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    let colors: [Color] = [AppTheme.gold, .orange, AppTheme.success, .white, AppTheme.accent]

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, _ in
                    for piece in pieces {
                        var transform = CGAffineTransform.identity
                        transform = transform.translatedBy(x: piece.x, y: piece.y)
                        transform = transform.rotated(by: piece.rotation * .pi / 180)
                        context.concatenate(transform)
                        let rect = CGRect(x: -piece.size / 2, y: -piece.size, width: piece.size, height: piece.size * 1.6)
                        context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(piece.color))
                        context.concatenate(transform.inverted())
                    }
                }
                .onChange(of: timeline.date) { _ in tick(in: geo.size) }
                .onAppear { spawn(in: geo.size) }
            }
        }
        .allowsHitTesting(false)
    }

    private func spawn(in size: CGSize) {
        pieces = (0..<60).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...max(size.width, 300)),
                y: CGFloat.random(in: -100...0),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 5...11),
                velocityY: CGFloat.random(in: 2...5),
                velocityX: CGFloat.random(in: -2...2),
                spin: Double.random(in: -8...8)
            )
        }
    }

    private func tick(in size: CGSize) {
        for i in pieces.indices {
            pieces[i].y += pieces[i].velocityY
            pieces[i].x += pieces[i].velocityX
            pieces[i].rotation += pieces[i].spin
            pieces[i].velocityY += 0.07
        }
        pieces.removeAll { $0.y > size.height + 60 }
        if pieces.count < 30 { spawn(in: size) }
    }
}

struct WinCelebrationOverlay: View {
    let time: String
    let moves: Int
    let score: Int?
    let isNewBest: Bool
    let mode: SolitaireMode
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            ConfettiView().ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppTheme.gold)
                    .scaleEffect(scale)

                Text(score != nil ? L10n.s("time_up") : L10n.s("you_win"))
                    .font(AppTheme.titleFont(38))
                    .foregroundStyle(AppTheme.gold)

                if isNewBest {
                    Text(L10n.s(score != nil ? "new_best_score_fmt" : "new_best_fmt", mode.title))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 20) {
                    if let score {
                        statBadge(icon: "star.fill", value: L10n.s("score_fmt", score))
                    }
                    statBadge(icon: score != nil ? "timer" : "clock.fill", value: time)
                    statBadge(icon: "arrow.triangle.swap", value: "\(moves)")
                }

                VStack(spacing: 10) {
                    AppButton(title: L10n.s("play_again"), systemImage: "arrow.clockwise", style: .gold, action: onPlayAgain)
                    AppButton(title: L10n.s("menu"), systemImage: "house.fill", style: .secondary, action: onMenu)
                }
                .padding(.horizontal, 28)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            AudioManager.shared.playMusic("win_music.wav", loop: false)
            HapticsManager.win()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.68)) {
                scale = 1
                opacity = 1
            }
        }
    }

    private func statBadge(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(value)
                .font(.headline.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
