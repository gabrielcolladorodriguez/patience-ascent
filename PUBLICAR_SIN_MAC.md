# Publicar Patience Ascent SIN MacBook

Ya pagaste los **99 USD** de Apple Developer. Puedes publicar **desde Windows** usando la nube. No necesitas comprar un Mac.

---

## Datos de tu app

| Campo | Valor |
|-------|--------|
| **Nombre App Store** | Patience Ascent |
| **Subtítulo** | 8 solitarios verticales |
| **Bundle ID** | `com.patienceascent.app` |
| **SKU** | `patience-ascent-ios-2026` |

---

## Paso 1 — Registrar el Bundle ID (desde Windows, en el navegador)

1. Entra en [developer.apple.com/account](https://developer.apple.com/account)
2. **Certificates, Identifiers & Profiles** → **Identifiers** → **+**
3. Elige **App IDs** → **App**
4. Description: `Patience Ascent`
5. Bundle ID: **Explicit** → `com.patienceascent.app`
6. Capabilities: no marques nada extra (el juego no usa push ni iCloud)
7. **Register**

---

## Paso 2 — Crear la app en App Store Connect

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** → **New App**
2. Plataformas: **iOS**
3. Nombre: **Patience Ascent**
4. Idioma principal: Español (o English)
5. Bundle ID: `com.patienceascent.app`
6. SKU: `patience-ascent-ios-2026`
7. Acceso: Full Access

Anota el **Apple ID numérico** de la app (aparece en App Information → Apple ID). Lo usarás en Codemagic.

---

## Paso 3 — Subir el código a GitHub

En PowerShell (desde la carpeta del proyecto):

```powershell
cd "C:\Users\pollo\Desktop\Juego Cartas\SolitaireRoyale"
git init
git add .
git commit -m "Patience Ascent v1.0"
```

Crea un repo **público** en [github.com/new](https://github.com/new) llamado `patience-ascent`.

**Importante:** el contenido del repo debe ser la carpeta `SolitaireRoyale` (con `SolitaireRoyale.xcodeproj` en la raíz), no la carpeta padre `Juego Cartas`.

```powershell
git remote add origin https://github.com/TU_USUARIO/patience-ascent.git
git branch -M main
git push -u origin main
```

---

## Paso 4 — Compilar en la nube (RECOMENDADO: Codemagic, sin Mac)

**Codemagic** genera certificados y firma la app por ti. Es la opción más fácil sin Mac.

1. Regístrate gratis en [codemagic.io](https://codemagic.io) (500 min/mes gratis)
2. **Add application** → conecta tu repo `patience-ascent`
3. Selecciona el proyecto Xcode: `SolitaireRoyale.xcodeproj`
4. En **Team settings** → **codemagic.yaml** ya está en el repo
5. **Code signing**:
   - Ve a **Teams** → **Code signing identities**
   - **iOS code signing** → **Generate certificate** (Codemagic lo hace automáticamente)
   - Bundle ID: `com.patienceascent.app`
6. **App Store Connect**:
   - En Codemagic → **Integrations** → **App Store Connect**
   - Crea API Key en App Store Connect:
     - [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API** → **+**
     - Nombre: `Codemagic`
     - Rol: **App Manager**
     - Descarga el archivo `.p8` (solo una vez)
     - Copia **Issuer ID** y **Key ID**
   - Pégalos en Codemagic
7. Pulsa **Start new build** → en ~10 min tendrás el IPA en TestFlight

### Alternativa: GitHub Actions (repo público = gratis)

El archivo `.github/workflows/ios.yml` compila en cada push. Solo verifica que compila; para **subir a TestFlight** desde GitHub necesitas configurar certificados manualmente (más complejo). Por eso Codemagic es más simple si no tienes Mac.

---

## Paso 5 — TestFlight y revisión de Apple

1. Cuando Codemagic termine, la build aparece en **App Store Connect → TestFlight**
2. Espera ~15–30 min a que Apple procese la build
3. Instala **TestFlight** en tu iPhone y pruébala
4. Cuando esté lista para publicar:
   - **App Store** → **+ Version** → 1.0
   - Rellena descripción, capturas, icono 1024×1024
   - **Submit for Review**

---

## Paso 6 — Icono y capturas (sin diseñar nada propio)

### Icono 1024×1024
- Usa el trofeo CC0 de Kenney: `Resources/Icons/trophy.png`
- Escala a 1024×1024 con [iloveimg.com/resize-image](https://www.iloveimg.com/resize-image) o Photopea
- Súbelo en App Store Connect → **App Icon**

### Capturas de pantalla
Opciones sin Mac:
1. **Codemagic** puede generar screenshots en simulador (feature opcional)
2. **Appetize.io** — sube el IPA y captura en simulador web
3. Pide a alguien con Mac 5 minutos en simulador Xcode
4. Tamaños mínimos: iPhone 6.7" (1290×2796) y iPad 12.9" (2048×2732) en **vertical**

---

## Paso 7 — Política de privacidad (obligatoria)

Como el juego **no recopila datos** (solo UserDefaults local), crea una página simple:

Opción gratis: [GitHub Pages](https://pages.github.com)

Crea `privacy.html` en un repo y activa Pages. Texto mínimo:

> Patience Ascent no recopila datos personales. El progreso del juego se guarda solo en tu dispositivo. No usamos analíticas ni publicidad.

Pon esa URL en App Store Connect → **App Privacy** → **Privacy Policy URL**.

En **App Privacy** marca: **No, we do not collect data**.

---

## Resumen de costes

| Concepto | Coste |
|----------|-------|
| Apple Developer | 99 USD/año ✅ ya pagado |
| Codemagic | Gratis (500 min/mes) |
| GitHub | Gratis (repo público) |
| Mac | **No necesario** |

---

## Checklist rápido

- [ ] Bundle ID `com.patienceascent.app` registrado en Developer
- [ ] App creada en App Store Connect como "Patience Ascent"
- [ ] Código en GitHub
- [ ] Codemagic conectado + certificado generado
- [ ] API Key App Store Connect en Codemagic
- [ ] Primera build en TestFlight
- [ ] Icono 1024×1024 subido
- [ ] Capturas vertical iPhone + iPad
- [ ] URL política de privacidad
- [ ] Enviar a revisión

---

## Si algo falla

| Error | Solución |
|-------|----------|
| Signing failed | Regenera certificado en Codemagic → Code signing |
| Bundle ID mismatch | Debe ser exactamente `com.patienceascent.app` en todos lados |
| Missing compliance | En App Store Connect marca "No encryption" (el juego no usa cifrado custom) |
| Build no aparece en TestFlight | Espera 30 min; revisa email de Apple por rechazos |

¿Dudas? El proyecto está listo; solo falta subirlo a GitHub y conectar Codemagic.
