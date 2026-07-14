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
                VStack(spacing: 20) {
                    Spacer(minLength: 16)

                    header

                    if !progress.dailyChallenge.completed {
                        dailyCard
                    }

                    VStack(spacing: 12) {
                        AppButton(title: "Jugar", systemImage: "play.fill", style: .primary) {
                            route = .game(.klondike, daily: false)
                        }

                        AppButton(title: "Elegir modo", systemImage: "square.grid.2x2", style: .secondary) {
                            route = .modes
                        }

                        AppButton(title: "Rankings", systemImage: "chart.bar.fill", style: .secondary) {
                            route = .rankings
                        }
                    }

                    quickStats

                    audioToggles

                    Spacer(minLength: 8)

                    if gameCenter.isAuthenticated {
                        Text("Game Center · \(gameCenter.playerName)")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textMutedOnGreen)
                    }

                    Link("Privacidad", destination: URL(string: AppIdentity.privacyURL)!)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textMutedOnGreen.opacity(0.7))
                }
                .padding(.horizontal, 22)
            }
        }
        .onAppear { AudioManager.shared.playMusic("menu_music.wav") }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "suit.spade.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.gold)
                .shadow(color: AppTheme.gold.opacity(0.3), radius: 10)
            Text(AppIdentity.name)
                .font(AppTheme.titleFont(34))
                .foregroundStyle(AppTheme.textOnGreen)
            Text("Relájate. Juega. Mejora tu tiempo.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textMutedOnGreen)
                .multilineTextAlignment(.center)
        }
    }

    private var quickStats: some View {
        HStack(spacing: 10) {
            statPill("Victorias", "\(progress.totalWins)")
            statPill("Racha", "\(progress.streak)")
            statPill("Tiempo", formatDuration(progress.totalTimePlayed))
        }
    }

    private var audioToggles: some View {
        HStack(spacing: 10) {
            miniToggle("Música", isOn: $audio.musicEnabled)
            miniToggle("Sonido", isOn: $audio.sfxEnabled)
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
                    Text("Desafío de hoy")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text(dc.mode.title)
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
        .tint(AppTheme.accent)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.panelFill)
        )
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

struct ModeSelectView: View {
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: "Modos", onBack: { route = .menu })
                ScrollView {
                    AdaptiveMenuContainer {
                        LazyVStack(spacing: 10) {
                            ForEach(SolitaireMode.allCases) { mode in
                                modeRow(mode)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private func modeRow(_ mode: SolitaireMode) -> some View {
        Button {
            AudioManager.shared.click()
            route = .game(mode, daily: false)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mode.iconName)
                    .font(.title2)
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text(mode.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                }
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.gold)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.panelFill)
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
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
                ScreenHeader(title: "Rankings", onBack: { route = .menu })
                ScrollView {
                    AdaptiveMenuContainer {
                        VStack(spacing: 12) {
                            summaryCard

                            AppButton(title: "Ver Game Center", systemImage: "gamecontroller.fill", style: .primary) {
                                gameCenter.showLeaderboards()
                            }

                            Text("Tus mejores tiempos")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)

                            ForEach(SolitaireMode.allCases) { mode in
                                bestTimeRow(mode)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 8) {
            Text("Tiempo total jugado")
                .font(.caption)
                .foregroundStyle(AppTheme.textMutedOnGreen)
            Text(formatLong(progress.totalTimePlayed))
                .font(.title.weight(.black))
                .foregroundStyle(AppTheme.gold)
            Text("\(progress.totalWins) victorias · racha \(progress.streak)")
                .font(.caption)
                .foregroundStyle(AppTheme.textMutedOnGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(panel)
    }

    private func bestTimeRow(_ mode: SolitaireMode) -> some View {
        HStack {
            Text(mode.title)
                .foregroundStyle(AppTheme.textOnGreen)
            Spacer()
            if let t = progress.bestTimes[mode.rawValue] {
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
