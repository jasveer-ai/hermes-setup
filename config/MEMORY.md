# Hermes Memory — MacBook Overseer

## Company Vision
- Building a zero-human company for software development, ops, and marketing
- This MacBook is the central hub — all agents operate from here
- Long-term: fully autonomous business that generates revenue without human intervention

## Current Infrastructure
- GitHub account: jasveer-ai (account@example.com)
- SSH key: ~/.ssh/id_ed25519_github (configured for github.com)
- GitHub CLI: authenticated via gh, SSH protocol
- Homebrew: installed at /opt/homebrew
- Hermes Agent: installed at ~/.hermes/hermes-agent
- Paperclip: planned for orchestration layer (not yet installed)

## Tech Stack
- macOS (Apple Silicon)
- Shell: zsh
- Node.js: installed via Hermes (v22.22.2 at ~/.hermes/node/)
- Python: 3.11.15 (managed by uv)
- Git: 2.50.1

## Operating Model
- Hermes is the top-level overseer agent on this MacBook
- Paperclip will serve as the company orchestration layer (managing multiple agents)
- Individual agents (Claude Code, Codex, etc.) will be workers under Paperclip
- All agents should have access to context via AGENTS.md and memory files
- Persistent memory is maintained in ~/.hermes/MEMORY.md and ~/.hermes/USER.md

## Key Directories
- ~/.hermes/ — Hermes config, memory, skills, sessions, logs
- ~/.ssh/ — SSH keys and config
- ~/.zshrc — Shell config (Homebrew PATH added)
- ~/.zprofile — Homebrew shellenv eval added
- ~/Projects/ — Project workspace

## Conventions
- Always update MEMORY.md after significant events or new learnings
- Keep USER.md current with user preferences and communication style
- Use direct, actionable language
- Maintain context continuity across all sessions
- Character limits: MEMORY.md ~2200 chars, USER.md ~1375 chars
