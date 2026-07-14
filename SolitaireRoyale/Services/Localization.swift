import Foundation

/// In-app localization — 30+ languages from Resources/strings.json
enum L10n {
    private static let table: [String: [String: String]] = loadTable()

    static var languageCode: String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        let id = Locale(identifier: preferred).identifier

        if id.hasPrefix("zh-Hans") || preferred.hasPrefix("zh-CN") || preferred.hasPrefix("zh-SG") {
            return "zh-Hans"
        }
        if id.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-TW") || preferred.hasPrefix("zh-HK") {
            return "zh-Hant"
        }
        if preferred.hasPrefix("pt") { return "pt" }
        if preferred.hasPrefix("nb") || preferred.hasPrefix("nn") { return "no" }
        if preferred.hasPrefix("es") { return "es" }
        if preferred.hasPrefix("fr") { return "fr" }
        if preferred.hasPrefix("de") { return "de" }
        if preferred.hasPrefix("it") { return "it" }
        if preferred.hasPrefix("ja") { return "ja" }
        if preferred.hasPrefix("ko") { return "ko" }
        if preferred.hasPrefix("ru") { return "ru" }
        if preferred.hasPrefix("ar") { return "ar" }
        if preferred.hasPrefix("hi") { return "hi" }
        if preferred.hasPrefix("tr") { return "tr" }
        if preferred.hasPrefix("pl") { return "pl" }
        if preferred.hasPrefix("nl") { return "nl" }
        if preferred.hasPrefix("sv") { return "sv" }
        if preferred.hasPrefix("id") { return "id" }
        if preferred.hasPrefix("vi") { return "vi" }
        if preferred.hasPrefix("th") { return "th" }
        if preferred.hasPrefix("uk") { return "uk" }
        if preferred.hasPrefix("cs") { return "cs" }
        if preferred.hasPrefix("ro") { return "ro" }
        if preferred.hasPrefix("hu") { return "hu" }
        if preferred.hasPrefix("he") { return "he" }
        if preferred.hasPrefix("ca") { return "ca" }
        if preferred.hasPrefix("ms") { return "ms" }
        if preferred.hasPrefix("da") { return "da" }
        if preferred.hasPrefix("no") { return "no" }
        if preferred.hasPrefix("fi") { return "fi" }
        if preferred.hasPrefix("sk") { return "sk" }
        if preferred.hasPrefix("el") { return "el" }
        return "en"
    }

    static func s(_ key: String) -> String {
        table[key]?[languageCode] ?? table[key]?["en"] ?? key
    }

    static func s(_ key: String, _ args: CVarArg...) -> String {
        let format = s(key)
        return String(format: format, locale: Locale(identifier: languageCode), arguments: args)
    }

    static var tagline: String { s("tagline") }

    static func modeTitle(_ mode: SolitaireMode) -> String { mode.title }
    static func modeSubtitle(_ mode: SolitaireMode) -> String { mode.subtitle }
    static func controlsHint(_ mode: SolitaireMode) -> String { mode.controlsHint }

    private static func loadTable() -> [String: [String: String]] {
        guard let url = Bundle.main.url(forResource: "strings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [String: String]].self, from: data) else {
            return [:]
        }
        return decoded
    }
}
