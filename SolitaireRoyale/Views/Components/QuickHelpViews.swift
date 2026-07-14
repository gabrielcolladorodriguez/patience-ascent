import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0
    @State private var iconPulse: CGFloat = 1

    private var pages: [(icon: String, title: String, lines: [String])] {
        [
            ("square.grid.3x3.fill", L10n.s("onboarding_blocks_title"), [
                L10n.s("onboarding_blocks_1"),
                L10n.s("onboarding_blocks_2"),
                L10n.s("onboarding_blocks_3")
            ]),
            ("arrow.down.circle.fill", L10n.s("onboarding_gravity_title"), [
                L10n.s("onboarding_gravity_1"),
                L10n.s("onboarding_gravity_2"),
                L10n.s("onboarding_gravity_3")
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
            GameBackground(theme: SolitaireMode.gravityBlocks.theme)
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
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppTheme.panelFill)
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke))
                    )

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
}
