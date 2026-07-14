import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let detail: String
    let coinReward: Int
    let goal: Int
    var progress: Int
    var claimed: Bool

    var isComplete: Bool { progress >= goal }
}

enum AchievementCatalog {
    static let all: [Achievement] = [
        Achievement(id: "first_win", title: "Primera Victoria", detail: "Gana tu primera partida", coinReward: 50, goal: 1, progress: 0, claimed: false),
        Achievement(id: "wins_10", title: "Veterano", detail: "Gana 10 partidas", coinReward: 100, goal: 10, progress: 0, claimed: false),
        Achievement(id: "wins_50", title: "Maestro de Fieltro", detail: "Gana 50 partidas", coinReward: 300, goal: 50, progress: 0, claimed: false),
        Achievement(id: "streak_5", title: "En Racha", detail: "Consigue racha de 5", coinReward: 80, goal: 5, progress: 0, claimed: false),
        Achievement(id: "streak_15", title: "Imparable", detail: "Consigue racha de 15", coinReward: 250, goal: 15, progress: 0, claimed: false),
        Achievement(id: "modes_3", title: "Explorador", detail: "Desbloquea 3 modos", coinReward: 120, goal: 3, progress: 0, claimed: false),
        Achievement(id: "modes_all", title: "Ascenso Completo", detail: "Desbloquea los 8 modos", coinReward: 500, goal: 8, progress: 0, claimed: false),
        Achievement(id: "daily_7", title: "Fiel Jugador", detail: "Reclama 7 días seguidos", coinReward: 200, goal: 7, progress: 0, claimed: false),
        Achievement(id: "klondike_speed", title: "Relámpago", detail: "Gana Klondike en menos de 3 min", coinReward: 150, goal: 1, progress: 0, claimed: false),
        Achievement(id: "combo_10", title: "Combo x10", detail: "Encadena 10 movimientos seguidos", coinReward: 100, goal: 10, progress: 0, claimed: false)
    ]
}

struct DailyChallenge: Codable, Equatable {
    let dateKey: String
    let mode: SolitaireMode
    let seed: UInt64
    var completed: Bool

    static func today() -> DailyChallenge {
        let today = Calendar.current.startOfDay(for: Date())
        let key = ISO8601DateFormatter().string(from: today).prefix(10)
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: today) ?? 1
        let mode = SolitaireMode.allCases[dayIndex % SolitaireMode.allCases.count]
        let seed = UInt64(dayIndex) &* 1_103_515_245 &+ 12_345
        return DailyChallenge(dateKey: String(key), mode: mode, seed: seed, completed: false)
    }
}
