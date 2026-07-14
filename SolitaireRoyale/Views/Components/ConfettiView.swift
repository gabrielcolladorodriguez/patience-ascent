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
    let colors: [Color] = [.yellow, .orange, .red, .green, .cyan, .white]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
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
            .onChange(of: timeline.date) { _ in
                tick()
            }
        }
        .allowsHitTesting(false)
        .onAppear { spawn() }
    }

    private func spawn() {
        pieces = (0..<80).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...400),
                y: CGFloat.random(in: -120...0),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                velocityY: CGFloat.random(in: 2...6),
                velocityX: CGFloat.random(in: -2...2),
                spin: Double.random(in: -8...8)
            )
        }
    }

    private func tick() {
        for i in pieces.indices {
            pieces[i].y += pieces[i].velocityY
            pieces[i].x += pieces[i].velocityX
            pieces[i].rotation += pieces[i].spin
            pieces[i].velocityY += 0.08
        }
        pieces.removeAll { $0.y > 900 }
        if pieces.count < 40 { spawn() }
    }
}

struct WinCelebrationOverlay: View {
    let coinsEarned: Int
    let xpEarned: Int
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            ConfettiView().ignoresSafeArea()

            VStack(spacing: 20) {
                BundleImage(name: "trophy.png", folder: "GameAssets/Icons")
                    .frame(width: 80, height: 80)
                    .scaleEffect(scale)

                Text("¡VICTORIA!")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                    )

                HStack(spacing: 24) {
                    rewardBadge(icon: "coin", value: "+\(coinsEarned)")
                    rewardBadge(icon: "star", value: "+\(xpEarned) XP")
                }

                VStack(spacing: 12) {
                    AppButton(title: "Otra partida", systemImage: "arrow.clockwise", style: .primary, action: onPlayAgain)
                    AppButton(title: "Menú", systemImage: "house.fill", style: .secondary, action: onMenu)
                }
                .padding(.horizontal, 32)
            }
            .padding()
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            HapticsManager.win()
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                scale = 1
                opacity = 1
            }
        }
    }

    private func rewardBadge(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            BundleImage(name: "\(icon).png", folder: "GameAssets/Icons")
                .frame(width: 24, height: 24)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
