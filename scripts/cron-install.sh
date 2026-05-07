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
CRON_JOB="0 3 * * * $HERMES_HOME/cron/memory-update.sh >> $HERMES_HOME/logs/cron-memory.log 2>&1 # $CRON_LABEL"

# Build new crontab (existing entries minus ours, plus new job)
CRONTAB_TMP=$(mktemp)
crontab -l 2>/dev/null | grep -v "$CRON_LABEL" > "$CRONTAB_TMP" || true
echo "$CRON_JOB" >> "$CRONTAB_TMP"

# Install with timeout — macOS permission prompt can hang indefinitely
INSTALL_OK=1
(crontab "$CRONTAB_TMP" 2>/dev/null) &
CMD_PID=$!
sleep 3 && kill "$CMD_PID" 2>/dev/null &
wait "$CMD_PID" 2>/dev/null || INSTALL_OK=0
rm -f "$CRONTAB_TMP"

if (( INSTALL_OK )); then
    log_info "Daily memory compaction installed (3am)"
else
    log_warn "crontab not available — skipping (grant Full Disk Access in System Settings)"
fi
