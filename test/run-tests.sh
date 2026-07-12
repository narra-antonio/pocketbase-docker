#!/usr/bin/env bash
# ===========================================
# pocketbase-docker — suite di test automatica
# Automatizza il piano manuale (Test 1-4).
# Requisiti: docker, curl. Nessuna dipendenza esterna.
#
# Uso:
#   ./test/run-tests.sh                 # builda alpine e gira tutti i test
#   VARIANT=debian ./test/run-tests.sh  # variante debian (Dockerfile.debian)
#   IMAGE=tonynarra/pocketbase-docker:latest ./test/run-tests.sh   # usa immagine esistente, salta build
#   KEEP=1 ./test/run-tests.sh          # non pulisce i container a fine test (debug)
# ===========================================
set -u

# --- config ---
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VARIANT="${VARIANT:-alpine}"
IMAGE="${IMAGE:-pocketbase-docker:test}"
BUILD="${BUILD:-1}"          # 0 = salta build (usa IMAGE esistente)
KEEP="${KEEP:-0}"
ADMIN_EMAIL="admin@test.local"
ADMIN_PASS="Test-Password-123456"
TMP_BASE="$(mktemp -d)"
CONTAINERS=()

# --- colori/log ---
c_g=$'\e[32m'; c_r=$'\e[31m'; c_y=$'\e[33m'; c_b=$'\e[34m'; c_0=$'\e[0m'
PASS_N=0; FAIL_N=0; FAILED_TESTS=()
log()  { echo "${c_b}▶${c_0} $*"; }
ok()   { echo "  ${c_g}✔${c_0} $*"; }
ko()   { echo "  ${c_r}x${c_0} $*"; }
info() { echo "    ${c_y}·${c_0} $*"; }

pass_test() { PASS_N=$((PASS_N+1)); echo "${c_g}PASS${c_0}: $1"; }
fail_test() { FAIL_N=$((FAIL_N+1)); FAILED_TESTS+=("$1"); echo "${c_r}FAIL${c_0}: $1"; }

cleanup() {
    if [ "$KEEP" = "1" ]; then
        info "KEEP=1 — container non rimossi: ${CONTAINERS[*]:-nessuno}"
    else
        for c in "${CONTAINERS[@]:-}"; do [ -n "$c" ] && docker rm -f "$c" >/dev/null 2>&1; done
    fi
    rm -rf "$TMP_BASE" 2>/dev/null
}
trap cleanup EXIT

start_pb() {  # start_pb <name> <hostport> <ctport> <datadir> [extra docker args...]
    local name="$1" hport="$2" cport="$3" datadir="$4"; shift 4
    mkdir -p "$datadir"
    CONTAINERS+=("$name")
    docker rm -f "$name" >/dev/null 2>&1
    docker run -d --name "$name" \
        -p "127.0.0.1:${hport}:${cport}" \
        -e PB_PORT="$cport" \
        -e PB_ADMIN_EMAIL="$ADMIN_EMAIL" \
        -e PB_ADMIN_PASSWORD="$ADMIN_PASS" \
        -e PB_APP_NAME="TestApp" \
        -v "${datadir}/pb_data:/pb_data" \
        "$@" \
        "$IMAGE" >/dev/null
}

wait_health() {  # wait_health <hostport>
    local port="$1" i
    for i in $(seq 1 40); do
        curl -fsS "http://127.0.0.1:${port}/api/health" >/dev/null 2>&1 && return 0
        sleep 1
    done
    return 1
}

pb_token() {  # pb_token <hostport> -> stdout token
    curl -fsS -X POST "http://127.0.0.1:$1/api/collections/_superusers/auth-with-password" \
        -H 'Content-Type: application/json' \
        -d "{\"identity\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASS}\"}" 2>/dev/null \
        | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

# ============================================================
log "Setup — variante=${VARIANT}, immagine=${IMAGE}, build=${BUILD}"
if [ "$BUILD" = "1" ]; then
    log "Build immagine da Dockerfile.${VARIANT}..."
    if ! docker build -f "${REPO_ROOT}/Dockerfile.${VARIANT}" -t "$IMAGE" "$REPO_ROOT"; then
        echo "${c_r}Build fallita — stop.${c_0}"; exit 1
    fi
    ok "Immagine buildata: $IMAGE"
fi

# ============================================================
# TEST 1 — Porta custom (PB_PORT=3000)
# ============================================================
test_1() {
    log "TEST 1 — Porta custom (3000)"
    local d="${TMP_BASE}/t1"
    start_pb pbtest1 3000 3000 "$d"
    if ! wait_health 3000; then ko "health non risponde su :3000"; docker logs pbtest1 2>&1 | tail -15; fail_test "T1 porta custom"; return; fi
    ok "health OK su :3000"
    local code
    code="$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3000/_/ )"
    [ "$code" = "200" ] && ok "dashboard /_/ raggiungibile ($code)" || { ko "dashboard /_/ = $code"; fail_test "T1 porta custom"; return; }
    pass_test "T1 porta custom"
}

# ============================================================
# TEST 2 — Migration utente con nomi difficili + seed
# ============================================================
test_2() {
    log "TEST 2 — Migration utente (ordine + nomi + 50 record)"
    local d="${TMP_BASE}/t2"
    mkdir -p "${d}/pb_migrations"
    cp "${REPO_ROOT}/test/fixtures/migrations/1_tabella.js" "${d}/pb_migrations/"
    cp "${REPO_ROOT}/test/fixtures/migrations/2_seed.js"    "${d}/pb_migrations/"
    start_pb pbtest2 3001 3001 "$d" -v "${d}/pb_migrations:/pb_migrations"
    if ! wait_health 3001; then ko "health non risponde"; docker logs pbtest2 2>&1 | tail -20; fail_test "T2 migration utente"; return; fi

    local logs; logs="$(docker logs pbtest2 2>&1)"
    # a) la nostra migration gira per prima
    if echo "$logs" | grep -q 'Initial settings migration running'; then ok "migration initial_settings eseguita"; else ko "initial_settings non trovata nei log"; fi

    # b) i file utente mantengono il nome originale dopo l'init
    if [ -f "${d}/pb_migrations/1_tabella.js" ] && [ -f "${d}/pb_migrations/2_seed.js" ]; then
        ok "nomi migration utente ripristinati (1_tabella.js, 2_seed.js)"
    else
        ko "nomi migration NON ripristinati:"; ls -1 "${d}/pb_migrations/" | sed 's/^/       /'; fail_test "T2 migration utente"; return
    fi

    # c) collection + 50 record via API
    local tok; tok="$(pb_token 3001)"
    if [ -z "$tok" ]; then ko "auth superuser fallita"; fail_test "T2 migration utente"; return; fi
    local total; total="$(curl -fsS "http://127.0.0.1:3001/api/collections/tabella/records?perPage=1" -H "Authorization: ${tok}" 2>/dev/null | sed -n 's/.*"totalItems":\([0-9]*\).*/\1/p')"
    if [ "$total" = "50" ]; then ok "collection 'tabella' con 50 record"; else ko "record attesi 50, trovati: ${total:-0}"; fail_test "T2 migration utente"; return; fi
    pass_test "T2 migration utente"
}

# ============================================================
# TEST 3 — Template email custom
# ============================================================
test_3() {
    log "TEST 3 — Template email custom"
    local d="${TMP_BASE}/t3"
    start_pb pbtest3 3002 3002 "$d" \
        -v "${REPO_ROOT}/test/fixtures/templates:/pb_templates:ro" \
        -e PB_TPL_VERIFICATION_BODY=/pb_templates/verification.html \
        -e PB_TPL_RESET_PWD_BODY=/pb_templates/reset-password.html \
        -e PB_TPL_CONFIRM_EMAIL_BODY=/pb_templates/confirm-email.html \
        -e PB_TPL_OTP_BODY=/pb_templates/otp.html
    if ! wait_health 3002; then ko "health non risponde"; docker logs pbtest3 2>&1 | tail -20; fail_test "T3 template email"; return; fi
    local tok; tok="$(pb_token 3002)"
    if [ -z "$tok" ]; then ko "auth superuser fallita"; fail_test "T3 template email"; return; fi

    # Cerca i marker dei template dove PB 0.36 li può tenere: settings globali + collection users/_superusers
    local found=0 where=""
    for url in "/api/settings" "/api/collections/users" "/api/collections/_superusers"; do
        local body; body="$(curl -fsS "http://127.0.0.1:3002${url}" -H "Authorization: ${tok}" 2>/dev/null)"
        if echo "$body" | grep -q 'PBTEST_verification_MARKER'; then found=1; where="$url"; break; fi
    done
    if [ "$found" = "1" ]; then
        ok "template custom applicato (marker trovato in ${where})"
        pass_test "T3 template email"
    else
        ko "marker template NON trovato — i template da env potrebbero non applicarsi in PB ${VARIANT}"
        info "in PB 0.23+ i template email sono per-collection: la migration setta settings.meta.* (posizione legacy) → possibile bug"
        fail_test "T3 template email"
    fi
}

# ============================================================
# TEST 4 — Reinizializzazione
# ============================================================
test_4() {
    log "TEST 4 — Reinizializzazione (delete lock + restart)"
    local d="${TMP_BASE}/t4"
    start_pb pbtest4 3003 3003 "$d"
    if ! wait_health 3003; then ko "health non risponde"; docker logs pbtest4 2>&1 | tail -20; fail_test "T4 reinit"; return; fi
    local tok; tok="$(pb_token 3003)"
    # cambia appName via API
    curl -fsS -X PATCH "http://127.0.0.1:3003/api/settings" -H "Authorization: ${tok}" \
        -H 'Content-Type: application/json' -d '{"meta":{"appName":"CHANGED-BY-TEST"}}' >/dev/null 2>&1
    local now; now="$(curl -fsS "http://127.0.0.1:3003/api/settings" -H "Authorization: ${tok}" 2>/dev/null | sed -n 's/.*"appName":"\([^"]*\)".*/\1/p')"
    info "appName dopo modifica: ${now}"

    # trova ed elimina il lock nel volume host
    local lock; lock="$(find "${d}/pb_data" -maxdepth 1 -name '.pb_initialized' 2>/dev/null)"
    if [ -z "$lock" ]; then ko ".pb_initialized non trovato nel volume"; fail_test "T4 reinit"; return; fi
    rm -f "$lock"; ok "lock .pb_initialized eliminato"
    docker restart pbtest4 >/dev/null
    if ! wait_health 3003; then ko "health non risponde dopo restart"; fail_test "T4 reinit"; return; fi

    local logs; logs="$(docker logs pbtest4 2>&1)"
    if echo "$logs" | grep -q 'First boot detected'; then ok "flusso di inizializzazione ri-eseguito"; else ko "reinit NON ripartito (no 'First boot detected')"; fi

    tok="$(pb_token 3003)"
    local after; after="$(curl -fsS "http://127.0.0.1:3003/api/settings" -H "Authorization: ${tok}" 2>/dev/null | sed -n 's/.*"appName":"\([^"]*\)".*/\1/p')"
    if [ "$after" = "TestApp" ]; then
        ok "settings tornati al valore .env (appName=TestApp)"
        pass_test "T4 reinit"
    else
        ko "appName atteso 'TestApp', trovato '${after}' — la migration initial non ri-applica i settings su reinit con pb_data persistente"
        info "probabile: _migrations già contiene 1000000000 → --automigrate la salta. Reinit resetta i settings solo con pb_data pulito."
        fail_test "T4 reinit"
    fi
}

# ============================================================
test_1
test_2
test_3
test_4

echo
echo "================ RISULTATI ================"
echo "  ${c_g}PASS: ${PASS_N}${c_0}   ${c_r}FAIL: ${FAIL_N}${c_0}"
if [ "$FAIL_N" -gt 0 ]; then
    printf '  falliti: %s\n' "${FAILED_TESTS[*]}"
    exit 1
fi
echo "  ${c_g}Tutti i test superati ✔${c_0}"
