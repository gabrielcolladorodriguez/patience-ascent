import Foundation

enum SolitaireMode: String, CaseIterable, Identifiable, Codable {
    case klondike
    case freeCell
    case spider
    case pyramid
    case triPeaks
    case golf
    case yukon
    case fortyThieves

    var id: String { rawValue }

    var title: String {
        switch self {
        case .klondike: return "Klondike"
        case .freeCell: return "FreeCell"
        case .spider: return "Spider"
        case .pyramid: return "Pirámide"
        case .triPeaks: return "TriPeaks"
        case .golf: return "Golf"
        case .yukon: return "Yukon"
        case .fortyThieves: return "40 Ladrones"
        }
    }

    var subtitle: String {
        switch self {
        case .klondike: return "El clásico de siempre"
        case .freeCell: return "Estrategia pura"
        case .spider: return "Secuencias del mismo palo"
        case .pyramid: return "Suma 13 para limpiar"
        case .triPeaks: return "Conquista las cumbres"
        case .golf: return "Sube o baja en secuencia"
        case .yukon: return "Klondike sin mazo"
        case .fortyThieves: return "Dos barajas, diez columnas"
        }
    }

    var unlockCost: Int {
        switch self {
        case .klondike: return 0
        case .freeCell: return 500
        case .spider: return 800
        case .pyramid: return 600
        case .triPeaks: return 700
        case .golf: return 500
        case .yukon: return 900
        case .fortyThieves: return 1000
        }
    }

    var winReward: Int {
        switch self {
        case .klondike: return 50
        case .freeCell: return 80
        case .spider: return 120
        case .pyramid: return 70
        case .triPeaks: return 90
        case .golf: return 60
        case .yukon: return 100
        case .fortyThieves: return 150
        }
    }

    var isFree: Bool { unlockCost == 0 }
}
