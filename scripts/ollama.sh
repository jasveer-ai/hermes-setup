#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo "── Ollama Setup ──"

# ── Install Ollama via Homebrew ──────────────
if ! command -v ollama &>/dev/null; then
    log_warn "Installing Ollama..."
    brew install ollama
    log_info "Ollama installed"
else
    log_info "Ollama already installed"
fi

# ── Start Ollama service ─────────────────────
if ! pgrep -x "ollama" > /dev/null 2>&1; then
    log_warn "Starting Ollama server..."
    ollama serve &
    # Wait for server to be ready
    for i in {1..30}; do
        if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        log_error "Ollama server failed to start"
        exit 1
    fi
    log_info "Ollama server started"
else
    log_info "Ollama server already running"
fi

# ── Pull gemma4:e4b ──────────────────────────
MODEL="gemma4:e4b"
if ollama list 2>/dev/null | grep -q "^${MODEL}"; then
    log_info "Model $MODEL already pulled"
else
    log_warn "Pulling $MODEL (~9.6GB, this will take a while)..."
    ollama pull "$MODEL"
    log_info "Model $MODEL pulled successfully"
fi

# ── Verify ───────────────────────────────────
log_info "Available models:"
ollama list

echo ""
log_info "Ollama setup complete. Server running at http://localhost:11434"
log_info "Hermes config will use $MODEL as the primary model."
