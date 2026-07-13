#!/bin/bash
set -e

# ===========================================
# PocketBase Docker Entrypoint
# https://github.com/narra-antonio/pocketbase-docker
# ===========================================

PB_BINARY="/app/pocketbase"
PB_DATA_DIR="/pb_data"
PB_MIGRATIONS_DIR="/pb_migrations"
PB_HOOKS_DIR="/pb_hooks"
PB_PUBLIC_DIR="/pb_public"
PB_INIT_LOCK="${PB_DATA_DIR}/.pb_initialized"

# Settings iniziali (solo settings, NON una migration utente): baked nell'immagine.
PB_MIGRATION_SRC="/app/pb_migrations_default/1000000000_initial_settings.js"
# Dir DEDICATA per la fase settings — mai /pb_migrations, così i file utente non vengono toccati
# e l'ordine "settings prima, migration utente dopo" è garantito per FASE, non per nome file.
PB_BOOTSTRAP_DIR="/app/pb_bootstrap"
# Hooks vuoti in fase 1: isola i settings (i tuoi hook potrebbero riferire collezioni
# create dalle migration utente, che in fase 1 non esistono ancora).
PB_BOOTSTRAP_HOOKS="/app/pb_bootstrap_hooks"

PB_HOST="${PB_HOST:-0.0.0.0}"
PB_PORT="${PB_PORT:-8090}"

# ===========================================
# Build serve command
#   $1 = migrationsDir (default: /pb_migrations)
#   $2 = hooksDir      (default: /pb_hooks)
# ===========================================
build_cmd() {
  local migdir="${1:-${PB_MIGRATIONS_DIR}}"
  local hookdir="${2:-${PB_HOOKS_DIR}}"
  local cmd="${PB_BINARY} serve"
  cmd="${cmd} --http=${PB_HOST}:${PB_PORT}"
  cmd="${cmd} --dir=${PB_DATA_DIR}"
  cmd="${cmd} --migrationsDir=${migdir}"
  cmd="${cmd} --hooksDir=${hookdir}"
  cmd="${cmd} --publicDir=${PB_PUBLIC_DIR}"
  cmd="${cmd} --automigrate"

  if [ "${PB_DEBUG}" = "true" ]; then
    cmd="${cmd} --dev"
  fi

  if [ -n "${PB_ENCRYPTION_KEY}" ]; then
    cmd="${cmd} --encryptionEnv=PB_ENCRYPTION_KEY"
  fi

  echo "${cmd}"
}

# ===========================================
# Wait for PocketBase health check
# ===========================================
wait_for_health() {
  local url="http://${PB_HOST}:${PB_PORT}/api/health"
  local retries=30
  local interval=2

  echo "⏳ Waiting for PocketBase to be ready at ${url}..."
  for i in $(seq 1 ${retries}); do
    if wget --no-verbose --tries=1 --spider "${url}" 2>/dev/null; then
      echo "✅ PocketBase is ready"
      return 0
    fi
    sleep ${interval}
  done

  echo "❌ PocketBase did not become ready in time"
  return 1
}

# ===========================================
# First boot: FASE 1 — applica i settings iniziali
#   Gira SOLO quando manca il lock (primo boot o reinit).
#   Applica system migrations + settings in una dir dedicata, senza vedere /pb_migrations.
#   NON tocca i file utente, NON rinomina nulla.
# ===========================================
first_boot() {
  echo "🚀 First boot detected — applying initial settings..."

  mkdir -p "${PB_BOOTSTRAP_DIR}" "${PB_BOOTSTRAP_HOOKS}"

  # Copia i settings con nome UNICO ad ogni first-boot.
  # Motivo: con nome fisso, dopo il primo avvio la migration resta in _migrations e
  # --automigrate la salta → su reinit (lock rimosso) i settings NON tornerebbero al .env.
  # Un nome nuovo forza il re-apply. La dir è baked/scrivibile: nessun churn dei file utente.
  local dst="${PB_BOOTSTRAP_DIR}/1$(date +%s%N)_initial_settings.js"
  cp "${PB_MIGRATION_SRC}" "${dst}"
  echo "📋 Initial settings staged (${dst##*/})"

  # Avvia PB in background sulla dir dedicata (system migrations + settings).
  # Invocazione DIRETTA (non eval): così $! è il PID reale di pocketbase e il kill lo termina
  # davvero. Con `eval "$cmd" &`, $! sarebbe la subshell e pocketbase resterebbe orfano tenendo
  # occupata la porta → la fase 2 fallirebbe il bind (address already in use).
  local -a args=(serve
    --http="${PB_HOST}:${PB_PORT}"
    --dir="${PB_DATA_DIR}"
    --migrationsDir="${PB_BOOTSTRAP_DIR}"
    --hooksDir="${PB_BOOTSTRAP_HOOKS}"
    --publicDir="${PB_PUBLIC_DIR}"
    --automigrate)
  [ -n "${PB_ENCRYPTION_KEY}" ] && args+=(--encryptionEnv=PB_ENCRYPTION_KEY)
  [ "${PB_DEBUG}" = "true" ] && args+=(--dev)
  echo "▶️  Phase 1 (settings): ${PB_BINARY} ${args[*]}"
  "${PB_BINARY}" "${args[@]}" &
  local PB_PID=$!

  if ! wait_for_health; then
    kill "${PB_PID}" 2>/dev/null || true
    wait "${PB_PID}" 2>/dev/null || true
    echo "❌ Settings phase failed"
    exit 1
  fi

  # Ferma SOLO il PB temporaneo della fase 1.
  # Il container NON si ferma: PID 1 è questo script, che prosegue a normal_boot → exec.
  kill "${PB_PID}" 2>/dev/null || true
  wait "${PB_PID}" 2>/dev/null || true

  # Pulizia file staged + lock
  rm -f "${PB_BOOTSTRAP_DIR}"/1*_initial_settings.js
  touch "${PB_INIT_LOCK}"
  echo "🔒 Initialized — lock: ${PB_INIT_LOCK}"
  echo "🎉 Settings applied — proceeding to user migrations"
}

# ===========================================
# Normal boot: FASE 2 — SEMPRE
#   Applica i migration utente da /pb_migrations e serve in foreground.
#   I nomi dei file utente sono liberi: i settings sono già stati applicati nella fase 1.
# ===========================================
normal_boot() {
  local cmd
  cmd="$(build_cmd)"
  echo "▶️  Starting PocketBase: ${cmd}"
  exec ${cmd}
}

# ===========================================
# Main
# ===========================================
echo "🐳 PocketBase Docker Entrypoint"
echo "   Host:    ${PB_HOST}"
echo "   Port:    ${PB_PORT}"
echo "   Data:    ${PB_DATA_DIR}"
echo "   Debug:   ${PB_DEBUG:-false}"

mkdir -p "${PB_DATA_DIR}" "${PB_MIGRATIONS_DIR}" "${PB_HOOKS_DIR}" "${PB_PUBLIC_DIR}"

# first_boot SOLO se il lock non esiste (primo boot / reinit); normal_boot sempre.
if [ ! -f "${PB_INIT_LOCK}" ]; then
  first_boot
fi
normal_boot
