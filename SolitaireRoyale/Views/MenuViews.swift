import SwiftUI

struct MainMenuView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute
    @State private var dailyReward = 0

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 20) {
                Spacer()
                BundleImage(name: "trophy.png", folder: "Resources/Icons")
                    .frame(width: 72, height: 72)
                Text(AppIdentity.name)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(AppIdentity.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                levelBar

                HStack(spacing: 16) {
                    statPill(title: "Racha", value: "\(progress.streak)")
                    statPill(title: "Victorias", value: "\(progress.wins.values.reduce(0, +))")
                    statPill(title: "Nivel", value: "\(progress.level)")
                }

                if !progress.dailyChallenge.completed {
                    dailyChallengeCard
                }

                VStack(spacing: 12) {
                    KenneyButton(title: "JUGAR", icon: "play", style: .primary) {
                        AudioManager.shared.click()
                        route = .modes
                    }
                    HStack(spacing: 10) {
                        KenneyButton(title: "TIENDA", icon: "shop", style: .secondary) {
                            AudioManager.shared.click()
                            route = .shop
                        }
                        KenneyButton(title: "LOGROS", icon: "trophy", style: .secondary) {
                            AudioManager.shared.click()
                            route = .achievements
                        }
                    }
                    HStack(spacing: 10) {
                        KenneyButton(title: "STATS", icon: "star", style: .secondary) {
                            AudioManager.shared.click()
                            route = .stats
                        }
                        KenneyButton(title: "AJUSTES", icon: "home", style: .secondary) {
                            AudioManager.shared.click()
                            route = .settings
                        }
                    }
                    if progress.canClaimDaily {
                        KenneyButton(title: "RECOMPENSA DIARIA", icon: "coin", style: .primary) {
                            dailyReward = progress.claimDailyReward()
                            AudioManager.shared.win()
                        }
                    }
                }
                .padding(.horizontal, 28)

                CoinBar()
                Spacer()
            }
        }
        .alert("¡Recompensa diaria!", isPresented: .init(
            get: { dailyReward > 0 },
            set: { if !$0 { dailyReward = 0 } }
        )) {
            Button("Genial") { dailyReward = 0 }
        } message: {
            Text("Has recibido \(dailyReward) monedas")
        }
        .onAppear {
            AudioManager.shared.playMusic("menu_music.ogg")
        }
    }

    private var levelBar: some View {
        VStack(spacing: 4) {
            ProgressView(value: progress.xpProgress)
                .tint(.yellow)
                .frame(width: 220)
            Text("Nivel \(progress.level) · \(progress.xp % progress.xpForNextLevel)/\(progress.xpForNextLevel) XP")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var dailyChallengeCard: some View {
        let dc = progress.dailyChallenge
        return Button {
            AudioManager.shared.click()
            route = .game(dc.mode, daily: true)
        } label: {
            HStack {
                BundleImage(name: "star.png", folder: "Resources/Icons")
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Desafío del día")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("\(dc.mode.title) · +150 monedas")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
                Spacer()
                BundleImage(name: "play.png", folder: "Resources/Icons")
                    .frame(width: 28, height: 28)
            }
            .padding()
            .background(
                LinearGradient(colors: [.purple.opacity(0.5), .blue.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.yellow.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 28)
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.white.opacity(0.7))
            Text(value).font(.headline.weight(.bold)).foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ModeSelectView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute
    @State private var alertMessage: String?

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                header
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(SolitaireMode.allCases) { mode in
                            modeRow(mode)
                        }
                    }
                    .padding()
                }
            }
        }
        .alert(AppIdentity.name, isPresented: .init(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK") { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var header: some View {
        HStack {
            Button {
                AudioManager.shared.click()
                route = .menu
            } label: {
                BundleImage(name: "home.png", folder: "Resources/Icons")
                    .frame(width: 32, height: 32)
            }
            Spacer()
            Text("Modos")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Spacer()
            CoinBar()
        }
        .padding()
    }

    private func modeRow(_ mode: SolitaireMode) -> some View {
        let unlocked = progress.isUnlocked(mode)
        return Button {
            AudioManager.shared.click()
            if unlocked {
                route = .game(mode, daily: false)
            } else if progress.unlockMode(mode) {
                route = .game(mode, daily: false)
            } else {
                alertMessage = "Necesitas \(mode.unlockCost) monedas para desbloquear \(mode.title)"
            }
        } label: {
            HStack(spacing: 12) {
                BundleImage(name: unlocked ? "unlocked.png" : "locked.png", folder: "Resources/Icons")
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(mode.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                    Text("+\(mode.winReward) monedas al ganar")
                        .font(.caption2)
                        .foregroundStyle(.yellow.opacity(0.9))
                }
                Spacer()
                if !unlocked {
                    HStack(spacing: 4) {
                        BundleImage(name: "coin.png", folder: "Resources/Icons")
                            .frame(width: 18, height: 18)
                        Text("\(mode.unlockCost)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.yellow)
                    }
                } else {
                    BundleImage(name: "play.png", folder: "Resources/Icons")
                        .frame(width: 28, height: 28)
                }
            }
            .padding()
            .background(
                BundleImage(name: "panel.png", folder: "Resources/UI")
                    .opacity(0.85)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

struct ShopView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute
    @State private var toast: String?

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                HStack {
                    Button {
                        AudioManager.shared.click()
                        route = .menu
                    } label: {
                        BundleImage(name: "home.png", folder: "Resources/Icons")
                            .frame(width: 32, height: 32)
                    }
                    Spacer()
                    Text("Tienda")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    CoinBar()
                }
                .padding()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(ShopItemKind.allCases.filter { !$0.isIAPPlaceholder }) { item in
                            shopRow(item)
                        }
                        sectionHeader("Desbloquear modos")
                        ForEach(SolitaireMode.allCases.filter { !$0.isFree && !progress.isUnlocked($0) }) { mode in
                            modeUnlockRow(mode)
                        }
                        if !progress.ownedCardBacks.contains("card_back_blue") || !progress.ownedCardBacks.contains("card_back_green") {
                            sectionHeader("Reversos de carta")
                        }
                    }
                    .padding()
                }
            }
        }
        .alert("Tienda", isPresented: .init(get: { toast != nil }, set: { if !$0 { toast = nil } })) {
            Button("OK") { toast = nil }
        } message: {
            Text(toast ?? "")
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.white.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private func shopRow(_ item: ShopItemKind) -> some View {
        HStack {
            BundleImage(name: "\(item.iconName).png", folder: "Resources/Icons")
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(item.title).font(.headline).foregroundStyle(.white)
                HStack(spacing: 4) {
                    BundleImage(name: "coin.png", folder: "Resources/Icons").frame(width: 16, height: 16)
                    Text("\(item.price)").foregroundStyle(.yellow).font(.subheadline.weight(.bold))
                }
            }
            Spacer()
            KenneyButton(title: "Comprar", icon: nil, style: .secondary) {
                if progress.purchase(item) {
                    AudioManager.shared.win()
                    toast = "¡Comprado!"
                } else {
                    toast = "Monedas insuficientes"
                }
            }
            .frame(width: 130)
        }
        .padding()
        .background(BundleImage(name: "panel.png", folder: "Resources/UI").opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func modeUnlockRow(_ mode: SolitaireMode) -> some View {
        HStack {
            BundleImage(name: "locked.png", folder: "Resources/Icons").frame(width: 36, height: 36)
            VStack(alignment: .leading) {
                Text(mode.title).font(.headline).foregroundStyle(.white)
                Text(mode.subtitle).font(.caption).foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            KenneyButton(title: "\(mode.unlockCost)", icon: "coin", style: .primary) {
                if progress.unlockMode(mode) {
                    toast = "\(mode.title) desbloqueado"
                } else {
                    toast = "Monedas insuficientes"
                }
            }
            .frame(width: 130)
        }
        .padding()
        .background(BundleImage(name: "panel.png", folder: "Resources/UI").opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
