#!/bin/zsh
###########################
# CYBERSNAKE CUSTOM ZSHRC #
###########################

# Fetch
nitch

# Custom Prompt 
PROMPT='%B%F{red} %~ %B%F{cyan}  %F{white}'
RPROMPT='%B%F{red}%T'
precmd() { print "" }

# Tab Completion
autoload -Uz compinit
setopt PROMPT_SUBST
compinit
zstyle ':completion:*' menu select 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
_comp_options+=(globdots)

# Source Previous Commands
SAVEHIST=100000
HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=100000
setopt hist_expire_dups_first
setopt hist_ignore_dups


## Notify that a backround command has finished
setopt notify

## Clear the entire backbuffer
function clear-screen-and-scrollback() {
  clear && printf '\e[3J'
  zle && zle .reset-prompt && zle -R
}
zle -N clear-screen-and-scrollback
bindkey '^L' clear-screen-and-scrollback

# Rehash After Package Modification

zshcache_time="$(date +%s%N)"

autoload -Uz add-zsh-hook

rehash_precmd() {
  if [[ -a /var/cache/zsh/pacman ]]; then
    local paccache_time="$(date -r /var/cache/zsh/pacman +%s%N)"
    if (( zshcache_time < paccache_time )); then
      rehash
      zshcache_time="$paccache_time"
    fi
  fi
}

add-zsh-hook -Uz precmd rehash_precmd

# Keybindings Fix 
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~" delete-char 
bindkey "^[[F" end-of-line
bindkey "^[[H" beginning-of-line
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Source Aliases 
source ~/.config/zsh/.zsh_aliases

# Source Zsh Syntax Highlighting
source ~/.config/zsh/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh 2>/dev/null
fast-theme -q catppuccin-macchiato

# Source Zsh Auto completion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# Soure Sub-String Search
source ~/.config/zsh/plugins/zsh-history-substring-search.zsh 2>/dev/null
