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
## Zsh Config                                                                                             ##
## Created by Cybersnake                                                                                  ##
############################################################################################################

export MOZ_ENABLE_WAYLAND=1

autoload -Uz add-zsh-hook

# ── Prompt (fast, static) ────────────────────────────────────────────
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{red}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{red}(%b|%a)%f'
precmd_vcs_info() { vcs_info }
add-zsh-hook precmd precmd_vcs_info
PROMPT='%B%F{green}%n@%m%f %F{cyan}%~%f${vcs_info_msg_0_}
%(?.%F{cyan}.%F{red})%B$ %b%f'
RPROMPT='%(?..%F{red}✗ %?%f )%F{8}%*%f'

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
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME

# ── History ───────────────────────────────────────────────────────
SAVEHIST=10000
HISTSIZE=10000
HISTFILE=$HOME/.config/zsh/.zsh_history
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# ── Tab Completion (cached, rebuilt once per day) ─────────────────
autoload -Uz compinit
[[ -d "$HOME/.cache/zsh" ]] || mkdir -p "$HOME/.cache/zsh"

compinit -u -C -d "$HOME/.cache/zsh/zcompdump"

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
  [[ $ZLE_STATE == *insert* || $ZLE_STATE == *overwrite* ]] && zle .reset-prompt && zle -R
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

# ── Secrets (credentials — chmod 600, never commit) ───────────────
[[ -f "$HOME/.config/zsh/.zsh_secrets" ]] && source "$HOME/.config/zsh/.zsh_secrets"

# ── Plugins ───────────────────────────────────────────────────────

# 1. history-substring-search
if [[ -f "$HOME/.config/zsh/plugins/zsh-history-substring-search.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-history-substring-search.zsh" 2>/dev/null
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# 2. zsh-autosuggestions
if [[ -f "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  ZSH_AUTOSUGGEST_STRATEGY=history
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=10
fi

# 3. fast-syntax-highlighting
_load_fsh() {
  if [[ -f "$HOME/.config/zsh/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh" ]]; then
    source "$HOME/.config/zsh/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh" 2>/dev/null
    fast-theme -q catppuccin-mocha 2>/dev/null
  fi
  add-zsh-hook -d precmd _load_fsh
}
add-zsh-hook precmd _load_fsh
