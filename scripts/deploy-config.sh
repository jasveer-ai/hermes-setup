#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
HERMES_HOME="$HOME/.hermes"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }

echo "Deploying Hermes configuration..."

mkdir -p "$HERMES_HOME"

# SOUL.md — always deploy (personality)
cp "$CONFIG_DIR/SOUL.md" "$HERMES_HOME/SOUL.md"
log_info "SOUL.md deployed"

# MEMORY.md — only if not exists (preserve memory)
if [[ ! -f "$HERMES_HOME/MEMORY.md" ]]; then
    cp "$CONFIG_DIR/MEMORY.md" "$HERMES_HOME/MEMORY.md"
    log_info "MEMORY.md deployed (new)"
else
    log_warn "MEMORY.md exists — not overwriting"
fi

# USER.md — only if not exists
if [[ ! -f "$HERMES_HOME/USER.md" ]]; then
    cp "$CONFIG_DIR/USER.md" "$HERMES_HOME/USER.md"
    log_info "USER.md deployed (new)"
else
    log_warn "USER.md exists — not overwriting"
fi

# AGENTS.md — deploy to home
if [[ ! -f "$HOME/AGENTS.md" ]]; then
    cp "$CONFIG_DIR/AGENTS.md" "$HOME/AGENTS.md"
    log_info "AGENTS.md deployed to $HOME/"
else
    log_warn "AGENTS.md exists at home — not overwriting"
fi

# config.yaml — deploy if not exists
if [[ -f "$CONFIG_DIR/config.yaml" ]]; then
    if [[ ! -f "$HERMES_HOME/config.yaml" ]]; then
        cp "$CONFIG_DIR/config.yaml" "$HERMES_HOME/config.yaml"
        log_info "config.yaml deployed"
    else
        log_warn "config.yaml exists — not overwriting"
    fi
fi

# .env — deploy if not exists
if [[ -f "$CONFIG_DIR/.env.example" ]]; then
    if [[ ! -f "$HERMES_HOME/.env" ]]; then
        cp "$CONFIG_DIR/.env.example" "$HERMES_HOME/.env"
        log_info ".env deployed from template — EDIT WITH YOUR API KEYS"
    else
        log_warn ".env exists — not overwriting"
    fi
fi

echo ""
echo "Done. Edit ~/.hermes/.env with your API keys, then run 'hermes'."
