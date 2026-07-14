import Foundation
import AVFoundation

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published var musicEnabled = true
    @Published var sfxEnabled = true

    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func playMusic(_ name: String, loop: Bool = true) {
        guard musicEnabled, let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: "GameAssets/Audio/Music")
            ?? Bundle.main.url(forResource: name.replacingOccurrences(of: ".ogg", with: ""), withExtension: "ogg") else { return }
        do {
            musicPlayer?.stop()
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = loop ? -1 : 0
            musicPlayer?.volume = 0.35
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {}
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func playSFX(_ filename: String) {
        guard sfxEnabled else { return }
        let base = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension.isEmpty ? "ogg" : (filename as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: base, withExtension: ext, subdirectory: "GameAssets/Audio/SFX")
            ?? Bundle.main.url(forResource: base, withExtension: ext) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.7
            player.prepareToPlay()
            player.play()
            sfxPlayers.append(player)
            sfxPlayers.removeAll { !$0.isPlaying }
        } catch {}
    }

    func click() { playSFX("click.ogg") }
    func tap() { playSFX("tap.ogg") }
    func cardPlace() { playSFX("card_place.ogg") }
    func cardSlide() { playSFX("card_slide.ogg") }
    func cardShuffle() { playSFX("card_shuffle.ogg") }
    func win() { playSFX("switch.ogg") }
}
