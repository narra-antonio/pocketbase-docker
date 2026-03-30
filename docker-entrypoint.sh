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
PB_MIGRATION_SRC="/app/pb_migrations_default/1000000000_initial_settings.js"
PB_MIGRATION_DST="${PB_MIGRATIONS_DIR}/1000000000_initial_settings.js"
PB_HIGH_PREFIX="99999999999_"
PB_HOST="${PB_HOST:-0.0.0.0}"
PB_PORT="${PB_PORT:-8090}"

# ===========================================
# Build serve command
# ===========================================
build_cmd() {
  local cmd="${PB_BINARY} serve"
  cmd="${cmd} --http=${PB_HOST}:${PB_PORT}"
  cmd="${cmd} --dir=${PB_DATA_DIR}"
  cmd="${cmd} --migrationsDir=${PB_MIGRATIONS_DIR}"
  cmd="${cmd} --hooksDir=${PB_HOOKS_DIR}"
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
# Rename user migrations with high prefix
# to ensure our migration runs first
# ===========================================
rename_user_migrations() {
  if [ ! -d "${PB_MIGRATIONS_DIR}" ]; then
    mkdir -p "${PB_MIGRATIONS_DIR}"
    return
  fi

  for f in "${PB_MIGRATIONS_DIR}"/*.js; do
    [ -f "${f}" ] || continue
    local basename
    basename="$(basename "${f}")"
    # Skip if already prefixed by us
    if [[ "${basename}" == ${PB_HIGH_PREFIX}* ]]; then
      continue
    fi
    mv "${f}" "${PB_MIGRATIONS_DIR}/${PB_HIGH_PREFIX}${basename}"
    echo "   renamed: ${basename} → ${PB_HIGH_PREFIX}${basename}"
  done
}

# ===========================================
# Restore user migrations to original names
# ===========================================
restore_user_migrations() {
  for f in "${PB_MIGRATIONS_DIR}"/${PB_HIGH_PREFIX}*.js; do
    [ -f "${f}" ] || continue
    local basename
    basename="$(basename "${f}")"
    local original="${basename#${PB_HIGH_PREFIX}}"
    mv "${f}" "${PB_MIGRATIONS_DIR}/${original}"
    echo "   restored: ${basename} → ${original}"
  done
}

# ===========================================
# First boot initialization
# ===========================================
first_boot() {
  echo "🚀 First boot detected — running initialization..."

  # Rename user migrations
  echo "📋 Renaming user migrations..."
  rename_user_migrations

  # Copy our initial migration
  mkdir -p "${PB_MIGRATIONS_DIR}"
  cp "${PB_MIGRATION_SRC}" "${PB_MIGRATION_DST}"
  echo "📋 Initial settings migration copied"

  # Build and start PocketBase in background
  local cmd
  cmd="$(build_cmd)"
  echo "▶️  Starting PocketBase: ${cmd}"
  eval "${cmd}" &
  local PB_PID=$!

  # Wait for health check
  if ! wait_for_health; then
    kill "${PB_PID}" 2>/dev/null || true
    exit 1
  fi

  # Restore user migrations
  echo "📋 Restoring user migrations..."
  restore_user_migrations

  # Remove our initial migration
  rm -f "${PB_MIGRATION_DST}"
  echo "🗑️  Initial settings migration removed"

  # Create lock file
  touch "${PB_INIT_LOCK}"
  echo "🔒 Lock file created: ${PB_INIT_LOCK}"

  echo "🎉 Initialization completed — handing off to PocketBase process"

  # Wait for PocketBase to exit
  wait "${PB_PID}"
}

# ===========================================
# Normal boot
# ===========================================
normal_boot() {
  echo "✅ Already initialized — starting PocketBase normally"
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

if [ -f "${PB_INIT_LOCK}" ]; then
  normal_boot
else
  first_boot
fi