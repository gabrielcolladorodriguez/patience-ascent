# Configurar la tienda con un comando

## Modo fácil (recomendado)

**Doble clic** en `scripts/CONFIGURAR_TIENDA.bat` → ventana gráfica.

Guía visual: **[CONFIGURAR_TIENDA.md](CONFIGURAR_TIENDA.md)**

---

## Modo terminal (avanzado)

Todo está preparado para que **tú solo pongas la clave API** y ejecutes el script. No hace falta pasarme credenciales por chat.

## Qué necesitas (solo esto)

1. **Issuer ID** — App Store Connect → Usuarios y acceso → Integraciones → App Store Connect API
2. **Key ID** — al crear la clave API
3. **Archivo `.p8`** — se descarga una sola vez (guárdalo en Descargas)

Rol recomendado: **Admin** o **App Manager**.

## Antes de ejecutar (una vez en Connect)

- [ ] App **Patience Ascent** creada (`com.patienceascent.app`)
- [ ] Versión **1.0** creada (App → iOS App → + Versión)
- [ ] **Game Center** activado en la app (si quieres las 9 tablas automáticas)

## Pasos en Windows

```powershell
cd "c:\Users\pollo\Desktop\Juego Cartas\SolitaireRoyale\scripts"

pip install -r requirements-asc.txt

copy .env.example .env
# Edita .env con tu Issuer ID, Key ID y ruta al .p8

python generate_app_icon.py

python configure_app_store.py --dry-run

python configure_app_store.py

python configure_app_store.py --game-center
```

## Qué hace el script

| Automático | Manual (tú después) |
|------------|---------------------|
| 35 idiomas: subtítulo, descripción, keywords | Capturas (o carpeta `store-assets/`) |
| Texto promocional y novedades v1.0 | Cuestionario App Privacy |
| Categorías: Juegos → Cartas + Casual | Edad / clasificación de contenido |
| URL privacidad y soporte | Enviar a revisión |
| 9 leaderboards Game Center (`--game-center`) | TestFlight / build Codemagic |

## Icono

El icono **no** sube por API. Va dentro del build:

- `scripts/generate_app_icon.py` crea `AppIcon.png` 1024×1024
- Codemagic build **9** lo incluye en TestFlight y App Store

## Capturas opcionales

Si más adelante tienes PNG:

```
store-assets/
  iphone-6.7/   → 1290×2796
  ipad-12.9/    → 2048×2732
```

```powershell
python configure_app_store.py --screenshots-dir ..\store-assets
```

## Archivos

- `scripts/metadata/store_metadata.json` — textos en 35 idiomas
- `scripts/configure_app_store.py` — script principal
- `scripts/.env.example` — plantilla de credenciales

## Seguridad

- **No** subas `.p8` ni `.env` a GitHub (ya están en `.gitignore`)
- **No** pegues la clave en el chat

Cuando tengas el `.env` listo, ejecuta los comandos. Si falla algo, copia el error y lo ajustamos.
