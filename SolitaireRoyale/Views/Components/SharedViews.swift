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
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.9), AppTheme.tableSurface2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
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
    var theme: ModeTheme?

    var body: some View {
        let t = theme
        ZStack {
            LinearGradient(
                colors: [
                    t?.feltTop ?? AppTheme.feltTop,
                    t?.feltMid ?? AppTheme.feltMid,
                    t?.feltBottom ?? AppTheme.feltBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [(t?.feltGlow ?? AppTheme.feltGlow).opacity(0.45), .clear],
                center: .init(x: 0.5, y: 0.12),
                startRadius: 10,
                endRadius: 560
            )
            ModePatternOverlay(symbol: t?.particleSymbol ?? "sparkles")
                .opacity(0.08)
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.28)],
                center: .bottom,
                startRadius: 60,
                endRadius: 520
            )
            RoundedRectangle(cornerRadius: 0)
                .stroke(
                    LinearGradient(
                        colors: [
                            (t?.gold ?? AppTheme.gold).opacity(0.35),
                            (t?.accent ?? AppTheme.accent).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .padding(8)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

private struct ModePatternOverlay: View {
    let symbol: String

    var body: some View {
        GeometryReader { geo in
            let cols = 5
            let rows = 8
            ForEach(0..<(cols * rows), id: \.self) { i in
                let col = i % cols
                let row = i / cols
                Image(systemName: symbol)
                    .font(.system(size: 28 + CGFloat(i % 3) * 4))
                    .foregroundStyle(.white)
                    .position(
                        x: geo.size.width * (CGFloat(col) + 0.5) / CGFloat(cols),
                        y: geo.size.height * (CGFloat(row) + 0.5) / CGFloat(rows)
                    )
                    .rotationEffect(.degrees(Double((i * 17) % 40) - 20))
            }
        }
        .allowsHitTesting(false)
    }
}

struct GameTableSurface<Content: View>: View {
    var theme: ModeTheme?
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme?.tableSurface ?? AppTheme.tableSurface,
                                    theme?.tableSurface2 ?? AppTheme.tableSurface2
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(theme?.tableBorder ?? AppTheme.tableBorder, lineWidth: 1.2)
                    RoundedRectangle(cornerRadius: 24)
                        .stroke((theme?.tableFrame ?? AppTheme.tableGoldFrame).opacity(0.55), lineWidth: 2.5)
                        .padding(3)
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.65), lineWidth: 1)
                        .padding(6)
                        .blendMode(.overlay)
                }
                .shadow(color: .black.opacity(0.22), radius: 16, y: 8)
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
    }
}

// MARK: - Layout

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

    enum Style { case primary, secondary, compact, gold }

    var body: some View {
        Button {
            AudioManager.shared.click()
            action()
        } label: {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(style == .compact ? .caption.weight(.bold) : .body.weight(.semibold))
                }
                Text(title)
                    .font(style == .compact ? .caption.weight(.bold) : .headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: style == .compact ? 42 : AppTheme.buttonHeight)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: style == .compact ? 12 : AppTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: style == .compact ? 12 : AppTheme.cornerRadius)
                    .stroke(border, lineWidth: borderWidth)
            )
            .overlay(
                RoundedRectangle(cornerRadius: style == .compact ? 12 : AppTheme.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(style == .primary || style == .gold ? 0.22 : 0.08), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            )
            .shadow(color: shadowColor, radius: style == .primary || style == .gold ? 8 : 2, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var foreground: Color {
        switch style {
        case .primary, .gold: return .white
        case .secondary: return AppTheme.textOnGreen
        case .compact: return AppTheme.textOnTable
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            AppTheme.primaryButtonGradient
        case .gold:
            AppTheme.goldShineGradient
        case .secondary:
            ZStack {
                AppTheme.panelFillStrong
                Color.white.opacity(0.06)
            }
        case .compact:
            Color.white
        }
    }

    private var border: Color {
        switch style {
        case .secondary: return AppTheme.panelStroke
        case .gold: return AppTheme.goldLight.opacity(0.8)
        case .primary: return AppTheme.accentLight.opacity(0.5)
        case .compact: return AppTheme.tableBorder
        }
    }

    private var borderWidth: CGFloat {
        style == .secondary || style == .gold ? 1.5 : 0
    }

    private var shadowColor: Color {
        switch style {
        case .primary: return AppTheme.accentPressed.opacity(0.45)
        case .gold: return AppTheme.goldDark.opacity(0.4)
        default: return .black.opacity(0.12)
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
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
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .fill(AppTheme.panelFillStrong)
                        .overlay(Circle().stroke(AppTheme.panelStroke, lineWidth: 1))
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.s("back"))
    }
}

struct ScreenHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            NavBackButton(action: onBack)
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.textOnGreen)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct NewBadge: View {
    var body: some View {
        Text(L10n.s("new_badge"))
            .font(.caption2.weight(.black))
            .foregroundStyle(.black)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(AppTheme.goldShineGradient)
                    .shadow(color: AppTheme.goldDark.opacity(0.35), radius: 3, y: 1)
            )
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
                    .fill(onTable ? Color.white : AppTheme.panelFillStrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(onTable ? AppTheme.tableBorder : AppTheme.panelStroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(onTable ? 0.08 : 0.12), radius: 6, y: 3)
            )
    }
}
