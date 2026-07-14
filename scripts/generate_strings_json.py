#!/usr/bin/env python3
"""Generate in-app strings.json — 32 languages, unique mode names."""

import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "SolitaireRoyale" / "Resources" / "strings.json"

LANGS = [
    "en", "es", "fr", "de", "it", "pt", "ja", "ko", "zh-Hans", "zh-Hant",
    "ru", "ar", "hi", "tr", "pl", "nl", "sv", "id", "vi", "th", "uk",
    "cs", "ro", "hu", "he", "ca", "ms", "da", "no", "fi", "sk", "el",
]

# Unique invented mode brands (Patience Ascent originals)
MODE_LINK = {
    "en": "Arc Weave", "es": "Tejido Arcano", "fr": "Tisseau d'Arc", "de": "Arkangewebe",
    "it": "Tessuto Arcano", "pt": "Tecido Arcano", "ja": "アークウィーブ", "ko": "아크 위브",
    "zh-Hans": "弧光编织", "zh-Hant": "弧光編織", "ru": "Ткань Дуги", "ar": "نسيج القوس",
    "hi": "आर्क वीव", "tr": "Ark Dokusu", "pl": "Tkanina Łuku", "nl": "Boogweefsel",
    "sv": "Bågväv", "id": "Anyaman Busur", "vi": "Dệt Cung", "th": "ถักธนู",
    "uk": "Тканина Дуги", "cs": "Tkanina Oblouku", "ro": "Țesătura Arcului",
    "hu": "Ív Szövet", "he": "אריג קשת", "ca": "Teixit Arc", "ms": "Anyaman Lengkung",
    "da": "Buevæv", "no": "Buevev", "fi": "Kaarikudos", "sk": "Tkanina Oblúka", "el": "Υφή Τόξου",
}
MODE_CHAIN = {
    "en": "Flux Surge", "es": "Oleada Flux", "fr": "Flux Ravage", "de": "Flux-Schwall",
    "it": "Onda Flux", "pt": "Onda Flux", "ja": "フラックスサージ", "ko": "플럭스 서지",
    "zh-Hans": "通量涌浪", "zh-Hant": "通量湧浪", "ru": "Поток Всплеск", "ar": "موجة الفلوكس",
    "hi": "फ्लक्स सर्ज", "tr": "Flux Dalgası", "pl": "Fala Flux", "nl": "Flux Golf",
    "sv": "Fluxvåg", "id": "Gelombang Flux", "vi": "Sóng Flux", "th": "คลื่นฟลักซ์",
    "uk": "Потік Сплеск", "cs": "Flux Vlna", "ro": "Val Flux", "hu": "Flux Hullám",
    "he": "גל פלוקס", "ca": "Ona Flux", "ms": "Gelombang Flux", "da": "Fluxbølge",
    "no": "Fluxbølge", "fi": "Flux-aalto", "sk": "Flux Vlna", "el": "Κύμα Flux",
}
MODE_RUSH = {
    "en": "Nova Blitz", "es": "Nova Blitz", "fr": "Nova Blitz", "de": "Nova Blitz",
    "it": "Nova Blitz", "pt": "Nova Blitz", "ja": "ノヴァブリッツ", "ko": "노바 블리츠",
    "zh-Hans": "新星闪击", "zh-Hant": "新星閃擊", "ru": "Нова Блиц", "ar": "نوفا بليتز",
    "hi": "नोवा ब्लिट्ज", "tr": "Nova Blitz", "pl": "Nova Blitz", "nl": "Nova Blitz",
    "sv": "Nova Blitz", "id": "Nova Blitz", "vi": "Nova Blitz", "th": "โนวาบลิตซ์",
    "uk": "Нова Бліц", "cs": "Nova Blitz", "ro": "Nova Blitz", "hu": "Nova Blitz",
    "he": "נובה בליץ", "ca": "Nova Blitz", "ms": "Nova Blitz", "da": "Nova Blitz",
    "no": "Nova Blitz", "fi": "Nova Blitz", "sk": "Nova Blitz", "el": "Nova Blitz",
}
MODE_ZEN = {
    "en": "Haze Drift", "es": "Bruma Serena", "fr": "Brume Lente", "de": "Nebeltreib",
    "it": "Bruma Quieta", "pt": "Névoa Serena", "ja": "ヘイズドリフト", "ko": "헤이즈 드리프트",
    "zh-Hans": "薄雾漂流", "zh-Hant": "薄霧漂流", "ru": "Туманный Дрейф", "ar": "انجراف الضباب",
    "hi": "हेज़ ड्रिफ्ट", "tr": "Pus Sürüklenmesi", "pl": "Mgławy Dryf", "nl": "Nevel Drijv",
    "sv": "Dimma Drift", "id": "Haze Drift", "vi": "Sương Trôi", "th": "หมอกลอย",
    "uk": "Туманний Дрейф", "cs": "Mlžný Drift", "ro": "Deriva Ceață", "hu": "Köd Sodrás",
    "he": "סחף ערפל", "ca": "Bruma Serena", "ms": "Haze Drift", "da": "Tågedrift",
    "no": "Tåkedrift", "fi": "Usvavirta", "sk": "Hmlistý Drift", "el": "Ομίχλη Πλάνη",
}


def pick(d: dict, lang: str) -> str:
    return d.get(lang, d["en"])


def build_base() -> dict[str, str]:
    link, chain, rush, zen = MODE_LINK["en"], MODE_CHAIN["en"], MODE_RUSH["en"], MODE_ZEN["en"]
    return {
        "tagline": "Match symbols. Chain combos. Rise up.",
        "play_now": "Play Now",
        "how_to_play": "How to Play",
        "play_mode_fmt": "Play %@",
        "rankings": "Rankings",
        "privacy": "Privacy",
        "music": "Music",
        "sound": "Sound",
        "wins": "Wins",
        "streak": "Streak",
        "time": "Time",
        "today_challenge": "Today's Challenge",
        "new_badge": "NEW",
        "glyph_link_tagline": "Tap matching symbols — paths bend twice",
        "modes_intro": "Four original puzzle modes. One board, four challenges.",
        "your_best_times": "Your records",
        "total_play_time": "Total play time",
        "open_game_center": "Open Game Center",
        "wins_streak_fmt": "%d wins · streak %d",
        "score_fmt": "%d pts",
        "hint": "Hint",
        "undo": "Undo",
        "shuffle": "Shuffle",
        "new_game": "New",
        "got_it": "Got it",
        "skip": "Skip",
        "next": "Next",
        "lets_play": "Let's play!",
        "you_win": "You win!",
        "time_up": "Time's up!",
        "new_best_fmt": "New best in %@!",
        "new_best_score_fmt": "New high score in %@!",
        "play_again": "Play again",
        "menu": "Menu",
        "back": "Back",
        "no_matches_shuffle": "No matches — shuffling",
        "no_matches_tap_shuffle": "No matches — tap Shuffle",
        "onboarding_glyph_title": link,
        "onboarding_glyph_1": "Tap two matching symbols to connect them.",
        "onboarding_glyph_2": "Paths can turn twice — even around the board edge.",
        "onboarding_glyph_3": "Clear the board. Beat your time. Climb the ranks.",
        "onboarding_modes_title": "Four originals",
        "onboarding_modes_1": f"{link} — clear the board fast.",
        "onboarding_modes_2": f"{chain} — chain nearby matches for huge combos.",
        "onboarding_modes_3": f"{rush} — 90 seconds, max score. {zen} — calm, no auto-shuffle.",
        "onboarding_relax_title": "Relax & compete",
        "onboarding_relax_1": "Lofi music and crisp sounds — toggle anytime.",
        "onboarding_relax_2": "Unlimited hints and undo in every mode.",
        "onboarding_relax_3": "Daily challenge and Game Center leaderboards.",
        "mode_glyph_link": link,
        "mode_glyph_chain": chain,
        "mode_glyph_rush": rush,
        "mode_glyph_zen": zen,
        "mode_glyph_sub": "Clear the board — signature rules",
        "mode_chain_sub": "Chain nearby matches for huge combos",
        "mode_rush_sub": "90 seconds — score as much as you can",
        "mode_zen_sub": "Relaxed pace — you control shuffles",
        "controls_glyph": "Tap · Match · Chain combos",
        "controls_zen": "Tap · Match · Shuffle when you want",
        "rules_glyph_1": "Tap two matching symbols to link them.",
        "rules_glyph_2": "Paths can bend twice and use the board edges.",
        "rules_glyph_3": "Matched symbols vanish; columns fall. Clear the board to win.",
        "rules_glyph_4": "Chain matches for combo speed. Shuffle if you're stuck.",
        "rules_chain_1": f"Same rules as {link} — connect matching symbols.",
        "rules_chain_2": "After a match, your next pair must touch the last clear.",
        "rules_chain_3": "Keep the chain alive for bigger combo multipliers.",
        "rules_chain_4": "Break the chain and your combo resets to 1.",
        "rules_rush_1": "You have 90 seconds — match as fast as you can.",
        "rules_rush_2": "Each match scores 100 × your current combo.",
        "rules_rush_3": "Clear the board? A fresh one appears instantly.",
        "rules_rush_4": "When time ends, your total score is saved.",
        "rules_zen_1": f"Peaceful {link} — no timer pressure.",
        "rules_zen_2": "The board never auto-shuffles when stuck.",
        "rules_zen_3": "Use Hint to find a pair, or Shuffle yourself.",
        "rules_zen_4": "Perfect for relaxing with lofi music.",
        "game_center_fmt": "Game Center · %@",
    }


def build_lang_overrides(lang: str) -> dict[str, str]:
    link, chain, rush, zen = pick(MODE_LINK, lang), pick(MODE_CHAIN, lang), pick(MODE_RUSH, lang), pick(MODE_ZEN, lang)
    packs = {
        "es": {
            "tagline": "Empareja símbolos. Encadena combos. Sube de nivel.",
            "play_now": "Jugar ahora", "how_to_play": "Cómo jugar", "play_mode_fmt": "Jugar %@",
            "rankings": "Clasificaciones", "privacy": "Privacidad", "music": "Música", "sound": "Sonido",
            "wins": "Victorias", "streak": "Racha", "time": "Tiempo", "today_challenge": "Desafío de hoy",
            "glyph_link_tagline": "Toca símbolos iguales — caminos con dos giros",
            "modes_intro": "Cuatro modos originales. Un tablero, cuatro retos.",
            "your_best_times": "Tus récords", "total_play_time": "Tiempo total jugado",
            "open_game_center": "Abrir Game Center", "wins_streak_fmt": "%d victorias · racha %d",
            "hint": "Pista", "undo": "Deshacer", "shuffle": "Mezclar", "new_game": "Nueva",
            "got_it": "Entendido", "skip": "Saltar", "next": "Siguiente", "lets_play": "¡A jugar!",
            "you_win": "¡Victoria!", "time_up": "¡Tiempo!", "new_best_fmt": "¡Nuevo récord en %@!",
            "new_best_score_fmt": "¡Nueva puntuación en %@!", "play_again": "Otra partida", "menu": "Menú",
            "no_matches_shuffle": "Sin parejas — mezclando",
            "no_matches_tap_shuffle": "Sin parejas — pulsa Mezclar",
            "onboarding_glyph_1": "Toca dos símbolos iguales para conectarlos.",
            "onboarding_glyph_2": "Los caminos giran dos veces — también por el borde.",
            "onboarding_glyph_3": "Limpia el tablero. Mejora tu tiempo. Sube en el ranking.",
            "onboarding_modes_title": "Cuatro originales",
            "onboarding_relax_title": "Relájate y compite",
            "onboarding_relax_1": "Música lofi y sonidos — actívalos cuando quieras.",
            "onboarding_relax_2": "Pistas y deshacer ilimitados en todos los modos.",
            "onboarding_relax_3": "Desafío diario y rankings en Game Center.",
            "mode_glyph_sub": "Limpia el tablero — reglas exclusivas",
            "mode_chain_sub": "Encadena parejas cercanas para combos enormes",
            "mode_rush_sub": "90 segundos — máxima puntuación",
            "mode_zen_sub": "Ritmo relajado — tú mezclas",
            "controls_glyph": "Toca · Empareja · Combos", "controls_zen": "Toca · Empareja · Mezcla cuando quieras",
            "rules_glyph_1": "Toca dos símbolos iguales para enlazarlos.",
            "rules_glyph_2": "Los caminos giran dos veces y usan los bordes.",
            "rules_glyph_3": "Desaparecen y caen las columnas. Limpia el tablero.",
            "rules_glyph_4": "Encadena para combos. Mezcla si te atascas.",
            "rules_chain_2": "Tras un match, la siguiente pareja debe tocar el último.",
            "rules_chain_3": "Mantén la cadena para multiplicadores de combo.",
            "rules_chain_4": "Rompe la cadena y el combo vuelve a 1.",
            "rules_rush_1": "Tienes 90 segundos — empareja lo más rápido posible.",
            "rules_rush_2": "Cada match suma 100 × tu combo actual.",
            "rules_rush_3": "¿Tablero vacío? Aparece uno nuevo al instante.",
            "rules_rush_4": "Al acabar el tiempo se guarda tu puntuación.",
            "rules_zen_2": "El tablero no se mezcla solo si te atascas.",
            "rules_zen_3": "Usa Pista o Mezclar cuando quieras.",
            "rules_zen_4": "Perfecto para relajarte con música lofi.",
        },
        "fr": {
            "tagline": "Associez les symboles. Enchaînez. Montez.",
            "play_now": "Jouer", "how_to_play": "Comment jouer", "rankings": "Classements",
            "privacy": "Confidentialité", "music": "Musique", "sound": "Son",
            "hint": "Indice", "undo": "Annuler", "shuffle": "Mélanger", "you_win": "Victoire !",
            "lets_play": "Jouons !", "modes_intro": "Quatre modes originaux. Un plateau, quatre défis.",
            "mode_glyph_sub": "Videz le plateau — règles signature",
            "mode_chain_sub": "Enchaînez les paires proches", "mode_rush_sub": "90 secondes — score max",
            "mode_zen_sub": "Rythme calme — vous mélangez",
        },
        "de": {
            "tagline": "Symbole verbinden. Combos ketten. Aufsteigen.",
            "play_now": "Jetzt spielen", "how_to_play": "So geht's", "rankings": "Ranglisten",
            "hint": "Tipp", "undo": "Rückgängig", "you_win": "Gewonnen!", "lets_play": "Los geht's!",
            "modes_intro": "Vier Originalmodi. Ein Brett, vier Herausforderungen.",
        },
        "it": {
            "play_now": "Gioca ora", "how_to_play": "Come si gioca", "rankings": "Classifiche",
            "hint": "Suggerimento", "undo": "Annulla", "you_win": "Hai vinto!",
        },
        "pt": {
            "play_now": "Jogar agora", "how_to_play": "Como jogar", "rankings": "Rankings",
            "hint": "Dica", "undo": "Desfazer", "you_win": "Vitória!",
        },
        "ja": {
            "play_now": "今すぐプレイ", "how_to_play": "遊び方", "rankings": "ランキング",
            "hint": "ヒント", "undo": "元に戻す", "you_win": "勝利！", "lets_play": "プレイ！",
            "modes_intro": "4つのオリジナルモード。1つの盤面、4つの挑戦。",
        },
        "ko": {
            "play_now": "지금 플레이", "how_to_play": "게임 방법", "rankings": "순위",
            "hint": "힌트", "undo": "실행 취소", "you_win": "승리!",
        },
        "zh-Hans": {
            "tagline": "匹配符号。连击组合。不断攀升。",
            "play_now": "立即开始", "how_to_play": "玩法说明", "rankings": "排行榜",
            "hint": "提示", "undo": "撤销", "you_win": "胜利！", "lets_play": "开始游戏！",
            "modes_intro": "四种原创模式。一个棋盘，四种挑战。",
        },
        "zh-Hant": {
            "play_now": "立即開始", "how_to_play": "玩法說明", "rankings": "排行榜",
            "hint": "提示", "undo": "復原", "you_win": "勝利！",
        },
        "ru": {
            "play_now": "Играть", "how_to_play": "Как играть", "rankings": "Рейтинги",
            "hint": "Подсказка", "undo": "Отмена", "you_win": "Победа!",
        },
    }
    o = dict(packs.get(lang, {}))
    o["mode_glyph_link"] = link
    o["mode_glyph_chain"] = chain
    o["mode_glyph_rush"] = rush
    o["mode_glyph_zen"] = zen
    o["onboarding_glyph_title"] = link
    o["onboarding_modes_1"] = f"{link} — " + (
        "limpia el tablero rápido." if lang == "es" else
        "clear the board fast." if lang == "en" else
        "videz le plateau vite." if lang == "fr" else
        "leere das Brett schnell." if lang == "de" else
        "快速清空棋盘。" if lang == "zh-Hans" else
        "быстро очистите поле." if lang == "ru" else
        "clear the board fast."
    )
    o["onboarding_modes_2"] = f"{chain} — " + (
        "encadena parejas cercanas." if lang == "es" else
        "chain nearby matches." if lang == "en" else
        "enchaînez les paires proches." if lang == "fr" else
        "kette nahe Paare." if lang == "de" else
        "连锁相邻配对。" if lang == "zh-Hans" else
        "chain nearby matches."
    )
    o["onboarding_modes_3"] = (
        f"{rush} — 90 s, máxima puntuación. {zen} — tranquilo." if lang == "es" else
        f"{rush} — 90 seconds, max score. {zen} — calm." if lang == "en" else
        f"{rush} — 90 s, score max. {zen} — calme." if lang == "fr" else
        f"{rush} — 90 Sekunden. {zen} — ruhig." if lang == "de" else
        f"{rush} — 90秒最高分。{zen} — 悠闲。" if lang == "zh-Hans" else
        f"{rush} — 90 seconds. {zen} — calm."
    )
    o["rules_chain_1"] = (
        f"Mismas reglas que {link} — conecta símbolos." if lang == "es" else
        f"Mêmes règles que {link}." if lang == "fr" else
        f"Gleiche Regeln wie {link}." if lang == "de" else
        f"与{link}相同规则——连接相同符号。" if lang == "zh-Hans" else
        f"Same rules as {link} — connect matching symbols."
    )
    o["rules_zen_1"] = (
        f"{zen} tranquilo — sin presión." if lang == "es" else
        f"Calm {zen} — no timer." if lang == "en" else
        f"{zen} paisible — sans chrono." if lang == "fr" else
        f"Ruhiges {zen} — ohne Timer." if lang == "de" else
        f"轻松的{zen}——无计时压力。" if lang == "zh-Hans" else
        f"Peaceful {zen} — no timer pressure."
    )
    return o


def build_table() -> dict:
    base = build_base()
    table: dict[str, dict[str, str]] = {}
    for key, en_val in base.items():
        row = {"en": en_val}
        for lang in LANGS:
            if lang == "en":
                continue
            overrides = build_lang_overrides(lang)
            row[lang] = overrides.get(key, en_val)
        table[key] = row
    return table


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    table = build_table()
    OUT.write_text(json.dumps(table, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {OUT} ({len(table)} keys, {len(LANGS)} languages)")


if __name__ == "__main__":
    main()
