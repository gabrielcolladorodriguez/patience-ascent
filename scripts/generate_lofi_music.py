"""Generate lofi-style WAV tracks for Patience Ascent (CC0 procedural audio)."""
import math
import random
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 22050
BASE = Path(__file__).resolve().parent.parent / "SolitaireRoyale" / "GameAssets" / "Audio" / "Music"
MIN_SECONDS = 72


def write_wav(path: Path, samples):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples)
        w.writeframes(frames)


def lofi_track(seconds: float, chords, bpm=72, seed=0):
    rng = random.Random(seed)
    beat = 60 / bpm
    bar = beat * 4
    total = int(SAMPLE_RATE * seconds)
    out = [0.0] * total
    chord_idx = 0
    t_chord = 0.0
    melody_phase = rng.random() * math.tau

    for i in range(total):
        t = i / SAMPLE_RATE
        if t >= t_chord + bar:
            chord_idx = (chord_idx + 1) % len(chords)
            t_chord += bar
        freqs = chords[chord_idx]
        s = 0.0
        for j, f in enumerate(freqs):
            w = 0.09 - j * 0.012
            s += w * math.sin(2 * math.pi * f * t)
            s += w * 0.45 * math.sin(2 * math.pi * f * 2 * t)
        # soft melody layer
        lead = freqs[1] * (1.0 + 0.02 * math.sin(melody_phase + t * 0.35))
        s += 0.035 * math.sin(2 * math.pi * lead * t)
        # kick
        phase = (t % beat) / beat
        if phase < 0.07:
            s += 0.11 * math.sin(2 * math.pi * (48 + seed % 12) * t) * (1 - phase / 0.07)
        # vinyl texture
        s += 0.007 * math.sin(2 * math.pi * (8800 + seed % 400) * t + t * 3.1)
        fade = min(1.0, t / 2.0, (seconds - t) / 2.0)
        out[i] = s * fade * 0.82

    return out


CHORD_SETS = [
    [[220.0, 261.63, 329.63, 392.0], [174.61, 220.0, 261.63, 329.63], [261.63, 329.63, 392.0, 493.88], [196.0, 246.94, 293.66, 392.0]],
    [[196.0, 246.94, 293.66, 349.23], [220.0, 261.63, 329.63, 392.0], [174.61, 220.0, 261.63, 329.63], [155.56, 196.0, 233.08, 293.66]],
    [[261.63, 329.63, 392.0, 523.25], [220.0, 277.18, 329.63, 415.30], [196.0, 246.94, 293.66, 369.99], [174.61, 220.0, 261.63, 329.63]],
    [[174.61, 207.65, 261.63, 311.13], [196.0, 233.08, 293.66, 349.23], [220.0, 261.63, 329.63, 392.0], [246.94, 293.66, 369.99, 440.0]],
    [[220.0, 261.63, 329.63, 440.0], [196.0, 233.08, 293.66, 392.0], [174.61, 207.65, 261.63, 349.23], [246.94, 293.66, 349.23, 493.88]],
    [[130.81, 164.81, 196.0, 246.94], [146.83, 174.61, 220.0, 261.63], [164.81, 196.0, 246.94, 293.66], [174.61, 220.0, 261.63, 329.63]],
    [[220.0, 277.18, 329.63, 415.30], [196.0, 246.94, 311.13, 392.0], [174.61, 220.0, 277.18, 349.23], [246.94, 311.13, 369.99, 466.16]],
    [[196.0, 246.94, 293.66, 392.0], [220.0, 261.63, 329.63, 440.0], [174.61, 220.0, 261.63, 349.23], [155.56, 196.0, 233.08, 311.13]],
]

MENU_BPMS = [64, 66, 68, 70, 72, 74, 76, 68, 70, 72, 66, 74, 68, 72, 70, 66]
GAME_BPMS = [72, 74, 76, 78, 80, 74, 76, 78, 72, 80, 76, 74, 78, 72, 76, 80]

count = 0
for i in range(1, 17):
    seconds = MIN_SECONDS + (i % 5) * 4
    chords = CHORD_SETS[i % len(CHORD_SETS)]
    write_wav(BASE / f"lofi_menu_{i:02d}.wav", lofi_track(seconds, chords, bpm=MENU_BPMS[i - 1], seed=i * 17))
    count += 1

for i in range(1, 17):
    seconds = MIN_SECONDS + (i % 4) * 5
    chords = CHORD_SETS[(i + 3) % len(CHORD_SETS)]
    write_wav(BASE / f"lofi_game_{i:02d}.wav", lofi_track(seconds, chords, bpm=GAME_BPMS[i - 1], seed=i * 31 + 7))
    count += 1

write_wav(BASE / "menu_music.wav", lofi_track(78, CHORD_SETS[0], bpm=68, seed=1))
write_wav(BASE / "game_music.wav", lofi_track(84, CHORD_SETS[2], bpm=74, seed=2))
write_wav(BASE / "win_sting.wav", lofi_track(6, [[261.63, 329.63, 392.0, 523.25]], bpm=96, seed=99))
write_wav(BASE / "win_music.wav", lofi_track(10, [[261.63, 329.63, 392.0, 523.25]], bpm=90, seed=100))
count += 4

print(f"Wrote {count} lofi tracks to {BASE}")
