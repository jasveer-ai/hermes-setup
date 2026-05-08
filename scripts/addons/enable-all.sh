#!/usr/bin/env bash
set -euo pipefail

echo "==> Enabling all Hermes toolsets and capabilities..."

hermes config set platform_toolsets.cli    '["hermes-cli","web","vision","image_gen","tts","browser","browser-cdp","code_execution","delegation","cronjob","skills","memory","session_search","moa","messaging"]'
hermes config set tts.provider             edge
hermes config set delegation.max_iterations 100
hermes config set delegation.max_concurrency 5
hermes config set code_execution.timeout   300
hermes config set code_execution.max_tool_calls 50
hermes config set cron.enabled             true
hermes config set agent.max_turns          120
hermes config set agent.max_tool_rounds    200
hermes config set memory.memory_char_limit 10000
hermes config set memory.user_char_limit   5000
hermes config set memory.nudge_interval    10
hermes config set memory.flush_min_turns   6
hermes config set skills.creation_nudge_interval 15
hermes config set approvals.mode           smart

echo ""
echo "  ✓ Toolsets enabled: web, vision, image_gen, tts, browser, browser-cdp, code_execution"
echo "  ✓ Toolsets: delegation, cronjob, skills, memory, session_search, moa, messaging"
echo "  ✓ Max turns: 120 | Memory: 10k/5k | Delegation: 5 concurrent"
echo "  ✓ TTS: edge | Cron: enabled | Approvals: smart mode"
echo ""
echo "==> Run 'hermes config show' to verify."
echo ""
echo "Remaining addons to unlock everything:"
echo "  ./scripts/addons/web-search.sh   (web search)"
echo "  ./scripts/addons/browser.sh       (Playwright browser)"
echo "  ./scripts/addons/voice.sh         (TTS)"
echo "  ./scripts/addons/image-gen.sh     (image gen)"
echo "  ./scripts/addons/mcp-servers.sh   (MCP)"
