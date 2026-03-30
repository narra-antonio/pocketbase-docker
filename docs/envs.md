# 🔧 Variabili d'ambiente

Elenco completo delle variabili d'ambiente supportate dall'immagine, con i valori
di default e una descrizione per ciascuna.

> 💡 Copia il file `env.example` nella root del progetto e rinominalo in `.env`
> per iniziare la configurazione.

---

## 🌐 Rete

| Variabile | Default   | Descrizione                                        |
| --------- | --------- | -------------------------------------------------- |
| `PB_HOST` | `0.0.0.0` | Indirizzo IP su cui PocketBase si mette in ascolto |
| `PB_PORT` | `8090`    | Porta su cui PocketBase si mette in ascolto        |

---

## 🏷️ Meta

| Variabile           | Default                 | Descrizione                                      |
| ------------------- | ----------------------- | ------------------------------------------------ |
| `PB_APP_NAME`       | `My PocketBase App`     | Nome dell'applicazione, mostrato nella dashboard |
| `PB_APP_URL`        | `http://localhost:8090` | URL pubblico dell'applicazione                   |
| `PB_SENDER_NAME`    | `Support`               | Nome del mittente per le email di sistema        |
| `PB_SENDER_ADDRESS` | `noreply@localhost`     | Indirizzo email del mittente                     |
| `PB_HIDE_CONTROLS`  | `false`                 | Nasconde i controlli di upgrade nella dashboard  |

---

## 🔐 Sicurezza

| Variabile           | Default          | Descrizione                                                                                      |
| ------------------- | ---------------- | ------------------------------------------------------------------------------------------------ |
| `PB_ADMIN_EMAIL`    | _(obbligatorio)_ | Email del superuser, creato automaticamente al primo avvio                                       |
| `PB_ADMIN_PASSWORD` | _(obbligatorio)_ | Password del superuser                                                                           |
| `PB_ENCRYPTION_KEY` | _(vuoto)_        | Chiave di 32 caratteri per cifrare le impostazioni nel DB. Genera con: `openssl rand -base64 32` |
| `PB_DEBUG`          | `false`          | Abilita la modalità debug (`--dev`). **Non usare in produzione**                                 |

---

## 📧 SMTP

| Variabile             | Default   | Descrizione                                       |
| --------------------- | --------- | ------------------------------------------------- |
| `PB_SMTP_ENABLED`     | `false`   | Abilita l'invio email tramite SMTP                |
| `PB_SMTP_HOST`        | _(vuoto)_ | Host del server SMTP                              |
| `PB_SMTP_PORT`        | `587`     | Porta del server SMTP                             |
| `PB_SMTP_USERNAME`    | _(vuoto)_ | Username per l'autenticazione SMTP                |
| `PB_SMTP_PASSWORD`    | _(vuoto)_ | Password per l'autenticazione SMTP                |
| `PB_SMTP_AUTH_METHOD` | `PLAIN`   | Metodo di autenticazione SMTP (`PLAIN` o `LOGIN`) |
| `PB_SMTP_TLS`         | `true`    | Abilita TLS per la connessione SMTP               |
| `PB_SMTP_LOCAL_NAME`  | _(vuoto)_ | Hostname usato nel comando HELO/EHLO              |

---

## 🗄️ S3 — Storage file

| Variabile                | Default   | Descrizione                                 |
| ------------------------ | --------- | ------------------------------------------- |
| `PB_S3_ENABLED`          | `false`   | Abilita lo storage S3 per i file caricati   |
| `PB_S3_BUCKET`           | _(vuoto)_ | Nome del bucket S3                          |
| `PB_S3_REGION`           | _(vuoto)_ | Regione del bucket S3                       |
| `PB_S3_ENDPOINT`         | _(vuoto)_ | Endpoint custom (es. MinIO, Cloudflare R2)  |
| `PB_S3_ACCESS_KEY`       | _(vuoto)_ | Access key S3                               |
| `PB_S3_SECRET`           | _(vuoto)_ | Secret key S3                               |
| `PB_S3_FORCE_PATH_STYLE` | `false`   | Forza il path style per provider come MinIO |

---

## 💾 Backup

| Variabile                        | Default     | Descrizione                                   |
| -------------------------------- | ----------- | --------------------------------------------- |
| `PB_BACKUPS_CRON`                | `0 0 * * *` | Schedule dei backup automatici (formato cron) |
| `PB_BACKUPS_CRON_MAX_KEEP`       | `3`         | Numero massimo di backup da conservare        |
| `PB_BACKUPS_S3_ENABLED`          | `false`     | Abilita lo storage S3 per i backup            |
| `PB_BACKUPS_S3_BUCKET`           | _(vuoto)_   | Nome del bucket S3 per i backup               |
| `PB_BACKUPS_S3_REGION`           | _(vuoto)_   | Regione del bucket S3 per i backup            |
| `PB_BACKUPS_S3_ENDPOINT`         | _(vuoto)_   | Endpoint custom S3 per i backup               |
| `PB_BACKUPS_S3_ACCESS_KEY`       | _(vuoto)_   | Access key S3 per i backup                    |
| `PB_BACKUPS_S3_SECRET`           | _(vuoto)_   | Secret key S3 per i backup                    |
| `PB_BACKUPS_S3_FORCE_PATH_STYLE` | `false`     | Forza il path style per i backup S3           |

---

## 📋 Log

| Variabile             | Default | Descrizione                                              |
| --------------------- | ------- | -------------------------------------------------------- |
| `PB_LOGS_MAX_DAYS`    | `7`     | Numero di giorni di log da conservare (0 = disabilitato) |
| `PB_LOGS_MIN_LEVEL`   | `0`     | Livello minimo di log (0=DEBUG, 1=INFO, 2=WARN, 3=ERROR) |
| `PB_LOGS_LOG_IP`      | `true`  | Logga l'indirizzo IP del client                          |
| `PB_LOGS_LOG_AUTH_ID` | `true`  | Logga l'ID dell'utente autenticato                       |

---

## 🚦 Rate Limiting

| Variabile                | Default   | Descrizione                                  |
| ------------------------ | --------- | -------------------------------------------- |
| `PB_RATE_LIMITS_ENABLED` | `false`   | Abilita il rate limiting                     |
| `PB_RATE_LIMITS_RULES`   | _(vuoto)_ | Regole di rate limiting (vedi formato sotto) |

### Formato delle regole

Le regole sono separate da `;` e ogni regola ha il formato `label|audience|duration|maxRequests`:

```bash
# Esempi
PB_RATE_LIMITS_RULES=*:auth||3|2;*:create||5|20;/api/batch||1|3
```

| Campo         | Descrizione                                |
| ------------- | ------------------------------------------ |
| `label`       | Identificatore della regola (es. `*:auth`) |
| `audience`    | Audience target (lascia vuoto per tutti)   |
| `duration`    | Finestra temporale in secondi              |
| `maxRequests` | Numero massimo di richieste nella finestra |

---

## 🔀 Trusted Proxy

| Variabile                          | Default   | Descrizione                                                                |
| ---------------------------------- | --------- | -------------------------------------------------------------------------- |
| `PB_TRUSTED_PROXY_HEADERS`         | _(vuoto)_ | Header proxy fidati, separati da virgola (es. `X-Real-IP,X-Forwarded-For`) |
| `PB_TRUSTED_PROXY_USE_LEFTMOST_IP` | `false`   | Usa l'IP più a sinistra nell'header proxy                                  |

---

## 📦 Batch Requests

| Variabile               | Default | Descrizione                              |
| ----------------------- | ------- | ---------------------------------------- |
| `PB_BATCH_ENABLED`      | `true`  | Abilita le richieste batch               |
| `PB_BATCH_MAX_REQUESTS` | `100`   | Numero massimo di richieste per batch    |
| `PB_BATCH_TIMEOUT`      | `120`   | Timeout delle richieste batch in secondi |

---

## 📨 Template Email

I template email possono essere personalizzati fornendo file HTML tramite il
volume `/pb_templates`. Se non vengono forniti, PocketBase usa i template di default.

Per creare template personalizzati consulta la guida [Template Email](./templates.md).

| Variabile                      | Default        | Descrizione                                                                        |
| ------------------------------ | -------------- | ---------------------------------------------------------------------------------- |
| `PB_TPL_VERIFICATION_SUBJECT`  | _(default PB)_ | Oggetto dell'email di verifica account                                             |
| `PB_TPL_VERIFICATION_BODY`     | _(vuoto)_      | Path al file HTML del template di verifica (es. `/pb_templates/verification.html`) |
| `PB_TPL_RESET_PWD_SUBJECT`     | _(default PB)_ | Oggetto dell'email di reset password                                               |
| `PB_TPL_RESET_PWD_BODY`        | _(vuoto)_      | Path al file HTML del template di reset password                                   |
| `PB_TPL_CONFIRM_EMAIL_SUBJECT` | _(default PB)_ | Oggetto dell'email di conferma cambio email                                        |
| `PB_TPL_CONFIRM_EMAIL_BODY`    | _(vuoto)_      | Path al file HTML del template di conferma cambio email                            |
| `PB_TPL_OTP_SUBJECT`           | _(default PB)_ | Oggetto dell'email OTP                                                             |
| `PB_TPL_OTP_BODY`              | _(vuoto)_      | Path al file HTML del template OTP                                                 |
