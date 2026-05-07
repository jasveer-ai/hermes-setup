# Hermes Memory

## Company Vision
- Building a zero-human autonomous company for software development, ops, and marketing
- This MacBook is the central hub — all agents operate from here
- Long-term: fully autonomous business that generates revenue without human intervention

## Current Infrastructure
- GitHub account: configured with SSH and gh CLI
- Homebrew: installed at /opt/homebrew
- Hermes Agent: installed at ~/.hermes/
- mise: environment and tool management

## Tech Stack
- macOS (Apple Silicon)
- Shell: zsh
- Node.js: v22 (mise-managed)
- Python: 3.11 (mise-managed)
- mise: tool version pinning and task routing

## Operating Model
- Hermes is the top-level overseer agent on this MacBook
- All agents should have access to context via AGENTS.md and memory files
- Persistent memory is maintained in ~/.hermes/MEMORY.md and ~/.hermes/USER.md
- Daily cron at 3am compacts memory files to stay within limits

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
