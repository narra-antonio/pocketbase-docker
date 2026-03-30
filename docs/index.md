# 🐳 PocketBase Docker — Documentazione

## Prefazione

PocketBase è un backend open source straordinariamente potente: un singolo eseguibile che racchiude database SQLite con subscription realtime, autenticazione, storage e una dashboard di amministrazione. Nonostante la sua popolarità, **non esiste un'immagine Docker ufficiale**.

Le immagini non ufficiali esistenti coprono solo i casi d'uso più basilari: avviano PocketBase, espongono la porta e fine. Chi vuole configurare SMTP, S3, rate limiting, backup automatici o creare il superuser al primo avvio deve farlo **a mano**, ogni volta, su ogni ambiente.

Questo progetto risolve il problema alla radice.

**`narra-antonio/pocketbase-docker`** è un'immagine Docker non ufficiale, completamente configurabile tramite variabili d'ambiente. Al primo avvio, tutte le impostazioni vengono applicate automaticamente — SMTP, S3, backup, rate limiting, superuser — senza toccare nulla manualmente. Basta un file `.env` e il container fa il resto.

### ✨ Caratteristiche principali

- ⚙️ **Configurazione 100% via env vars** — nessun file da modificare, nessuna configurazione manuale
- 🚀 **Zero-touch first start** — il superuser e tutte le impostazioni vengono create automaticamente al primo avvio
- 🏗️ **Multi-arch** — supporto nativo per `amd64` e `arm64`
- 📦 **Tre varianti** — Alpine (default), Debian Trixie Slim, UBI9 Minimal (Red Hat / OpenShift)
- 🔒 **Sicurezza** — esecuzione come utente non-root, encryption key configurabile
- 🔄 **Aggiornamenti automatici** — la GitHub Action aggiorna l'immagine ad ogni nuova release di PocketBase

### 📋 Requisiti minimi

| Componente     | Versione minima   |
| -------------- | ----------------- |
| Docker Engine  | 20.10+            |
| Docker Compose | V2 (plugin)       |
| Architettura   | `amd64` o `arm64` |

> 💡 Docker Desktop 3.4+ include già Compose V2. Se hai un'installazione aggiornata negli ultimi anni sei coperto.

---

## 📚 Indice

1. [🚀 Getting Started](./getting-started.md) — Come usare l'immagine in pochi minuti
2. [⚙️ Configurazione](./configuration.md) — Architettura e decisioni tecniche
3. [🔧 Variabili d'ambiente](./envs.md) — Elenco completo delle variabili configurabili con valori di default
4. [🏗️ Build & Tagging](./building.md) — Come buildare localmente e strategia di versionamento
5. [🤝 Contributing](./contributing.md) — Come contribuire al progetto
6. [🐛 Segnalazioni](./issues.md) — Come aprire una segnalazione o richiedere una funzionalità
