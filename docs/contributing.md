# 🤝 Contributing

Grazie per l'interesse nel contribuire a `narra-antonio/pocketbase-docker`!
Ogni contributo è benvenuto — che si tratti di una segnalazione, una correzione
o una nuova funzionalità.

---

## 📋 Prima di iniziare

- Controlla le [issue aperte](https://github.com/narra-antonio/pocketbase-docker/issues)
  per evitare duplicati
- Per modifiche significative apri prima una issue per discutere l'approccio
- Leggi la [documentazione di configurazione](./configuration.md) per capire
  l'architettura del progetto

---

## 🔄 Workflow

Il progetto usa **Git Flow**. Tutti i contributi devono seguire questo workflow:

```bash
# 1. Forka il repository e clonalo
git clone git@github.com:<tuo-username>/pocketbase-docker.git
cd pocketbase-docker

# 2. Inizializza Git Flow
git flow init

# 3. Crea un branch feature
git flow feature start nome-della-feature

# 4. Fai le tue modifiche e committa
git add .
git commit -m "feat: descrizione della modifica"

# 5. Pusha il branch
git push origin feature/nome-della-feature

# 6. Apri una Pull Request verso develop
```

---

## 📝 Convenzioni di commit

Il progetto segue la convenzione **Conventional Commits**:

| Prefisso    | Quando usarlo                            |
| ----------- | ---------------------------------------- |
| `feat:`     | Nuova funzionalità                       |
| `fix:`      | Correzione di un bug                     |
| `docs:`     | Modifiche alla documentazione            |
| `chore:`    | Manutenzione, dipendenze, configurazione |
| `refactor:` | Refactoring senza cambiamenti funzionali |
| `test:`     | Aggiunta o modifica di test              |

Esempi:

```text
feat: aggiunge supporto per variabile PB_TPL_OTP_BODY
fix: corregge il prefisso timestamp nelle migration utente
docs: aggiorna envs.md con le nuove variabili S3
chore: aggiorna PocketBase a v0.39.0
```

---

## 🧪 Test prima di aprire una PR

Prima di aprire una Pull Request assicurati di aver testato le modifiche:

```bash
# Build dell'immagine modificata
docker build -f Dockerfile.alpine -t pocketbase-docker:test .

# Test rapido
docker run --rm \
  -p 8090:8090 \
  -e PB_ADMIN_EMAIL=admin@test.local \
  -e PB_ADMIN_PASSWORD=Test1234! \
  pocketbase-docker:test

# Verifica health
curl http://localhost:8090/api/health
```

---

## 📐 Standard del codice

- **Shell scripts** — conformi a ShellCheck, formattati con shell-format
- **Dockerfile** — un'istruzione per riga, layer ottimizzati
- **Markdown** — conformi a MDLint
- **YAML** — indentazione 2 spazi, nessun campo `version:`

---

## 🙏 Codice di condotta

Questo progetto adotta un ambiente rispettoso e inclusivo. Si prega di:

- Usare un linguaggio accogliente e inclusivo
- Rispettare i diversi punti di vista
- Accettare le critiche costruttive con spirito collaborativo
- Concentrarsi su ciò che è meglio per la community
