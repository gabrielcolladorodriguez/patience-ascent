import SwiftUI

struct MainMenuView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute
    @State private var dailyReward = 0

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 18) {
                Spacer(minLength: 8)

                VStack(spacing: 6) {
                    Image(systemName: "suit.spade.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.gold)
                    Text(AppIdentity.name)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text("Solitarios sencillos en vertical")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                }

                HStack(spacing: 12) {
                    miniStat("Victorias", "\(progress.wins.values.reduce(0, +))")
                    miniStat("Racha", "\(progress.streak)")
                    miniStat("Nivel", "\(progress.level)")
                }

                if !progress.dailyChallenge.completed {
                    dailyChallengeCard
                }

                VStack(spacing: 10) {
                    AppButton(title: "Jugar Klondike", systemImage: "play.fill", style: .primary) {
                        route = .game(.klondike, daily: false)
                    }

                    AppButton(title: "Elegir modo", systemImage: "square.grid.2x2.fill", style: .secondary) {
                        route = .modes
                    }

                    HStack(spacing: 10) {
                        AppButton(title: "Cómo jugar", systemImage: "questionmark.circle.fill", style: .secondary) {
                            route = .howToPlay
                        }
                        AppButton(title: "Ajustes", systemImage: "gearshape.fill", style: .secondary) {
                            route = .settings
                        }
                    }

                    AppButton(title: "Estadísticas", systemImage: "chart.bar.fill", style: .secondary) {
                        route = .stats
                    }

                    if progress.canClaimDaily {
                        AppButton(title: "Recompensa diaria", systemImage: "gift.fill", style: .primary) {
                            dailyReward = progress.claimDailyReward()
                            AudioManager.shared.win()
                        }
                    }
                }
                .padding(.horizontal, 24)

                CoinBar()
                Spacer(minLength: 12)
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
        .onAppear { AudioManager.shared.playMusic("menu_music.wav") }
    }

    private func miniStat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.textOnGreen)
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

    private var dailyChallengeCard: some View {
        let dc = progress.dailyChallenge
        return Button {
            AudioManager.shared.click()
            route = .game(dc.mode, daily: true)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Desafío del día")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text("\(dc.mode.title) · +150 monedas")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.textMutedOnGreen)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.panelFill)
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.gold.opacity(0.4), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
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
                ScreenHeader(title: "Modos", onBack: { route = .menu })
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(SolitaireMode.allCases) { mode in
                            modeRow(mode)
                        }
                    }
                    .padding(16)
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
                Image(systemName: unlocked ? "lock.open.fill" : "lock.fill")
                    .font(.title3)
                    .foregroundStyle(unlocked ? AppTheme.gold : AppTheme.textMutedOnGreen)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textOnGreen)
                    Text(mode.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                    Text(mode.quickRules.first ?? "")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.gold.opacity(0.9))
                        .lineLimit(2)
                }
                Spacer()
                if !unlocked {
                    HStack(spacing: 4) {
                        BundleImage(name: "coin.png", folder: "GameAssets/Icons")
                            .frame(width: 16, height: 16)
                        Text("\(mode.unlockCost)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                    }
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.gold)
                }
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

struct ShopView: View {
    @ObservedObject var progress = ProgressStore.shared
    @Binding var route: AppRoute
    @State private var toast: String?

    var body: some View {
        ZStack {
            GameBackground()
            VStack(spacing: 0) {
                ScreenHeader(title: "Tienda", onBack: { route = .menu })
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(ShopItemKind.allCases.filter { !$0.isIAPPlaceholder }) { item in
                            shopRow(item)
                        }
                        sectionHeader("Desbloquear modos")
                        ForEach(SolitaireMode.allCases.filter { !$0.isFree && !progress.isUnlocked($0) }) { mode in
                            modeUnlockRow(mode)
                        }
                    }
                    .padding(16)
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
            .foregroundStyle(AppTheme.textMutedOnGreen)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private func shopRow(_ item: ShopItemKind) -> some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(AppTheme.gold)
                .frame(width: 32)
            VStack(alignment: .leading) {
                Text(item.title).font(.headline).foregroundStyle(AppTheme.textOnGreen)
                HStack(spacing: 4) {
                    BundleImage(name: "coin.png", folder: "GameAssets/Icons").frame(width: 14, height: 14)
                    Text("\(item.price)").foregroundStyle(AppTheme.gold).font(.subheadline.weight(.bold))
                }
            }
            Spacer()
            AppButton(title: "Comprar", style: .secondary) {
                if progress.purchase(item) {
                    AudioManager.shared.win()
                    toast = "¡Comprado!"
                } else {
                    toast = "Monedas insuficientes"
                }
            }
            .frame(width: 110)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFill)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }

    private func modeUnlockRow(_ mode: SolitaireMode) -> some View {
        HStack {
            Image(systemName: "lock.fill").foregroundStyle(AppTheme.textMutedOnGreen)
            VStack(alignment: .leading) {
                Text(mode.title).font(.headline).foregroundStyle(AppTheme.textOnGreen)
                Text(mode.subtitle).font(.caption).foregroundStyle(AppTheme.textMutedOnGreen)
            }
            Spacer()
            AppButton(title: "\(mode.unlockCost)", systemImage: "dollarsign.circle.fill", style: .primary) {
                if progress.unlockMode(mode) {
                    toast = "\(mode.title) desbloqueado"
                } else {
                    toast = "Monedas insuficientes"
                }
            }
            .frame(width: 110)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.panelFill)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.panelStroke, lineWidth: 1))
        )
    }
}
