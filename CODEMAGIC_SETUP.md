# Codemagic — configuración manual (si el escáner falla)

Cuando Codemagic diga *"The repository doesn't seem to contain a mobile application"*:

## Opción A — Configurar manualmente (recomendado)

1. Pulsa **"Set project type manually"** o **"Configure manually"**
2. Elige: **iOS**
3. Rellena:
   - **Xcode project path:** `SolitaireRoyale.xcodeproj`
   - **Xcode scheme:** `SolitaireRoyale`
   - **Bundle ID:** `com.patienceascent.app`
4. Pulsa **Finish** / **Save**
5. Ve a **Start your first build** → selecciona workflow **Patience Ascent iOS** (desde `codemagic.yaml`)

## Opción B — Usar solo codemagic.yaml

1. En la pantalla del escáner, busca **"Use codemagic.yaml"** o **"Skip configuration"**
2. Confirma que el archivo `codemagic.yaml` está en la raíz del repo
3. Inicia build del workflow **patience-ascent-ios**

## Antes del primer build

En Codemagic → **Teams** → **codemagic.yaml settings** → activa **Enable codemagic.yaml**

En **Code signing** → genera certificado para `com.patienceascent.app`

En **Integrations** → conecta **App Store Connect API** (archivo .p8 de Apple)

## Rutas del proyecto

```
patience-ascent/          ← raíz del repo GitHub
├── codemagic.yaml
├── SolitaireRoyale.xcodeproj/
│   ├── project.pbxproj
│   └── project.xcworkspace/
└── SolitaireRoyale/      ← código fuente Swift
```
