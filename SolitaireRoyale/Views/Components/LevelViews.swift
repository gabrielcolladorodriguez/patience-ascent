import SwiftUI

struct XPProgressBar: View {
    let progress: Double
    let level: Int
    var theme: ModeTheme = ModeTheme.forMode(.glyphLink)
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 6 : 8) {
            LevelBadge(level: level, theme: theme, compact: compact)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.14))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [theme.accentLight, theme.gold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, geo.size.width * progress))
                }
            }
            .frame(height: compact ? 8 : 10)
        }
    }
}

struct LevelBadge: View {
    let level: Int
    var theme: ModeTheme = ModeTheme.forMode(.glyphLink)
    var compact = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [theme.gold, theme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("\(level)")
                .font(.system(size: compact ? 11 : 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: compact ? 26 : 32, height: compact ? 26 : 32)
        .shadow(color: theme.gold.opacity(0.4), radius: 4, y: 2)
    }
}

struct AscentRankCard: View {
    let globalRank: Int
    let rankTitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.goldShineGradient)
                    .frame(width: 52, height: 52)
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(rankTitle)
                    .font(.headline.weight(.black))
                    .foregroundStyle(AppTheme.textOnGreen)
                Text(L10n.s("ascent_rank_fmt", globalRank))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFillStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.gold.opacity(0.4), lineWidth: 1.5)
                )
        )
    }
}

struct StarRatingView: View {
    let stars: Int
    var tint: Color = AppTheme.gold

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...3, id: \.self) { i in
                Image(systemName: i <= stars ? "star.fill" : "star")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(i <= stars ? tint : Color.white.opacity(0.25))
            }
        }
    }
}

struct ComboMeterView: View {
    let combo: Int
    let theme: ModeTheme

    var body: some View {
        if combo > 1 {
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.caption2.weight(.bold))
                Text(L10n.s("combo_fmt", combo))
                    .font(.caption.weight(.black))
            }
            .foregroundStyle(theme.gold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(theme.accent.opacity(0.35))
                    .overlay(Capsule().stroke(theme.gold.opacity(0.6), lineWidth: 1))
            )
            .scaleEffect(1.0 + min(0.12, CGFloat(combo) * 0.02))
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: combo)
        }
    }
}

struct LevelUpBanner: View {
    let result: LevelUpResult
    let theme: ModeTheme

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up.forward.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(theme.gold)
                .scaleEffect(pulse ? 1.08 : 1)
            Text(L10n.s("level_up"))
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
            Text(L10n.s("level_up_fmt", result.newLevel, result.mode.title))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textMutedOnGreen)
            Text(L10n.s("xp_gained_fmt", result.xpGained))
                .font(.caption.weight(.bold))
                .foregroundStyle(theme.accentLight)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [theme.feltTop.opacity(0.9), theme.feltMid.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.gold, lineWidth: 2)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct ResetProgressButton: View {
    @ObservedObject var progress = ProgressStore.shared
    @State private var showConfirm = false

    var body: some View {
        Button {
            AudioManager.shared.click()
            showConfirm = true
        } label: {
            Label(L10n.s("reset_progress"), systemImage: "arrow.counterclockwise.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.danger.opacity(0.9))
        }
        .buttonStyle(.plain)
        .alert(L10n.s("reset_progress"), isPresented: $showConfirm) {
            Button(L10n.s("cancel"), role: .cancel) {}
            Button(L10n.s("reset_confirm"), role: .destructive) {
                progress.resetAllProgress()
                AudioManager.shared.tap()
            }
        } message: {
            Text(L10n.s("reset_progress_msg"))
        }
    }
}
