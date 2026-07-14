import SwiftUI

struct AscentTop100View: View {
    @ObservedObject private var gc = GameCenterManager.shared
    @Environment(\.dismiss) private var dismiss
    private let theme = SolitaireMode.gravityBlocks.theme

    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground(theme: theme)
                content
            }
            .navigationTitle(L10n.s("top100_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.s("close")) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await gc.refreshTop100() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(gc.isLoadingLeaderboard)
                }
            }
            .task { await gc.refreshTop100() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if gc.isLoadingLeaderboard && gc.top100.isEmpty {
            ProgressView(L10n.s("loading_rankings"))
                .tint(AppTheme.gold)
        } else if let error = gc.leaderboardError, gc.top100.isEmpty {
            VStack(spacing: 14) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.gold)
                Text(error)
                    .font(AppTheme.bodyFont())
                    .foregroundStyle(AppTheme.textMutedOnGreen)
                    .multilineTextAlignment(.center)
                AppButton(title: L10n.s("retry"), systemImage: "arrow.clockwise", style: .secondary) {
                    Task { await gc.refreshTop100() }
                }
                .padding(.horizontal, 40)
            }
            .padding(24)
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    localPlayerCard
                    leaderboardList
                }
                .padding(16)
            }
        }
    }

    private var localPlayerCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.gold)

            VStack(alignment: .leading, spacing: 2) {
                Text(gc.playerName.isEmpty ? L10n.s("you") : gc.playerName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.textOnGreen)
                if let rank = gc.localRank {
                    Text(L10n.s("your_rank_fmt", rank))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                } else {
                    Text(L10n.s("not_ranked_yet"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textMutedOnGreen)
                }
            }

            Spacer()

            Text(L10n.s("score_fmt", max(gc.localScore, ProgressStore.shared.bestScore)))
                .font(.title3.weight(.black).monospacedDigit())
                .foregroundStyle(AppTheme.gold)
        }
        .padding(14)
        .background(cardBackground)
    }

    private var leaderboardList: some View {
        VStack(spacing: 6) {
            HStack {
                Text(L10n.s("top100_header"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textMutedOnGreen)
                Spacer()
                Text(L10n.s("score_label"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textMutedOnGreen)
            }
            .padding(.horizontal, 8)

                    if gc.top100.isEmpty {
                Text(L10n.s("no_scores_yet"))
                    .font(AppTheme.bodyFont())
                    .foregroundStyle(AppTheme.textMutedOnGreen)
                    .padding(.vertical, 24)
            } else {
                ForEach(gc.top100) { row in
                    rankRow(row)
                }
            }

            AppButton(title: L10n.s("open_game_center"), systemImage: "gamecontroller.fill", style: .compact) {
                gc.showNativeLeaderboards()
            }
            .padding(.top, 8)
        }
        .padding(12)
        .background(cardBackground)
    }

    private func rankRow(_ row: LeaderboardRow) -> some View {
        HStack(spacing: 10) {
            rankBadge(row.rank)
            Text(row.playerName)
                .font(.subheadline.weight(row.isLocalPlayer ? .bold : .medium))
                .foregroundStyle(row.isLocalPlayer ? AppTheme.gold : AppTheme.textOnGreen)
                .lineLimit(1)
            Spacer()
            Text(L10n.s("score_fmt", row.score))
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(AppTheme.textOnGreen)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(row.isLocalPlayer ? AppTheme.gold.opacity(0.12) : Color.clear)
        )
    }

    @ViewBuilder
    private func rankBadge(_ rank: Int) -> some View {
        let medal = rank <= 3
        Text("\(rank)")
            .font(.caption.weight(.black).monospacedDigit())
            .foregroundStyle(medal ? .black : AppTheme.textOnGreen)
            .frame(width: 28, height: 28)
            .background(
                Circle().fill(medal ? medalColor(rank) : AppTheme.panelFillStrong)
            )
    }

    private func medalColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return AppTheme.gold
        case 2: return Color(white: 0.78)
        case 3: return Color(red: 0.82, green: 0.55, blue: 0.32)
        default: return AppTheme.panelFill
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(AppTheme.panelFill)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.panelStroke))
    }
}
