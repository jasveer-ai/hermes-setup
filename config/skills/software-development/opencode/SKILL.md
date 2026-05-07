---
name: opencode
description: "Use OpenCode CLI for AI-assisted software engineering on projects."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [coding, opencode, development, projects, ide]
    related_skills: [subagent-driven-development, writing-plans, test-driven-development]
platforms: [macos, linux]
---

# OpenCode CLI Integration

## Overview

OpenCode is an AI coding agent that operates inside project directories. It can read, write, edit, and refactor code, run tests, execute commands, and manage git operations. Use it when you need to make changes to projects in `~/Projects/`.

## Key Commands

### Run in a project (non-interactive)
```bash
opencode run --dir ~/Projects/<project> "<instruction>"
```
This tells OpenCode to execute a specific instruction and exit. Best for targeted tasks.

### Run with TUI (interactive)
```bash
opencode ~/Projects/<project>
```
Opens the full TUI. Only use this for the initial `terminal` tool call — after that the user interacts directly.

### Attach to a running server
```bash
opencode attach <url>
```

### GitHub PR workflow
```bash
opencode pr <number>
```
Fetches and checks out a PR branch, then runs OpenCode.

### Plugin management
```bash
opencode plugin <module>
```

## Usage Guidelines

### When to use OpenCode vs built-in tools
- **Use OpenCode for**: Complex multi-file refactors, running project-specific tests, installing dependencies, git operations, any task that needs the project's full context
- **Use built-in tools for**: Quick file reads/writes, simple edits, searching code

### How to delegate work
1. First understand what needs to be done
2. Formulate a clear, specific instruction
3. Run `opencode run --dir <project> "<instruction>"`
4. Review the output and verify
5. If changes are needed, give follow-up instructions

### Best practices
- Always specify the full project path
- Keep instructions focused and atomic — one task per call
- Let OpenCode handle its own context window; don't try to pre-digest files for it
- Use `opencode run` (not TUI) when delegating from Hermes — it's non-interactive and returns results
- After OpenCode finishes, verify the changes with built-in tools if needed
