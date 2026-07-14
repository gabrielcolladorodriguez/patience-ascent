# Mejoras v1.0 build 3 — Patience Ascent

## Cambios principales

### UI/UX profesional y sencilla
- Botones nativos verdes con texto blanco (sin sprites grises Kenney)
- Menú simplificado: **Jugar Klondike** directo + elegir modo
- Mesa de juego **blanca/crema** sobre fondo verde fieltro
- Botón volver con chevron (ya no icono negro)
- Controles de juego con SF Symbols claros (Pista, Deshacer, Nueva)
- Tienda y Logros accesibles desde Ajustes

### Audio arreglado
- iOS no reproduce `.ogg` → generados archivos `.wav` compatibles
- Música menú, juego y victoria funcionando
- SFX: click, cartas, shuffle, etc.
- Ajustes de música/SFX se guardan entre sesiones

### Apple compliance
- `PrivacyInfo.xcprivacy` (UserDefaults CA92.1)
- `ITSAppUsesNonExemptEncryption = false`
- `UIRequiresFullScreen` para iPad vertical
- Pantalla de lanzamiento con color verde
- Build 3

## Compilar

```bash
# En Codemagic: Start new build → main
# Rama main, workflow Patience Ascent iOS
```

## TestFlight

Tras build exitosa, rellena en App Store Connect → TestFlight → Test Information:
- Feedback Email, nombre, teléfono

## Encriptación (App Store Connect)

Selecciona: **Ninguno de los algoritmos mencionados anteriormente**
