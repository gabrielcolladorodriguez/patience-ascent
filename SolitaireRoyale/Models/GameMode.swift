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

    var isFree: Bool { true }

    /// Reglas rápidas (2 líneas) para el jugador casual
    var quickRules: [String] {
        switch self {
        case .klondike:
            return [
                "Coloca cartas alternando color y bajando de valor (K→Q→J…).",
                "Toca el mazo para sacar cartas; arrastra a las 4 pilas superiores.",
                "Objetivo: subir todas las cartas del As al Rey por palo."
            ]
        case .freeCell:
            return [
                "Mueve una carta a una celda libre (máx. 4) como apoyo temporal.",
                "En columnas: color alterno y valor descendente.",
                "Vacía todas las columnas llevando cartas a las 4 bases."
            ]
        case .spider:
            return [
                "Ordena secuencias del mismo palo de Rey a As en columnas.",
                "Una secuencia completa se retira sola.",
                "Objetivo: limpiar las 8 secuencias del tablero."
            ]
        case .pyramid:
            return [
                "Toca dos cartas visibles que sumen 13 (ej. Q + As).",
                "El Rey vale 13 y se elimina solo.",
                "Limpia toda la pirámide para ganar."
            ]
        case .triPeaks:
            return [
                "Toca cartas ±1 en valor respecto a la carta de descarte.",
                "Las cartas sin bloqueo quedan disponibles.",
                "Elimina los 3 picos del tablero."
            ]
        case .golf:
            return [
                "Coloca en descarte cartas ±1 en valor (As junto a 2 o K).",
                "Solo cartas libres en las 7 columnas.",
                "Vacía todas las columnas para ganar."
            ]
        case .yukon:
            return [
                "Como Klondike pero puedes mover grupos sin orden previo.",
                "Colores alternos y valores descendentes al apilar.",
                "Sube los 4 palos completos a las bases."
            ]
        case .fortyThieves:
            return [
                "Dos barajas: apila mismo palo y valor descendente.",
                "Solo la carta superior de cada columna se mueve.",
                "Llena las 8 bases del As al Rey."
            ]
        }
    }

    var controlsHint: String {
        "Toca · Arrastra · Pista ilimitada"
    }

    var iconName: String {
        switch self {
        case .klondike: return "suit.spade.fill"
        case .freeCell: return "square.grid.3x3.fill"
        case .spider: return "square.stack.3d.up.fill"
        case .pyramid: return "triangle.fill"
        case .triPeaks: return "mountain.2.fill"
        case .golf: return "flag.fill"
        case .yukon: return "snowflake"
        case .fortyThieves: return "lock.shield.fill"
        }
    }
}
