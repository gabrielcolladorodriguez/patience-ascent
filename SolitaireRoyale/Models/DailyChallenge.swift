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
        let modes = SolitaireMode.puzzleModes
        let mode = modes[dayIndex % modes.count]
        let seed = UInt64(dayIndex) &* 1_103_515_245 &+ 12_345
        return DailyChallenge(dateKey: String(key), mode: mode, seed: seed, completed: false)
    }

    /// Migrate saved challenges from older app versions.
    static func normalize(_ challenge: DailyChallenge) -> DailyChallenge {
        guard SolitaireMode.puzzleModes.contains(challenge.mode) else {
            return DailyChallenge(
                dateKey: challenge.dateKey,
                mode: .glyphLink,
                seed: challenge.seed,
                completed: challenge.completed
            )
        }
        return challenge
    }
}
