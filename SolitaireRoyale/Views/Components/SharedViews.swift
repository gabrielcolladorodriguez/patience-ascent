import SwiftUI

// MARK: - Image loading

struct BundleImage: View {
    let name: String
    var folder: String = "GameAssets"

    var body: some View {
        if let uiImage = loadImage() {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.panelFill)
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

// MARK: - Backgrounds

struct GameBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.feltTop, AppTheme.feltBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [AppTheme.feltGlow.opacity(0.35), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 520
            )
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.18)],
                center: .bottom,
                startRadius: 80,
                endRadius: 480
            )
            // Marco fino decorativo (como el icono)
            RoundedRectangle(cornerRadius: 0)
                .stroke(AppTheme.tableGoldFrame.opacity(0.22), lineWidth: 2)
                .padding(10)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

struct GameTableSurface<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(AppTheme.tableSurface)
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppTheme.tableBorder, lineWidth: 1.5)
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppTheme.tableGoldFrame.opacity(0.45), lineWidth: 2)
                        .padding(3)
                }
                .shadow(color: .black.opacity(0.14), radius: 10, y: 5)
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
    }
}

// MARK: - Layout

/// Centra y limita ancho en iPad para menús y formularios.
struct AdaptiveMenuContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                content
                    .frame(maxWidth: DeviceLayout.menuMaxWidth(for: geo.size.width))
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Buttons

struct AppButton: View {
    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    let action: () -> Void

    enum Style { case primary, secondary, compact }

    var body: some View {
        Button {
            AudioManager.shared.click()
            action()
        } label: {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(style == .compact ? .caption.weight(.bold) : .body.weight(.semibold))
                }
                Text(title)
                    .font(style == .compact ? .caption.weight(.bold) : .headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: style == .compact ? 40 : AppTheme.buttonHeight)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: style == .compact ? 12 : AppTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: style == .compact ? 12 : AppTheme.cornerRadius)
                    .stroke(border, lineWidth: style == .secondary ? 1.5 : 0)
            )
            .shadow(color: style == .primary ? .black.opacity(0.18) : .clear, radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch style {
        case .primary: return .white
        case .secondary: return AppTheme.textOnGreen
        case .compact: return AppTheme.textOnTable
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentPressed],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            AppTheme.panelFillStrong
        case .compact:
            Color.white
        }
    }

    private var border: Color {
        style == .secondary ? AppTheme.panelStroke : .clear
    }
}

struct NavBackButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            AudioManager.shared.click()
            action()
        } label: {
            Image(systemName: "chevron.left")
                .font(.body.weight(.bold))
                .foregroundStyle(AppTheme.textOnGreen)
                .frame(width: 40, height: 40)
                .background(Circle().fill(AppTheme.panelFill))
                .overlay(Circle().stroke(AppTheme.panelStroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Volver")
    }
}

struct ScreenHeader: View {
    let title: String
    let onBack: () -> Void
    var showCoins: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            NavBackButton(action: onBack)
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.textOnGreen)
            Spacer()
            if showCoins { CoinBar() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Panels

struct AppPanel<Content: View>: View {
    var onTable: Bool = false
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(onTable ? Color.white : AppTheme.panelFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(onTable ? AppTheme.tableBorder : AppTheme.panelStroke, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Cards

struct CardFaceView: View {
    let card: PlayingCard?
    let cardBackName: String
    let width: CGFloat
    let highlighted: Bool
    var lifted: Bool = false

    var body: some View {
        let radius = width * AppTheme.cardCornerRatio
        ZStack {
            if let card, card.faceUp {
                BundleImage(name: "\(card.imageName).png", folder: "GameAssets/Cards")
                    .aspectRatio(0.72, contentMode: .fit)
            } else {
                BundleImage(name: "\(cardBackName).png", folder: "GameAssets/Cards")
                    .aspectRatio(0.72, contentMode: .fit)
            }
        }
        .frame(width: width)
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
        .scaleEffect(lifted ? 1.05 : 1)
        .offset(y: lifted ? -5 : 0)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: lifted)
        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(highlighted ? AppTheme.gold : Color.clear, lineWidth: 3)
                .shadow(color: highlighted ? AppTheme.gold.opacity(0.5) : .clear, radius: 5)
        )
        .shadow(color: .black.opacity(lifted ? 0.25 : 0.12), radius: lifted ? 6 : 2, y: lifted ? 4 : 1)
    }
}

struct CoinBar: View {
    @ObservedObject var progress = ProgressStore.shared

    var body: some View {
        HStack(spacing: 6) {
            BundleImage(name: "coin.png", folder: "GameAssets/Icons")
                .frame(width: 22, height: 22)
            Text("\(progress.coins)")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(AppTheme.gold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppTheme.panelFill)
                .overlay(Capsule().stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }
}

// Legacy removed — use AppButton
