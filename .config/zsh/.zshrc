#!/bin/zsh
############################################################################################################
##   ______  __      __  _______   ________  _______    ______   __    __   ______   __    __  ________   ##
##  /      \|  \    /  \|       \ |        \|       \  /      \ |  \  |  \ /      \ |  \  /  \|        \  ##
## |  $$$$$$\\$$\  /  $$| $$$$$$$\| $$$$$$$$| $$$$$$$\|  $$$$$$\| $$\ | $$|  $$$$$$\| $$ /  $$| $$$$$$$$  ##
## | $$   \$$ \$$\/  $$ | $$__/ $$| $$__    | $$__| $$| $$___\$$| $$$\| $$| $$__| $$| $$/  $$ | $$__      ##
## | $$        \$$  $$  | $$    $$| $$  \   | $$    $$ \$$    \ | $$$$\ $$| $$    $$| $$  $$  | $$  \     ##
## | $$   __    \$$$$   | $$$$$$$\| $$$$$   | $$$$$$$\ _\$$$$$$\| $$\$$ $$| $$$$$$$$| $$$$$\  | $$$$$     ##
## | $$__/  \   | $$    | $$__/ $$| $$_____ | $$  | $$|  \__| $$| $$ \$$$$| $$  | $$| $$ \$$\ | $$_____   ##
##  \$$    $$   | $$    | $$    $$| $$     \| $$  | $$ \$$    $$| $$  \$$$| $$  | $$| $$  \$$\| $$     \  ##
##   \$$$$$$     \$$     \$$$$$$$  \$$$$$$$$ \$$   \$$  \$$$$$$  \$$   \$$ \$$   \$$ \$$   \$$ \$$$$$$$$  ##
##                                                                                                        ##
## Created by Cybersnake                                                                                  ##
############################################################################################################

# ── Starship ──────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── Zsh Options ───────────────────────────────────────────────────
setopt AUTOCD
setopt PROMPT_SUBST
setopt MENU_COMPLETE
setopt LIST_PACKED
setopt AUTO_LIST
setopt COMPLETE_IN_WORD
setopt NOTIFY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# ── History ───────────────────────────────────────────────────────
SAVEHIST=100000
HISTSIZE=100000
HISTFILE=$HOME/.config/zsh/.zsh_history

# ── Hook Framework ────────────────────────────────────────────────
autoload -Uz add-zsh-hook

# ── Pacman Rehash (no subprocess forks via zstat) ─────────────────
zmodload -F zsh/stat b:zstat
zshcache_time=0

rehash_precmd() {
  if [[ -a /var/cache/zsh/pacman ]]; then
    local paccache_time
    zstat -A paccache_time +mtime /var/cache/zsh/pacman
    if (( zshcache_time < paccache_time )); then
      rehash
      zshcache_time=$paccache_time
    fi
  fi
}
add-zsh-hook precmd rehash_precmd

# ── Tab Completion (cached, rebuilt once per day) ─────────────────
autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"

if [[ -n "$HOME/.cache/zsh/zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$HOME/.cache/zsh/zcompdump"
else
  compinit -C -d "$HOME/.cache/zsh/zcompdump"
fi

_comp_options+=(globdots)

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;197;1'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:warnings' format "%B%F{red}No matches for:%f %F{magenta}%d%b"
zstyle ':completion:*:descriptions' format '%F{yellow}[-- %d --]%f'

# ── Clear Screen + Scrollback ─────────────────────────────────────
function clear-screen-and-scrollback() {
  echoti clear
  printf '\e[3J'
  zle && zle .reset-prompt && zle -R
}
zle -N clear-screen-and-scrollback

# ── Keybindings ───────────────────────────────────────────────────
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~"   delete-char
bindkey "^[[F"    end-of-line
bindkey "^[[H"    beginning-of-line
bindkey '^L'      clear-screen-and-scrollback
bindkey '^O'      clear-screen-and-scrollback

# ── Aliases ───────────────────────────────────────────────────────
[[ -f "$HOME/.config/zsh/.zsh_aliases" ]] && source "$HOME/.config/zsh/.zsh_aliases"

# ── Secrets (credentials, never commit this file) ────────────────
[[ -f "$HOME/.config/zsh/.zsh_secrets" ]] && source "$HOME/.config/zsh/.zsh_secrets"

# ── Plugins ───────────────────────────────────────────────────────

# fast-syntax-highlighting — deferred to after first prompt
_load_fsh() {
  if [[ -f "$HOME/.config/zsh/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh" ]]; then
    source "$HOME/.config/zsh/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh" 2>/dev/null
    fast-theme -q catppuccin-mocha
  fi
  add-zsh-hook -d precmd _load_fsh
}
add-zsh-hook precmd _load_fsh

# zsh-autosuggestions
if [[ -f "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=10
fi

# zsh-history-substring-search — bindings inside guard
if [[ -f "$HOME/.config/zsh/plugins/zsh-history-substring-search.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-history-substring-search.zsh" 2>/dev/null
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi
