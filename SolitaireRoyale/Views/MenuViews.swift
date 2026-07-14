import SwiftUI

struct MainMenuView: View {
    @ObservedObject var progress = ProgressStore.shared
    @ObservedObject var gameCenter = GameCenterManager.shared
    @ObservedObject var audio = AudioManager.shared
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            AdaptiveMenuContainer {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        header
                        AscentRankCard(globalRank: progress.globalAscentRank, rankTitle: progress.globalRankTitle)

                        if !progress.dailyChallenge.completed {
                            dailyCard
                        }

                        playHeroButton

                        HStack(spacing: 10) {
                            AppButton(title: L10n.s("rankings"), systemImage: "chart.bar.fill", style: .secondary) {
                                route = .rankings
                            }
                            AppButton(title: L10n.s("how_to_play"), systemImage: "questionmark.circle.fill", style: .secondary) {
                                route = .modes
                            }
                        }

                        quickStats
                        audioToggles
                        ResetProgressButton()

                        if gameCenter.isAuthenticated {
                            Text(L10n.s("game_center_fmt", gameCenter.playerName))
                                .font(.caption2)
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                        }

                        Link(L10n.s("privacy"), destination: URL(string: AppIdentity.privacyURL)!)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textMutedOnGreen.opacity(0.7))
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear { AudioManager.shared.startMenuMusic() }
    }

    private var playHeroButton: some View {
        Button {
            AudioManager.shared.click()
            route = .playPicker
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.goldShineGradient)
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.s("play_now"))
                        .font(.title3.weight(.black))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text(L10n.s("play_subtitle"))
                        .font(.caption)
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                        .multilineTextAlignment(.leading)
                    Text(L10n.s("ascent_rank_fmt", progress.globalAscentRank))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.gold.opacity(0.85))
            }
            .padding(16)
            .background(heroPanel)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var heroPanel: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppTheme.panelFillStrong)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.goldLight, AppTheme.goldDark.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: AppTheme.goldDark.opacity(0.25), radius: 10, y: 4)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image("BrandIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)

            Text(AppIdentity.name)
                .font(AppTheme.titleFont(34))
                .foregroundStyle(AppTheme.textOnGreen)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)

            Text(L10n.tagline)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textMutedOnGreen)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var quickStats: some View {
        HStack(spacing: 10) {
            statPill(L10n.s("wins"), "\(progress.totalWins)")
            statPill(L10n.s("streak"), "\(progress.streak)")
            statPill(L10n.s("time"), formatDuration(progress.totalTimePlayed))
        }
    }

    private var audioToggles: some View {
        HStack(spacing: 10) {
            miniToggle(L10n.s("music"), isOn: $audio.musicEnabled)
            miniToggle(L10n.s("sound"), isOn: $audio.sfxEnabled)
        }
    }

    private var dailyCard: some View {
        let dc = progress.dailyChallenge
        return Button {
            AudioManager.shared.click()
            route = .game(dc.mode, daily: true)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.s("today_challenge"))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text("\(dc.mode.title) · \(L10n.s("diff_level_fmt", progress.level(for: dc.mode)))")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.textMutedOnGreen)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.panelFillStrong)
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.gold.opacity(0.35), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    private func statPill(_ title: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.textOnGreen)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(AppTheme.textMutedOnGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.panelFill)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }

    private func miniToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textOnGreen)
        }
        .tint(AppTheme.accentLight)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.panelFill))
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

struct PlayModePickerView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: L10n.s("choose_mode"), onBack: { route = .menu })
                ScrollView(showsIndicators: false) {
                    AdaptiveMenuContainer {
                        VStack(spacing: 14) {
                            Text(L10n.s("ascent_intro"))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(SolitaireMode.puzzleModes) { mode in
                                modePickerCard(mode)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .onAppear { AudioManager.shared.startMenuMusic() }
    }

    private func modePickerCard(_ mode: SolitaireMode) -> some View {
        let theme = mode.theme
        let level = progress.level(for: mode)
        let config = LevelConfig.forMode(mode, level: level)
        return Button {
            AudioManager.shared.click()
            route = .game(mode, daily: false)
        } label: {
            VStack(spacing: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [theme.accentLight, theme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 54, height: 54)
                        Image(systemName: mode.iconName)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: theme.accent.opacity(0.45), radius: 8, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(mode.title)
                                .font(.headline.weight(.black))
                                .foregroundStyle(AppTheme.textOnGreen)
                            Text(config.tierName)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(theme.gold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(theme.accent.opacity(0.3)))
                        }
                        Text(mode.subtitle)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textMutedOnGreen)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "play.fill")
                        .font(.body.weight(.bold))
                        .foregroundStyle(theme.gold)
                        .padding(12)
                        .background(Circle().fill(AppTheme.panelFillStrong))
                }

                XPProgressBar(progress: progress.xpProgress(for: mode), level: level, theme: theme)

                FlowTagsView(tags: config.difficultyTags, theme: theme)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [theme.feltTop.opacity(0.55), theme.feltMid.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(
                                LinearGradient(colors: [theme.gold.opacity(0.7), theme.accent.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: theme.accent.opacity(0.2), radius: 10, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct FlowTagsView: View {
    let tags: [String]
    let theme: ModeTheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(theme.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                }
            }
        }
    }
}

struct ModeSelectView: View {
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: L10n.s("how_to_play"), onBack: { route = .menu })
                ScrollView {
                    AdaptiveMenuContainer {
                        LazyVStack(spacing: 12) {
                            Text(L10n.s("modes_intro"))
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(SolitaireMode.puzzleModes) { mode in
                                modeHelpCard(mode)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private func modeHelpCard(_ mode: SolitaireMode) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: mode.iconName)
                    .font(.title2)
                    .foregroundStyle(AppTheme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text(mode.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(mode.quickRules, id: \.self) { rule in
                    Text("• \(rule)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                }
                Text("• \(mode.controlsHint)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
            }

            AppButton(title: L10n.s("play_mode_fmt", mode.title), systemImage: "play.fill", style: .gold) {
                route = .game(mode, daily: false)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFill)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }
}

struct RankingsView: View {
    @ObservedObject var progress = ProgressStore.shared
    @ObservedObject var gameCenter = GameCenterManager.shared
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: L10n.s("rankings"), onBack: { route = .menu })
                ScrollView {
                    AdaptiveMenuContainer {
                        VStack(spacing: 12) {
                            summaryCard

                            AppButton(title: L10n.s("open_game_center"), systemImage: "gamecontroller.fill", style: .gold) {
                                gameCenter.showLeaderboards()
                            }

                            Text(L10n.s("your_best_times"))
                                .font(.headline)
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)

                            ForEach(SolitaireMode.puzzleModes) { mode in
                                bestRow(mode)
                            }

                            ResetProgressButton()
                                .padding(.top, 8)
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 8) {
            Text(L10n.s("total_play_time"))
                .font(.caption)
                .foregroundStyle(AppTheme.textMutedOnGreen)
            Text(formatLong(progress.totalTimePlayed))
                .font(.title.weight(.black))
                .foregroundStyle(AppTheme.gold)
            Text(L10n.s("wins_streak_fmt", progress.totalWins, progress.streak))
                .font(.caption)
                .foregroundStyle(AppTheme.textMutedOnGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(panel)
    }

    private func bestRow(_ mode: SolitaireMode) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.title)
                    .foregroundStyle(AppTheme.textOnGreen)
                Text(L10n.s("level_tier_fmt", progress.level(for: mode), LevelConfig.forMode(mode, level: progress.level(for: mode)).tierName))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textMutedOnGreen)
            }
            Spacer()
            if mode.usesScoreLeaderboard, let s = progress.bestScores[mode.rawValue] {
                Text(L10n.s("score_fmt", s))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
            } else if let t = progress.bestTimes[mode.rawValue] {
                Text(formatTime(t))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
            } else {
                Text("—")
                    .foregroundStyle(AppTheme.textMutedOnGreen)
            }
        }
        .padding(14)
        .background(panel)
    }

    private var panel: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppTheme.panelFill)
            .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
    }

    private func formatTime(_ t: TimeInterval) -> String {
        String(format: "%d:%02d", Int(t) / 60, Int(t) % 60)
    }

    private func formatLong(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        let s = Int(t) % 60
        if h > 0 { return String(format: "%dh %02dm", h, m) }
        return String(format: "%d:%02d", m, s)
    }
}
