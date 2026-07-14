import SwiftUI

// MARK: - Onboarding (primera vez)

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    private let pages: [(icon: String, title: String, lines: [String])] = [
        ("hand.tap.fill", "Toca y arrastra", [
            "Toca una carta para seleccionarla.",
            "Arrastra a otra pila válida.",
            "Un solo dedo, en vertical."
        ]),
        ("lightbulb.fill", "Pista y deshacer", [
            "Pista: te muestra un movimiento posible.",
            "Deshacer: corrige el último paso.",
            "Nueva: empieza otra partida."
        ]),
        ("trophy.fill", "Gana y progresa", [
            "Completa el solitario para ganar monedas.",
            "Desbloquea modos en la tienda.",
            "Cada modo tiene reglas distintas."
        ])
    ]

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: pages[page].icon)
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.gold)
                    .symbolEffect(.bounce, value: page)

                Text(pages[page].title)
                    .font(AppTheme.titleFont(28))
                    .foregroundStyle(AppTheme.textOnGreen)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(pages[page].lines, id: \.self) { line in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.success)
                                .font(.body)
                            Text(line)
                                .font(AppTheme.bodyFont())
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(panelBackground)

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? AppTheme.gold : AppTheme.panelStroke)
                            .frame(width: i == page ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: page)
                    }
                }

                VStack(spacing: 10) {
                    AppButton(
                        title: page < pages.count - 1 ? "Siguiente" : "¡A jugar!",
                        systemImage: page < pages.count - 1 ? "arrow.right" : "play.fill",
                        style: .primary
                    ) {
                        if page < pages.count - 1 {
                            page += 1
                        } else {
                            onFinish()
                        }
                    }
                    Button("Saltar") {
                        AudioManager.shared.click()
                        onFinish()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textMutedOnGreen)
                }
                .padding(.horizontal, 28)
                Spacer()
            }
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppTheme.panelFillStrong)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.panelStroke, lineWidth: 1)
            )
            .padding(.horizontal, 24)
    }
}

// MARK: - Ayuda por modo

struct QuickHelpSheet: View {
    let mode: SolitaireMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                HStack {
                    Text("Cómo jugar: \(mode.title)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Spacer()
                    Button {
                        AudioManager.shared.click()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.textMutedOnGreen)
                    }
                }
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ruleBlock(icon: "target", title: "Objetivo", lines: [mode.quickRules.last ?? ""])
                        ruleBlock(icon: "list.bullet", title: "Reglas rápidas", lines: Array(mode.quickRules.dropLast()))
                        ruleBlock(icon: "hand.point.up.left.fill", title: "Controles", lines: [mode.controlsHint])
                    }
                    .padding()
                }

                AppButton(title: "Entendido", systemImage: "checkmark", style: .primary) {
                    dismiss()
                }
                .padding()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func ruleBlock(icon: String, title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.gold)
            ForEach(lines.filter { !$0.isEmpty }, id: \.self) { line in
                Text("• \(line)")
                    .font(AppTheme.bodyFont())
                    .foregroundStyle(AppTheme.textOnGreen)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFill)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }
}

// MARK: - Banner tip en partida

struct GameTipBanner: View {
    let text: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(AppTheme.gold)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textOnTable)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 4)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textMutedOnTable)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.tableGoldFrame.opacity(0.5), lineWidth: 1))
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
        .padding(.horizontal, 12)
    }
}

// MARK: - Guía general (menú)

struct HowToPlayView: View {
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: "Cómo jugar", onBack: { route = .menu }, showCoins: false)
                ScrollView {
                    VStack(spacing: 12) {
                        generalCard(
                            icon: "hand.tap.fill",
                            title: "Controles básicos",
                            text: "Toca para seleccionar. Arrastra a una pila válida. Usa Pista si no ves movimiento. Deshacer corrige el último paso."
                        )
                        generalCard(
                            icon: "paintpalette.fill",
                            title: "Colores",
                            text: "Rojo y negro se alternan en la mayoría de modos. Los valores bajan: Rey, Reina, Jota… hasta el As en las bases."
                        )
                        ForEach(SolitaireMode.allCases) { mode in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(mode.title)
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(AppTheme.gold)
                                Text(mode.quickRules.first ?? "")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textMutedOnGreen)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.panelFill)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.panelStroke, lineWidth: 1))
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private func generalCard(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.textOnGreen)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textMutedOnGreen)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFillStrong)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }
}
