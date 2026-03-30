# 🐛 Segnalazioni e Richieste

Questa guida spiega come aprire una segnalazione di bug o una richiesta di
nuova funzionalità in modo efficace.

---

## 🔍 Prima di aprire una issue

1. **Cerca tra le issue esistenti** — la tua segnalazione potrebbe essere già
   presente o già risolta
   → [Issue aperte](https://github.com/narra-antonio/pocketbase-docker/issues)

2. **Controlla il CHANGELOG** — l'issue potrebbe essere già stata risolta in
   una versione più recente
   → [CHANGELOG.md](../CHANGELOG.md)

3. **Verifica la documentazione** — la risposta potrebbe essere già nella docs
   → [Variabili d'ambiente](./envs.md) · [Getting Started](./getting-started.md)

---

## 🐛 Segnalare un bug

Quando apri una issue per un bug, includi sempre:

### Informazioni sull'ambiente

```text
- Versione immagine: (es. 1.0.0-alpine)
- Variante: (alpine / trixie / ubi9-minimal)
- Sistema operativo host: (es. Ubuntu 24.04, macOS 15)
- Architettura: (amd64 / arm64)
- Versione Docker: (docker --version)
- Versione Docker Compose: (docker compose version)
- Docker info: (docker info)
```

> 💡 `docker info` è particolarmente utile per identificare moduli non caricati,
> driver di storage, runtime e configurazioni del daemon che potrebbero influenzare
> il comportamento del container.

### Descrizione del problema

- **Cosa ti aspettavi** che succedesse
- **Cosa è successo** invece
- **Come riprodurre** il problema (passi precisi)

### Log del container

Allega sempre i log del container — sono fondamentali per la diagnosi:

```bash
# Log completi
docker logs pocketbase

# Ultimi 100 righe
docker logs pocketbase --tail 100

# Log in tempo reale
docker logs pocketbase -f
```

### Variabili d'ambiente

Includi le variabili d'ambiente usate — **rimuovi le informazioni sensibili**
(password, chiavi API, encryption key) prima di condividerle:

```bash
# Esempio di .env da allegare (con dati sensibili rimossi)
PB_APP_NAME=My App
PB_APP_URL=https://example.com
PB_SMTP_ENABLED=true
PB_SMTP_HOST=smtp.example.com
PB_SMTP_PORT=587
PB_SMTP_PASSWORD=***RIMOSSO***
```

---

## ✨ Richiedere una nuova funzionalità

Per richiedere una nuova funzionalità o un miglioramento:

1. **Descrivi il problema** che vuoi risolvere, non solo la soluzione
2. **Spiega il caso d'uso** — perché questa funzionalità sarebbe utile
3. **Proponi una soluzione** se ne hai una in mente
4. **Valuta alternative** che hai già considerato

---

## ❓ Domande e supporto

Per domande generali sull'uso dell'immagine che non sono bug o richieste di
funzionalità, apri una
[GitHub Discussion](https://github.com/narra-antonio/pocketbase-docker/discussions)
invece di una issue — manteniamo le issue per bug e feature request concrete.

---

## ⏱️ Tempi di risposta

Questo è un progetto open source mantenuto nel tempo libero. I tempi di risposta
possono variare. La community è incoraggiata a partecipare alle discussioni e
ad aiutarsi reciprocamente.
