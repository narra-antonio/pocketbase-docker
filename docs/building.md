# 🏗️ Build & Tagging

Questa guida spiega come buildare l'immagine localmente e la strategia di
versionamento adottata per i tag su Docker Hub e ghcr.io.

---

## 🔨 Build locale

### Prerequisiti

- Docker Engine 20.10+
- Il binario `pocketbase` scaricato nella root del progetto (vedi sotto)

### Scarica PocketBase

```bash
curl -fSL "https://github.com/pocketbase/pocketbase/releases/download/v0.36.8/pocketbase_0.36.8_linux_arm64.zip" -o pocketbase.zip && \
unzip pocketbase.zip && \
rm pocketbase.zip CHANGELOG.md README.md
```

> 💡 Sostituisci `arm64` con `amd64` se stai buildando su una macchina x86_64.

### Build delle tre varianti

```bash
# Alpine (default)
docker build -f Dockerfile.alpine -t pocketbase-docker:local-alpine .

# Debian Trixie Slim
docker build -f Dockerfile.debian -t pocketbase-docker:local-trixie .

# UBI9 Minimal
docker build -f Dockerfile.ubi -t pocketbase-docker:local-ubi .
```

### Build con versione PocketBase custom

La versione di PocketBase è configurabile tramite `ARG`:

```bash
docker build \
  -f Dockerfile.alpine \
  --build-arg POCKETBASE_VERSION=0.36.8 \
  -t pocketbase-docker:local-alpine .
```

### Build multi-arch con buildx

Per buildare e pubblicare immagini multi-arch (`amd64` + `arm64`) in locale:

```bash
# Crea un builder buildx (una sola volta)
docker buildx create --name pb-builder --use

# Build e push multi-arch Alpine
docker buildx build \
  -f Dockerfile.alpine \
  --platform linux/amd64,linux/arm64 \
  --build-arg POCKETBASE_VERSION=0.36.8 \
  -t tonynarra/pocketbase-docker:local-alpine \
  --push .

# Build e push multi-arch Debian
docker buildx build \
  -f Dockerfile.debian \
  --platform linux/amd64,linux/arm64 \
  --build-arg POCKETBASE_VERSION=0.36.8 \
  -t tonynarra/pocketbase-docker:local-trixie \
  --push .

# Build e push multi-arch UBI9
docker buildx build \
  -f Dockerfile.ubi \
  --platform linux/amd64,linux/arm64 \
  --build-arg POCKETBASE_VERSION=0.36.8 \
  -t tonynarra/pocketbase-docker:local-ubi \
  --push .
```

> 💡 Il flag `--push` è necessario per le build multi-arch — le immagini multi-arch
> non possono essere caricate nel daemon Docker locale, devono essere pubblicate
> su un registry. Per test locali usa la build singola arch senza `--push`.

### Test rapido

```bash
# Avvia con le impostazioni minime
docker run --rm \
  -p 8090:8090 \
  -e PB_ADMIN_EMAIL=admin@test.local \
  -e PB_ADMIN_PASSWORD=Test1234! \
  pocketbase-docker:local-alpine

# Verifica che risponda
curl http://localhost:8090/api/health
```

---

## 🏷️ Strategia di tagging

I tag seguono il versionamento **SemVer** del progetto (`MAJOR.MINOR.PATCH`),
indipendente dalla versione di PocketBase inclusa nell'immagine.

### Struttura dei tag

Per ogni release (es. `v1.0.0`) vengono pubblicati i seguenti tag:

| Tag | Variante | Descrizione |
|---|---|---|
| `latest` | Alpine | Ultima versione stabile, variante Alpine |
| `1-alpine` | Alpine | Major version, variante Alpine |
| `1.0-alpine` | Alpine | Minor version, variante Alpine |
| `1.0.0-alpine` | Alpine | Patch version, variante Alpine |
| `1-trixie` | Debian | Major version, variante Debian |
| `1.0-trixie` | Debian | Minor version, variante Debian |
| `1.0.0-trixie` | Debian | Patch version, variante Debian |
| `1-ubi9-minimal` | UBI9 | Major version, variante UBI9 |
| `1.0-ubi9-minimal` | UBI9 | Minor version, variante UBI9 |
| `1.0.0-ubi9-minimal` | UBI9 | Patch version, variante UBI9 |

### Quale tag usare in produzione?

```yaml
# ✅ Consigliato — aggiornamenti automatici di patch e minor
image: tonynarra/pocketbase-docker:1-alpine

# ✅ Stabile — aggiornamenti solo manuali
image: tonynarra/pocketbase-docker:1.0.0-alpine

# ⚠️ Sconsigliato in produzione — sempre l'ultima versione
image: tonynarra/pocketbase-docker:latest
```

---

## 🤖 Build automatica con GitHub Actions

Le immagini vengono buildate e pubblicate automaticamente dalla GitHub Action
`.github/workflows/release.yml` ad ogni nuova release del progetto.

Il workflow:

1. Builda le tre varianti (`alpine`, `trixie`, `ubi`) per `amd64` e `arm64`
2. Pubblica su **Docker Hub** (`tonynarra/pocketbase-docker`)
3. Pubblica su **ghcr.io** (`ghcr.io/narra-antonio/pocketbase-docker`)
4. Applica tutti i tag SemVer automaticamente
5. Aggiorna il `CHANGELOG.md`

> 💡 Per pubblicare una nuova release usa Git Flow:
>
> ```bash
> git flow release start 1.0.0
> # ... aggiorna CHANGELOG.md e versione ...
> git flow release finish 1.0.0
> git push origin main develop --tags
> ```