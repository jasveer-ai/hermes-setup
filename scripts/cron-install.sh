#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="$HOME/.hermes"

echo "── Cron Jobs ──"

mkdir -p "$HERMES_HOME/cron"

# Copy cron scripts into hermes home
cp "$SCRIPT_DIR/../cron/memory-update.sh" "$HERMES_HOME/cron/"
chmod +x "$HERMES_HOME/cron/memory-update.sh"

CRON_LABEL="hermes-memory-compaction"

# Remove existing entry
crontab -l 2>/dev/null | grep -v "$CRON_LABEL" | crontab - || true

# Add new entry — daily at 3am
(crontab -l 2>/dev/null | grep -v "$CRON_LABEL"
echo "0 3 * * * $HERMES_HOME/cron/memory-update.sh >> $HERMES_HOME/logs/cron-memory.log 2>&1 # $CRON_LABEL") | crontab - 2>/dev/null || {
    log_warn "crontab not available — skipping"
    exit 0
}

log_info "Daily memory compaction installed (3am)"
