#!/bin/bash
# oc-vpn.sh — Wrapper pour oc-go-cc avec gestion VPN intégrée
# Permet de switcher les serveurs VPN et les providers pour bypasser les rate limits.

set -euo pipefail

# --- Config ---
OC_GO_CC_BIN="${OC_GO_CC_BIN:-oc-go-cc}"
VPN_BIN="${VPN_BIN:-vpn}"
OC_CONFIG_DIR="${HOME}/.config/oc-go-cc"
OC_CONFIG_FILE="${OC_CONFIG_DIR}/config.json"
LOG_FILE="/tmp/oc-vpn.log"

# --- Fonctions ---
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

check_vpn() {
    if ! docker ps --format '{{.Names}}' | grep -q "vpn_namecheap"; then
        log "❌ VPN non actif. Démarrage..."
        $VPN_BIN change "$1" > /dev/null 2>&1
    else
        log "✅ VPN actif."
    fi
}

switch_provider() {
    local provider="$1"
    local base_url=""

    case "$provider" in
        zen)
            base_url="https://opencode.ai/zen/v1/chat/completions"
            ;;
        go)
            base_url="https://opencode.ai/zen/go/v1/chat/completions"
            ;;
        custom)
            read -rp "URL personnalisée: " base_url
            ;;
        *)
            log "❌ Provider inconnu: $provider"
            exit 1
            ;;
    esac

    log "🔄 Switch provider vers: $provider ($base_url)"
    # Met à jour la config JSON (nécessite jq)
    if command -v jq &> /dev/null; then
        local tmp=$(mktemp)
        jq --arg url "$base_url" '.providers["opencode-zen"].base_url = $url' "$OC_CONFIG_FILE" > "$tmp" && mv "$tmp" "$OC_CONFIG_FILE"
        log "✅ Config mise à jour."
    else
        log "⚠️ jq non trouvé. Mise à jour manuelle requise."
    fi
}

run_oc() {
    log "🚀 Lancement de oc-go-cc..."
    exec $OC_GO_CC_BIN serve
}

# --- Main ---
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <command> [args]"
    echo ""
    echo "Commandes:"
    echo "  start <location>     Démarre VPN + proxy"
    echo "  switch <provider>    Change le provider (zen/go/custom)"
    echo "  status               Affiche l'état"
    echo "  stop                 Arrête tout"
    exit 0
fi

CMD="$1"
shift

case "$CMD" in
    start)
        LOC="${1:-new-york}"
        check_vpn "$LOC"
        run_oc
        ;;
    switch)
        PROV="${1:-zen}"
        switch_provider "$PROV"
        ;;
    status)
        echo "--- VPN Status ---"
        $VPN_BIN status
        echo ""
        echo "--- Proxy Config ---"
        if [[ -f "$OC_CONFIG_FILE" ]]; then
            cat "$OC_CONFIG_FILE"
        else
            echo "Config non trouvée."
        fi
        ;;
    stop)
        log "🛑 Arrêt du proxy et du VPN..."
        $VPN_BIN stop
        ;;
    *)
        log "❌ Commande inconnue: $CMD"
        exit 1
        ;;
esac
