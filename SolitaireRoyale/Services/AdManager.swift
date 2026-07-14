import GoogleMobileAds
import UIKit

/// Anuncios intersticiales puntuales: como máximo uno cada 5 minutos, solo en pausas (menú).
final class AdManager: NSObject {
    static let shared = AdManager()

    private let lastShownKey = "lastInterstitialAdShown"
    private let launchTime = Date()

    private var interstitial: InterstitialAd?
    private var isLoading = false
    private var isShowing = false
    private var userOnMenu = true
    private var checkTimer: Timer?

    private override init() {
        super.init()
    }

    func configure() {
        MobileAds.shared.start()
        Task { await loadInterstitial() }
        startPeriodicCheck()
    }

    func setUserOnMenu(_ onMenu: Bool) {
        userOnMenu = onMenu
    }

    /// Llamar al volver al menú desde una partida u otra pantalla de juego.
    func notifyReturnedToMenu() {
        Task { await tryShowIfEligible(reason: .returnedToMenu) }
    }

    func pauseChecks() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    func resumeChecks() {
        guard checkTimer == nil else { return }
        startPeriodicCheck()
    }

    // MARK: - Private

    private enum ShowReason {
        case returnedToMenu
        case scheduledOnMenu
    }

    private var lastShown: Date {
        get {
            let t = UserDefaults.standard.double(forKey: lastShownKey)
            return t > 0 ? Date(timeIntervalSince1970: t) : .distantPast
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: lastShownKey)
        }
    }

    private var canShowByTime: Bool {
        let sinceLaunch = Date().timeIntervalSince(launchTime)
        guard sinceLaunch >= AdConfig.launchGracePeriod else { return false }
        return Date().timeIntervalSince(lastShown) >= AdConfig.minimumInterval
    }

    private func startPeriodicCheck() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self, self.userOnMenu, !self.isShowing else { return }
            Task { await self.tryShowIfEligible(reason: .scheduledOnMenu) }
        }
    }

    @MainActor
    private func loadInterstitial() async {
        guard !isLoading, interstitial == nil else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let ad = try await InterstitialAd.load(
                with: AdConfig.interstitialUnitID,
                request: Request()
            )
            ad.fullScreenContentDelegate = self
            interstitial = ad
        } catch {
            interstitial = nil
        }
    }

    @MainActor
    private func tryShowIfEligible(reason: ShowReason) async {
        guard userOnMenu, !isShowing, canShowByTime else { return }
        guard let ad = interstitial else {
            await loadInterstitial()
            return
        }
        guard let presenter = Self.topViewController() else { return }

        isShowing = true
        ad.present(from: presenter)
        interstitial = nil
    }

    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        if let nav = root as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(base: presented)
        }
        return root
    }
}

extension AdManager: FullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        lastShown = Date()
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowing = false
        Task { await loadInterstitial() }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowing = false
        interstitial = nil
        Task { await loadInterstitial() }
    }
}
