import SwiftUI

struct StatsView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: "Estadísticas", onBack: { route = .menu })
                ScrollView {
                    VStack(spacing: 12) {
                        levelCard
                        gridStat(title: "Victorias", value: "\(progress.wins.values.reduce(0, +))", icon: "trophy.fill")
                        gridStat(title: "Racha actual", value: "\(progress.streak)", icon: "flame.fill")
                        gridStat(title: "Mejor racha", value: "\(progress.bestStreak)", icon: "star.fill")
                        gridStat(title: "Nivel", value: "\(progress.level)", icon: "chart.line.uptrend.xyaxis")
                        gridStat(title: "Combo máximo", value: "\(progress.maxCombo)", icon: "bolt.fill")

                        Text("Por modo")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textMutedOnGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(SolitaireMode.allCases) { mode in
                            HStack {
                                Text(mode.title).foregroundStyle(AppTheme.textOnGreen)
                                Spacer()
                                Text("\(progress.wins[mode.rawValue, default: 0]) victorias")
                                    .foregroundStyle(AppTheme.gold)
                                if let t = progress.bestTimes[mode.rawValue] {
                                    Text(bestTime(t))
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textMutedOnGreen)
                                }
                            }
                            .padding(14)
                            .background(panel)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var levelCard: some View {
        VStack(spacing: 8) {
            Text("Nivel \(progress.level)")
                .font(.title2.weight(.black))
                .foregroundStyle(AppTheme.textOnGreen)
            ProgressView(value: progress.xpProgress)
                .tint(AppTheme.gold)
            Text("\(progress.xp % progress.xpForNextLevel) / \(progress.xpForNextLevel) XP")
                .font(.caption)
                .foregroundStyle(AppTheme.textMutedOnGreen)
        }
        .padding(16)
        .background(panel)
    }

    private func gridStat(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundStyle(AppTheme.textMutedOnGreen)
                Text(value).font(.title3.weight(.bold)).foregroundStyle(AppTheme.textOnGreen)
            }
            Spacer()
        }
        .padding(14)
        .background(panel)
    }

    private func bestTime(_ t: TimeInterval) -> String {
        String(format: "%d:%02d", Int(t) / 60, Int(t) % 60)
    }

    private var panel: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppTheme.panelFill)
            .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
    }
}

struct SettingsView: View {
    @ObservedObject var audio = AudioManager.shared
    @Binding var route: AppRoute
    @AppStorage("autoComplete") private var autoComplete = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: "Ajustes", onBack: { route = .menu }, showCoins: false)
                ScrollView {
                    VStack(spacing: 12) {
                        toggleRow("Música", isOn: $audio.musicEnabled)
                        toggleRow("Efectos de sonido", isOn: $audio.sfxEnabled)
                        toggleRow("Vibración", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { HapticsManager.enabled = $0 }
                        toggleRow("Auto-completar al ganar", isOn: $autoComplete)

                        AppButton(title: "Tienda", systemImage: "bag.fill", style: .secondary) {
                            route = .shop
                        }
                        AppButton(title: "Logros", systemImage: "trophy.fill", style: .secondary) {
                            route = .achievements
                        }

                        AppButton(title: "Ver tutorial otra vez", systemImage: "arrow.counterclockwise", style: .secondary) {
                            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                        }

                        AppPanel {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppIdentity.name)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textOnGreen)
                                Text("Versión \(AppIdentity.version) (\(AppIdentity.build))")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textMutedOnGreen)
                                Link("Política de privacidad", destination: URL(string: AppIdentity.privacyURL)!)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.gold)
                                Text("Anuncios ocasionales en el menú (máx. cada 5 min)")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.textMutedOnGreen)
                                Text("Assets CC0: Kenney, Byron Knoll")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.textMutedOnGreen)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .onAppear { hapticsEnabled = HapticsManager.enabled }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .foregroundStyle(AppTheme.textOnGreen)
                .font(.body.weight(.medium))
        }
        .tint(AppTheme.accent)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFill)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }
}

struct AchievementsView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute
    @State private var claimedToast: String?

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: "Logros", onBack: { route = .menu })
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(progress.achievements) { ach in
                            achievementRow(ach)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .alert("Logro", isPresented: .init(get: { claimedToast != nil }, set: { if !$0 { claimedToast = nil } })) {
            Button("OK") { claimedToast = nil }
        } message: {
            Text(claimedToast ?? "")
        }
    }

    private func achievementRow(_ ach: Achievement) -> some View {
        HStack(spacing: 12) {
            Image(systemName: ach.isComplete ? "trophy.fill" : "lock.fill")
                .font(.title3)
                .foregroundStyle(ach.isComplete ? AppTheme.gold : AppTheme.textMutedOnGreen)
            VStack(alignment: .leading, spacing: 4) {
                Text(ach.title).font(.headline).foregroundStyle(AppTheme.textOnGreen)
                Text(ach.detail).font(.caption).foregroundStyle(AppTheme.textMutedOnGreen)
                ProgressView(value: Double(ach.progress), total: Double(ach.goal))
                    .tint(ach.isComplete ? AppTheme.gold : AppTheme.accent)
            }
            Spacer()
            if ach.isComplete && !ach.claimed {
                Button("+\(ach.coinReward)") {
                    if let r = progress.claimAchievement(ach.id) {
                        claimedToast = "¡+\(r) monedas!"
                        HapticsManager.coin()
                    }
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.textOnGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(AppTheme.gold.opacity(0.35)))
            } else if ach.claimed {
                Image(systemName: "checkmark.seal.fill").foregroundStyle(AppTheme.accent)
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
