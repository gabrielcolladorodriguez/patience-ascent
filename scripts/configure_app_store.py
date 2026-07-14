#!/usr/bin/env python3
"""Configure Patience Ascent on App Store Connect via API."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Any

import jwt
import requests
from dotenv import load_dotenv

API_BASE = "https://api.appstoreconnect.apple.com/v1"
SCRIPT_DIR = Path(__file__).resolve().parent
METADATA_PATH = SCRIPT_DIR / "metadata" / "store_metadata.json"

LEADERBOARDS = [
    {
        "vendorIdentifier": "patience_total_time",
        "referenceName": "Total Play Time",
        "defaultFormatter": "ELAPSED_TIME_SECOND",
        "submissionType": "MOST_RECENT_SCORE",
        "scoreSortType": "DESC",
        "localizations": {
            "en-US": {"name": "Total Play Time", "suffix": "sec"},
            "es-ES": {"name": "Tiempo total", "suffix": "s"},
            "fr-FR": {"name": "Temps total", "suffix": "s"},
            "de-DE": {"name": "Gesamtspielzeit", "suffix": "s"},
            "ja": {"name": "総プレイ時間", "suffix": "秒"},
        },
    },
    {
        "vendorIdentifier": "patience_ascent_top100",
        "referenceName": "Top 100 Ascent Score",
        "defaultFormatter": "INTEGER",
        "submissionType": "BEST_SCORE",
        "scoreSortType": "DESC",
        "localizations": {
            "en-US": {"name": "Top 100 Ascent", "suffix": "pts"},
            "es-ES": {"name": "Top 100 Ascenso", "suffix": "pts"},
            "fr-FR": {"name": "Top 100 Ascension", "suffix": "pts"},
            "de-DE": {"name": "Top 100 Aufstieg", "suffix": "Pkt"},
            "ja": {"name": "トップ100アセント", "suffix": "pt"},
        },
    },
]


KEEP_LEADERBOARD_VENDORS = {b["vendorIdentifier"] for b in LEADERBOARDS}

LEGACY_LEADERBOARD_VENDORS = {
    "patience_best_klondike",
    "patience_best_freeCell",
    "patience_best_spider",
    "patience_best_pyramid",
    "patience_best_triPeaks",
    "patience_best_golf",
    "patience_best_yukon",
    "patience_best_fortyThieves",
    "patience_best_glyphLink",
    "patience_best_glyphChain",
    "patience_best_glyphRush",
    "patience_best_glyphZen",
    "patience_best_gravityBlocks",
}


class ASCClient:
    def __init__(self, issuer_id: str, key_id: str, private_key: str) -> None:
        self.issuer_id = issuer_id
        self.key_id = key_id
        self.private_key = private_key
        self.session = requests.Session()

    def _token(self) -> str:
        now = int(time.time())
        payload = {
            "iss": self.issuer_id,
            "iat": now,
            "exp": now + 1200,
            "aud": "appstoreconnect-v1",
        }
        headers = {"alg": "ES256", "kid": self.key_id, "typ": "JWT"}
        return jwt.encode(payload, self.private_key, algorithm="ES256", headers=headers)

    def request(
        self,
        method: str,
        path: str,
        *,
        params: dict[str, Any] | None = None,
        body: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        url = f"{API_BASE}{path}"
        headers = {
            "Authorization": f"Bearer {self._token()}",
            "Content-Type": "application/json",
        }
        response = self.session.request(
            method,
            url,
            headers=headers,
            params=params,
            json=body,
            timeout=120,
        )
        if response.status_code >= 400:
            raise RuntimeError(
                f"{method} {path} failed ({response.status_code}): {response.text}"
            )
        if not response.text:
            return {}
        return response.json()

    def get_all(self, path: str, *, params: dict[str, Any] | None = None) -> list[dict[str, Any]]:
        items: list[dict[str, Any]] = []
        next_url: str | None = path
        query = params
        while next_url:
            if next_url.startswith("http"):
                response = self.session.get(
                    next_url,
                    headers={"Authorization": f"Bearer {self._token()}"},
                    timeout=120,
                )
                if response.status_code >= 400:
                    raise RuntimeError(
                        f"GET {next_url} failed ({response.status_code}): {response.text}"
                    )
                payload = response.json()
            else:
                payload = self.request("GET", next_url, params=query)
                query = None
            items.extend(payload.get("data", []))
            next_url = payload.get("links", {}).get("next")
        return items


def load_metadata() -> dict[str, Any]:
    with METADATA_PATH.open(encoding="utf-8") as handle:
        return json.load(handle)


def find_app(client: ASCClient, bundle_id: str) -> dict[str, Any]:
    apps = client.get_all("/apps", params={"filter[bundleId]": bundle_id, "limit": 10})
    if not apps:
        raise RuntimeError(
            f"No app found for bundle ID {bundle_id}. Create it in App Store Connect first."
        )
    return apps[0]


def find_ios_app_info(client: ASCClient, app_id: str) -> dict[str, Any]:
    infos = client.get_all(f"/apps/{app_id}/appInfos")
    for info in infos:
        if info.get("attributes", {}).get("appStoreState"):
            pass
        if info.get("attributes", {}).get("appStoreAgeRating") is not None:
            return info
    for info in infos:
        if info.get("attributes", {}).get("brazilAgeRating") is not None:
            return info
    if not infos:
        raise RuntimeError("No appInfo found. Ensure the app exists in App Store Connect.")
    return infos[0]


def find_editable_version(client: ASCClient, app_id: str, version_string: str) -> dict[str, Any]:
    versions = client.get_all(
        f"/apps/{app_id}/appStoreVersions",
        params={"limit": 50},
    )
    preferred_states = {
        "PREPARE_FOR_SUBMISSION",
        "DEVELOPER_REJECTED",
        "WAITING_FOR_REVIEW",
        "READY_FOR_SALE",
    }
    matching = [
        item
        for item in versions
        if item.get("attributes", {}).get("versionString") == version_string
    ]
    if not matching:
        raise RuntimeError(
            f"Version {version_string} not found. Create it in App Store Connect → App → iOS App → + Version"
        )
    for state in preferred_states:
        for item in matching:
            if item.get("attributes", {}).get("appStoreState") == state:
                return item
    return matching[0]


def patch_app_info(client: ASCClient, app_info_id: str, metadata: dict[str, Any]) -> None:
    app_meta = metadata["app"]
    relationships: dict[str, Any] = {
        "primaryCategory": {
            "data": {"type": "appCategories", "id": app_meta["primaryCategory"]}
        },
        "primarySubcategoryOne": {
            "data": {"type": "appCategories", "id": app_meta["primarySubcategoryOne"]}
        },
    }
    if app_meta.get("secondaryCategory"):
        relationships["secondaryCategory"] = {
            "data": {"type": "appCategories", "id": app_meta["secondaryCategory"]}
        }
    if app_meta.get("secondarySubcategoryOne"):
        relationships["secondarySubcategoryOne"] = {
            "data": {"type": "appCategories", "id": app_meta["secondarySubcategoryOne"]}
        }
    try:
        client.request(
            "PATCH",
            f"/appInfos/{app_info_id}",
            body={
                "data": {
                    "type": "appInfos",
                    "id": app_info_id,
                    "relationships": relationships,
                }
            },
        )
        print("✓ App categories updated")
    except RuntimeError as exc:
        print(f"! Categories skipped: {exc}")


def upsert_app_info_localizations(
    client: ASCClient,
    app_info_id: str,
    metadata: dict[str, Any],
) -> None:
    existing = {
        item["attributes"]["locale"]: item
        for item in client.get_all(f"/appInfos/{app_info_id}/appInfoLocalizations")
    }
    app_name = metadata["app"]["name"]
    for locale, content in metadata["locales"].items():
        subtitle = content["subtitle"][:30]
        try:
            if locale in existing:
                loc_id = existing[locale]["id"]
                body = {
                    "data": {
                        "type": "appInfoLocalizations",
                        "id": loc_id,
                        "attributes": {
                            "name": app_name,
                            "subtitle": subtitle,
                        },
                    }
                }
                client.request("PATCH", f"/appInfoLocalizations/{loc_id}", body=body)
                print(f"  ✓ appInfo {locale}")
            else:
                body = {
                    "data": {
                        "type": "appInfoLocalizations",
                        "attributes": {
                            "locale": locale,
                            "name": app_name,
                            "subtitle": subtitle,
                        },
                        "relationships": {
                            "appInfo": {
                                "data": {"type": "appInfos", "id": app_info_id}
                            }
                        },
                    }
                }
                client.request("POST", "/appInfoLocalizations", body=body)
                print(f"  + appInfo {locale}")
        except RuntimeError as exc:
            print(f"  ! appInfo {locale}: {exc}")


def upsert_version_localizations(
    client: ASCClient,
    version_id: str,
    metadata: dict[str, Any],
) -> None:
    existing = {
        item["attributes"]["locale"]: item
        for item in client.get_all(
            f"/appStoreVersions/{version_id}/appStoreVersionLocalizations"
        )
    }
    app_meta = metadata["app"]
    for locale, content in metadata["locales"].items():
        attrs = {
            "description": content["description"],
            "keywords": content["keywords"][:100],
            "supportUrl": app_meta["supportUrl"],
            "marketingUrl": app_meta.get("marketingUrl"),
        }
        promo = metadata.get("promotionalText", {}).get(locale)
        whats_new = metadata.get("whatsNew", {}).get(locale)
        if promo:
            attrs["promotionalText"] = promo[:170]

        def apply(include_whats_new: bool) -> None:
            payload = dict(attrs)
            if include_whats_new and whats_new:
                payload["whatsNew"] = whats_new
            if locale in existing:
                loc_id = existing[locale]["id"]
                body = {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": loc_id,
                        "attributes": payload,
                    }
                }
                client.request("PATCH", f"/appStoreVersionLocalizations/{loc_id}", body=body)
                print(f"  ✓ version {locale}")
            else:
                body = {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "attributes": {"locale": locale, **payload},
                        "relationships": {
                            "appStoreVersion": {
                                "data": {"type": "appStoreVersions", "id": version_id}
                            }
                        },
                    }
                }
                client.request("POST", "/appStoreVersionLocalizations", body=body)
                print(f"  + version {locale}")

        try:
            apply(include_whats_new=True)
        except RuntimeError as exc:
            if whats_new and "whatsNew" in str(exc):
                try:
                    apply(include_whats_new=False)
                except RuntimeError as retry_exc:
                    print(f"  ! version {locale}: {retry_exc}")
            else:
                print(f"  ! version {locale}: {exc}")


def set_privacy_policy_url(client: ASCClient, app_id: str, url: str) -> None:
    infos = client.get_all(f"/apps/{app_id}/appInfos")
    for info in infos:
        info_id = info["id"]
        try:
            client.request(
                "PATCH",
                f"/appInfos/{info_id}",
                body={
                    "data": {
                        "type": "appInfos",
                        "id": info_id,
                        "attributes": {"privacyPolicyUrl": url},
                    }
                },
            )
            print("✓ Privacy policy URL set")
            return
        except RuntimeError:
            continue
    print("! Could not set privacy policy URL automatically — set it manually in Connect")


def find_bundle_id_resource(client: ASCClient, identifier: str) -> dict[str, Any]:
    items = client.get_all("/bundleIds", params={"filter[identifier]": identifier, "limit": 1})
    if not items:
        raise RuntimeError(
            f"Bundle ID {identifier} not found in Developer Portal. Register it at developer.apple.com first."
        )
    return items[0]


def bundle_has_capability(client: ASCClient, bundle_id_resource_id: str, capability: str) -> bool:
    caps = client.get_all(f"/bundleIds/{bundle_id_resource_id}/bundleIdCapabilities")
    return any(c.get("attributes", {}).get("capabilityType") == capability for c in caps)


def enable_bundle_capability(client: ASCClient, bundle_id_resource_id: str, capability: str) -> None:
    if bundle_has_capability(client, bundle_id_resource_id, capability):
        print(f"✓ Capability {capability} already enabled on App ID")
        return
    client.request(
        "POST",
        "/bundleIdCapabilities",
        body={
            "data": {
                "type": "bundleIdCapabilities",
                "attributes": {"capabilityType": capability},
                "relationships": {
                    "bundleId": {
                        "data": {"type": "bundleIds", "id": bundle_id_resource_id}
                    }
                },
            }
        },
    )
    print(f"✓ Enabled {capability} on App ID")


def ensure_game_center_bundle_capability(client: ASCClient, bundle_id: str) -> None:
    bundle = find_bundle_id_resource(client, bundle_id)
    enable_bundle_capability(client, bundle["id"], "GAME_CENTER")


def get_or_create_game_center_detail_id(client: ASCClient, app_id: str) -> str:
    try:
        response = client.request("GET", f"/apps/{app_id}/gameCenterDetail")
        if response.get("data", {}).get("id"):
            return response["data"]["id"]
    except RuntimeError:
        pass

    try:
        created = client.request(
            "POST",
            "/gameCenterDetails",
            body={
                "data": {
                    "type": "gameCenterDetails",
                    "relationships": {
                        "app": {"data": {"type": "apps", "id": app_id}}
                    },
                }
            },
        )
        print("✓ Game Center enabled")
        return created["data"]["id"]
    except RuntimeError as exc:
        message = str(exc)
        match = re.search(r"GameCenterDetail with the id '([^']+)'", message)
        if match:
            detail_id = match.group(1)
            print(f"✓ Game Center already enabled ({detail_id})")
            return detail_id
        raise RuntimeError(
            "Could not access Game Center. Enable it in App Store Connect → App → Services → Game Center. "
            f"({exc})"
        ) from exc


def ensure_leaderboards(client: ASCClient, game_center_detail_id: str) -> None:
    existing = {
        item["attributes"]["vendorIdentifier"]: item
        for item in client.get_all(
            f"/gameCenterDetails/{game_center_detail_id}/gameCenterLeaderboards"
        )
    }
    for board in LEADERBOARDS:
        vendor_id = board["vendorIdentifier"]
        try:
            leaderboard_id = _ensure_single_leaderboard(client, game_center_detail_id, board, existing)
            if not leaderboard_id:
                continue
            _upsert_leaderboard_localizations(client, leaderboard_id, vendor_id, board)
        except RuntimeError as exc:
            print(f"  ! leaderboard {vendor_id}: {exc}")


def _ensure_single_leaderboard(
    client: ASCClient,
    game_center_detail_id: str,
    board: dict,
    existing: dict,
) -> str | None:
    vendor_id = board["vendorIdentifier"]
    if vendor_id in existing:
        print(f"  = leaderboard exists: {vendor_id}")
        return existing[vendor_id]["id"]
    try:
        body = {
            "data": {
                "type": "gameCenterLeaderboards",
                "attributes": {
                    "referenceName": board["referenceName"],
                    "vendorIdentifier": vendor_id,
                    "defaultFormatter": board["defaultFormatter"],
                    "submissionType": board["submissionType"],
                    "scoreSortType": board["scoreSortType"],
                },
                "relationships": {
                    "gameCenterDetail": {
                        "data": {"type": "gameCenterDetails", "id": game_center_detail_id}
                    }
                },
            }
        }
        created = client.request("POST", "/gameCenterLeaderboards", body=body)
        print(f"  + leaderboard: {vendor_id}")
        return created["data"]["id"]
    except RuntimeError as exc:
        if "vendorIdentifier" in str(exc) or "DUPLICATE" in str(exc):
            print(f"  = leaderboard exists: {vendor_id}")
            return existing.get(vendor_id, {}).get("id")
        raise


def _upsert_leaderboard_localizations(
    client: ASCClient, leaderboard_id: str, vendor_id: str, board: dict
) -> None:
    try:
        locs = {
            item["attributes"]["locale"]: item
            for item in client.get_all(f"/gameCenterLeaderboards/{leaderboard_id}/localizations")
        }
        for locale, text in board["localizations"].items():
            if locale in locs:
                loc_id = locs[locale]["id"]
                try:
                    client.request(
                        "PATCH",
                        f"/gameCenterLeaderboardLocalizations/{loc_id}",
                        body={
                            "data": {
                                "type": "gameCenterLeaderboardLocalizations",
                                "id": loc_id,
                                "attributes": {
                                    "name": text["name"],
                                    "formatterSuffix": text["suffix"],
                                    "formatterSuffixSingular": text["suffix"],
                                },
                            }
                        },
                    )
                except RuntimeError as exc:
                    print(f"  ! update loc {vendor_id}/{locale}: {exc}")
                continue
            client.request(
                "POST",
                "/gameCenterLeaderboardLocalizations",
                body={
                    "data": {
                        "type": "gameCenterLeaderboardLocalizations",
                        "attributes": {
                            "locale": locale,
                            "name": text["name"],
                            "formatterSuffix": text["suffix"],
                            "formatterSuffixSingular": text["suffix"],
                        },
                        "relationships": {
                            "gameCenterLeaderboard": {
                                "data": {"type": "gameCenterLeaderboards", "id": leaderboard_id}
                            }
                        },
                    }
                },
            )
    except RuntimeError as exc:
        print(f"  ! localizations {vendor_id}: skipped ({exc})")


def cleanup_legacy_leaderboards(client: ASCClient, game_center_detail_id: str) -> None:
    """Remove old solitaire leaderboards from Game Center."""
    boards = client.get_all(
        f"/gameCenterDetails/{game_center_detail_id}/gameCenterLeaderboards"
    )
    for board in boards:
        vendor = board["attributes"]["vendorIdentifier"]
        if vendor in KEEP_LEADERBOARD_VENDORS:
            continue
        if vendor not in LEGACY_LEADERBOARD_VENDORS:
            print(f"  ? unknown leaderboard kept: {vendor}")
            continue
        board_id = board["id"]
        try:
            client.request("DELETE", f"/gameCenterLeaderboards/{board_id}")
            print(f"  - removed legacy: {vendor}")
        except RuntimeError as exc:
            print(f"  ! could not remove {vendor}: {exc}")


def upload_screenshots(client: ASCClient, version_id: str, screenshots_dir: Path) -> None:
    display_map = {
        "iphone-6.7": "APP_IPHONE_67",
        "iphone-6.5": "APP_IPHONE_65",
        "iphone-5.5": "APP_IPHONE_55",
        "ipad-12.9": "APP_IPAD_PRO_3GEN_129",
        "ipad-11": "APP_IPAD_PRO_129",
    }
    localizations = client.get_all(
        f"/appStoreVersions/{version_id}/appStoreVersionLocalizations",
        params={"filter[locale]": "en-US"},
    )
    if not localizations:
        print("! No en-US localization for screenshots")
        return
    loc_id = localizations[0]["id"]
    existing_sets = {
        item["attributes"]["screenshotDisplayType"]: item
        for item in client.get_all(
            f"/appStoreVersionLocalizations/{loc_id}/appScreenshotSets"
        )
    }
    for folder_name, display_type in display_map.items():
        folder = screenshots_dir / folder_name
        if not folder.is_dir():
            continue
        images = sorted(folder.glob("*.png"))
        if not images:
            continue
        if display_type in existing_sets:
            set_id = existing_sets[display_type]["id"]
        else:
            created = client.request(
                "POST",
                "/appScreenshotSets",
                body={
                    "data": {
                        "type": "appScreenshotSets",
                        "attributes": {"screenshotDisplayType": display_type},
                        "relationships": {
                            "appStoreVersionLocalization": {
                                "data": {
                                    "type": "appStoreVersionLocalizations",
                                    "id": loc_id,
                                }
                            }
                        },
                    }
                },
            )
            set_id = created["data"]["id"]
        for image_path in images:
            upload_one_screenshot(client, set_id, image_path)
            print(f"  ✓ screenshot {display_type}: {image_path.name}")


def upload_one_screenshot(client: ASCClient, set_id: str, image_path: Path) -> None:
    raw = image_path.read_bytes()
    checksum = base64.b64encode(hashlib.md5(raw).digest()).decode("ascii")
    reserved = client.request(
        "POST",
        "/appScreenshots",
        body={
            "data": {
                "type": "appScreenshots",
                "attributes": {
                    "fileName": image_path.name,
                    "fileSize": len(raw),
                },
                "relationships": {
                    "appScreenshotSet": {
                        "data": {"type": "appScreenshotSets", "id": set_id}
                    }
                },
            }
        },
    )
    screenshot_id = reserved["data"]["id"]
    upload_ops = reserved["data"]["attributes"].get("uploadOperations", [])
    if not upload_ops:
        raise RuntimeError(f"No upload URL for screenshot {image_path.name}")
    op = upload_ops[0]
    headers = {item["name"]: item["value"] for item in op.get("requestHeaders", [])}
    put_response = requests.put(op["url"], data=raw, headers=headers, timeout=300)
    if put_response.status_code >= 400:
        raise RuntimeError(f"Screenshot upload failed: {put_response.text}")
    client.request(
        "PATCH",
        f"/appScreenshots/{screenshot_id}",
        body={
            "data": {
                "type": "appScreenshots",
                "id": screenshot_id,
                "attributes": {
                    "uploaded": True,
                    "sourceFileChecksum": checksum,
                },
            }
        },
    )


def configure_store(
    client: ASCClient,
    *,
    bundle_id: str,
    version: str,
    game_center: bool,
    screenshots_dir: Path | None,
) -> None:
    metadata = load_metadata()
    app = find_app(client, bundle_id)
    app_id = app["id"]
    print(f"App: {app['attributes'].get('name')} ({app_id})")

    app_info = find_ios_app_info(client, app_id)
    app_info_id = app_info["id"]
    patch_app_info(client, app_info_id, metadata)
    set_privacy_policy_url(client, app_id, metadata["app"]["privacyPolicyUrl"])

    print("Updating app info localizations...")
    upsert_app_info_localizations(client, app_info_id, metadata)

    version_item = find_editable_version(client, app_id, version)
    version_id = version_item["id"]
    state = version_item["attributes"].get("appStoreState")
    print(f"Version {version} ({state})")

    print("Updating version localizations...")
    upsert_version_localizations(client, version_id, metadata)

    if screenshots_dir:
        print("Uploading screenshots...")
        upload_screenshots(client, version_id, screenshots_dir)

    if game_center:
        print("Enabling Game Center capability on App ID...")
        ensure_game_center_bundle_capability(client, bundle_id)
        print("Configuring Game Center leaderboards...")
        try:
            detail_id = get_or_create_game_center_detail_id(client, app_id)
            print("Removing legacy solitaire leaderboards...")
            cleanup_legacy_leaderboards(client, detail_id)
            ensure_leaderboards(client, detail_id)
        except RuntimeError as exc:
            print(f"! Game Center skipped: {exc}")

    print("\nDone. Review App Store Connect, then upload build 14 from Codemagic.")


def load_client() -> ASCClient:
    env_path = SCRIPT_DIR / ".env"
    load_dotenv(env_path)
    issuer_id = os.getenv("ASC_ISSUER_ID", "").strip()
    key_id = os.getenv("ASC_KEY_ID", "").strip()
    key_path = os.getenv("ASC_PRIVATE_KEY_PATH", "").strip()
    if not issuer_id or not key_id or not key_path:
        raise RuntimeError(
            "Missing credentials. Copy scripts/.env.example to scripts/.env and fill ASC_ISSUER_ID, ASC_KEY_ID, ASC_PRIVATE_KEY_PATH."
        )
    private_key = Path(key_path).expanduser().read_text(encoding="utf-8")
    return ASCClient(issuer_id, key_id, private_key)


def main() -> int:
    parser = argparse.ArgumentParser(description="Configure Patience Ascent on App Store Connect")
    parser.add_argument(
        "--bundle-id",
        default=os.getenv("ASC_BUNDLE_ID", "com.patienceascent.app"),
    )
    parser.add_argument("--version", default=os.getenv("ASC_VERSION", "1.0"))
    parser.add_argument(
        "--game-center",
        action="store_true",
        help="Create Game Center leaderboards (enable Game Center in Connect first)",
    )
    parser.add_argument(
        "--screenshots-dir",
        type=Path,
        help="Folder with iphone-6.7/, ipad-12.9/, etc.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Validate config only")
    args = parser.parse_args()

    if args.dry_run:
        metadata = load_metadata()
        print(f"Metadata locales: {len(metadata['locales'])}")
        print(f"Leaderboards: {len(LEADERBOARDS)}")
        print("Dry run OK — credentials not required.")
        return 0

    client = load_client()
    configure_store(
        client,
        bundle_id=args.bundle_id,
        version=args.version,
        game_center=args.game_center,
        screenshots_dir=args.screenshots_dir,
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
