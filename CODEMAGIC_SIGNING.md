# Arreglar: "No matching profiles found"

Ese error significa que Codemagic **no puede crear ni encontrar** el perfil de App Store para `com.patienceascent.app`. Haz estos pasos **en orden**:

---

## Paso 1 — Verifica en Apple Developer (navegador)

1. [developer.apple.com/account](https://developer.apple.com/account) → **Identifiers**
2. Confirma que existe: **`com.patienceascent.app`**
3. Si NO existe → créalo (App IDs → + → Explicit → `com.patienceascent.app`)

---

## Paso 2 — Verifica en App Store Connect

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps**
2. Debe existir **Patience Ascent** con Bundle ID **`com.patienceascent.app`**
3. Si no la creaste → créala ahora (mismo Bundle ID)

---

## Paso 3 — Crea API Key (OBLIGATORIO para Codemagic)

1. App Store Connect → **Users and Access** → pestaña **Integrations**
2. **App Store Connect API** → **+** (Generate API Key)
3. Nombre: `Codemagic`
4. Rol: **Admin** (recomendado) o **App Manager**
5. **Generate**
6. **Descarga el archivo `.p8`** (solo se puede una vez)
7. Anota:
   - **Issuer ID** (arriba en la misma página)
   - **Key ID** (en la tabla de claves)

---

## Paso 4 — Conecta la API Key en Codemagic

1. Codemagic → icono **Teams** (arriba) → tu equipo
2. **Team integrations** → **Developer Portal** → **Connect**
3. Rellena:
   - **Issuer ID:** (el de Apple)
   - **Key ID:** (el de Apple)
   - **API key:** pega el contenido del archivo `.p8`
4. **Nombre de la integración:** escribe exactamente → **`app_store_connect`**
5. Guarda

---

## Paso 5 — Clave privada del certificado (OBLIGATORIO)

Error: `Cannot save Signing Certificates without certificate private key`

Apple necesita una **clave RSA** para crear el certificado de distribución.

### Opción A — Más fácil (recomendada)

1. Codemagic → **Teams** → **Code signing identities**
2. **iOS certificates** → **Generate certificate**
3. Tipo: **Apple Distribution**
4. API key: tu integración `app_store_connect`
5. **Create certificate**
6. Luego **iOS provisioning profiles** → **Fetch profiles** → perfil App Store para `com.patienceascent.app`

### Opción B — Variable de entorno (automático en el yaml)

1. Lanza **una build** en rama `main` (generará la clave en el log)
2. En el log de **Set up code signing**, copia el bloque entre las líneas `-----BEGIN RSA PRIVATE KEY-----` y `-----END RSA PRIVATE KEY-----`
3. Codemagic → tu app **patience-ascent** → **Environment variables**
4. Crea grupo **`code-signing`** (si no existe)
5. Variable: **`CERTIFICATE_PRIVATE_KEY`** | Valor: la clave copiada | **Secret** ✓
6. Vuelve a compilar

---

## Paso 6 — Vuelve a compilar (tras el fix del yaml)

El error aparece si `ios_signing` está en el yaml pero **no hay perfiles subidos** en Codemagic.
El proyecto ya usa **firma automática por API** (sin `ios_signing`).

1. Repo → **patience-ascent** → **Start new build**
2. Workflow: **Patience Ascent iOS**
3. **Start build**

---

## Alternativa: subir perfiles en la UI de Codemagic

Si prefieres usar `ios_signing` en el yaml:

1. Codemagic → **Teams** → **Code signing identities**
2. **iOS certificates** → **Generate certificate** → tipo **Apple Distribution**
3. **iOS provisioning profiles** → **Fetch profiles**
4. Elige perfil **App Store** para `com.patienceascent.app`
5. Reference name: `patience_ascent_appstore`
6. **Download selected**

Sin el paso 3–4, Codemagic muestra exactamente el error que viste.

---

## Verifica el nombre de la integración

En Codemagic → **Team integrations** → mira el **nombre** de tu API key.

Debe coincidir con `codemagic.yaml`:

```yaml
integrations:
  app_store_connect: app_store_connect
```

Si lo nombraste distinto (ej. `Codemagic`), cambia la segunda línea al nombre real.

---

## Si sigue fallando

### Opción manual en Apple Developer (sin Mac, solo web)

1. developer.apple.com → **Certificates** → **+**
2. Tipo: **Apple Distribution**
3. Sigue los pasos (Codemagic puede generarlo por ti si el Paso 4 está bien)

Luego **Profiles** → **+**:
1. Tipo: **App Store**
2. App ID: `com.patienceascent.app`
3. Certificado: el de Distribution que creaste
4. Nombre: `Patience Ascent App Store`
5. **Generate** → descarga el `.mobileprovision`
6. En Codemagic → **Code signing** → **Upload provisioning profile** → sube el archivo

---

## Datos de tu proyecto

| Campo | Valor |
|-------|--------|
| Team ID | `T8GC6LS6RS` |
| Bundle ID | `com.patienceascent.app` |
| Integración Codemagic | `app_store_connect` |

El paso que casi siempre falta es el **Paso 4** (API Key `.p8` en Codemagic). Sin eso, Codemagic no puede crear perfiles.
