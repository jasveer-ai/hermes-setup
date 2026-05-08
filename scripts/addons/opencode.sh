#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing OpenCode integration ==="

SCRIPT_SRC="$(dirname "$0")/../../bin/hermes-opencode"
SCRIPT_DST="$HOME/.hermes/bin/hermes-opencode"

if [ -f "$SCRIPT_SRC" ]; then
  cp "$SCRIPT_SRC" "$SCRIPT_DST"
else
  echo "Error: hermes-opencode script not found at $SCRIPT_SRC"
  exit 1
fi
chmod +x "$SCRIPT_DST"

echo "✅ hermes-opencode installed to $SCRIPT_DST"
echo ""
echo "Start the server:  hermes-opencode start"
echo "Check status:      hermes-opencode status"
echo "Send a task:       hermes-opencode run 'your task description'"
echo "List sessions:     hermes-opencode sessions"
echo "Stop the server:   hermes-opencode stop"
echo ""
echo "Then tell Hermes: 'use opencode to [your task]'"
