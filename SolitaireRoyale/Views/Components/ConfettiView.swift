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
