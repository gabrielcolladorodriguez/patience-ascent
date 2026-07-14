import SwiftUI

struct MainMenuView: View {
    @Binding var route: AppRoute
    @ObservedObject private var progress = ProgressStore.shared
    @ObservedObject private var audio = AudioManager.shared
    @State private var showSettings = false
    @State private var showRankings = false
    @State private var showResetConfirm = false

    private let theme = SolitaireMode.gravityBlocks.theme

    var body: some View {
        ZStack {
            GameBackground(theme: theme)
            AdaptiveMenuContainer {
                VStack(spacing: 20) {
                    Spacer(minLength: 8)

                    VStack(spacing: 6) {
                        Text(AppIdentity.name)
                            .font(AppTheme.titleFont(36))
                            .foregroundStyle(AppTheme.goldShineGradient)
                            .shadow(color: AppTheme.gold.opacity(0.35), radius: 8)

                        Text(L10n.tagline)
                            .font(AppTheme.bodyFont(.semibold))
                            .foregroundStyle(AppTheme.textMutedOnGreen)
                            .multilineTextAlignment(.center)
                    }

                    statsCard

                    AppButton(title: L10n.s("play_now"), systemImage: "play.fill", style: .gold) {
                        route = .game
                    }

                    AppButton(title: L10n.s("top100_title"), systemImage: "trophy.fill", style: .secondary) {
                        showRankings = true
                    }

                    HStack(spacing: 12) {
                        AppButton(title: L10n.s("how_to_play"), systemImage: "questionmark.circle", style: .secondary) {
                            showSettings = true
                        }
                        AppButton(title: L10n.s("settings"), systemImage: "gearshape.fill", style: .secondary) {
                            showSettings = true
                        }
                    }

                    if progress.gamesPlayed > 0 {
                        Button(L10n.s("reset_progress")) {
                            showResetConfirm = true
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textMutedOnGreen.opacity(0.8))
                    }

                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .onAppear { AudioManager.shared.startMenuMusic() }
        .sheet(isPresented: $showSettings) { settingsSheet }
        .sheet(isPresented: $showRankings) { AscentTop100View() }
        .alert(L10n.s("reset_progress"), isPresented: $showResetConfirm) {
            Button(L10n.s("cancel"), role: .cancel) {}
            Button(L10n.s("reset_confirm"), role: .destructive) {
                progress.resetAllProgress()
            }
        } message: {
            Text(L10n.s("reset_message"))
        }
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(title: L10n.s("best_label"), value: L10n.s("score_fmt", progress.bestScore))
            Divider().frame(height: 36).overlay(AppTheme.panelStroke)
            statItem(title: L10n.s("games_played"), value: "\(progress.gamesPlayed)")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFill)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke))
        )
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textMutedOnGreen)
            Text(value)
                .font(.headline.weight(.bold).monospacedDigit())
                .foregroundStyle(AppTheme.textOnGreen)
        }
        .frame(maxWidth: .infinity)
    }

    private var settingsSheet: some View {
        NavigationStack {
            ZStack {
                GameBackground(theme: theme)
                VStack(spacing: 16) {
                    toggleRow(title: L10n.s("music"), isOn: $audio.musicEnabled)
                    toggleRow(title: L10n.s("sound"), isOn: $audio.sfxEnabled)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.s("how_to_play"))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.textOnGreen)
                        ForEach(SolitaireMode.gravityBlocks.quickRules, id: \.self) { rule in
                            Text("• \(rule)")
                                .font(AppTheme.bodyFont())
                                .foregroundStyle(AppTheme.textMutedOnGreen)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.panelFill))

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(L10n.s("settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.s("got_it")) { showSettings = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textOnGreen)
        }
        .tint(AppTheme.accent)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.panelFill))
    }
}
