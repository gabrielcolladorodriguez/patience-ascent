import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0
    @State private var iconPulse: CGFloat = 1

    private let pages: [(icon: String, title: String, lines: [String])] = [
        ("hand.tap.fill", "Así se juega", [
            "Toca una carta y arrástrala donde encaje.",
            "Pista y Deshacer son ilimitados.",
            "Gana lo más rápido que puedas."
        ]),
        ("chart.bar.fill", "Rankings", [
            "Compite en Game Center.",
            "Mejor tiempo por modo y tiempo total jugado.",
            "Relájate con música lofi."
        ])
    ]

    var body: some View {
        ZStack {
            GameBackground()
            AdaptiveMenuContainer {
                VStack(spacing: 22) {
                    Spacer()
                    Image(systemName: pages[page].icon)
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.gold)
                        .scaleEffect(iconPulse)
                        .onChange(of: page) { _ in
                            iconPulse = 0.9
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { iconPulse = 1.05 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) { iconPulse = 1 }
                            }
                        }

                    Text(pages[page].title)
                        .font(AppTheme.titleFont(28))
                        .foregroundStyle(AppTheme.textOnGreen)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(pages[page].lines, id: \.self) { line in
                            Text("• \(line)")
                                .font(AppTheme.bodyFont())
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(panel)

                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == page ? AppTheme.gold : AppTheme.panelStroke)
                                .frame(width: i == page ? 22 : 8, height: 8)
                        }
                    }

                    AppButton(
                        title: page < pages.count - 1 ? "Siguiente" : "¡A jugar!",
                        systemImage: page < pages.count - 1 ? "arrow.right" : "play.fill",
                        style: .primary
                    ) {
                        if page < pages.count - 1 { page += 1 } else { onFinish() }
                    }

                    Button("Saltar") { onFinish() }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textMutedOnGreen)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var panel: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppTheme.panelFillStrong)
            .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
    }
}

struct QuickHelpSheet: View {
    let mode: SolitaireMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 16) {
                Text(mode.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.textOnGreen)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(mode.quickRules, id: \.self) { rule in
                        Text("• \(rule)")
                            .font(.body)
                            .foregroundStyle(AppTheme.textMutedOnGreen)
                    }
                    Text("• \(mode.controlsHint)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.gold)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppTheme.panelFill)
                )
                .padding(.horizontal)

                AppButton(title: "Entendido", systemImage: "checkmark", style: .primary) { dismiss() }
                    .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
        .presentationDetents([.medium])
    }
}
