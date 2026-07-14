# Configurar la tienda — MODO FÁCIL

## Opción 1: Doble clic (recomendado)

1. Abre la carpeta `scripts`
2. **Doble clic** en **`CONFIGURAR_TIENDA.bat`**
3. Se abre una ventana con 3 campos

## Qué poner en la ventana

| Campo | Dónde lo sacas |
|-------|----------------|
| **Issuer ID** | App Store Connect → Usuarios y acceso → Integraciones → API |
| **Key ID** | Al crear la clave (columna Key ID) |
| **Archivo .p8** | Botón **Examinar** → el `AuthKey_XXXXX.p8` de Descargas |

Pulsa **❓ Ayuda** dentro de la ventana si te pierdes.

## Botones

1. **Guardar** — guarda en tu PC (`scripts/.env`)
2. **Probar conexión** — comprueba que la clave funciona
3. **Configurar tienda (38 idiomas)** — descripciones, keywords, categorías…
4. **+ Game Center (9 tablas)** — lo anterior + clasificaciones

## ¿Me pasas la clave por chat?

**No.** Por seguridad Apple no permite revocar un `.p8` compartido fácilmente.

- La clave **solo** va en tu PC (ventana o `.env`)
- Si algo falla, copia el **Registro** de abajo en la ventana y pégalo en Cursor
- **No** pegues Issuer ID + Key ID + .p8 en el chat

## Antes de pulsar Configurar

En [App Store Connect](https://appstoreconnect.apple.com):

- [ ] App **Patience Ascent** creada
- [ ] Versión **1.0** creada
- [ ] Game Center activado (solo si usas el botón de Game Center)

## Opción 2: Línea de comandos

Ver sección avanzada en `SETUP_APP_STORE.md` si prefieres terminal.

## Archivos

| Archivo | Qué es |
|---------|--------|
| `CONFIGURAR_TIENDA.bat` | Abre la interfaz |
| `configure_store_gui.py` | La ventana gráfica |
| `configure_app_store.py` | Motor detrás |
| `metadata/store_metadata.json` | Textos en 38 idiomas |
