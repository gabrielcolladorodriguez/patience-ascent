# App Store — Patience Ascent

## Nombre oficial

| Campo | Valor |
|-------|-------|
| **Nombre App Store** | **Patience Ascent** |
| **Subtítulo** | 8 solitarios verticales |
| **Bundle ID** | `com.patienceascent.app` |
| **SKU** | `patience-ascent-ios-2026` |

"Ascent" evoca subir de nivel (XP, logros, desafío diario). No hay app de cartas con este nombre exacto en la App Store.

---

## Sin MacBook

Ver **[PUBLICAR_SIN_MAC.md](PUBLICAR_SIN_MAC.md)** — guía completa para Windows + Codemagic + GitHub.

---

## API Key App Store Connect

1. App Store Connect → Users and Access → Integrations → **App Store Connect API**
2. Generar clave con rol **App Manager**
3. Guardar: Issuer ID, Key ID, archivo `.p8`

Usar en Codemagic o GitHub Secrets para TestFlight automático.

---

## Checklist App Store

- [ ] Bundle ID registrado en developer.apple.com
- [ ] App creada en App Store Connect
- [ ] Build en TestFlight probada en iPhone
- [ ] Icono 1024×1024
- [ ] Capturas verticales iPhone + iPad
- [ ] Política de privacidad (URL)
- [ ] App Privacy: no recopila datos
- [ ] Categoría: Juegos → Cartas
- [ ] Edad: 4+
