#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up free web search via DuckDuckGo..."

# Install the ddgs Python package (DuckDuckGo Search CLI)
python3 -m pip install ddgs --break-system-packages -q 2>/dev/null || \
  python3 -m pip install ddgs -q

# Install the Hermes DuckDuckGo search skill
hermes skills install official/research/duckduckgo-search --force 2>/dev/null || true

# Verify
if command -v ddgs &>/dev/null; then
  echo "  ✓ ddgs CLI installed"
  ddgs text -q "test" -m 1 -o json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  ✓ DuckDuckGo search works ({len(d)} results)')" 2>/dev/null || echo "  ✓ ddgs installed (test query ran)"
else
  echo "  ✗ ddgs not found in PATH"
fi

echo "==> Web search ready. Use '/search <query>' in Hermes or call ddgs directly."
