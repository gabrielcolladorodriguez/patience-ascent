#!/usr/bin/env python3
"""Generate strings.json for Patience Ascent — gravity block puzzle."""

import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "SolitaireRoyale" / "Resources" / "strings.json"

LANGS = [
    "en", "es", "fr", "de", "it", "pt", "ja", "ko", "zh-Hans", "zh-Hant",
    "ru", "ar", "hi", "tr", "pl", "nl", "sv", "id", "vi", "th", "uk",
    "cs", "ro", "hu", "he", "ca", "ms", "da", "no", "fi", "sk", "el",
]

TRANSLATIONS = {
    "tagline": {
        "en": "Drop blocks. Clear lines. Rise.",
        "es": "Suelta bloques. Limpia líneas. Sube.",
        "fr": "Posez des blocs. Effacez des lignes. Montez.",
        "de": "Blöcke setzen. Linien löschen. Aufsteigen.",
    },
    "play_now": {"en": "Play Now", "es": "Jugar ahora", "fr": "Jouer", "de": "Jetzt spielen"},
    "rankings": {"en": "Rankings", "es": "Clasificación", "fr": "Classements", "de": "Rangliste"},
    "how_to_play": {"en": "How to Play", "es": "Cómo jugar", "fr": "Comment jouer", "de": "So geht's"},
    "settings": {"en": "Settings", "es": "Ajustes", "fr": "Réglages", "de": "Einstellungen"},
    "music": {"en": "Music", "es": "Música", "fr": "Musique", "de": "Musik"},
    "sound": {"en": "Sound", "es": "Sonido", "fr": "Son", "de": "Ton"},
    "got_it": {"en": "Got it", "es": "Entendido", "fr": "Compris", "de": "Verstanden"},
    "next": {"en": "Next", "es": "Siguiente", "fr": "Suivant", "de": "Weiter"},
    "skip": {"en": "Skip", "es": "Saltar", "fr": "Passer", "de": "Überspringen"},
    "lets_play": {"en": "Let's play!", "es": "¡A jugar!", "fr": "Jouons !", "de": "Los geht's!"},
    "score_label": {"en": "Score", "es": "Puntos", "fr": "Score", "de": "Punkte"},
    "best_label": {"en": "Best", "es": "Récord", "fr": "Record", "de": "Rekord"},
    "score_fmt": {"en": "%d pts", "es": "%d pts", "fr": "%d pts", "de": "%d Pkt."},
    "combo_fmt": {"en": "x%d combo", "es": "x%d combo", "fr": "x%d combo", "de": "x%d Combo"},
    "lines_cleared_fmt": {"en": "%d line(s)!", "es": "¡%d línea(s)!", "fr": "%d ligne(s) !", "de": "%d Linie(n)!"},
    "undo": {"en": "Undo", "es": "Deshacer", "fr": "Annuler", "de": "Rückgängig"},
    "new_game": {"en": "New", "es": "Nueva", "fr": "Nouvelle", "de": "Neu"},
    "game_over": {"en": "Game Over", "es": "Fin del juego", "fr": "Partie terminée", "de": "Spiel vorbei"},
    "new_best": {"en": "New best score!", "es": "¡Nuevo récord!", "fr": "Nouveau record !", "de": "Neuer Rekord!"},
    "play_again": {"en": "Play Again", "es": "Jugar otra vez", "fr": "Rejouer", "de": "Nochmal"},
    "menu": {"en": "Menu", "es": "Menú", "fr": "Menu", "de": "Menü"},
    "games_played": {"en": "Games", "es": "Partidas", "fr": "Parties", "de": "Spiele"},
    "reset_progress": {"en": "Reset progress", "es": "Borrar progreso", "fr": "Réinitialiser", "de": "Fortschritt löschen"},
    "reset_confirm": {"en": "Reset", "es": "Borrar", "fr": "Réinitialiser", "de": "Löschen"},
    "cancel": {"en": "Cancel", "es": "Cancelar", "fr": "Annuler", "de": "Abbrechen"},
    "reset_message": {
        "en": "This clears your best score and game count.",
        "es": "Se borrará tu récord y el número de partidas.",
        "fr": "Cela efface votre record et le nombre de parties.",
        "de": "Dies löscht Rekord und Spielanzahl.",
    },
    "mode_gravity_blocks": {
        "en": "Gravity Ascent",
        "es": "Ascenso Gravedad",
        "fr": "Ascension Gravité",
        "de": "Schwerkraft-Aufstieg",
    },
    "mode_gravity_sub": {
        "en": "Place shapes, gravity drops, clear full rows.",
        "es": "Coloca piezas, cae con gravedad, limpia filas.",
        "fr": "Placez des formes, la gravité tombe, effacez les lignes.",
        "de": "Formen setzen, Schwerkraft fällt, volle Reihen löschen.",
    },
    "controls_gravity": {
        "en": "Tap a piece, then tap the board to place it.",
        "es": "Toca una pieza y luego el tablero para colocarla.",
        "fr": "Touchez une pièce puis le plateau pour la placer.",
        "de": "Teil antippen, dann Brett antippen zum Platzieren.",
    },
    "rules_gravity_1": {
        "en": "You get three block shapes at a time.",
        "es": "Recibes tres piezas de bloques cada vez.",
        "fr": "Vous recevez trois formes à la fois.",
        "de": "Du erhältst jeweils drei Blockformen.",
    },
    "rules_gravity_2": {
        "en": "After placing, all blocks fall down with gravity.",
        "es": "Al colocar, todos los bloques caen por gravedad.",
        "fr": "Après placement, tous les blocs tombent.",
        "de": "Nach dem Setzen fallen alle Blöcke nach unten.",
    },
    "rules_gravity_3": {
        "en": "Full rows AND columns clear for huge combos.",
        "es": "Filas Y columnas completas dan combos enormes.",
        "fr": "Lignes ET colonnes pleines = combos énormes.",
        "de": "Volle Reihen UND Spalten = große Combos.",
    },
    "rules_gravity_4": {
        "en": "Game ends when no shape fits anywhere.",
        "es": "Termina cuando ninguna pieza cabe.",
        "fr": "Fin quand aucune forme ne rentre.",
        "de": "Ende, wenn keine Form mehr passt.",
    },
    "onboarding_blocks_title": {
        "en": "Place block shapes",
        "es": "Coloca piezas de bloques",
        "fr": "Placez des blocs",
        "de": "Blöcke platzieren",
    },
    "onboarding_blocks_1": {
        "en": "Pick one of three shapes in the tray.",
        "es": "Elige una de las tres piezas del bandeja.",
        "fr": "Choisissez une des trois formes.",
        "de": "Wähle eine von drei Formen.",
    },
    "onboarding_blocks_2": {
        "en": "Tap the grid where the top-left of the shape should go.",
        "es": "Toca la cuadrícula donde va la esquina de la pieza.",
        "fr": "Touchez la grille pour placer la forme.",
        "de": "Tippe auf das Raster zum Platzieren.",
    },
    "onboarding_blocks_3": {
        "en": "Used shapes are replaced when the tray is empty.",
        "es": "Las piezas usadas se renuevan al vaciar la bandeja.",
        "fr": "Les formes utilisées sont remplacées.",
        "de": "Benutzte Formen werden ersetzt.",
    },
    "onboarding_gravity_title": {
        "en": "Gravity changes everything",
        "es": "La gravedad lo cambia todo",
        "fr": "La gravité change tout",
        "de": "Schwerkraft verändert alles",
    },
    "onboarding_gravity_1": {
        "en": "After each move, blocks fall to the bottom of each column.",
        "es": "Tras cada jugada, los bloques caen al fondo de cada columna.",
        "fr": "Après chaque coup, les blocs tombent en bas.",
        "de": "Nach jedem Zug fallen Blöcke nach unten.",
    },
    "onboarding_gravity_2": {
        "en": "Complete rows disappear and score combo points.",
        "es": "Las filas completas desaparecen y dan combo.",
        "fr": "Les lignes pleines disparaissent avec combo.",
        "de": "Volle Reihen verschwinden mit Combo-Punkten.",
    },
    "onboarding_gravity_3": {
        "en": "Plan ahead — gaps can help or hurt after gravity.",
        "es": "Piensa adelante: los huecos cambian con la gravedad.",
        "fr": "Anticipez — les trous bougent avec la gravité.",
        "de": "Plane voraus — Lücken verschieben sich.",
    },
    "onboarding_relax_title": {
        "en": "Chill soundtrack",
        "es": "Música relajada",
        "fr": "Bande-son chill",
        "de": "Entspannte Musik",
    },
    "onboarding_relax_1": {
        "en": "Real CC0 lofi tracks — dozens of songs, no repeats.",
        "es": "Lofi CC0 real — decenas de canciones distintas.",
        "fr": "Vrais morceaux lofi CC0 — des dizaines de titres.",
        "de": "Echte CC0-Lofi-Tracks — viele verschiedene Songs.",
    },
    "onboarding_relax_2": {
        "en": "Toggle music and sound in Settings.",
        "es": "Activa música y sonido en Ajustes.",
        "fr": "Musique et son dans Réglages.",
        "de": "Musik und Ton in Einstellungen.",
    },
    "onboarding_relax_3": {
        "en": "Relax, stack smart, beat your best score.",
        "es": "Relájate, apila bien y bate tu récord.",
        "fr": "Détendez-vous et battez votre record.",
        "de": "Entspann dich und schlag deinen Rekord.",
    },
    "top100_title": {
        "en": "Top 100 Ascent",
        "es": "Top 100 Ascenso",
        "fr": "Top 100 Ascension",
        "de": "Top 100 Aufstieg",
    },
    "top100_header": {
        "en": "Global best scores",
        "es": "Mejores puntuaciones globales",
        "fr": "Meilleurs scores mondiaux",
        "de": "Globale Bestenliste",
    },
    "your_rank_fmt": {
        "en": "Your rank: #%d",
        "es": "Tu puesto: #%d",
        "fr": "Votre rang : #%d",
        "de": "Dein Rang: #%d",
    },
    "not_ranked_yet": {
        "en": "Play to enter the ranking",
        "es": "Juega para entrar al ranking",
        "fr": "Jouez pour entrer au classement",
        "de": "Spiele um in die Rangliste zu kommen",
    },
    "loading_rankings": {
        "en": "Loading rankings…",
        "es": "Cargando ranking…",
        "fr": "Chargement…",
        "de": "Rangliste lädt…",
    },
    "no_scores_yet": {
        "en": "No scores yet — be the first!",
        "es": "Sin puntuaciones — ¡sé el primero!",
        "fr": "Aucun score — soyez le premier !",
        "de": "Noch keine Scores — sei der Erste!",
    },
    "gc_sign_in_required": {
        "en": "Sign in to Game Center to see rankings",
        "es": "Inicia sesión en Game Center para ver el ranking",
        "fr": "Connectez-vous à Game Center",
        "de": "Melde dich bei Game Center an",
    },
    "gc_leaderboard_missing": {
        "en": "Leaderboard not configured yet in App Store Connect",
        "es": "Ranking aún no configurado en App Store Connect",
        "fr": "Classement pas encore configuré",
        "de": "Rangliste noch nicht konfiguriert",
    },
    "close": {"en": "Close", "es": "Cerrar", "fr": "Fermer", "de": "Schließen"},
    "retry": {"en": "Retry", "es": "Reintentar", "fr": "Réessayer", "de": "Erneut"},
    "you": {"en": "You", "es": "Tú", "fr": "Vous", "de": "Du"},
    "wave_fmt": {
        "en": "Wave %d",
        "es": "Oleada %d",
        "fr": "Vague %d",
        "de": "Welle %d",
    },
    "clear_rows_cols_fmt": {
        "en": "%d rows + %d cols!",
        "es": "¡%d filas + %d columnas!",
        "fr": "%d lignes + %d colonnes !",
        "de": "%d Reihen + %d Spalten!",
    },
    "open_game_center": {
        "en": "Open Game Center",
        "es": "Abrir Game Center",
        "fr": "Ouvrir Game Center",
        "de": "Game Center öffnen",
    },
}


def pick(key: str, lang: str) -> str:
    d = TRANSLATIONS[key]
    return d.get(lang, d.get("en", key))


def main() -> None:
    out: dict[str, dict[str, str]] = {}
    for key in TRANSLATIONS:
        out[key] = {lang: pick(key, lang) for lang in LANGS}
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(out)} keys)")


if __name__ == "__main__":
    main()
