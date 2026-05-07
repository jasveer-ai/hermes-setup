#!/bin/bash
set -euo pipefail

# Hermes Memory Compaction Cron Job
# Runs daily to ensure MEMORY.md and USER.md are concise and up-to-date
# This script triggers Hermes to review and consolidate its memory

HERMES_HOME="$HOME/.hermes"
MEMORY_FILE="$HERMES_HOME/MEMORY.md"
USER_FILE="$HERMES_HOME/USER.md"
LOG_FILE="$HERMES_HOME/logs/cron-memory.log"

mkdir -p "$HERMES_HOME/logs"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Memory compaction started" >> "$LOG_FILE"

# Check if memory files exist
if [[ ! -f "$MEMORY_FILE" ]]; then
    echo "[$(date)] MEMORY.md not found, skipping" >> "$LOG_FILE"
    exit 0
fi

# Check memory file size — if over 4000 chars, trigger compaction via Hermes
CHAR_COUNT=$(wc -c < "$MEMORY_FILE" 2>/dev/null || echo "0")

if [[ "$CHAR_COUNT" -gt 4000 ]]; then
    echo "[$(date)] MEMORY.md is ${CHAR_COUNT} chars (over 4000 limit), triggering compaction" >> "$LOG_FILE"
    
    # Use Hermes to compact memory — send a message asking it to consolidate
    if command -v hermes &>/dev/null; then
        hermes --message "Review MEMORY.md and consolidate. Keep only the most important facts, remove duplicates, and compress verbose entries. Stay under 2200 characters. Do the same for USER.md if it exists, keeping it under 1375 characters." --max-turns 10 2>> "$LOG_FILE"
        echo "[$(date)] Compaction complete" >> "$LOG_FILE"
    else
        echo "[$(date)] Hermes not found, skipping compaction" >> "$LOG_FILE"
    fi
else
    echo "[$(date)] MEMORY.md is ${CHAR_COUNT} chars — within limits, no compaction needed" >> "$LOG_FILE"
fi

echo "[$(date)] Memory compaction finished" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
