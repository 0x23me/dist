#!/usr/bin/env bash

CONFIG_DIR="/etc/ss"
ALIASES_FILE="$CONFIG_DIR/aliases.sh"
ZSHRC_BASE="$CONFIG_DIR/zshrc.base"

install_starship() {
    if has_cmd starship; then
        return 0
    fi

    info "Installing starship..."
    curl -sS https://starship.rs/install.sh 2>/dev/null | sh -s -- -y >/dev/null 2>&1
}

setup_shared_configs() {
    mkdir -p "$CONFIG_DIR"

    if [[ ! -f "$ALIASES_FILE" ]]; then
        cat > "$ALIASES_FILE" << 'EOF'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ls improvements (eza)
alias ls='eza'
alias ll='eza -la --group-directories-first'
alias la='eza -a'
alias l='eza'
alias tree='eza --tree'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# grep colors
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System monitoring
alias top='htop'
alias ports='ss -tulanp'
alias mem='free -h'
alias disk='df -h'

# Docker shortcuts
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dimg='docker images'
alias dlog='docker logs -f'
alias dexec='docker exec -it'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

# tmux
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux list-sessions'

# Quick edit
alias zshrc='${EDITOR:-vim} ~/.zshrc'
alias reload='source ~/.zshrc'
EOF
    fi

    if [[ ! -d "$CONFIG_DIR/zsh-autosuggestions" ]]; then
        info "Installing zsh-autosuggestions..."
        git clone --quiet --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$CONFIG_DIR/zsh-autosuggestions" 2>/dev/null
    fi

    if [[ ! -f "$ZSHRC_BASE" ]]; then
        cat > "$ZSHRC_BASE" << 'EOF'

# ===== History Configuration =====
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt EXTENDED_HISTORY

# ===== Directory Options =====
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ===== Completion =====
autoload -Uz compinit
compinit -d ~/.zcompdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# ===== Key Bindings =====
bindkey -e  # Emacs mode
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# ===== Path =====
typeset -U path
path=(~/.local/bin $path)

# ===== Shared Aliases =====
[[ -f /etc/ss/aliases.sh ]] && source /etc/ss/aliases.sh

# ===== Starship Prompt =====
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ===== UV (Python) =====
if command -v uv &>/dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# ===== fzf =====
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

# ===== Autosuggestions =====
if [[ -f /etc/ss/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /etc/ss/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi
EOF
    fi
}

configure_shell_for_user() {
    local user="$1"
    local password="$2"
    local home_dir

    if [[ "$user" == "root" ]]; then
        home_dir="/root"
    else
        home_dir="/home/$user"
    fi

    local zshrc="$home_dir/.zshrc"
    local zshrc_local="$home_dir/.zshrc.local"

    setup_shared_configs
    install_starship

    if [[ -n "$password" ]]; then
        echo "$user:$password" | chpasswd
    fi

    if [[ "$(getent passwd "$user" | cut -d: -f7)" != "/bin/zsh" ]]; then
        chsh -s /bin/zsh "$user" 2>/dev/null || true
    fi

    local marker="# ss-bootstrap"

    if [[ ! -f "$zshrc" ]] || ! grep -q "$marker" "$zshrc"; then
        [[ -f "$zshrc" ]] && cp "$zshrc" "${zshrc}.backup.$(date +%Y%m%d_%H%M%S)"

        cat > "$zshrc" << EOF
$marker
# User: $user
# Generated: $(date -Iseconds)

# Source shared base configuration
source $ZSHRC_BASE

# ===== User-specific customizations =====
# Add your personal settings in ~/.zshrc.local
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
EOF

        if [[ "$user" != "root" ]]; then
            chown "$user:$user" "$zshrc"
        fi
    fi

    if [[ ! -f "$zshrc_local" ]]; then
        cat > "$zshrc_local" << EOF
# Personal zsh configuration for $user
# This file is sourced after the base config
# Add your custom aliases, functions, and settings here

# Example:
# export EDITOR=vim
# alias myalias='my command'
EOF
        if [[ "$user" != "root" ]]; then
            chown "$user:$user" "$zshrc_local"
        fi
    fi
}

setup_current_user() {
    configure_shell_for_user "$USER" ""
}
