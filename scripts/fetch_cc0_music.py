#!/usr/bin/env python3
"""
Download CC0 lofi tracks from open-lofi (https://github.com/btahir/open-lofi)
and copy a varied subset into GameAssets/Audio/Music as cc0_menu_XX / cc0_game_XX.

License: CC0 — see open-lofi repository.
"""

from __future__ import annotations

import random
import shutil
import sys
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MUSIC_DIR = ROOT / "SolitaireRoyale" / "GameAssets" / "Audio" / "Music"
CACHE = ROOT / "scripts" / ".cache"
ZIP_URL = "https://github.com/btahir/open-lofi/releases/latest/download/openlofi.zip"
TRACK_COUNT = 24


def download_zip() -> Path:
    CACHE.mkdir(parents=True, exist_ok=True)
    zip_path = CACHE / "open-lofi.zip"
    if not zip_path.exists() or zip_path.stat().st_size < 1_000_000:
        print(f"Downloading {ZIP_URL} ...")
        urllib.request.urlretrieve(ZIP_URL, zip_path)
    return zip_path


def collect_audio(extract_dir: Path) -> list[Path]:
    exts = {".mp3", ".wav", ".ogg", ".m4a"}
    files = [p for p in extract_dir.rglob("*") if p.suffix.lower() in exts and p.stat().st_size > 200_000]
    files.sort(key=lambda p: p.name.lower())
    return files


def main() -> int:
    MUSIC_DIR.mkdir(parents=True, exist_ok=True)
    zip_path = download_zip()
    extract_dir = CACHE / "open-lofi"
    if not extract_dir.exists():
        print("Extracting zip...")
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(extract_dir)

    tracks = collect_audio(extract_dir)
    if len(tracks) < TRACK_COUNT * 2:
        print(f"Warning: only {len(tracks)} audio files found", file=sys.stderr)

    rng = random.Random(42)
    pool = tracks.copy()
    rng.shuffle(pool)
    needed = TRACK_COUNT * 2
    while len(pool) < needed and tracks:
        pool.extend(tracks)
    pool = pool[:needed]

    # Remove old procedural tracks
    for old in MUSIC_DIR.glob("lofi_*"):
        old.unlink(missing_ok=True)

    for i, src in enumerate(pool[:TRACK_COUNT], start=1):
        ext = src.suffix.lower()
        dst = MUSIC_DIR / f"cc0_menu_{i:02d}{ext}"
        shutil.copy2(src, dst)
        print(f"  {dst.name} <- {src.name}")

    for i, src in enumerate(pool[TRACK_COUNT:TRACK_COUNT * 2], start=1):
        ext = src.suffix.lower()
        dst = MUSIC_DIR / f"cc0_game_{i:02d}{ext}"
        shutil.copy2(src, dst)
        print(f"  {dst.name} <- {src.name}")

    print(f"Done — {TRACK_COUNT * 2} tracks in {MUSIC_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
