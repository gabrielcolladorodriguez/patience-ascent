import Foundation
import AVFoundation
import SwiftUI

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @AppStorage("musicEnabled") var musicEnabled = true
    @AppStorage("sfxEnabled") var sfxEnabled = true

    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []

    private init() {
        configureSession()
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func playMusic(_ name: String, loop: Bool = true) {
        guard musicEnabled else { return }
        guard let url = audioURL(name: name, folder: "GameAssets/Audio/Music") else {
            print("Music not found: \(name)")
            return
        }
        do {
            musicPlayer?.stop()
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = loop ? -1 : 0
            musicPlayer?.volume = 0.22
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Music play error: \(error)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func playSFX(_ filename: String) {
        guard sfxEnabled else { return }
        guard let url = audioURL(name: filename, folder: "GameAssets/Audio/SFX") else {
            print("SFX not found: \(filename)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.5
            player.prepareToPlay()
            player.play()
            sfxPlayers.append(player)
            sfxPlayers.removeAll { !$0.isPlaying }
        } catch {
            print("SFX play error: \(error)")
        }
    }

    private func audioURL(name: String, folder: String) -> URL? {
        let base = (name as NSString).deletingPathExtension
        for ext in ["wav", "m4a", "caf", "mp3", "ogg"] {
            if let url = Bundle.main.url(forResource: base, withExtension: ext, subdirectory: folder) {
                return url
            }
        }
        if let url = Bundle.main.url(forResource: base, withExtension: "wav") {
            return url
        }
        return nil
    }

    func click() { playSFX("click.wav") }
    func tap() { playSFX("tap.wav") }
    func cardPlace() { playSFX("card_place.wav") }
    func cardSlide() { playSFX("card_slide.wav") }
    func cardShuffle() { playSFX("card_shuffle.wav") }
    func win() {
        playSFX("switch.wav")
        playMusic("win_music.wav", loop: false)
    }
}
