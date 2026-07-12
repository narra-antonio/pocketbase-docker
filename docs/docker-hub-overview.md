# PocketBase Docker

**Unofficial, fully environment-configurable Docker image for [PocketBase](https://pocketbase.io) — zero-touch first start, multi-arch, three base variants.**

## Quick reference

- **Maintained by:** [Antonio Narra](https://github.com/narra-antonio)
- **Where to get help:** [GitHub Issues](https://github.com/narra-antonio/pocketbase-docker/issues)
- **Where to file issues:** [github.com/narra-antonio/pocketbase-docker/issues](https://github.com/narra-antonio/pocketbase-docker/issues)
- **Supported architectures:** `amd64`, `arm64`
- **Source of this description:** [`docs/docker-hub-overview.md`](https://github.com/narra-antonio/pocketbase-docker/blob/main/docs/docker-hub-overview.md) ([history](https://github.com/narra-antonio/pocketbase-docker/commits/main/docs/docker-hub-overview.md))
- **Also available on:** [GitHub Container Registry](https://github.com/narra-antonio/pocketbase-docker/pkgs/container/pocketbase-docker)

## Supported tags and respective `Dockerfile` links

- `0.39.0`, `0.39.0-alpine`, `alpine`, `latest` → [`Dockerfile.alpine`](https://github.com/narra-antonio/pocketbase-docker/blob/main/Dockerfile.alpine)
- `0.39.0-trixie`, `trixie` → [`Dockerfile.debian`](https://github.com/narra-antonio/pocketbase-docker/blob/main/Dockerfile.debian)
- `0.39.0-ubi9-minimal`, `ubi9-minimal` → [`Dockerfile.ubi`](https://github.com/narra-antonio/pocketbase-docker/blob/main/Dockerfile.ubi)

> Image versions mirror the bundled PocketBase version — tag `0.39.0` ships PocketBase **0.39.0**. Image-only fixes use a revision suffix (e.g. `0.39.0-r2`).

## What is this image?

[PocketBase](https://pocketbase.io) is an open-source backend in a single file — SQLite database, authentication, file storage, an admin dashboard and a realtime REST-ish API. It ships as a standalone binary and, by design, has **no official Docker image**.

**pocketbase-docker** wraps that binary in a production-minded image that is **100% configurable via environment variables**:

- ⚙️ **Configure everything via env vars** — SMTP, S3 storage, backups (+ S3), rate limiting, trusted-proxy headers, batch API, email templates and logs.
- 🚀 **Zero-touch first start** — superuser and application settings are created automatically from your environment on first boot.
- 🏗️ **Multi-arch** — `linux/amd64` and `linux/arm64`.
- 📦 **Three variants** — Alpine (default), Debian Trixie slim, UBI9 minimal.
- 🔒 **Non-root** — runs as an unprivileged user.
- ✅ **Tested & CI-built** — every release is gated by an automated test suite.

## How to use this image

### docker run

```console
$ docker run -d \
    --name pocketbase \
    --restart unless-stopped \
    -p 8090:8090 \
    -v $(pwd)/pb_data:/pb_data \
    -e PB_ADMIN_EMAIL=admin@example.com \
    -e PB_ADMIN_PASSWORD=a-strong-password \
    -e PB_APP_NAME="My App" \
    -e PB_APP_URL=http://localhost:8090 \
    tonynarra/pocketbase-docker:latest
```

Then open the admin dashboard at `http://localhost:8090/_/`.

### docker compose

```yaml
services:
  pocketbase:
    image: tonynarra/pocketbase-docker:latest
    container_name: pocketbase
    restart: unless-stopped
    ports:
      - "8090:8090"
    volumes:
      - ./pb_data:/pb_data
    env_file:
      - .env
```

### Pulling from GitHub Container Registry

```console
$ docker pull ghcr.io/narra-antonio/pocketbase-docker:latest
```

### Configuration

Every setting is driven by `PB_*` environment variables. Full reference:

- [Environment variables](https://github.com/narra-antonio/pocketbase-docker/blob/main/docs/envs.md)
- [Getting started](https://github.com/narra-antonio/pocketbase-docker/blob/main/docs/getting-started.md)
- [Configuration & first-boot flow](https://github.com/narra-antonio/pocketbase-docker/blob/main/docs/configuration.md)
- [Custom email templates](https://github.com/narra-antonio/pocketbase-docker/blob/main/docs/templates.md)

### Volumes

| Path | Purpose |
| --- | --- |
| `/pb_data` | **Required** — database, file storage and backups (persist this) |
| `/pb_migrations` | Optional — your JS migrations |
| `/pb_hooks` | Optional — your JS hooks |
| `/pb_public` | Optional — static files served by PocketBase |
| `/pb_templates` | Optional — custom email templates |

### First boot & re-initialization

On first start the entrypoint applies your settings, creates the superuser, then writes a `/pb_data/.pb_initialized` marker. Subsequent starts boot PocketBase directly, untouched. Remove that marker to intentionally re-apply the settings from your current environment.

## License

[MIT](https://github.com/narra-antonio/pocketbase-docker/blob/main/LICENSE). This is an unofficial image and is **not affiliated with or endorsed by** the PocketBase project.
