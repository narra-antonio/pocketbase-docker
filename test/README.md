# Test suite — pocketbase-docker

Automazione del piano di test manuale (4 test). Richiede `docker` e `curl`, nessuna dipendenza esterna.

## Uso

```bash
./test/run-tests.sh                 # builda la variante alpine e gira tutti i test
VARIANT=debian ./test/run-tests.sh  # variante debian
VARIANT=ubi    ./test/run-tests.sh  # variante ubi9-minimal
BUILD=0 IMAGE=tonynarra/pocketbase-docker:latest ./test/run-tests.sh   # usa immagine esistente
KEEP=1 ./test/run-tests.sh          # non rimuove i container (debug)
```

Exit code `0` = tutti verdi, `1` = almeno un fallimento. Adatto alla CI.

## Cosa copre

| # | Test | Verifica |
|---|------|----------|
| 1 | Porta custom | `PB_PORT=3000`, health + dashboard `/_/` |
| 2 | Migration utente | ordine (initial prima), nomi ripristinati, collection + 50 record via API |
| 3 | Template email | i template da env risultano applicati (marker via API) |
| 4 | Reinizializzazione | delete `.pb_initialized` → reinit + settings dal `.env` |

Le asserzioni sono via API PocketBase (health, auth superuser, settings, records) invece che a mano in dashboard.
