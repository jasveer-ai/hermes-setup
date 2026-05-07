# Hermes Setup

Infrastructure-as-code for provisioning a macOS MacBook as a persistent, fully agentic workspace. Powered by [Hermes Agent](https://github.com/NousResearch/hermes-agent) and [mise](https://mise.jdx.dev/).

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

## Prerequisites

- macOS (Apple Silicon)
- Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

## Quick Start

```bash
# 1. Install mise
brew install mise

# 2. Activate mise in your shell (add to ~/.zshrc)
eval "$(mise activate zsh)"

# 3. Clone this repo
git clone https://github.com/jasveer-ai/hermes-setup.git ~/Projects/hermes-setup
cd ~/Projects/hermes-setup

# 4. Install tool versions
mise install

# 5. Run full setup
mise run
```

## Tasks

Run `mise tasks ls` for the full list.

| Task | Description |
|------|-------------|
| `mise` | Full setup — system, hermes, config, cron |
| `mise run system` | System prerequisites (git, ssh, github, tools) |
| `mise run hermes:install` | Install Hermes Agent |
| `mise run hermes:setup` | Interactive Hermes setup wizard |
| `mise run hermes:start` | Start Hermes agent |
| `mise run hermes:tools` | Review enabled tools |
| `mise run hermes:model` | Change the model |
| `mise run hermes:gateway` | Setup messaging gateway |
| `mise run config:deploy` | Deploy config files to `~/.hermes/` |
| `mise run config:edit-env` | Edit API keys in `~/.hermes/.env` |
| `mise run config:edit-yaml` | Edit `~/.hermes/config.yaml` |
| `mise run cron:install` | Install daily memory compaction cron |
| `mise run cron:run` | Run memory compaction manually |
| `mise run cron:logs` | View cron logs |

## Repository Structure

```
hermes-setup/
├── .mise.toml                # mise config — tools, env, tasks
├── LICENSE                   # MIT License
├── README.md                 # This file
├── config/
│   ├── SOUL.md               # Agent personality (always deployed)
│   ├── MEMORY.md             # Agent memory (preserved across deploys)
│   ├── USER.md               # User profile (preserved across deploys)
│   ├── AGENTS.md             # Workspace-wide agent instructions
│   ├── config.yaml           # Hermes configuration
│   ├── wezterm.lua           # WezTerm terminal config
│   └── .env.example          # API key template
├── scripts/
│   ├── system.sh             # System: git, ssh, github, tools
│   ├── terminal.sh           # Terminal: WezTerm, Starship, fzf, zsh plugins
│   ├── hermes-install.sh     # Install Hermes Agent
│   ├── deploy-config.sh      # Deploy config files to ~/.hermes/
│   └── cron-install.sh       # Install crontab entries
└── cron/
    └── memory-update.sh      # Daily memory compaction logic
```

## Config Files

| Config File | Deployed To | Purpose | Preserved? |
|-------------|-------------|---------|------------|
| `config/SOUL.md` | `~/.hermes/SOUL.md` | Personality/role | No (always overwritten) |
| `config/MEMORY.md` | `~/.hermes/MEMORY.md` | Agent notes | Yes |
| `config/USER.md` | `~/.hermes/USER.md` | User profile | Yes |
| `config/AGENTS.md` | `~/AGENTS.md` | Workspace instructions | Yes |
| `config/config.yaml` | `~/.hermes/config.yaml` | Hermes config | Yes |
| `config/wezterm.lua` | `~/.config/wezterm/wezterm.lua` | WezTerm terminal config | No (always overwritten) |
| `config/.env.example` | `~/.hermes/.env` | API keys | Yes |

## After Setup

```bash
# Set your API key
cp config/.env.example ~/.hermes/.env
$EDITOR ~/.hermes/.env

# Or use the interactive wizard
mise run hermes:setup

# Start the agent
mise run hermes:start

# Review tools
mise run hermes:tools

# Setup messaging (Telegram, Discord, etc.)
mise run hermes:gateway
```

## Key Paths

| Path | Purpose |
|------|---------|
| `~/.hermes/` | Hermes home — config, memory, skills, sessions, logs |
| `~/.hermes/SOUL.md` | Agent personality |
| `~/.hermes/MEMORY.md` | Persistent agent memory |
| `~/.hermes/USER.md` | User profile |
| `~/.hermes/config.yaml` | Hermes configuration |
| `~/.hermes/.env` | API keys |
| `~/.hermes/skills/` | Agent skills |
| `~/.hermes/sessions/` | Conversation sessions |
| `~/.hermes/logs/` | Session logs |
| `~/AGENTS.md` | Workspace-wide agent instructions |
| `~/Projects/` | Project workspace |

## License

MIT — see [LICENSE](LICENSE).
