import SwiftUI

struct BundleImage: View {
    let name: String
    var folder: String = "Resources"

    var body: some View {
        if let uiImage = loadImage() {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Rectangle().fill(Color.gray.opacity(0.3))
        }
    }

    private func loadImage() -> UIImage? {
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "png" : (name as NSString).pathExtension
        if let path = Bundle.main.path(forResource: base, ofType: ext, inDirectory: folder) {
            return UIImage(contentsOfFile: path)
        }
        if let path = Bundle.main.path(forResource: base, ofType: ext) {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}

struct CardFaceView: View {
    let card: PlayingCard?
    let cardBackName: String
    let width: CGFloat
    let highlighted: Bool
    var lifted: Bool = false

    var body: some View {
        ZStack {
            if let card, card.faceUp {
                BundleImage(name: "\(card.imageName).png", folder: "Resources/Cards")
                    .aspectRatio(0.72, contentMode: .fit)
            } else {
                BundleImage(name: "\(cardBackName).png", folder: "Resources/Cards")
                    .aspectRatio(0.72, contentMode: .fit)
            }
        }
        .frame(width: width)
        .scaleEffect(lifted ? 1.06 : 1)
        .offset(y: lifted ? -6 : 0)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: lifted)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(highlighted ? Color.yellow : Color.clear, lineWidth: 3)
                .shadow(color: highlighted ? .yellow.opacity(0.6) : .clear, radius: 6)
        )
        .shadow(color: .black.opacity(lifted ? 0.45 : 0.25), radius: lifted ? 8 : 2, x: 0, y: lifted ? 6 : 2)
    }
}

struct KenneyButton: View {
    let title: String
    let icon: String?
    var style: ButtonStyleKind = .primary
    let action: () -> Void

    enum ButtonStyleKind { case primary, secondary }

    var body: some View {
        Button(action: action) {
            ZStack {
                BundleImage(
                    name: style == .primary ? "button_primary.png" : "button_secondary.png",
                    folder: "Resources/UI"
                )
                .aspectRatio(3.2, contentMode: .fit)
                HStack(spacing: 8) {
                    if let icon {
                        BundleImage(name: "\(icon).png", folder: "Resources/Icons")
                            .frame(width: 22, height: 22)
                    }
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                }
                .padding(.horizontal, 8)
            }
        }
        .buttonStyle(.plain)
    }
}

struct CoinBar: View {
    @ObservedObject var progress = ProgressStore.shared

    var body: some View {
        HStack(spacing: 6) {
            BundleImage(name: "coin.png", folder: "Resources/Icons")
                .frame(width: 28, height: 28)
            Text("\(progress.coins)")
                .font(.title3.weight(.heavy))
                .foregroundStyle(.yellow)
                .shadow(color: .black, radius: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            BundleImage(name: "panel.png", folder: "Resources/UI")
                .opacity(0.9)
        )
    }
}

struct GameBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.28, blue: 0.14),
                    Color(red: 0.02, green: 0.12, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color.white.opacity(0.06), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}
