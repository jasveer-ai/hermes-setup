#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo "── Hermes Agent ──"

export PATH="$HOME/.local/bin:$PATH"

# Do NOT export HERMES_HOME — let the installer use its default ($HOME/.hermes).
# Exporting a literal "~/.hermes" breaks path resolution in the installer.
unset HERMES_HOME 2>/dev/null || true

# ---------------------------------------------------------------------------
# Detect broken or missing Hermes installation
# ---------------------------------------------------------------------------

HERMES_WRAPPER=""
WRAPPER_BROKEN=false

if command -v hermes &>/dev/null; then
    HERMES_WRAPPER="$(command -v hermes)"

    # Parse where the wrapper points to (our shim: exec "/path/to/bin/hermes" "$@")
    local_target=""
    if [ -f "$HERMES_WRAPPER" ] && head -1 "$HERMES_WRAPPER" 2>/dev/null | grep -q "#!/usr/bin/env bash"; then
        local_target=$(sed -n 's/exec "\(.*\)" "\\$@""/\1/p' "$HERMES_WRAPPER" 2>/dev/null || true)
    fi

    # Resolve symlink if it's a direct link
    if [ -z "$local_target" ]; then
        local_target=$(readlink -f "$HERMES_WRAPPER" 2>/dev/null || readlink "$HERMES_WRAPPER" 2>/dev/null || true)
    fi

    # Check if the actual binary exists and runs
    if [ -n "$local_target" ] && [ -x "$local_target" ] && "$local_target" --version &>/dev/null; then
        log_info "Hermes already installed ($("$local_target" --version 2>/dev/null | head -1))"
        exit 0
    else
        log_warn "Hermes wrapper exists but the target binary is broken or missing"
        WRAPPER_BROKEN=true
    fi
fi

# ---------------------------------------------------------------------------
# Clean up broken state before reinstalling
# ---------------------------------------------------------------------------

if [ "$WRAPPER_BROKEN" = true ] && [ -n "$HERMES_WRAPPER" ]; then
    rm -f "$HERMES_WRAPPER"
    log_warn "Removed broken hermes wrapper"
fi

if [ -d "$HOME/.hermes/hermes-agent" ]; then
    log_warn "Removing stale Hermes code directory..."
    rm -rf "$HOME/.hermes/hermes-agent"
fi

# Also nuke any stale ~/.local/bin symlinks pointing inside a non-existent hermes-agent
for f in "$HOME/.local/bin/hermes" "$HOME/.local/bin/node" "$HOME/.local/bin/npm" "$HOME/.local/bin/npx"; do
    if [ -L "$f" ] && [ ! -e "$f" ]; then
        rm -f "$f"
        log_warn "Removed stale symlink: $f"
    fi
done

# ---------------------------------------------------------------------------
# Run the official installer with its defaults
# ---------------------------------------------------------------------------

echo "Installing Hermes Agent (this may take a few minutes)..."

# Pass --skip-setup for fully non-interactive installs
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash -s -- --skip-setup

# Ensure ~/.local/bin is on PATH for future shells
for rc in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    [ -f "$rc" ] || continue
    if ! grep -v '^[[:space:]]*#' "$rc" 2>/dev/null | grep -qE 'PATH=.*\.local/bin'; then
        echo "" >> "$rc"
        echo '# Hermes Setup — ensure ~/.local/bin is on PATH' >> "$rc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
    fi
done

# Verify it worked
export PATH="$HOME/.local/bin:$PATH"
if command -v hermes &>/dev/null && hermes --version &>/dev/null; then
    log_info "Hermes installed ($(hermes --version 2>/dev/null | head -1))"
else
    log_error "Hermes installation failed — try running the installer manually:"
    log_error "  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
    exit 1
fi
