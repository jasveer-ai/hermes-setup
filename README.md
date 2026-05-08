# Hermes Setup

Infrastructure-as-code for provisioning a macOS MacBook as a persistent, fully agentic workspace. Powered by [Hermes Agent](https://github.com/NousResearch/hermes-agent) and [mise](https://mise.jdx.dev/).

## Architecture

```
┌─────────────────────────────────────┐
│         This MacBook                │
│                                     │
│  ┌─────────────────────────────┐    │
│  │       Hermes (Overseer)     │
│  │  Persistent memory & cron   │
│  │  ~/.hermes/SOUL.md          │
│  │  ~/.hermes/MEMORY.md        │
│  │  ~/.hermes/USER.md          │
│  └──────────────┬──────────────┘    │
│                 │                    │
│  ┌──────────────▼──────────────┐    │
│  │    Paperclip (Planned)      │
│  │  Company orchestration      │
│  │  Org charts, budgets, goals │
│  └──────────────┬──────────────┘    │
│                 │                    │
│  ┌──────────────▼──────────────┐    │
│  │     Worker Agents           │
│  │  Claude Code / Codex / etc  │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

## Quick Start

```bash
# 1. Install mise
brew install mise

# 2. Activate mise in your shell (add to ~/.zshrc)
eval "$(mise activate zsh)"

# 3. Clone this repo
git clone https://github.com/jasveer-ai/hermes-setup.git ~/Projects/hermes-setup
cd ~/Projects/hermes-setup

# 4. Run full automated setup (non-interactive)
mise run

# 5. Run interactive one-shot for system credentials
mise run system
```

> **Note:** `mise run` is fully automated and non-interactive. Steps like Git config, SSH keys, and GitHub CLI auth are interactive-only (`mise run system`).

## Commands

Run `mise tasks` to see all available commands.

| Command | What it does |
|---------|--------------|
| `mise run` | Full automated setup (non-interactive: tools, system checks, terminal, hermes, config, cron, power) |
| `mise run system` | **Interactive only** — git config, SSH keys, GitHub CLI auth |
| `mise run config:deploy` | Deploy config files to `~/.hermes/` (preserves existing) |
| `mise run hermes:install` | Install or update Hermes Agent |
| `mise run cron:install` | Install daily memory compaction cron (3am) |
| `hermes setup` | Interactive wizard: API keys, model, messaging |
| `hermes` | Start the agent |

After setup, use `hermes` directly (start, tools, model, gateway) — no wrappers needed.

## Repository Structure

```
hermes-setup/
├── .mise.toml                # mise config — tasks (no env overrides)
├── .hermes → ~/.hermes/      # Symlink to Hermes home (gitignored)
├── LICENSE
├── README.md
├── config/
│   ├── SOUL.md               # Agent personality (always deployed)
│   ├── MEMORY.md             # Agent memory (preserved across deploys)
│   ├── USER.md               # User profile (preserved across deploys)
│   ├── AGENTS.md             # Workspace-wide agent instructions
│   ├── config.yaml           # Hermes configuration
│   ├── wezterm.lua           # WezTerm terminal config
│   └── .env.example          # API key template (never deployed, copy to ~/.hermes/.env)
├── scripts/
│   ├── system.sh             # System: git, ssh, github, tools
│   ├── terminal.sh           # Terminal: WezTerm, Starship, fzf, zsh plugins
│   ├── hermes-install.sh     # Install Hermes Agent (auto-cleans stale state)
│   ├── deploy-config.sh      # Deploy config files to ~/.hermes/
│   ├── cron-install.sh       # Install crontab entries
│   └── power-settings.sh     # Disable sleep (requires sudo)
├── docs/
│   └── HERMES.md             # Hermes Agent usage guide
└── cron/
    └── memory-update.sh      # Daily memory compaction logic
```

## Config Files

Deployment rules (handled by `scripts/deploy-config.sh`):

| Config File | Deployed To | Purpose | Preserved? |
|-------------|-------------|---------|------------|
| `config/SOUL.md` | `~/.hermes/SOUL.md` | Personality/role | **No** (always overwritten) |
| `config/MEMORY.md` | `~/.hermes/MEMORY.md` | Agent notes | Yes |
| `config/USER.md` | `~/.hermes/USER.md` | User profile | Yes |
| `config/AGENTS.md` | `~/AGENTS.md` | Workspace instructions | Yes |
| `config/config.yaml` | `~/.hermes/config.yaml` | Hermes config | Yes |
| `config/wezterm.lua` | `~/.config/wezterm/wezterm.lua` | WezTerm config | **No** |
| `config/.env.example` | *(not deployed)* | API key template | N/A — copy to `~/.hermes/.env` |

## After Setup

```bash
# Configure gateway secrets and API keys
$EDITOR ~/.hermes/.env

# Hermes commands
hermes setup       # Interactive wizard
hermes             # Start the agent
hermes tools       # Review enabled tools
hermes model       # Change the model
hermes gateway setup  # Setup messaging (Telegram, Discord, etc.)
```

## Key Paths

| Path | Purpose |
|------|---------|
| `.hermes/` (in repo) | Symlink to `~/.hermes/` — browse & edit in VSCode |
| `~/.hermes/` | Hermes home — config, memory, skills, sessions, logs |
| `~/.hermes/SOUL.md` | Agent personality |
| `~/.hermes/MEMORY.md` | Persistent agent memory |
| `~/.hermes/USER.md` | User profile |
| `~/.hermes/config.yaml` | Hermes configuration |
| `~/.hermes/.env` | API keys (user-managed, outside git) |
| `~/.hermes/skills/` | Agent skills |
| `~/.hermes/sessions/` | Conversation sessions |
| `~/.hermes/logs/` | Session logs |
| `~/AGENTS.md` | Workspace-wide agent instructions |

## License

MIT — see [LICENSE](LICENSE).
