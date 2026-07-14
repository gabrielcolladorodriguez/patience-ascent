#!/usr/bin/env python3
"""Install the AI-generated Patience Ascent icon into the Xcode asset catalog.

Source: assets/PatienceAscentIcon.png (generated — not hand-drawn).
Regenerate the source with Cursor image generation, then run this script.
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SIZE = 1024

SOURCES = [
    ROOT / "assets" / "PatienceAscentIcon.png",
    ROOT.parent / ".cursor" / "projects" / "c-Users-pollo-Desktop-Juego-Cartas" / "assets" / "PatienceAscentIcon.png",
]

TARGETS = [
    ROOT / "SolitaireRoyale" / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon.png",
    ROOT / "SolitaireRoyale" / "Assets.xcassets" / "BrandIcon.imageset" / "BrandIcon.png",
    ROOT / "assets" / "PatienceAscentIcon.png",
]


def find_source() -> Path:
    for path in SOURCES:
        if path.exists():
            return path
    raise FileNotFoundError(
        "No PatienceAscentIcon.png found. Generate one with the AI image tool first."
    )


def main() -> None:
    src = find_source()
    img = Image.open(src).convert("RGB").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    for target in TARGETS:
        target.parent.mkdir(parents=True, exist_ok=True)
        img.save(target, format="PNG", optimize=True)
        print(f"Installed {target}")


if __name__ == "__main__":
    main()
