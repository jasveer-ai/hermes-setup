# Hermes MacBook Overseer Setup

Infrastructure-as-code setup for a top-level Hermes agent running on macOS. This MacBook is the central hub for a zero-human autonomous company.

## Architecture

```
Hermes (Overseer) ─→ Paperclip (Company Orchestration) ─→ Worker Agents
```

- **Hermes**: Persistent agent with memory, cron, skills, and cross-session continuity
- **Paperclip** (planned): Multi-agent orchestration with org charts, budgets, goals
- **Worker Agents**: Claude Code, Codex, and other specialized agents

## Quick Start

```bash
# 1. Clone the repo
git clone <your-repo-url> ~/Projects/hermes-setup
cd ~/Projects/hermes-setup

# 2. Run the setup script
./setup.sh
```

The setup script handles:
1. System prerequisites (Homebrew, ripgrep, ffmpeg)
2. Git configuration
3. SSH key generation and GitHub setup
4. GitHub CLI authentication
5. Hermes Agent installation
6. Deployment of SOUL.md, MEMORY.md, USER.md, AGENTS.md
7. API key configuration
8. Cron job for daily memory compaction

## Repository Structure

```
hermes-setup/
├── setup.sh                  # Main setup script (run this)
├── config/
│   ├── SOUL.md               # Agent personality and role
│   ├── MEMORY.md             # Agent memory template
│   ├── USER.md               # User profile and preferences
│   ├── AGENTS.md             # Workspace-wide agent instructions
│   ├── config.yaml           # Hermes configuration
│   └── .env.example          # API key template
├── scripts/                  # Individual setup scripts
└── cron/
    └── memory-update.sh      # Daily memory compaction job
```

## Memory System

Hermes maintains persistent memory across sessions via three files:

| File | Purpose | Limit |
|------|---------|-------|
| `~/.hermes/SOUL.md` | Personality and role | N/A |
| `~/.hermes/MEMORY.md` | Agent notes, system state | ~2200 chars |
| `~/.hermes/USER.md` | User profile and preferences | ~1375 chars |

A cron job runs daily at 3am to compact memory if it exceeds limits.

## After Setup

```bash
# Start chatting with your overseer
hermes

# Interactive configuration
hermes setup

# Review enabled tools
hermes tools

# Change the model
hermes model

# Start the messaging gateway (Telegram, Discord, etc.)
hermes gateway setup
```

## Updating

After modifying any config files in this repo:

```bash
# Redeploy config to ~/.hermes/
./scripts/deploy-config.sh

# Or manually
cp config/SOUL.md ~/.hermes/SOUL.md
cp config/MEMORY.md ~/.hermes/MEMORY.md
cp config/USER.md ~/.hermes/USER.md
```

## API Keys

Get an OpenRouter key at https://openrouter.ai/settings/keys

Edit `~/.hermes/.env` after setup:

```env
OPENROUTER_API_KEY=your-key-here
```
