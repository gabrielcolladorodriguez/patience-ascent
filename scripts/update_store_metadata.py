#!/usr/bin/env python3
"""ASO-optimized App Store metadata — puzzle-only, 38 locales."""

import json
from pathlib import Path

PATH = Path(__file__).resolve().parent / "metadata" / "store_metadata.json"

# ASO 2026: subtitle 30 chars, no repeat title words (Patience/Ascent), keywords 100 no spaces
PACKS = {
    "en": {
        "subtitle": "Match Symbols · Brain Puzzle",
        "keywords": "tile,connect,link,logic,mahjong,zen,combo,offline,free,casual,lofi,daily,challenge,relax,portrait",
        "promo": "Connect matching symbols in 4 original modes. Unlimited hints, lofi music, daily challenge — free, no ads on iPhone & iPad.",
        "whats": "Build 14 — Original puzzle game\n\n• Arc Weave, Flux Surge, Nova Blitz & Haze Drift\n• Symbol-matching puzzle — not solitaire\n• 32 languages, Game Center rankings\n• Unlimited hints, lofi music, daily challenge",
        "description": """Patience Ascent is a free symbol-matching puzzle game for iPhone and iPad — connect tiles, train your brain, and relax with lofi music. Not solitaire. No ads.

WHY PLAYERS LOVE IT
• Easy to learn in 30 seconds — addictive match-and-clear gameplay
• Four original modes on one gorgeous 6×8 board
• Unlimited hints and undo — never stuck
• Portrait play, no scrolling, perfect for one hand
• Daily challenge and Game Center leaderboards

FOUR ORIGINAL MODES
• Arc Weave — connect matching symbols, paths bend twice
• Flux Surge — chain nearby matches for massive combos
• Nova Blitz — 90-second score attack, how high can you go?
• Haze Drift — calm zen mode, play at your own pace

PERFECT FOR
Brain training, commute breaks, relaxing before sleep, puzzle fans who want something fresh — not another card solitaire clone.

FREE FOREVER
No coins, no energy, no shop, no ads. Just puzzles, music, and your best time.

Download Patience Ascent — the symbol puzzle game built to be different.""",
    },
    "es": {
        "subtitle": "Empareja · Puzzle Cerebral",
        "keywords": "tile,conectar,enlace,logica,mahjong,zen,combo,offline,gratis,casual,lofi,diario,reto,relajar,vertical",
        "promo": "Conecta símbolos iguales en 4 modos originales. Pistas ilimitadas, música lofi y desafío diario — gratis, sin anuncios.",
        "whats": "Build 14 — Puzzle original\n\n• Tejido Arcano, Oleada Flux, Nova Blitz y Bruma Serena\n• Puzzle de símbolos — no es solitario\n• 32 idiomas y rankings Game Center\n• Pistas ilimitadas, música lofi, desafío diario",
        "description": """Patience Ascent es un puzzle gratuito de símbolos para iPhone y iPad. Conecta fichas, entrena tu cerebro y relájate con música lofi. No es solitario. Sin anuncios.

POR QUÉ ENCAJA
• Aprende en 30 segundos — adictivo y fácil de jugar
• Cuatro modos originales en un tablero 6×8
• Pistas y deshacer ilimitados
• Vertical, sin scroll, ideal con una mano
• Desafío diario y rankings en Game Center

CUATRO MODOS ORIGINALES
• Tejido Arcano — conecta símbolos, caminos con dos giros
• Oleada Flux — encadena parejas cercanas para combos enormes
• Nova Blitz — 90 segundos, máxima puntuación
• Bruma Serena — modo zen tranquilo

GRATIS PARA SIEMPRE
Sin monedas, sin energía, sin tienda, sin anuncios.

Descarga Patience Ascent — un puzzle de símbolos diferente a todo lo demás.""",
    },
    "fr": {
        "subtitle": "Symboles · Puzzle Cérébral",
        "keywords": "tuile,connecter,lien,logique,mahjong,zen,combo,horsligne,gratuit,casual,lofi,quotidien,defi,relax,portrait",
        "promo": "Associez des symboles dans 4 modes originaux. Indices illimités, musique lofi, défi quotidien — gratuit, sans pub.",
        "whats": "Build 14 — Puzzle original\n\n• Tisseau d'Arc, Flux Ravage, Nova Blitz, Brume Lente\n• Puzzle de symboles — pas de solitaire\n• 32 langues et classements Game Center",
        "description": """Patience Ascent est un puzzle gratuit de symboles pour iPhone et iPad. Connectez les tuiles, stimulez votre cerveau, détendez-vous avec de la musique lofi. Pas de solitaire. Sans publicité.

QUATRE MODES ORIGINAUX
• Tisseau d'Arc — connectez les symboles, chemins à deux virages
• Flux Ravage — enchaînez les paires proches
• Nova Blitz — 90 secondes, score maximum
• Brume Lente — mode zen tranquille

Indices et annulations illimités. Défi quotidien. Classements Game Center. Gratuit, sans pub.""",
    },
    "de": {
        "subtitle": "Symbole Match Denkspiel",
        "keywords": "kachel,verbinden,link,logik,mahjong,zen,combo,offline,frei,casual,lofi,täglich,challenge,entspann,hochformat",
        "promo": "Verbinde Symbole in 4 Originalmodi. Unbegrenzte Tipps, Lofi-Musik, Tagesherausforderung — kostenlos, ohne Werbung.",
        "whats": "Build 14 — Originales Puzzle\n\n• Arkangewebe, Flux-Schwall, Nova Blitz, Nebeltreib\n• Symbol-Puzzle — kein Solitaire\n• 32 Sprachen, Game Center-Ranglisten",
        "description": """Patience Ascent ist ein kostenloses Symbol-Puzzle für iPhone und iPad. Verbinde Kacheln, trainiere dein Gehirn, entspanne mit Lofi-Musik. Kein Solitaire. Keine Werbung.

VIER ORIGINALMODI: Arkangewebe, Flux-Schwall, Nova Blitz, Nebeltreib. Unbegrenzte Tipps. Tägliche Herausforderung. Game Center. Kostenlos.""",
    },
    "it": {
        "subtitle": "Abbina Simboli · Puzzle",
        "keywords": "tile,collega,link,logica,mahjong,zen,combo,offline,gratis,casual,lofi,giornaliero,sfida,rilass,verticale",
        "promo": "Collega simboli in 4 modalità originali. Suggerimenti illimitati, musica lofi, sfida giornaliera — gratis, senza pubblicità.",
        "whats": "Build 14 — Puzzle originale\n\n• Tessuto Arcano, Onda Flux, Nova Blitz, Bruma Quieta\n• Puzzle di simboli — non solitario\n• 32 lingue, classifiche Game Center",
        "description": """Patience Ascent è un puzzle gratuito di simboli per iPhone e iPad. Collega le tessere, allenati e rilassati con musica lofi. Non solitario. Nessuna pubblicità. Quattro modalità originali, suggerimenti illimitati, sfida giornaliera e Game Center.""",
    },
    "pt": {
        "subtitle": "Combine Símbolos Puzzle",
        "keywords": "tile,conectar,link,logica,mahjong,zen,combo,offline,gratis,casual,lofi,diario,desafio,relax,vertical",
        "promo": "Combine símbolos em 4 modos originais. Dicas ilimitadas, música lofi, desafio diário — grátis, sem anúncios.",
        "whats": "Build 14 — Puzzle original\n\n• Tecido Arcano, Onda Flux, Nova Blitz, Névoa Serena\n• Puzzle de símbolos — não é paciência\n• 32 idiomas, rankings Game Center",
        "description": """Patience Ascent é um puzzle gratuito de símbolos para iPhone e iPad. Conecte peças, treine o cérebro e relaxe com música lofi. Não é solitário. Sem anúncios. Quatro modos originais, dicas ilimitadas, desafio diário e Game Center.""",
    },
    "ja": {
        "subtitle": "シンボルマッチ脳トレパズル",
        "keywords": "タイル,連結,リンク,論理,まちゃん,禅,コンボ,オフライン,無料,カジュアル,ローファイ,デイリー,チャレンジ,リラックス,縦画面",
        "promo": "4つのオリジナルモードでシンボルをマッチ。無制限ヒント、ローファイ音楽、デイリーチャレンジ——無料、広告なし。",
        "whats": "Build 14 — オリジナルパズル\n\n• アークウィーブ、フラックスサージ、ノヴァブリッツ、ヘイズドリフト\n• シンボルマッチパズル——ソリティアではありません\n• 32言語、Game Centerランキング",
        "description": """Patience AscentはiPhone/iPad向けの無料シンボルマッチパズルです。タイルを繋ぎ、脳トレし、ローファイ音楽でリラックス。ソリティアではありません。広告なし。4つのオリジナルモード、無制限ヒント、デイリーチャレンジ、Game Center対応。""",
    },
    "ko": {
        "subtitle": "심볼 매칭 두뇌 퍼즐",
        "keywords": "타일,연결,링크,논리,마작,젠,콤보,오프라인,무료,캐주얼,로파이,데일리,챌린지,휴식,세로",
        "promo": "4가지 오리지널 모드에서 심볼을 매칭하세요. 무제한 힌트, 로파이 음악, 일일 챌린지 — 무료, 광고 없음.",
        "whats": "Build 14 — 오리지널 퍼즐\n\n• 아크 위브, 플럭스 서지, 노바 블리츠, 헤이즈 드리프트\n• 심볼 매칭 퍼즐 — 솔리테어 아님\n• 32개 언어, Game Center 순위",
        "description": """Patience Ascent는 iPhone/iPad용 무료 심볼 매칭 퍼즐입니다. 타일을 연결하고 두뇌를 훈련하며 로파이 음악으로 휴식하세요. 솔리테어가 아닙니다. 광고 없음. 4가지 오리지널 모드, 무제한 힌트, 일일 챌린지, Game Center.""",
    },
    "zh-Hans": {
        "subtitle": "符号连线·脑力益智",
        "keywords": "方块,连接,连线,逻辑,麻将,禅,连击,离线,免费,休闲,低保真,每日,挑战,放松,竖屏",
        "promo": "四种原创模式中连接相同符号。无限提示、低保真音乐、每日挑战——免费，无广告。",
        "whats": "Build 14 — 原创益智游戏\n\n• 弧光编织、通量涌浪、新星闪击、薄雾漂流\n• 符号连线益智——不是纸牌接龙\n• 32种语言，Game Center 排行榜",
        "description": """Patience Ascent 是一款免费的符号连线益智游戏，适用于 iPhone 和 iPad。连接方块、锻炼大脑、用低保真音乐放松。不是纸牌接龙。无广告。四种原创模式、无限提示、每日挑战、Game Center 排行榜。""",
    },
    "zh-Hant": {
        "subtitle": "符號連線·腦力益智",
        "keywords": "方塊,連接,連線,邏輯,麻將,禪,連擊,離線,免費,休閒,低保真,每日,挑戰,放鬆,直向",
        "promo": "四種原創模式中連接相同符號。無限提示、低保真音樂、每日挑戰——免費，無廣告。",
        "whats": "Build 14 — 原創益智遊戲\n\n• 弧光編織、通量湧浪、新星閃擊、薄霧漂流\n• 符號連線益智——不是接龍\n• 32種語言，Game Center 排行榜",
        "description": """Patience Ascent 是一款免費的符號連線益智遊戲，適用於 iPhone 和 iPad。連接方塊、鍛鍊大腦、用低保真音樂放鬆。不是接龍。無廣告。四種原創模式、無限提示、每日挑戰、Game Center 排行榜。""",
    },
    "ru": {
        "subtitle": "Символы · Головоломка",
        "keywords": "плитка,связь,логика,маджонг,дзен,комбо,офлайн,бесплатно,казуал,lofi,ежедневно,челлендж,релакс,портрет",
        "promo": "Соединяйте символы в 4 оригинальных режимах. Безлимитные подсказки, lofi-музыка, ежедневный вызов — бесплатно.",
        "whats": "Build 14 — Оригинальная головоломка\n\n• Ткань Дуги, Поток Всплеск, Нова Блиц, Туманный Дрейф\n• Не пасьянс\n• 32 языка, Game Center",
        "description": """Patience Ascent — бесплатная головоломка со символами для iPhone и iPad. Соединяйте плитки, тренируйте мозг, расслабляйтесь под lofi. Не пасьянс. Без рекламы. Четыре оригинальных режима, безлимитные подсказки, ежедневный вызов.""",
    },
}

# Locales → pack key
LOCALE_PACK = {
    "en-US": "en", "en-GB": "en", "en-AU": "en", "en-CA": "en",
    "es-ES": "es", "es-MX": "es",
    "fr-FR": "fr", "fr-CA": "fr",
    "de-DE": "de",
    "it": "it",
    "pt-BR": "pt", "pt-PT": "pt",
    "ja": "ja",
    "ko": "ko",
    "zh-Hans": "zh-Hans", "zh-Hant": "zh-Hant",
    "ru": "ru",
    "nl-NL": "en", "sv": "en", "da": "en", "no": "en", "fi": "en",
    "pl": "en", "tr": "en", "th": "en", "vi": "en", "id": "en", "ms": "en",
    "ca": "es", "cs": "en", "el": "en", "hu": "en", "ro": "en", "sk": "en",
    "uk": "ru", "hi": "en", "ar-SA": "en", "he": "en",
}

OLD_LEADERBOARDS = {
    "patience_best_klondike", "patience_best_freeCell", "patience_best_spider",
    "patience_best_pyramid", "patience_best_triPeaks", "patience_best_golf",
    "patience_best_yukon", "patience_best_fortyThieves",
}

KEEP_LEADERBOARDS = {
    "patience_total_time", "patience_best_glyphLink", "patience_best_glyphChain",
    "patience_best_glyphRush", "patience_best_glyphZen",
}


def main() -> None:
    data = json.loads(PATH.read_text(encoding="utf-8"))
    data["app"]["primarySubcategoryOne"] = "GAMES_PUZZLE"

    for locale in data["locales"]:
        pack_key = LOCALE_PACK.get(locale, "en")
        pack = PACKS[pack_key]
        data["locales"][locale] = {
            "subtitle": pack["subtitle"][:30],
            "keywords": pack["keywords"][:100],
            "description": pack["description"],
        }
        if locale in data.get("promotionalText", {}):
            data["promotionalText"][locale] = pack["promo"][:170]
        if locale in data.get("whatsNew", {}):
            data["whatsNew"][locale] = pack["whats"]

    PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Updated {PATH} — {len(data['locales'])} locales, category GAMES_PUZZLE")


if __name__ == "__main__":
    main()
