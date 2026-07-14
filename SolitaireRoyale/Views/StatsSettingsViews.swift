import SwiftUI

struct StatsView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                navBar(title: "Estadísticas")
                ScrollView {
                    VStack(spacing: 14) {
                        levelCard
                        gridStat(title: "Victorias", value: "\(progress.wins.values.reduce(0, +))", icon: "trophy")
                        gridStat(title: "Racha actual", value: "\(progress.streak)", icon: "star")
                        gridStat(title: "Mejor racha", value: "\(progress.bestStreak)", icon: "trophy")
                        gridStat(title: "Nivel", value: "\(progress.level)", icon: "trophy")
                        gridStat(title: "Combo máximo", value: "\(progress.maxCombo)", icon: "play")
                        gridStat(title: "Movimientos totales", value: "\(progress.totalMoves)", icon: "play")

                        Text("Por modo")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(SolitaireMode.allCases) { mode in
                            HStack {
                                Text(mode.title).foregroundStyle(.white)
                                Spacer()
                                Text("\(progress.wins[mode.rawValue, default: 0]) W")
                                    .foregroundStyle(.yellow)
                                if let t = progress.bestTimes[mode.rawValue] {
                                    Text(bestTime(t))
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(glassPanel)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var levelCard: some View {
        VStack(spacing: 8) {
            Text("Nivel \(progress.level)")
                .font(.title2.weight(.black))
                .foregroundStyle(.white)
            ProgressView(value: progress.xpProgress)
                .tint(.yellow)
            Text("\(progress.xp % progress.xpForNextLevel) / \(progress.xpForNextLevel) XP")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding()
        .background(glassPanel)
    }

    private func gridStat(title: String, value: String, icon: String) -> some View {
        HStack {
            BundleImage(name: "\(icon).png", folder: "GameAssets/Icons")
                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundStyle(.white.opacity(0.7))
                Text(value).font(.title3.weight(.bold)).foregroundStyle(.white)
            }
            Spacer()
        }
        .padding()
        .background(glassPanel)
    }

    private func bestTime(_ t: TimeInterval) -> String {
        String(format: "%d:%02d", Int(t) / 60, Int(t) % 60)
    }

    private var glassPanel: some View {
        BundleImage(name: "panel.png", folder: "GameAssets/UI")
            .opacity(0.85)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func navBar(title: String) -> some View {
        HStack {
            Button { route = .menu; AudioManager.shared.click() } label: {
                BundleImage(name: "home.png", folder: "GameAssets/Icons").frame(width: 32, height: 32)
            }
            Spacer()
            Text(title).font(.title2.weight(.bold)).foregroundStyle(.white)
            Spacer()
            CoinBar()
        }
        .padding()
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
                navBar(title: "Ajustes")
                ScrollView {
                    VStack(spacing: 12) {
                        toggleRow("Música", isOn: $audio.musicEnabled)
                        toggleRow("Efectos de sonido", isOn: $audio.sfxEnabled)
                        toggleRow("Vibración háptica", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { HapticsManager.enabled = $0 }
                        toggleRow("Auto-completar al ganar", isOn: $autoComplete)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(AppIdentity.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("v\(AppIdentity.version) (\(AppIdentity.build))")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Text("Bundle: \(AppIdentity.bundleID)")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(glassPanel)
                    }
                    .padding()
                }
            }
        }
        .onAppear { hapticsEnabled = HapticsManager.enabled }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title).foregroundStyle(.white).font(.body.weight(.medium))
        }
        .tint(.green)
        .padding()
        .background(glassPanel)
    }

    private var glassPanel: some View {
        BundleImage(name: "panel.png", folder: "GameAssets/UI")
            .opacity(0.85)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func navBar(title: String) -> some View {
        HStack {
            Button { route = .menu; AudioManager.shared.click() } label: {
                BundleImage(name: "home.png", folder: "GameAssets/Icons").frame(width: 32, height: 32)
            }
            Spacer()
            Text(title).font(.title2.weight(.bold)).foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 80, height: 1)
        }
        .padding()
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
                navBar(title: "Logros")
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(progress.achievements) { ach in
                            achievementRow(ach)
                        }
                    }
                    .padding()
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
            BundleImage(name: ach.isComplete ? "trophy.png" : "locked.png", folder: "GameAssets/Icons")
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(ach.title).font(.headline).foregroundStyle(.white)
                Text(ach.detail).font(.caption).foregroundStyle(.white.opacity(0.7))
                ProgressView(value: Double(ach.progress), total: Double(ach.goal))
                    .tint(ach.isComplete ? .yellow : .green)
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
                .padding(8)
                .background(Color.yellow.opacity(0.3))
                .clipShape(Capsule())
            } else if ach.claimed {
                Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
            }
        }
        .padding()
        .background(
            BundleImage(name: "panel.png", folder: "GameAssets/UI").opacity(0.85)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func navBar(title: String) -> some View {
        HStack {
            Button { route = .menu; AudioManager.shared.click() } label: {
                BundleImage(name: "home.png", folder: "GameAssets/Icons").frame(width: 32, height: 32)
            }
            Spacer()
            Text(title).font(.title2.weight(.bold)).foregroundStyle(.white)
            Spacer()
            CoinBar()
        }
        .padding()
    }
}
