#!/usr/bin/env python3
"""Preflight checks before Codemagic build — run locally: python scripts/verify_apple_setup.py"""

from __future__ import annotations

import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from configure_app_store import (  # noqa: E402
    bundle_has_capability,
    find_bundle_id_resource,
    load_client,
)

BUNDLE_ID = "com.patienceascent.app"
REQUIRED_CAPS = ["GAME_CENTER"]


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    root = SCRIPT_DIR.parent
    checks = [
        root / "SolitaireRoyale.xcodeproj" / "project.pbxproj",
        root / "SolitaireRoyale" / "SolitaireRoyale.entitlements",
        root / "SolitaireRoyale" / "Info.plist",
        root / "codemagic.yaml",
        root / "scripts" / "codemagic_signing.sh",
        root / "scripts" / "verify_xcode_sdk.sh",
    ]
    for path in checks:
        if not path.exists():
            errors.append(f"Missing file: {path.relative_to(root)}")

    pbx = (root / "SolitaireRoyale.xcodeproj" / "project.pbxproj").read_text(encoding="utf-8")
    if "com.patienceascent.app" not in pbx:
        errors.append("project.pbxproj: bundle ID mismatch")
    if "CODE_SIGN_STYLE = Manual" not in pbx:
        errors.append("project.pbxproj: Release must use Manual signing for Codemagic")
    if "SUPPORTED_PLATFORMS = iphoneos;" not in pbx:
        errors.append("project.pbxproj: Release must target iphoneos only")
    sources_phase = pbx.split("/* Begin PBXSourcesBuildPhase section */", 1)[-1].split("/* End PBXSourcesBuildPhase section */", 1)[0]
    legacy_sources = [
        "GameSessionViewModel.swift in Sources",
        "GameBoardView.swift in Sources",
        "GlyphLinkBoardView.swift in Sources",
        "GlyphLinkEngine.swift in Sources",
        "Card.swift in Sources",
        "KlondikeEngine.swift in Sources",
    ]
    for legacy in legacy_sources:
        if legacy in sources_phase:
            errors.append(f"project.pbxproj: legacy file still compiled: {legacy}")
    if "SharedViews.swift in Sources" in pbx and "PlayingCard" in (
        root / "SolitaireRoyale" / "Views" / "Components" / "SharedViews.swift"
    ).read_text(encoding="utf-8"):
        errors.append("SharedViews.swift still references PlayingCard in compiled target")

    cm = (root / "codemagic.yaml").read_text(encoding="utf-8")
    if "xcode: 16" in cm or "xcode: latest" in cm:
        errors.append("codemagic.yaml: must use xcode 26.6+ (Apple requires iOS 26 SDK since 2026-04-28)")
    if "xcode: 26" not in cm:
        errors.append("codemagic.yaml: set xcode: 26.6 for App Store uploads")

    plist_build = ""
    for line in (root / "SolitaireRoyale" / "Info.plist").read_text(encoding="utf-8").splitlines():
        if "<string>" in line and plist_build == "pending":
            plist_build = line.strip().replace("<string>", "").replace("</string>", "")
            break
        if "CFBundleVersion" in line:
            plist_build = "pending"
    if "patience_ascent_top100" not in (root / "SolitaireRoyale" / "Services" / "GameCenterManager.swift").read_text(encoding="utf-8"):
        errors.append("GameCenterManager: missing leaderboard ID patience_ascent_top100")
    if "CURRENT_PROJECT_VERSION = 24" not in pbx:
        errors.append("project.pbxproj: build number should be 24")
    if plist_build != "24":
        errors.append(f"Info.plist CFBundleVersion mismatch: {plist_build!r}")

    ent = (root / "SolitaireRoyale" / "SolitaireRoyale.entitlements").read_text(encoding="utf-8")
    if "com.apple.developer.game-center" not in ent:
        warnings.append("Entitlements: Game Center not declared (OK if disabled)")

    try:
        client = load_client()
        bundle = find_bundle_id_resource(client, BUNDLE_ID)
        print(f"App ID resource: {bundle['id']} ({bundle['attributes'].get('name')})")
        for cap in REQUIRED_CAPS:
            if bundle_has_capability(client, bundle["id"], cap):
                print(f"OK capability: {cap}")
            else:
                errors.append(f"Apple App ID missing capability: {cap}")
    except Exception as exc:
        warnings.append(f"Apple API check skipped: {exc}")

    if warnings:
        print("\nWarnings:")
        for w in warnings:
            print(f"  ! {w}")

    if errors:
        print("\nERRORS:")
        for e in errors:
            print(f"  x {e}")
        return 1

    print("\nAll preflight checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
