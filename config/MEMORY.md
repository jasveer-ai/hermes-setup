# Hermes Memory

## Company Vision
- Building a zero-human autonomous company for software development, ops, and marketing
- This MacBook is the central hub — all agents operate from here
- Long-term: fully autonomous business that generates revenue without human intervention

## Current Infrastructure
- GitHub account: configured with SSH and gh CLI
- Homebrew: installed at /opt/homebrew
- Hermes Agent: v0.12.0 at ~/.hermes/
- mise: environment and tool management
- Ollama: v0.23.1 (Homebrew), manages local LLMs at http://localhost:11434

## Tech Stack
- macOS (Apple Silicon, 18GB RAM)
- Shell: zsh
- Node.js: v22 (mise-managed)
- Python: 3.11 (mise-managed)
- mise: tool version pinning and task routing
- Local AI: models run via Ollama (qwen3-vl:8b-instruct-q4_K_M for chat + vision)

## Operating Model
- Hermes is the top-level overseer agent on this MacBook
- All agents should have access to context via AGENTS.md and memory files
- Persistent memory is maintained in ~/.hermes/MEMORY.md and ~/.hermes/USER.md
- Daily cron at 3am compacts memory files to stay within limits
- Default chat model: local Ollama; fallback: OpenRouter (kimi-k2.6)

## Operational Notes & Known Issues

### Running Hermes with Local Ollama Models
- **Provider must be "custom"** for any OpenAI-compatible local endpoint (Ollama, vLLM, llama.cpp)
- **context_length must be manually set** in config.yaml. Hermes enforces a 64K minimum. Check `ollama show <model>` for the model's max context and set `model.context_length` to that value.
- **Use `hermes config set`** to update model settings (direct file edits may not take effect if the config writer caches values; fall back to direct YAML edit if CLI command doesn't persist)

### Model Management
- `ollama list` — show installed models
- `ollama pull <name>` — download a model
- `ollama rm <name>` — remove a model
- Available: qwen3-vl:8b-instruct-q4_K_M (6.1GB, 262K context, vision-capable)

### RAM Constraints (18GB total)
- 30B+ parameter models (e.g. qwen3-coder:30b, ~18GB) exceed available RAM and are not usable
- 8B models (6GB) fit comfortably alongside macOS
- 14B models may fit with memory pressure

### Config Locations
- Repo source of truth: `hermes-setup/config/config.yaml`
- Active config: `~/.hermes/config.yaml` (deployed via `mise run config:deploy` but deploy script preserves existing files)
- Deploy overwrites none of these: config.yaml, .env, MEMORY.md, USER.md (all preserved if they exist)

### BlueBubbles iMessage Gateway
- **Purpose**: Always-on bidirectional iMessage integration via BlueBubbles REST API + webhooks
- **Server**: BlueBubbles v1.9.9 runs locally on port 1234 (`brew install --cask bluebubbles`)
- **Auth**: Password via query param `?password=...` (not Bearer header). Stored in `BLUEBUBBLES_PASSWORD` in `.env`
- **iMessage Account**: Apple ID configured in .env
- **Known Chat**: chat GUID configured in .env
- **Gateway Adapter**: Bundled at `hermes-agent/gateway/platforms/bluebubbles.py` — no custom code needed
- **Detected by env vars**: `BLUEBUBBLES_SERVER_URL` + `BLUEBUBBLES_PASSWORD` both set → platform auto-enabled
- **Authorization**: Set `GATEWAY_ALLOW_ALL_USERS=true` in `.env` to allow all incoming messages
- **Model**: `gemma4:e4b` via Ollama (9.6GB, 131K ctx, supports tools + vision)

### IPv6 Webhook Fix (Critical)
- **Problem**: BlueBubbles server resolves `localhost` to IPv6 `::1`. Default webhook host `127.0.0.1` only listens on IPv4. Webhook dispatch fails with `ECONNREFUSED ::1:8645`.
- **Fix**: Set `BLUEBUBBLES_WEBHOOK_HOST=::` in `.env` so the gateway webhook listens on IPv6 loopback
- BlueBubbles server log at `~/Library/Logs/bluebubbles-server/main.log` confirmed the exact error

### BlueBubbles Limitations (No SIP Disable)
- `private_api=false, helper_connected=false` — typing indicators, read receipts, new-chat-creation unavailable
- Basic send/receive works via standard API (AppleScript fallback)
- Messages from the user's own Apple ID (`isFromMe=true`) are filtered by the webhook handler — cannot message self
- To message Hermes: send FROM another account TO the configured Apple ID

### Hermes Gateway Troubleshooting
- **`HERMES_HOME=~/.hermes` (literal tilde) breaks `.env` loading**: `Path('~/.hermes')` doesn't expand `~`, so `~/.hermes/.env` is never found→platforms never enabled. Fix: `unset HERMES_HOME` or use expanded path `/Users/jazz.ai/.hermes`
- **Gateway log**: `~/.hermes/logs/gateway.log` and `gateway.error.log`
- **Webhook test**: `curl -X POST "http://127.0.0.1:8645/bluebubbles-webhook?password=..."` with JSON payload to simulate an incoming message

## Key Directories
- ~/.hermes/ — Hermes config, memory, skills, sessions, logs
- ~/.ssh/ — SSH keys and config
- ~/Projects/ — Project workspace

## Conventions
- Always update MEMORY.md after significant events or new learnings
- Keep USER.md current with user preferences and communication style
- Use direct, actionable language
- Maintain context continuity across all sessions
- Character limits: MEMORY.md ~2200 chars, USER.md ~1375 chars
