# Hermes Agent — Usage Guide

[Hermes Agent](https://github.com/NousResearch/hermes-agent) is the AI overseer that powers this workspace.

## Quick Start

```bash
# Run interactive setup wizard (API keys, model, messaging)
hermes setup

# Start the agent
hermes

# Stop the agent
Ctrl+C
```

## Configuration

All config lives in `~/.hermes/` (symlinked to `.hermes/` in this repo).

| File | Purpose |
|------|---------|
| `.env` | API keys for LLM providers, messaging, tools |
| `config.yaml` | Agent behavior, model, memory limits, skills |
| `SOUL.md` | Agent personality/role (overwritten on deploy) |
| `MEMORY.md` | Persistent agent memory (preserved) |
| `USER.md` | Your profile (preserved) |

### API Keys

Edit `~/.hermes/.env`:

```bash
$EDITOR ~/.hermes/.env
```

**Required:** at least one LLM provider key.
**Recommended:** [OpenRouter](https://openrouter.ai/keys) — one key for 200+ models.

### Model

```bash
# Interactive model selector
hermes model

# Or edit directly in config.yaml
$EDITOR ~/.hermes/config.yaml
```

Look for the `model.default` field.

## Common Commands

| Command | What it does |
|---------|--------------|
| `hermes` | Start the agent |
| `hermes setup` | Interactive setup wizard |
| `hermes model` | Change the model |
| `hermes tools` | Review enabled tools |
| `hermes config set <key> <value>` | Set a config value |
| `hermes gateway setup` | Setup Telegram, Discord, etc. |

## Tools

Hermes has access to tools that extend its capabilities. Enable/configure them via:

```bash
hermes tools
```

Key tools:
- **Terminal** — run shell commands
- **File system** — read/write files
- **Web search** — requires `EXA_API_KEY`
- **Image generation** — requires `FAL_KEY`
- **Browser automation** — requires `BROWSERBASE_API_KEY`

## Memory System

Hermes maintains persistent memory between sessions:

- **`MEMORY.md`** — facts, notes, context (auto-compacted via cron)
- **`USER.md`** — your preferences and profile

Memory compaction runs daily at 3am (installed by `mise run cron:install`).

```bash
# Run compaction manually
mise run cron:run

# View compaction logs
mise run cron:logs
```

## Cron Jobs

```bash
# Install daily memory compaction (3am)
mise run cron:install
```

Requires **Full Disk Access** for your terminal in System Settings → Privacy & Security.

## Tips

- Run `hermes` with `--max-turns N` to limit conversation length
- Run `hermes` with `--resume` to continue a previous session
- Sessions are stored in `~/.hermes/sessions/`
- Logs are in `~/.hermes/logs/`
