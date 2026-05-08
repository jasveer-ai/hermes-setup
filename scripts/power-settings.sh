#!/bin/bash
set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo "── Power Settings ──"

# pmset requires root; suppress stderr when run without sudo
if ! pmset -a sleep 0 2>/dev/null; then
    log_warn "pmset requires root — skipping power settings (run with sudo if desired)"
    exit 0
fi

pmset -a disksleep 0
pmset -a displaysleep 0
pmset -a hibernatemode 0
pmset -a powernap 0

log_info "Sleep disabled (AC + battery)"
log_info "Display sleep disabled"
log_info "Hibernation disabled"

# Show current settings
echo ""
echo "Current power settings:"
pmset -g | grep -E "sleep|displaysleep|hibernatemode|powernap"
