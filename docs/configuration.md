# ⚙️ Configurazione — Architettura e Decisioni Tecniche

Questo documento descrive le scelte architetturali alla base di
`narra-antonio/pocketbase-docker` e le motivazioni che le hanno guidate.

---

## 🏗️ Struttura dell'immagine

L'immagine è costruita con un **multi-stage build** per minimizzare la dimensione
finale:

- **Stage 1 (downloader)** — scarica e decomprime il binario PocketBase direttamente
  da GitHub Releases per l'architettura target (`amd64` o `arm64`)
- **Stage 2 (runtime)** — copia solo il binario e i file necessari nell'immagine
  finale, senza strumenti di build

Il binario PocketBase è un eseguibile Go staticamente linkato: non ha dipendenze
esterne e gira su qualsiasi base Linux, il che rende possibile il supporto a tre
varianti distinte.

---

## 📦 Tre varianti — perché

| Variante               | Base image            | Caso d'uso                                                                         |
| ---------------------- | --------------------- | ---------------------------------------------------------------------------------- |
| **Alpine**             | `alpine:latest`       | Default — minimale, ~15MB, ideale per la maggior parte dei deploy                  |
| **Debian Trixie Slim** | `debian:trixie-slim`  | Massima compatibilità — utile quando si montano script o tool che richiedono glibc |
| **UBI9 Minimal**       | `redhat/ubi9-minimal` | Ambienti enterprise Red Hat / OpenShift — certificata e supportata da Red Hat      |

Ogni variante usa il proprio package manager per installare le dipendenze runtime
minime (`wget` per l'health check, `ca-certificates`, `tzdata`):

- Alpine → `apk add`
- Debian → `apt-get install`
- UBI9 → `microdnf install`

---

## 🔄 Il problema della configurazione via env vars

PocketBase non legge variabili d'ambiente per la propria configurazione — tutte
le impostazioni (SMTP, S3, backup, meta) vengono salvate nel database SQLite e
gestite dalla dashboard o dall'API.

La soluzione adottata è il sistema di **migration JavaScript** integrato in
PocketBase: al primo avvio, uno script JS legge le variabili d'ambiente e le
applica alle impostazioni tramite l'API interna `app.settings()`.

---

## 🔐 Meccanismo del primo avvio

Il cuore dell'immagine è la logica di inizializzazione nell'entrypoint, progettata
per essere **sicura, idempotente e trasparente** per l'utente.

### Il file `.pb_initialized`

Al termine del primo avvio, l'entrypoint crea il file `/pb_data/.pb_initialized`.
Questo file è il segnalibro che distingue il primo avvio dai successivi.

- **Presente** → PocketBase si avvia normalmente, nessuna migration aggiuntiva
- **Assente** → l'entrypoint esegue la procedura di inizializzazione completa

> ⚠️ Non rimuovere questo file se non vuoi reinizializzare le impostazioni.
> Consultare la sezione dedicata in [Getting Started](./getting-started.md).

### Flusso completo del primo avvio

```arduino
entrypoint
    │
    ├─ .pb_initialized esiste?
    │       │
    │      NO
    │       │
    │       ├─ Rinomina le migration utente (aggiunge prefisso timestamp alto)
    │       │   → garantisce che la nostra migration giri per prima
    │       │
    │       ├─ Copia la migration iniziale in /pb_migrations
    │       │
    │       ├─ Avvia PocketBase
    │       │
    │       ├─ Attende /api/health → 200 OK
    │       │
    │       ├─ Ripristina i nomi originali delle migration utente
    │       │
    │       ├─ Rimuove la migration iniziale da /pb_migrations
    │       │
    │       └─ Crea /pb_data/.pb_initialized
    │
    └─ SÌ → avvia PocketBase direttamente
```

### Perché rinominare le migration dell'utente?

PocketBase esegue le migration in ordine alfabetico/numerico. La nostra migration
iniziale ha un timestamp basso (`1000000000_initial_settings.js`) per garantire
di girare per prima.

Tuttavia, un utente potrebbe avere migration con nomi come `0_setup.js` o
`1_collections.js` che verrebbero eseguite **prima** della nostra, causando
potenziali conflitti.

La soluzione: al primo avvio l'entrypoint rinomina temporaneamente le migration
dell'utente aggiungendo un prefisso timestamp molto alto (es. `99999999999_`),
garantendo che la nostra giri sempre per prima. Al termine, i nomi originali
vengono ripristinati e l'utente non si accorge di nulla.

---

## 🔒 Sicurezza

### Utente non-root

Il container esegue PocketBase come utente non-root (`pocketbase:pocketbase`,
UID/GID 1000). Questo riduce la superficie di attacco in caso di vulnerabilità
nell'applicazione.

### Encryption key

Le impostazioni di PocketBase (incluse credenziali SMTP e S3) vengono salvate
nel database SQLite come JSON in chiaro per default. Impostando `PB_ENCRYPTION_KEY`
con una chiave di 32 caratteri, le impostazioni vengono cifrate prima di essere
salvate.

```bash
# Genera una chiave sicura
openssl rand -base64 32
```

> ⚠️ Conserva la chiave in un posto sicuro. Se perdi la chiave, le impostazioni
> non saranno più decifrabili e dovrai riconfigurare tutto da zero.

---

## 📁 Volumi e persistenza

| Path             | Tipo             | Descrizione                                                             |
| ---------------- | ---------------- | ----------------------------------------------------------------------- |
| `/pb_data`       | **Obbligatorio** | Dati persistenti (DB, storage file, backup, cache Let's Encrypt)        |
| `/pb_migrations` | Opzionale        | Migration JavaScript personalizzate                                     |
| `/pb_hooks`      | Opzionale        | Hook JavaScript personalizzati                                          |
| `/pb_public`     | Opzionale        | File statici serviti da PocketBase (html, css, immagini)                |
| `/pb_templates`  | Opzionale        | Template HTML personalizzati per le email (aggiunto da questa immagine) |

> 💡 Montare `/pb_data` è sufficiente per la persistenza del database e dei file.
> Monta `/pb_migrations` e `/pb_hooks` solo se vuoi gestirli dall'esterno del container.
> 💡 Mappa sempre `/pb_data` su un volume o una cartella dell'host per garantire
> la persistenza dei dati tra i riavvii del container.

---

## 🏷️ Strategia di versionamento

I tag dell'immagine seguono il versionamento **SemVer** del progetto, non quello
di PocketBase. La versione di PocketBase inclusa nell'immagine è specificata come
`ARG POCKETBASE_VERSION` nel Dockerfile e documentata nel changelog.

Per la strategia completa di tagging consulta [Build & Tagging](./building.md).
