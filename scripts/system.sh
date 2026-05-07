#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# ── Homebrew ─────────────────────────────────
echo "── Homebrew ──"

if ! command -v brew &>/dev/null && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v brew &>/dev/null; then
    log_error "Homebrew not found. Install first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "   echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile"
    echo "   eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    exit 1
fi
log_info "Homebrew ready"

# ── System tools ─────────────────────────────
echo "── System Tools ──"

for pkg in ripgrep ffmpeg; do
    if ! command -v "$pkg" &>/dev/null; then
        log_warn "Installing $pkg..."
        brew install "$pkg"
    else
        log_info "$pkg already installed"
    fi
done

# ── Git ──────────────────────────────────────
echo "── Git ──"

read -rp "Git username: " GH_USER
if [[ -z "$GH_USER" ]]; then
    log_error "Git username is required"
    exit 1
fi

read -rp "Git email: " GH_EMAIL
if [[ -z "$GH_EMAIL" ]]; then
    log_error "Git email is required"
    exit 1
fi

git config --global user.name "$GH_USER"
git config --global user.email "$GH_EMAIL"
log_info "Git configured: $GH_USER <$GH_EMAIL>"

# ── SSH Key ──────────────────────────────────
echo "── SSH Key ──"

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

# ── GitHub CLI ───────────────────────────────
echo "── GitHub CLI ──"

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
