#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)"
HERMES_HOME="$HOME/.hermes"

echo "── Deploying Config ──"

# Create ~/.hermes if missing
mkdir -p "$HERMES_HOME"

# Create repo-level symlink for VSCode visibility
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ! -L "$REPO_ROOT/.hermes" ]]; then
    ln -sf "$HERMES_HOME" "$REPO_ROOT/.hermes"
    log_info "Symlink created: .hermes → $HERMES_HOME"
fi

# SOUL.md — always deploy (personality, not memory)
cp "$CONFIG_DIR/SOUL.md" "$HERMES_HOME/SOUL.md"
log_info "SOUL.md deployed"

# MEMORY.md — preserve if exists
if [[ -f "$CONFIG_DIR/MEMORY.md" ]]; then
    if [[ ! -f "$HERMES_HOME/MEMORY.md" ]]; then
        cp "$CONFIG_DIR/MEMORY.md" "$HERMES_HOME/MEMORY.md"
        log_info "MEMORY.md deployed (new)"
    else
        log_warn "MEMORY.md exists — preserved"
    fi
fi

# USER.md — preserve if exists
if [[ -f "$CONFIG_DIR/USER.md" ]]; then
    if [[ ! -f "$HERMES_HOME/USER.md" ]]; then
        cp "$CONFIG_DIR/USER.md" "$HERMES_HOME/USER.md"
        log_info "USER.md deployed (new)"
    else
        log_warn "USER.md exists — preserved"
    fi
fi

# AGENTS.md — deploy to home
if [[ -f "$CONFIG_DIR/AGENTS.md" ]]; then
    if [[ ! -f "$HOME/AGENTS.md" ]]; then
        cp "$CONFIG_DIR/AGENTS.md" "$HOME/AGENTS.md"
        log_info "AGENTS.md deployed to $HOME/"
    else
        log_warn "AGENTS.md at home exists — preserved"
    fi
fi

# config.yaml
if [[ -f "$CONFIG_DIR/config.yaml" ]]; then
    if [[ ! -f "$HERMES_HOME/config.yaml" ]]; then
        cp "$CONFIG_DIR/config.yaml" "$HERMES_HOME/config.yaml"
        log_info "config.yaml deployed"
    else
        log_warn "config.yaml exists — preserved"
    fi
fi

# Skills — deploy all to ~/.hermes/skills/
SKILLS_SRC="$CONFIG_DIR/skills"
if [[ -d "$SKILLS_SRC" ]]; then
    find "$SKILLS_SRC" -name 'SKILL.md' | while read -r skill_file; do
        rel_path="${skill_file#$SKILLS_SRC/}"
        dst="$HERMES_HOME/skills/$rel_path"
        mkdir -p "$(dirname "$dst")"
        cp "$skill_file" "$dst"
        log_info "Skill deployed: $rel_path"
    done
fi

# .env from template
if [[ -f "$CONFIG_DIR/.env.example" ]]; then
    if [[ ! -f "$HERMES_HOME/.env" ]]; then
        cp "$CONFIG_DIR/.env.example" "$HERMES_HOME/.env"
        log_info ".env deployed — edit with your API keys"
    else
        log_warn ".env exists — preserved"
    fi
fi
