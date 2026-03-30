# 🚀 Getting Started

Questa guida ti accompagna nei primi passi con `tonynarra/pocketbase-docker`,
dalla scelta della variante alla prima esecuzione.

---

## 1️⃣ Scegli la variante

L'immagine è disponibile in tre varianti. Scegli quella più adatta al tuo ambiente:

| Variante | Tag | Quando usarla |
|---|---|---|
| **Alpine** | `latest`, `1-alpine` | Uso generale, immagine più leggera |
| **Debian Trixie Slim** | `1-trixie` | Massima compatibilità con librerie di sistema |
| **UBI9 Minimal** | `1-ubi9-minimal` | Ambienti enterprise Red Hat / OpenShift |

> 💡 Se non sai quale scegliere, usa `latest` — è la variante Alpine ed è quella
> consigliata per la maggior parte dei casi d'uso.

---

## 2️⃣ Configura le variabili d'ambiente

Copia il file di esempio e personalizzalo:

```bash
cp env.example .env
```

Modifica almeno queste variabili prima di avviare il container:

```bash
# Rete (default: 0.0.0.0:8090)
PB_HOST=0.0.0.0
PB_PORT=8090

# Impostazioni base
PB_APP_NAME=My App
PB_APP_URL=https://mio-dominio.com

# Superuser (creato automaticamente al primo avvio)
PB_ADMIN_EMAIL=admin@mio-dominio.com
PB_ADMIN_PASSWORD=una-password-sicura

# Chiave di cifratura (32 caratteri — genera con: openssl rand -base64 32)
PB_ENCRYPTION_KEY=
```

> ⚠️ Non committare mai il file `.env` nel repository. È già incluso nel `.gitignore`.

Per l'elenco completo delle variabili disponibili, consulta la sezione
[Variabili d'ambiente](./envs.md).

---

## 3️⃣ Avvio

### Con Docker Compose (consigliato)

Crea un file `compose.yaml` nella tua cartella di progetto:

```yaml
services:
  pocketbase:
    image: tonynarra/pocketbase-docker:latest
    container_name: pocketbase
    restart: unless-stopped
    ports:
      - "${PB_PORT:-8090}:${PB_PORT:-8090}"
    volumes:
      - ./pb_data:/pb_data
    env_file:
      - .env
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:${PB_PORT:-8090}/api/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

Avvia il container:

```bash
docker compose up -d
```

**Esempio con porta custom:**

```bash
# Nel tuo .env
PB_HOST=0.0.0.0
PB_PORT=3000
```

```yaml
# Nel tuo compose.yaml
ports:
  - "3000:3000"
```

### Con Docker Run

```bash
docker run -d \
  --name pocketbase \
  --restart unless-stopped \
  -p 8090:8090 \
  -v $(pwd)/pb_data:/pb_data \
  --env-file .env \
  tonynarra/pocketbase-docker:latest
```

**Esempio con porta e host custom:**

```bash
docker run -d \
  --name pocketbase \
  --restart unless-stopped \
  -p 3000:3000 \
  -v $(pwd)/pb_data:/pb_data \
  -e PB_HOST=0.0.0.0 \
  -e PB_PORT=3000 \
  --env-file .env \
  tonynarra/pocketbase-docker:latest
```

---

## 4️⃣ Verifica

Una volta avviato, verifica che tutto funzioni correttamente:

```bash
# Controlla i log
docker logs pocketbase

# Verifica lo stato dell'health check
docker inspect --format='{{.State.Health.Status}}' pocketbase
```

Se tutto è andato a buon fine, PocketBase è raggiungibile a:

- **API:** `http://localhost:8090/api/`
- **Dashboard:** `http://localhost:8090/_/`

> 🎉 Al primo avvio il superuser viene creato automaticamente con le credenziali
> definite in `PB_ADMIN_EMAIL` e `PB_ADMIN_PASSWORD`. Non è necessario nessun
> intervento manuale.

---

## 5️⃣ Dietro le quinte — cosa succede al primo avvio

Per chi vuole capire cosa fa l'immagine al primo avvio:

1. L'entrypoint controlla se è il primo avvio verificando la presenza di `/pb_data/.pb_initialized`
2. Se è il primo avvio, sposta temporaneamente le migration dell'utente per garantire che la nostra venga eseguita per prima
3. Avvia PocketBase con la migration iniziale che configura tutte le impostazioni tramite le env vars
4. Attende che l'health check risponda con `200 OK`
5. Ripristina le migration dell'utente al loro nome originale
6. Rimuove la migration iniziale da `pb_migrations`
7. Crea il file `/pb_data/.pb_initialized` per segnalare che il primo avvio è completato

Dai avvii successivi, l'entrypoint rileva il file `.pb_initialized` e avvia
PocketBase direttamente, senza toccare nulla.

> ⚠️ **Non rimuovere il file `/pb_data/.pb_initialized`** — è il segnalibro che
> indica all'immagine che il primo avvio è già stato completato. Se viene rimosso,
> al riavvio successivo l'immagine eseguirà nuovamente la migration iniziale,
> sovrascrivendo tutte le impostazioni con i valori delle variabili d'ambiente
> attuali.
>
> Rimuovilo **solo se vuoi intenzionalmente reinizializzare le impostazioni**
> di PocketBase con i valori correnti del file `.env`.

---

## Prossimi passi

- ⚙️ [Configurazione avanzata](./configuration.md)
- 🔧 [Tutte le variabili d'ambiente](./envs.md)
- 🏗️ [Build locale e tagging](./building.md)