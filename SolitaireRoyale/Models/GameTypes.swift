import Foundation

struct GridPos: Hashable, Codable {
    let row: Int
    let col: Int
}

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0xDEAD_BEEF_CAFE_BABE : seed
    }

    mutating func next() -> UInt64 {
        state &*= 6_364_136_223_847_093_763
        state &+= 1
        return state
    }
}

extension Int {
    static func random(in range: Range<Int>, using rng: inout SeededRNG) -> Int {
        let span = UInt64(range.upperBound - range.lowerBound)
        return range.lowerBound + Int(rng.next() % span)
    }
}
