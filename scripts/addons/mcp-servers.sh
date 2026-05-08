#!/usr/bin/env bash
set -euo pipefail

echo "==> Adding MCP servers to Hermes config..."

if ! command -v npx &>/dev/null; then
  echo "  npx not found. Install Node.js: mise install node@22"
  exit 1
fi

# Add MCP servers via hermes config set (YAML path)
# Each MCP server is added under mcp_servers.<name>
hermes config set mcp_servers.filesystem.command "npx"
hermes config set mcp_servers.filesystem.args    '["-y", "@modelcontextprotocol/server-filesystem", "/Users/jazz-ai/Projects", "/Users/jazz-ai/Desktop"]'
hermes config set mcp_servers.filesystem.enabled true
hermes config set mcp_servers.fetch.command      "npx"
hermes config set mcp_servers.fetch.args         '["-y", "@mcp-docs/server-fetch"]'
hermes config set mcp_servers.fetch.enabled      false

echo "  ✓ MCP servers added: filesystem (enabled), fetch (disabled)"
echo ""
echo "==> Restart Hermes or run '/reload-mcp' to load servers."
echo ""
echo "To add GitHub MCP:"
echo "  1. Set GITHUB_TOKEN in ~/.hermes/.env"
echo "  2. hermes config set mcp_servers.github.command npx"
echo '  3. hermes config set mcp_servers.github.args \'["-y", "@modelcontextprotocol/server-github"]\'
echo "  4. hermes config set mcp_servers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN \${GITHUB_TOKEN}"
