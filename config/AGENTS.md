# AGENTS.md — MacBook Workspace Instructions

This file provides context to any AI agent operating on this MacBook.

## System Overview

This MacBook is the central hub for a zero-human autonomous company. The primary agent is **Hermes** (installed at `~/.hermes/`), which serves as the top-level overseer with persistent memory and cross-session continuity.

## Architecture

```
┌─────────────────────────────────────┐
│         This MacBook                │
│                                     │
│  ┌─────────────────────────────┐    │
│  │       Hermes (Overseer)     │    │
│  │  Persistent memory & cron   │    │
│  │  ~/.hermes/SOUL.md          │    │
│  │  ~/.hermes/MEMORY.md        │    │
│  │  ~/.hermes/USER.md          │    │
│  └──────────────┬──────────────┘    │
│                 │                    │
│  ┌──────────────▼──────────────┐    │
│  │    Paperclip (Planned)      │    │
│  │  Company orchestration      │    │
│  │  Org charts, budgets, goals │    │
│  └──────────────┬──────────────┘    │
│                 │                    │
│  ┌──────────────▼──────────────┐    │
│  │     Worker Agents           │    │
│  │  Claude Code / Codex / etc  │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

## Key Paths

| Path | Purpose |
|------|---------|
| `~/.hermes/SOUL.md` | Hermes personality and role definition |
| `~/.hermes/MEMORY.md` | Hermes persistent memory (agent notes, system state) |
| `~/.hermes/USER.md` | User profile and preferences |
| `~/.hermes/config.yaml` | Hermes configuration |
| `~/.hermes/.env` | API keys and secrets |
| `~/.hermes/skills/` | Agent skills directory |
| `~/.hermes/sessions/` | Conversation sessions |
| `~/.hermes/logs/` | Session logs |
| `~/.ssh/` | SSH keys and config |
| `~/Projects/` | Project workspace |

## Git & GitHub

- SSH key: `~/.ssh/id_ed25519_github` (or your preferred key)
- Protocol: SSH
- CLI: `gh` (authenticated)

## Operating Rules

1. **Read context first** — Check SOUL.md, MEMORY.md, USER.md before acting
2. **Update memory** — After significant actions, update MEMORY.md
3. **Preserve continuity** — Assume no prior conversation context; rely on files
4. **Be proactive** — Surface issues, suggest improvements, don't wait
5. **Script everything** — Manual steps should be captured in scripts
6. **Version control** — All configuration should be in git repos

## Tech Stack

- macOS Apple Silicon
- zsh (default shell)
- Homebrew: `/opt/homebrew`
- mise: environment management (`~/.mise.toml`)
- Node.js: v22 (mise-managed)
- Python: 3.11 (mise-managed)

## Addons (scripts/addons/)

| Addon | What it does | Run with |
|-------|-------------|----------|
| `web-search.sh` | Free DuckDuckGo web search (ddgs CLI) | `mise run addons:web-search` |
| `browser.sh` | Playwright browser automation (Chromium) | `mise run addons:browser` |
| `voice.sh` | Free Edge TTS (`hermes-speak`) | `mise run addons:voice` |
| `image-gen.sh` | Local image gen via MLX | `mise run addons:image-gen` |
| `mcp-servers.sh` | MCP integrations (GitHub, filesystem) | `mise run addons:mcp` |
| `enable-all.sh` | Enable all toolsets + max settings | `mise run addons:enable-all` |

Run all at once: `mise run addons:all`

## Hermes Tools

| Tool | Location | Usage |
|------|----------|-------|
| `hermes-browser` | `~/.hermes/bin/` | Playwright browser automation |
| `hermes-speak` | `~/.hermes/bin/` | Free TTS via Edge |
| `hermes-image-gen` | `~/.hermes/bin/` | Local image gen (MLX) |
| `chrome-cdp` | `~/.hermes/bin/` | Chrome CDP launcher |
| `hermes-playwright-run` | `~/.hermes/bin/` | Run custom Playwright scripts |

## Web Search

DuckDuckGo free search:
```bash
ddgs text -q "your query" -m 5        # text search
ddgs news -q "your query" -m 5        # news search
```

## Browser

Playwright-based browser automation:
```bash
hermes-browser search "query"          # Google search
hermes-browser extract https://url     # Extract page text
hermes-browser screenshot url out.png  # Screenshot
hermes-browser pdf url out.pdf         # Save as PDF
hermes-browser interactive             # Visible browser
hermes-browser script script.py        # Custom Playwright script
```

## Cron Jobs

- Daily at 3am: Memory compaction (`~/.hermes/cron/memory-update.sh`)
