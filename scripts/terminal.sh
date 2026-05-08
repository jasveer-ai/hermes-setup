#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo "── Terminal Setup ──"

# ── Homebrew ─────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── WezTerm ──────────────────────────────────
if ! command -v wezterm &>/dev/null; then
    log_warn "Installing WezTerm..."
    brew install --cask wezterm
else
    log_info "WezTerm already installed"
fi

# ── Nerd Font ────────────────────────────────
if [[ ! -f "/Users/$USER/Library/Fonts/JetBrainsMonoNerdFontMono-Regular.ttf" ]]; then
    log_warn "Installing JetBrains Mono Nerd Font..."
    brew install font-jetbrains-mono-nerd-font
else
    log_info "JetBrains Mono Nerd Font already installed"
fi

# ── Starship ─────────────────────────────────
if ! command -v starship &>/dev/null; then
    log_warn "Installing Starship..."
    brew install starship
else
    log_info "Starship already installed"
fi

# ── fzf ──────────────────────────────────────
if ! command -v fzf &>/dev/null; then
    log_warn "Installing fzf..."
    brew install fzf
    /opt/homebrew/opt/fzf/install --bin --no-update-rc --no-fish
else
    log_info "fzf already installed"
fi

# ── zsh plugins ──────────────────────────────
mkdir -p ~/.zsh

if [[ ! -d ~/.zsh/zsh-syntax-highlighting ]]; then
    log_warn "Cloning zsh-syntax-highlighting..."
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
else
    log_info "zsh-syntax-highlighting already installed"
fi

if [[ ! -d ~/.zsh/zsh-autosuggestions ]]; then
    log_warn "Cloning zsh-autosuggestions..."
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
else
    log_info "zsh-autosuggestions already installed"
fi

# ── WezTerm config ────────────────────────────
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
WEZTERM_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)/wezterm.lua"
if [[ -f "$WEZTERM_SOURCE" ]]; then
    mkdir -p "$WEZTERM_CONFIG_DIR"
    cp "$WEZTERM_SOURCE" "$WEZTERM_CONFIG_DIR/wezterm.lua"
    log_info "WezTerm config deployed"
fi

# ── zshrc setup (safe, non-destructive) ──────
ZSHRC="$HOME/.zshrc"

ensure_zshrc_line() {
    local line="$1"
    if [[ ! -f "$ZSHRC" ]] || ! grep -qxF "$line" "$ZSHRC" 2>/dev/null; then
        echo "$line" >> "$ZSHRC"
        return 0
    fi
    return 1
}

if [[ ! -f "$ZSHRC" ]]; then
    log_warn "Creating ~/.zshrc..."
    touch "$ZSHRC"
    log_info "~/.zshrc created"
else
    log_info "~/.zshrc exists — appending missing lines only"
fi

# Append starship init if missing
if ensure_zshrc_line 'eval "$(starship init zsh)"'; then
    log_info "Added Starship init to ~/.zshrc"
fi

# Append plugin sources if missing
if ensure_zshrc_line 'source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'; then
    log_info "Added zsh-syntax-highlighting to ~/.zshrc"
fi

if ensure_zshrc_line 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh'; then
    log_info "Added zsh-autosuggestions to ~/.zshrc"
fi

# Append fzf bindings if missing
if ensure_zshrc_line 'source /opt/homebrew/opt/fzf/shell/key-bindings.zsh 2>/dev/null'; then
    log_info "Added fzf key bindings to ~/.zshrc"
fi

if ensure_zshrc_line 'source /opt/homebrew/opt/fzf/shell/completion.zsh 2>/dev/null'; then
    log_info "Added fzf completion to ~/.zshrc"
fi

# Append PATH if missing
if ensure_zshrc_line 'export PATH="$HOME/.local/bin:$PATH"'; then
    log_info "Added PATH export to ~/.zshrc"
fi

log_info "Terminal setup complete. Restart your shell to apply."
