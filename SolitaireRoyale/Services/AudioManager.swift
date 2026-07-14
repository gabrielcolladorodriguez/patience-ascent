import Foundation
import AVFoundation
import SwiftUI

private final class MusicPlaybackDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinished: (() -> Void)?

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished?()
    }
}

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    enum PlaylistContext {
        case menu
        case game
        case win
    }

    @AppStorage("musicEnabled") var musicEnabled = true
    @AppStorage("sfxEnabled") var sfxEnabled = true

    private var musicPlayer: AVAudioPlayer?
    private var musicDelegate = MusicPlaybackDelegate()
    private var sfxPlayers: [AVAudioPlayer] = []
    private var playlist: [URL] = []
    private var playlistContext: PlaylistContext = .menu
    private var lastTrackIndex: Int?

    private init() {
        configureSession()
        musicDelegate.onFinished = { [weak self] in
            Task { @MainActor in self?.playNextInPlaylist() }
        }
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func startMenuMusic() {
        startPlaylist(context: .menu, names: Self.menuTracks)
    }

    func startGameMusic() {
        startPlaylist(context: .game, names: Self.gameTracks)
    }

    func playWinMusic() {
        guard musicEnabled else { return }
        guard let url = trackURL("win_sting") ?? trackURL("win_music") else { return }
        playURL(url, loop: false)
    }

    private func startPlaylist(context: PlaylistContext, names: [String]) {
        playlistContext = context
        playlist = names.compactMap { trackURL($0) }
        if playlist.isEmpty {
            print("No music tracks found for \(context)")
            return
        }
        playNextInPlaylist(forceDifferent: false)
    }

    private func playNextInPlaylist(forceDifferent: Bool = true) {
        guard musicEnabled, !playlist.isEmpty else { return }
        var index = Int.random(in: 0..<playlist.count)
        if forceDifferent, playlist.count > 1, let last = lastTrackIndex {
            while index == last {
                index = Int.random(in: 0..<playlist.count)
            }
        }
        lastTrackIndex = index
        playURL(playlist[index], loop: false)
    }

    private func playURL(_ url: URL, loop: Bool) {
        do {
            musicPlayer?.stop()
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.delegate = musicDelegate
            musicPlayer?.numberOfLoops = loop ? -1 : 0
            musicPlayer?.volume = 0.24
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Music play error: \(error)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
        playlist.removeAll()
    }

    func playSFX(_ filename: String) {
        guard sfxEnabled else { return }
        guard let url = audioURL(name: filename, folder: "GameAssets/Audio/SFX") else {
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

    private func trackURL(_ base: String) -> URL? {
        audioURL(name: base, folder: "GameAssets/Audio/Music")
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
        playWinMusic()
    }

    private static let menuTracks: [String] = {
        var tracks = (1...16).map { String(format: "lofi_menu_%02d", $0) }
        tracks.append("menu_music")
        return tracks
    }()

    private static let gameTracks: [String] = {
        var tracks = (1...16).map { String(format: "lofi_game_%02d", $0) }
        tracks.append("game_music")
        return tracks
    }()
}
