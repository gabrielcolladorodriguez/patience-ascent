"""Generate lofi-style WAV loops for Patience Ascent (CC0 procedural audio)."""
import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 22050
BASE = Path(__file__).resolve().parent.parent / "SolitaireRoyale" / "GameAssets" / "Audio" / "Music"


def write_wav(path: Path, samples):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples)
        w.writeframes(frames)


def lofi_loop(seconds: float, chords, bpm=72):
    beat = 60 / bpm
    bar = beat * 4
    total = int(SAMPLE_RATE * seconds)
    out = [0.0] * total
    chord_idx = 0
    t_chord = 0.0

    for i in range(total):
        t = i / SAMPLE_RATE
        if t >= t_chord + bar:
            chord_idx = (chord_idx + 1) % len(chords)
            t_chord += bar
        freqs = chords[chord_idx]
        s = 0.0
        for f in freqs:
            s += 0.09 * math.sin(2 * math.pi * f * t)
            s += 0.04 * math.sin(2 * math.pi * f * 2 * t)
        # soft kick on beats
        phase = (t % beat) / beat
        if phase < 0.08:
            s += 0.12 * math.sin(2 * math.pi * 55 * t) * (1 - phase / 0.08)
        # vinyl hiss
        s += 0.008 * math.sin(2 * math.pi * 9000 * t + t * 3.7)
        # gentle fade loop
        fade = min(1.0, t / 1.5, (seconds - t) / 1.5)
        out[i] = s * fade * 0.85

    return out


# Am7 - Fmaj7 - Cmaj7 - G6 (lofi vibe)
CHORDS = [
    [220.0, 261.63, 329.63, 392.0],
    [174.61, 220.0, 261.63, 329.63],
    [261.63, 329.63, 392.0, 493.88],
    [196.0, 246.94, 293.66, 392.0],
]

write_wav(BASE / "menu_music.wav", lofi_loop(48, CHORDS, bpm=68))
write_wav(BASE / "game_music.wav", lofi_loop(56, CHORDS, bpm=74))
write_wav(BASE / "win_music.wav", lofi_loop(8, [[261.63, 329.63, 392.0, 523.25]], bpm=90))
print("LoFi music written to", BASE)
