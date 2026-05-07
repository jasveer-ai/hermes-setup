#!/bin/bash
set -euo pipefail

echo "═══════════════════════════════════════════"
echo "  Hermes MacBook Overseer — Setup"
echo "═══════════════════════════════════════════"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="$HOME/.hermes"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_step()  { echo -e "\n── $1 ──"; }

# ── 1. Homebrew ──────────────────────────────
log_step "1. Homebrew"

eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

if ! command -v brew &>/dev/null; then
    log_error "Homebrew not found. Install first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "   echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile"
    echo "   eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    exit 1
fi
log_info "Homebrew ready"

# ── 2. System tools ──────────────────────────
log_step "2. System Tools"

for pkg in ripgrep ffmpeg; do
    if ! command -v "$pkg" &>/dev/null; then
        log_warn "Installing $pkg..."
        brew install "$pkg"
    else
        log_info "$pkg already installed"
    fi
done

# ── 3. Git ────────────────────────────────────
log_step "3. Git"

read -rp "Git username (default: jasveer-ai): " GH_USER
GH_USER="${GH_USER:-jasveer-ai}"

read -rp "Git email (default: account@example.com): " GH_EMAIL
GH_EMAIL="${GH_EMAIL:-account@example.com}"

git config --global user.name "$GH_USER"
git config --global user.email "$GH_EMAIL"
log_info "Git configured: $GH_USER <$GH_EMAIL>"

# ── 4. SSH Key ────────────────────────────────
log_step "4. SSH Key"

SSH_KEY="$HOME/.ssh/id_ed25519_github"

if [[ -f "$SSH_KEY" ]]; then
    log_info "SSH key exists at $SSH_KEY"
else
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$GH_EMAIL" -f "$SSH_KEY" -N ""
    log_info "SSH key generated"
fi

if ! grep -q "github.com" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" << EOF

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $SSH_KEY
EOF
    log_info "SSH config updated for github.com"
else
    log_info "SSH config already has github.com"
fi

chmod 600 "$HOME/.ssh/config" 2>/dev/null || true

echo ""
echo "Public key:"
cat "${SSH_KEY}.pub"
echo ""
echo "Add to GitHub: https://github.com/settings/ssh/new"
read -rp "Press Enter after adding the key..."

# ── 5. GitHub CLI ─────────────────────────────
log_step "5. GitHub CLI"

if ! command -v gh &>/dev/null; then
    brew install gh
    log_info "GitHub CLI installed"
else
    log_info "GitHub CLI already installed"
fi

if gh auth status &>/dev/null 2>&1; then
    log_info "GitHub CLI authenticated"
else
    echo "Authenticating with GitHub CLI (SSH)..."
    gh auth login --hostname github.com --git-protocol ssh
fi

# ── 6. Hermes Agent ──────────────────────────
log_step "6. Hermes Agent"

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

# ── 7. Deploy memory/context files ───────────
log_step "7. Memory & Context Files"

mkdir -p "$HERMES_HOME"

# SOUL.md — always deploy (personality)
if [[ -f "$SCRIPT_DIR/config/SOUL.md" ]]; then
    cp "$SCRIPT_DIR/config/SOUL.md" "$HERMES_HOME/SOUL.md"
    log_info "SOUL.md deployed"
fi

# MEMORY.md — only if not exists (preserve memory)
if [[ -f "$SCRIPT_DIR/config/MEMORY.md" ]]; then
    if [[ ! -f "$HERMES_HOME/MEMORY.md" ]]; then
        cp "$SCRIPT_DIR/config/MEMORY.md" "$HERMES_HOME/MEMORY.md"
        log_info "MEMORY.md deployed (new)"
    else
        log_warn "MEMORY.md exists — not overwriting"
    fi
fi

# USER.md — only if not exists
if [[ -f "$SCRIPT_DIR/config/USER.md" ]]; then
    if [[ ! -f "$HERMES_HOME/USER.md" ]]; then
        cp "$SCRIPT_DIR/config/USER.md" "$HERMES_HOME/USER.md"
        log_info "USER.md deployed (new)"
    else
        log_warn "USER.md exists — not overwriting"
    fi
fi

# AGENTS.md at home
if [[ -f "$SCRIPT_DIR/config/AGENTS.md" ]]; then
    if [[ ! -f "$HOME/AGENTS.md" ]]; then
        cp "$SCRIPT_DIR/config/AGENTS.md" "$HOME/AGENTS.md"
        log_info "AGENTS.md deployed to $HOME/"
    else
        log_warn "AGENTS.md at home exists — not overwriting"
    fi
fi

# config.yaml
if [[ -f "$SCRIPT_DIR/config/config.yaml" ]]; then
    if [[ ! -f "$HERMES_HOME/config.yaml" ]]; then
        cp "$SCRIPT_DIR/config/config.yaml" "$HERMES_HOME/config.yaml"
        log_info "config.yaml deployed"
    else
        log_warn "config.yaml exists — not overwriting"
    fi
fi

# .env from template
if [[ -f "$SCRIPT_DIR/config/.env.example" ]]; then
    if [[ ! -f "$HERMES_HOME/.env" ]]; then
        cp "$SCRIPT_DIR/config/.env.example" "$HERMES_HOME/.env"
        log_info ".env deployed from template"
    else
        log_warn ".env exists — not overwriting"
    fi
fi

# ── 8. API Key ───────────────────────────────
log_step "8. API Key"

echo "Hermes needs at least one LLM provider API key."
echo "OpenRouter (recommended): https://openrouter.ai/settings/keys"
echo ""
read -rp "OpenRouter API key (leave blank to edit ~/.hermes/.env later): " OPENROUTER_KEY

if [[ -n "$OPENROUTER_KEY" ]]; then
    if grep -q "OPENROUTER_API_KEY=" "$HERMES_HOME/.env"; then
        sed -i '' "s|^OPENROUTER_API_KEY=.*|OPENROUTER_API_KEY=$OPENROUTER_KEY|" "$HERMES_HOME/.env"
    else
        echo "OPENROUTER_API_KEY=$OPENROUTER_KEY" >> "$HERMES_HOME/.env"
    fi
    # Set provider to openrouter in config
    sed -i '' 's|provider: "auto"|provider: "openrouter"|' "$HERMES_HOME/config.yaml"
    log_info "OpenRouter API key saved"
fi

# ── 9. Cron (memory compaction) ──────────────
log_step "9. Cron Jobs"

if [[ -f "$SCRIPT_DIR/cron/memory-update.sh" ]]; then
    mkdir -p "$HERMES_HOME/cron"
    cp "$SCRIPT_DIR/cron/memory-update.sh" "$HERMES_HOME/cron/"
    chmod +x "$HERMES_HOME/cron/memory-update.sh"

    CRON_LABEL="hermes-memory-compaction"
    crontab -l 2>/dev/null | grep -v "$CRON_LABEL" | crontab - || true
    (crontab -l 2>/dev/null | grep -v "$CRON_LABEL"; echo "0 3 * * * $HERMES_HOME/cron/memory-update.sh >> $HERMES_HOME/logs/cron-memory.log 2>&1 # $CRON_LABEL") | crontab - 2>/dev/null || log_warn "crontab not available"

    log_info "Daily memory compaction cron installed (3am)"
fi

# ── 10. Done ─────────────────────────────────
log_step "Setup Complete"

echo ""
echo "Run 'hermes' to start your overseer agent."
echo ""
echo "Config files:"
echo "  SOUL.md   → ~/.hermes/SOUL.md"
echo "  MEMORY.md → ~/.hermes/MEMORY.md"
echo "  USER.md   → ~/.hermes/USER.md"
echo "  AGENTS.md → ~/AGENTS.md"
echo "  config    → ~/.hermes/config.yaml"
echo "  .env      → ~/.hermes/.env"
echo ""
