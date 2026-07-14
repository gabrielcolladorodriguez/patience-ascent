#!/usr/bin/env python3
"""ASO metadata — Patience Ascent gravity block puzzle, 38 locales."""

import json
from pathlib import Path

PATH = Path(__file__).resolve().parent / "metadata" / "store_metadata.json"

PACKS = {
    "en": {
        # ASO 2026: title=brand only; subtitle=primary keywords; keywords=no overlap
        "subtitle": "Gravity Drop · Clear Lines",
        "keywords": "block,blast,grid,stack,combo,offline,free,casual,lofi,rank,undo,wave,piece,fit,brain,zen,square",
        "promo": "Fit colorful blocks, gravity drops, clear rows & columns. Free block puzzle — Top 100 leaderboard, 48 lofi songs, no ads.",
        "whats": "Build 21 — New icon & Top 100 ranking\n\n• Colorful block puzzle — place shapes, gravity falls\n• Clear full rows AND columns for combo chains\n• Top 100 Ascent global leaderboard\n• 48 real CC0 lofi tracks\n• Waves, undo, free, no ads",
        "description": """Patience Ascent is a free block puzzle game for iPhone and iPad. Fit colorful shapes on an 8×8 grid, gravity pulls every block down, and full lines disappear for huge combos. Chase the Top 100 global leaderboard. Not solitaire. No ads.

HOW TO PLAY
• Pick 1 of 3 block shapes and place it on the board
• Gravity drops all blocks to the bottom of each column
• Clear full rows AND columns to score combo points
• Waves increase — your score multiplier rises as you ascend

WHY PLAYERS LOVE IT
• Learn in 10 seconds, addictive line-clear gameplay
• Undo mistakes — fair difficulty, always passable
• 48 unique lofi songs (real music, not loops)
• Top 100 Ascent — compete with the best worldwide
• One-hand portrait play for commute & breaks

FREE FOREVER — no coins, no energy, no shop, no ads.

Download Patience Ascent — the gravity block puzzle with a twist.""",
    },
    "es": {
        "subtitle": "Encaja Bloques · Gravedad",
        "keywords": "rompecabezas,cuadricula,linea,columna,combo,offline,gratis,casual,lofi,puntos,ranking,deshacer,oleada,pieza,tablero,zen,mani",
        "promo": "Encaja bloques de colores, cae la gravedad, limpia filas y columnas. Puzzle gratis — Top 100, 48 canciones lofi, sin anuncios.",
        "whats": "Build 21 — Icono nuevo y Top 100\n\n• Puzzle de bloques con gravedad\n• Filas y columnas completas = combos\n• Ranking global Top 100 Ascent\n• 48 pistas lofi CC0 reales\n• Oleadas, deshacer — gratis, sin anuncios",
        "description": """Patience Ascent es un puzzle gratuito de bloques para iPhone y iPad. Encaja piezas de colores en un tablero 8×8, la gravedad hace caer todo y las líneas llenas explotan en combos. Compite por el Top 100 mundial. No es solitario. Sin anuncios.

CÓMO SE JUEGA
• Elige una de tres piezas y colócala en el tablero
• La gravedad tira los bloques al fondo de cada columna
• Filas y columnas completas se borran con puntos extra
• Las oleadas suben el multiplicador de puntuación

GRATIS PARA SIEMPRE — sin monedas, sin energía, sin tienda, sin anuncios.""",
    },
    "fr": {
        "subtitle": "Blocs qui Tombent · Lignes",
        "keywords": "casse-tete,grille,colonne,combo,horsligne,gratuit,casual,lofi,classement,annuler,vague,piece,cerveau,zen,carre",
        "promo": "Posez des blocs colorés, gravité, effacez lignes et colonnes. Puzzle gratuit — Top 100, 48 morceaux lofi, sans pub.",
        "whats": "Build 21 — Nouvelle icône et Top 100\n\n• Puzzle blocs avec gravité\n• Lignes et colonnes = combos\n• Classement Top 100 Ascent\n• 48 morceaux lofi CC0\n• Gratuit, sans pub",
        "description": """Patience Ascent est un puzzle de blocs gratuit pour iPhone et iPad. Placez des formes colorées, la gravité fait tomber les blocs, effacez les lignes pleines et visez le Top 100 mondial. Pas de solitaire. Sans publicité.""",
    },
    "de": {
        "subtitle": "Blöcke Fallen · Linien",
        "keywords": "rätsel,raster,spalte,combo,offline,frei,casual,lofi,rangliste,rückgängig,welle,stein,gehirn,zen,quadrat,klar",
        "promo": "Bunte Blöcke setzen, Schwerkraft fällt, Reihen löschen. Kostenloses Puzzle — Top 100, 48 Lofi-Songs, ohne Werbung.",
        "whats": "Build 21 — Neues Icon & Top 100\n\n• Block-Puzzle mit Schwerkraft\n• Reihen und Spalten = Combos\n• Top 100 Ascent Rangliste\n• 48 CC0-Lofi-Tracks\n• Kostenlos, keine Werbung",
        "description": """Patience Ascent ist ein kostenloses Block-Puzzle für iPhone und iPad. Formen setzen, Schwerkraft fällt, volle Linien löschen, Top 100 jagen. Kein Solitaire. Keine Werbung.""",
    },
    "it": {
        "subtitle": "Blocchi Cadono · Linee",
        "keywords": "rompicapo,griglia,colonna,combo,offline,gratis,casual,lofi,classifica,annulla,ondata,pezzo,cervello,zen,quadrato",
        "promo": "Incastra blocchi colorati, gravità, cancella righe e colonne. Puzzle gratis — Top 100, 48 brani lofi, senza pubblicità.",
        "whats": "Build 21 — Nuova icona e Top 100\n\n• Puzzle blocchi con gravità\n• Righe e colonne = combo\n• Classifica Top 100 Ascent\n• 48 tracce lofi CC0\n• Gratis, senza pubblicità",
        "description": """Patience Ascent è un puzzle di blocchi gratuito per iPhone e iPad. Incastra forme colorate, la gravità fa cadere i blocchi, cancella le linee e punta alla Top 100. Non solitario. Nessuna pubblicità.""",
    },
    "pt": {
        "subtitle": "Blocos Caem · Linhas",
        "keywords": "quebra-cabeça,grade,coluna,combo,offline,gratis,casual,lofi,ranking,desfazer,onda,peça,cérebro,zen,quadrado",
        "promo": "Encaixe blocos coloridos, gravidade cai, limpe linhas e colunas. Puzzle grátis — Top 100, 48 músicas lofi, sem anúncios.",
        "whats": "Build 21 — Novo ícone e Top 100\n\n• Puzzle de blocos com gravidade\n• Linhas e colunas = combos\n• Ranking Top 100 Ascent\n• 48 faixas lofi CC0\n• Grátis, sem anúncios",
        "description": """Patience Ascent é um puzzle de blocos gratuito para iPhone e iPad. Encaixe formas coloridas, a gravidade puxa os blocos, limpe linhas e dispute o Top 100 global. Não é paciência. Sem anúncios.""",
    },
    "ja": {
        "subtitle": "重力ドロップ·ライン消し",
        "keywords": "ブロック,パズル,グリッド,コンボ,オフライン,無料,カジュアル,ローファイ,ランキング,元に戻す,ウェーブ,ピース,脳トレ,禅,スクエア,8x8",
        "promo": "カラフルなブロックを配置、重力で落下、ライン消し。無料パズル——Top100、ローファイ48曲、広告なし。",
        "whats": "Build 21 — 新アイコン＆Top100\n\n• 重力ブロックパズル\n• 横縦ライン消しコンボ\n• Top 100 Ascentランキング\n• CC0ローファイ48曲\n• 無料、広告なし",
        "description": """Patience AscentはiPhone/iPad向けの無料ブロックパズルです。形を置き、重力で落とし、ラインを消して世界Top100を目指します。ソリティアではありません。広告なし。""",
    },
    "ko": {
        "subtitle": "중력 낙하 · 라인 클리어",
        "keywords": "블록,퍼즐,격자,콤보,오프라인,무료,캐주얼,로파이,순위,실행취소,웨이브,조각,두뇌,젠,사각,8x8",
        "promo": "컬러 블록 맞추기, 중력 낙하, 라인 제거. 무료 퍼즐 — Top 100, 로파이 48곡, 광고 없음.",
        "whats": "Build 21 — 새 아이콘 & Top 100\n\n• 중력 블록 퍼즐\n• 가로세로 라인 클리어\n• Top 100 Ascent 순위\n• CC0 로파이 48곡\n• 무료, 광고 없음",
        "description": """Patience Ascent는 iPhone/iPad용 무료 블록 퍼즐입니다. 블록을 배치하고 중력으로 떨어뜨려 라인을 지우며 세계 Top 100에 도전하세요. 솔리테어가 아닙니다. 광고 없음.""",
    },
    "zh-Hans": {
        "subtitle": "重力下落·消行挑战",
        "keywords": "方块,拼图,网格,连击,离线,免费,休闲,低保真,排行榜,撤销,波次,碎片,脑力,禅,方形,8x8",
        "promo": "彩色方块拼放，重力下落，消除行列。免费益智——百强榜、48首低保真、无广告。",
        "whats": "Build 21 — 新图标与百强榜\n\n• 重力方块益智\n• 横竖满线连击\n• Top 100 Ascent 全球榜\n• 48首 CC0 低保真\n• 免费，无广告",
        "description": """Patience Ascent 是一款免费的 iPhone/iPad 重力方块益智游戏。放置彩色方块，重力下落，消除满线，冲击全球 Top 100。不是纸牌接龙。无广告。""",
    },
    "zh-Hant": {
        "subtitle": "重力下落·消行挑戰",
        "keywords": "方塊,拼圖,網格,連擊,離線,免費,休閒,低保真,排行榜,撤銷,波次,碎片,腦力,禪,方形,8x8",
        "promo": "彩色方塊拼放，重力下落，消除行列。免費益智——百強榜、48首低保真、無廣告。",
        "whats": "Build 21 — 新圖示與百強榜\n\n• 重力方塊益智\n• 橫豎滿線連擊\n• Top 100 Ascent 全球榜\n• 48首 CC0 低保真\n• 免費，無廣告",
        "description": """Patience Ascent 是一款免費的 iPhone/iPad 重力方塊益智遊戲。放置彩色方塊，重力下落，消除滿線，衝擊全球 Top 100。不是接龍。無廣告。""",
    },
    "ru": {
        "subtitle": "Падение · Линии",
        "keywords": "головоломка,сетка,столбец,комбо,офлайн,бесплатно,казуал,lofi,рейтинг,отмена,волна,фигура,мозг,дзен,квадрат",
        "promo": "Цветные блоки, гравитация, очистка линий. Бесплатная головоломка — Топ 100, 48 lofi-треков, без рекламы.",
        "whats": "Build 21 — Новая иконка и Топ 100\n\n• Блоки с гравитацией\n• Ряды и столбцы = комбо\n• Рейтинг Top 100 Ascent\n• 48 треков CC0 lofi\n• Бесплатно, без рекламы",
        "description": """Patience Ascent — бесплатная головоломка с блоками и гравитацией для iPhone и iPad. Ставьте фигуры, линии исчезают, гонитесь за Топ 100. Не пасьянс. Без рекламы.""",
    },
}

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
    print(f"Updated {PATH} — {len(data['locales'])} locales")


if __name__ == "__main__":
    main()
