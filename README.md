# Hermes MacBook Overseer

Infrastructure-as-code setup for a top-level Hermes agent running on macOS. This MacBook is the central hub for a zero-human autonomous company.

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

- **Hermes**: Persistent agent with memory, cron, skills, and cross-session continuity
- **Paperclip** (planned): Multi-agent orchestration with org charts, budgets, goals
- **Worker Agents**: Claude Code, Codex, and other specialized agents

## Quick Start

```bash
# Clone the repo
git clone https://github.com/jasveer-ai/hermes-setup.git ~/Projects/hermes-setup
cd ~/Projects/hermes-setup

# Run the setup script
./setup.sh
```

The setup script handles:

1. Homebrew (required)
2. System tools (ripgrep, ffmpeg)
3. Git configuration
4. SSH key generation and GitHub setup
5. GitHub CLI authentication
6. Hermes Agent installation
7. Deployment of all config files (SOUL.md, MEMORY.md, USER.md, AGENTS.md, config.yaml, .env)
8. API key configuration
9. Cron job for daily memory compaction

## Repository Structure

```
hermes-setup/
├── setup.sh                  # Main setup script — run this once
├── README.md                 # This file
├── config/
│   ├── SOUL.md               # Agent personality and role definition
│   ├── MEMORY.md             # Agent memory (system state, conventions)
│   ├── USER.md               # User profile and preferences
│   ├── AGENTS.md             # Workspace-wide agent instructions
│   ├── config.yaml           # Hermes configuration (model, tools, display)
│   └── .env.example          # API key template (copy to ~/.hermes/.env)
├── scripts/
│   └── deploy-config.sh      # Deploy config files to ~/.hermes/ (rerun after edits)
└── cron/
    └── memory-update.sh      # Daily memory compaction job (runs at 3am)
```

## Memory System

Hermes maintains persistent memory across sessions via three files:

| File | Deployed To | Purpose | Limit |
|------|-------------|---------|-------|
| `config/SOUL.md` | `~/.hermes/SOUL.md` | Personality and role | N/A |
| `config/MEMORY.md` | `~/.hermes/MEMORY.md` | Agent notes, system state | ~2200 chars |
| `config/USER.md` | `~/.hermes/USER.md` | User profile and preferences | ~1375 chars |
| `config/AGENTS.md` | `~/AGENTS.md` | Workspace-wide instructions | N/A |

A cron job runs daily at 3am to compact memory if it exceeds limits.

## Configuration

### API Keys

Copy and edit the `.env` file:

```bash
cp config/.env.example ~/.hermes/.env
```

At minimum, set your LLM provider key:

```env
OPENROUTER_API_KEY=your-key-here
```

Get a key at https://openrouter.ai/settings/keys

### Model Selection

```bash
# Interactive setup
hermes setup

# Or set directly
hermes config set model.provider openrouter
hermes config set model.default anthropic/claude-sonnet-4-20250514
```

### Hermes Config

Edit `~/.hermes/config.yaml` or use CLI:

```bash
hermes config          # View current config
hermes config set <key> <value>  # Set a value
hermes tools           # Review enabled tools
hermes model           # Change the model
```

## After Setup

```bash
# Start chatting with your overseer
hermes

# Review enabled tools
hermes tools

# Start the messaging gateway (Telegram, Discord, etc.)
hermes gateway setup
```

## Updating Config

After editing files in this repo, redeploy to `~/.hermes/`:

```bash
# Deploy all config files (preserves existing memory)
./scripts/deploy-config.sh

# Or manually
cp config/SOUL.md ~/.hermes/SOUL.md
cp config/MEMORY.md ~/.hermes/MEMORY.md
cp config/USER.md ~/.hermes/USER.md
```

Note: MEMORY.md and USER.md are **not** overwritten by deploy if they already exist, to preserve accumulated memory. SOUL.md is always overwritten since it defines personality, not memory.

## Key Paths

| Path | Purpose |
|------|---------|
| `~/.hermes/` | Hermes home — config, memory, skills, sessions, logs |
| `~/.hermes/SOUL.md` | Agent personality (redeployed on every deploy) |
| `~/.hermes/MEMORY.md` | Persistent agent memory (preserved across deploys) |
| `~/.hermes/USER.md` | User profile (preserved across deploys) |
| `~/.hermes/config.yaml` | Hermes configuration |
| `~/.hermes/.env` | API keys and secrets |
| `~/.hermes/skills/` | Agent skills directory |
| `~/.hermes/sessions/` | Conversation sessions |
| `~/.hermes/logs/` | Session logs |
| `~/.hermes/cron/` | Cron job scripts |
| `~/.ssh/id_ed25519_github` | GitHub SSH key |
| `~/AGENTS.md` | Workspace-wide agent instructions |
| `~/Projects/` | Project workspace |
