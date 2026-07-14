import Foundation

enum AdConfig {
    /// IDs de prueba de Google. Sustituye por los tuyos en admob.google.com → Apps → Patience Ascent.
    static let applicationID = "ca-app-pub-3940256099942544~1458002511"
    static let interstitialUnitID = "ca-app-pub-3940256099942544/4411468910"

    /// Mínimo entre anuncios (5 minutos).
    static let minimumInterval: TimeInterval = 300

    /// Gracia al abrir la app antes del primer anuncio posible.
    static let launchGracePeriod: TimeInterval = 120
}
