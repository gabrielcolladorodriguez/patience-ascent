import Foundation

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
