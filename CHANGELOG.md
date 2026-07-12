# Changelog

Le versioni dell'immagine specchiano la versione di PocketBase inclusa.
Per fix della sola immagine (stessa PocketBase) si usa un suffisso di revisione (es. `v0.39.0-r2`).

## v0.39.0

Prima release pubblica. Include **PocketBase 0.39.0**.

### Fix (bug reali individuati dalla nuova suite di test)

- **Entrypoint eseguibile**: `docker-entrypoint.sh` non era tracciato come eseguibile e i Dockerfile non facevano `chmod +x` → una build da clone pulito (CI) non partiva. Aggiunto `chmod +x` nei tre Dockerfile.
- **Default sender valido**: il default `PB_SENDER_ADDRESS=noreply@localhost` non è un'email valida e faceva crashare il primo avvio out-of-the-box. Cambiato in `noreply@example.com`.
- **Template email per-collection (PB 0.23+)**: impostare un `PB_TPL_*_BODY` faceva crashare la migration iniziale, che scriveva nella posizione legacy `settings.meta.*Template`. I template ora vengono applicati alla collection auth `users` (`verificationTemplate`, `resetPasswordTemplate`, `confirmEmailChangeTemplate`, `otp.emailTemplate`).
- **Lettura template**: il corpo del template veniva salvato come array di byte (`String()` invece del corretto `toString()` del JSVM). Corretto.
- **Reinizializzazione coerente con la doc**: rimuovere `/pb_data/.pb_initialized` ora ri-applica davvero le impostazioni dal `.env` (in precedenza la migration risultava già applicata in `_migrations` e veniva saltata). L'entrypoint copia la migration iniziale con un nome univoco ad ogni first-boot.

### Documentazione

- Corretto `cp env.example` → `cp .env.example` in README e `compose.yaml`.

### Sviluppo

- Aggiunta suite di test automatica (`test/run-tests.sh`) che copre i 4 scenari del piano manuale (porta custom, migration utente + ordine + seed, template email, reinizializzazione). Nessuna dipendenza esterna oltre a `docker` e `curl`.
- Pipeline `release.yml`: gate di test + build multi-arch (amd64/arm64) delle 3 varianti (alpine/trixie/ubi9-minimal) con push automatico su ghcr.io e — se configurati i secret — su Docker Hub.
