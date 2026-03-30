# 🐳 pocketbase-docker

> Immagine Docker non ufficiale per PocketBase — completamente configurabile
> via variabili d'ambiente, zero configurazione manuale.

[![Version](https://img.shields.io/github/v/release/narra-antonio/pocketbase-docker?label=version&style=flat-square)](https://github.com/narra-antonio/pocketbase-docker/releases)
[![PocketBase](https://img.shields.io/badge/PocketBase-v0.36.8-blue?style=flat-square)](https://pocketbase.io)
[![Docker Pulls](https://img.shields.io/docker/pulls/narra-antonio/pocketbase-docker?style=flat-square)](https://hub.docker.com/r/narra-antonio/pocketbase-docker)
[![License](https://img.shields.io/github/license/narra-antonio/pocketbase-docker?style=flat-square)](./LICENSE)
[![Build](https://img.shields.io/github/actions/workflow/status/narra-antonio/pocketbase-docker/release.yml?style=flat-square)](https://github.com/narra-antonio/pocketbase-docker/actions)
[![Alpine](https://img.shields.io/badge/alpine-latest-0D597F?style=flat-square&logo=alpine-linux&logoColor=white)](https://hub.docker.com/r/narra-antonio/pocketbase-docker/tags)
[![Debian](https://img.shields.io/badge/debian-trixie--slim-A81D33?style=flat-square&logo=debian&logoColor=white)](https://hub.docker.com/r/narra-antonio/pocketbase-docker/tags)
[![UBI](https://img.shields.io/badge/ubi-9--minimal-EE0000?style=flat-square&logo=redhat&logoColor=white)](https://hub.docker.com/r/narra-antonio/pocketbase-docker/tags)
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-lightgrey?style=flat-square)](https://hub.docker.com/r/narra-antonio/pocketbase-docker/tags)
[![Changelog](https://img.shields.io/badge/changelog-latest-green?style=flat-square)](./CHANGELOG.md)

---

## ✨ Caratteristiche

- ⚙️ **100% configurabile via env vars** — SMTP, S3, backup, rate limiting e altro
- 🚀 **Zero-touch first start** — superuser e impostazioni creati automaticamente
- 🏗️ **Multi-arch** — `amd64` e `arm64`
- 📦 **Tre varianti** — Alpine (default), Debian Trixie Slim, UBI9 Minimal
- 🔒 **Non-root** — esecuzione come utente non privilegiato
- 🔄 **Aggiornamenti automatici** — nuova immagine ad ogni release di PocketBase

---

## 🚀 Quick Start

### Con Docker Compose (consigliato)

```bash
# 1. Copia il file di esempio
cp env.example .env

# 2. Modifica almeno queste variabili
# PB_ADMIN_EMAIL, PB_ADMIN_PASSWORD, PB_APP_NAME, PB_APP_URL

# 3. Pull dell'immagine
docker compose pull

# 4. Avvia
docker compose up -d
```

`compose.yaml` minimale:

```yaml
services:
  pocketbase:
    image: narra-antonio/pocketbase-docker:latest
    container_name: pocketbase
    restart: unless-stopped
    ports:
      - '${PB_PORT:-8090}:${PB_PORT:-8090}'
    volumes:
      - ./pb_data:/pb_data
    env_file:
      - .env
```

### Con Docker Run

```bash
# 1. Pull dell'immagine
docker pull narra-antonio/pocketbase-docker:latest

# 2. Avvia
docker run -d \
  --name pocketbase \
  --restart unless-stopped \
  -p 8090:8090 \
  -v $(pwd)/pb_data:/pb_data \
  -e PB_ADMIN_EMAIL=admin@example.com \
  -e PB_ADMIN_PASSWORD=una-password-sicura \
  -e PB_APP_NAME="My App" \
  -e PB_APP_URL=http://localhost:8090 \
  narra-antonio/pocketbase-docker:latest
```

Al primo avvio PocketBase è disponibile su:

- **API:** `http://localhost:8090/api/`
- **Dashboard:** `http://localhost:8090/_/`

---

## 📦 Varianti disponibili

| Tag                                    | Base               | Arch         |
| -------------------------------------- | ------------------ | ------------ |
| `latest`, `1-alpine`, `1.0.0-alpine`   | Alpine             | amd64, arm64 |
| `1-trixie`, `1.0.0-trixie`             | Debian Trixie Slim | amd64, arm64 |
| `1-ubi9-minimal`, `1.0.0-ubi9-minimal` | UBI9 Minimal       | amd64, arm64 |

---

## 📚 Documentazione

Per la configurazione completa, le variabili d'ambiente, la strategia di
tagging e altro, consulta la documentazione:

- [🚀 Getting Started](./docs/getting-started.md)
- [⚙️ Configurazione](./docs/configuration.md)
- [🔧 Variabili d'ambiente](./docs/envs.md)
- [🏗️ Build & Tagging](./docs/building.md)
- [📨 Template Email](./docs/templates.md)
- [🤝 Contributing](./docs/contributing.md)
- [🐛 Segnalazioni](./docs/issues.md)

---

## 📋 Changelog

Consulta il [CHANGELOG.md](./CHANGELOG.md) per la lista completa delle modifiche
per versione.

---

## ☕ Support

Se questo progetto ti è utile, considera di supportarne lo sviluppo:

<a href="https://www.buymeacoffee.com/narra.antonio"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=narra.antonio&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" /></a>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/G2G41WWYAM)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=flat-square&logo=github-sponsors&logoColor=white)](https://github.com/sponsors/narra-antonio)

---

## 🤝 Contributors

<a href="https://github.com/narra-antonio/pocketbase-docker/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=narra-antonio/pocketbase-docker" />
</a>

---

## 💼 Used by

<!-- USED-BY-LIST:START -->
<!-- USED-BY-LIST:END -->

---

## 🏆 Sponsors

<a href="https://github.com/sponsors/narra-antonio">
  <img src="https://raw.githubusercontent.com/narra-antonio/pocketbase-docker/main/sponsors.svg" />
</a>

---

## 🤜🤛 Collaborations

<!-- COLLABORATIONS-LIST:START -->
<!-- COLLABORATIONS-LIST:END -->

---

## 📄 Licenza

MIT © [Antonio Narra](https://antonionarra.io)

> Questo progetto non è affiliato con il team ufficiale di PocketBase.
> PocketBase è un progetto open source di [Gani Georgiev](https://github.com/ganigeorgiev).
