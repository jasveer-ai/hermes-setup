#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }

echo "── Hermes Agent ──"

export PATH="$HOME/.local/bin:$PATH"

if command -v hermes &>/dev/null; then
    log_info "Hermes already installed"
else
    echo "Installing Hermes Agent..."
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

    export PATH="$HOME/.local/bin:$PATH"
    grep -q "$HOME/.local/bin" "$HOME/.zshrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    grep -q "$HOME/.local/bin" "$HOME/.zprofile" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zprofile"

    log_info "Hermes installed"
fi
