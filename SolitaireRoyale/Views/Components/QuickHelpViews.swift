import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0
    @State private var iconPulse: CGFloat = 1

    private var pages: [(icon: String, title: String, lines: [String])] {
        [
            ("link.circle.fill", L10n.s("onboarding_glyph_title"), [
                L10n.s("onboarding_glyph_1"),
                L10n.s("onboarding_glyph_2"),
                L10n.s("onboarding_glyph_3")
            ]),
            ("bolt.circle.fill", L10n.s("onboarding_modes_title"), [
                L10n.s("onboarding_modes_1"),
                L10n.s("onboarding_modes_2"),
                L10n.s("onboarding_modes_3")
            ]),
            ("music.note", L10n.s("onboarding_relax_title"), [
                L10n.s("onboarding_relax_1"),
                L10n.s("onboarding_relax_2"),
                L10n.s("onboarding_relax_3")
            ])
        ]
    }

    var body: some View {
        ZStack {
            GameBackground()
            AdaptiveMenuContainer {
                VStack(spacing: 22) {
                    Spacer()
                    Image(systemName: pages[page].icon)
                        .font(.system(size: 58))
                        .foregroundStyle(AppTheme.goldShineGradient)
                        .scaleEffect(iconPulse)
                        .shadow(color: AppTheme.gold.opacity(0.35), radius: 12)
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
                        title: page < pages.count - 1 ? L10n.s("next") : L10n.s("lets_play"),
                        systemImage: page < pages.count - 1 ? "arrow.right" : "play.fill",
                        style: .primary
                    ) {
                        if page < pages.count - 1 { page += 1 } else { onFinish() }
                    }

                    Button(L10n.s("skip")) { onFinish() }
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

struct ModeTutorialOverlay: View {
    @ObservedObject var session: GlyphLinkSessionViewModel
    let theme: ModeTheme

    private var steps: [String] { session.mode.tutorialSteps }
    private var step: Int { session.tutorialStep }

    var body: some View {
        ZStack {
            Color.black.opacity(step == 1 ? 0.35 : 0.62)
                .ignoresSafeArea()
                .allowsHitTesting(step != 1)

            VStack {
                Spacer()
                tutorialCard
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: step)
    }

    private var tutorialCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: session.mode.iconName)
                    .font(.title2)
                    .foregroundStyle(theme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.s("tutorial_title"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.accentLight)
                    Text(session.mode.title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(AppTheme.textOnGreen)
                }
                Spacer()
                Text("\(min(step + 1, steps.count))/\(steps.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(AppTheme.panelFill))
            }

            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? theme.accentLight : AppTheme.panelStroke)
                        .frame(height: 4)
                }
            }

            Text(currentText)
                .font(.body.weight(.medium))
                .foregroundStyle(AppTheme.textMutedOnGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if step == 1 {
                Label(L10n.s("tutorial_practice"), systemImage: "hand.tap.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.gold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 10) {
                if step < 2 {
                    Button(L10n.s("tutorial_skip")) { session.skipTutorial() }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                }
                Spacer()
                Button {
                    AudioManager.shared.click()
                    if step == 0 {
                        session.advanceTutorial()
                    } else if step == 1 && session.tutorialPracticeDone {
                        session.advanceTutorial()
                    } else if step >= 2 || session.tutorialPracticeDone {
                        session.advanceTutorial()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: primaryIcon)
                        Text(primaryLabel)
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(AppTheme.primaryButtonGradient(theme: theme))
                    )
                }
                .buttonStyle(.plain)
                .disabled(step == 1 && !session.tutorialPracticeDone)
                .opacity(step == 1 && !session.tutorialPracticeDone ? 0.45 : 1)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.panelFillStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(colors: [theme.gold, theme.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )
                .shadow(color: theme.accent.opacity(0.35), radius: 16, y: 8)
        )
    }

    private var currentText: String {
        guard step < steps.count else { return steps.last ?? "" }
        return steps[step]
    }

    private var primaryLabel: String {
        if step == 0 { return L10n.s("tutorial_continue") }
        if step == 1 { return L10n.s("tutorial_continue") }
        return L10n.s("tutorial_start")
    }

    private var primaryIcon: String {
        step >= 2 ? "play.fill" : "arrow.right"
    }
}

struct QuickHelpSheet: View {
    let mode: SolitaireMode
    var theme: ModeTheme = ModeTheme.forMode(.glyphLink)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GameBackground(theme: theme)
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: mode.iconName)
                        .font(.title2)
                        .foregroundStyle(theme.gold)
                    Text(mode.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(mode.quickRules, id: \.self) { rule in
                        Text("• \(rule)")
                            .font(.body)
                            .foregroundStyle(AppTheme.textMutedOnGreen)
                    }
                    Text("• \(mode.controlsHint)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.gold)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppTheme.panelFill)
                )
                .padding(.horizontal)

                AppButton(title: L10n.s("got_it"), systemImage: "checkmark", style: .primary) { dismiss() }
                    .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
        .presentationDetents([.medium, .large])
    }
}
