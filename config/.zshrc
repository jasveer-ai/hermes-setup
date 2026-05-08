# ── Homebrew ─────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── Starship prompt ──────────────────────────
eval "$(starship init zsh)"

# ── zsh plugins ──────────────────────────────
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# ── fzf ──────────────────────────────────────
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
source /opt/homebrew/opt/fzf/shell/completion.zsh

# ── ENV ──────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Aliases ──────────────────────────────────
alias ll='ls -la'
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh 2>/dev/null
source /opt/homebrew/opt/fzf/shell/completion.zsh 2>/dev/null
export PATH="$HOME/.hermes/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
