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

# Env Variables 
export VISUAL='nvim'
export EDITOR='nvim'
export TERMINAL='foot'
export BROWSER='brave'
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export DMENU='rofi -dmenu'
export IRQBALANCE_ARGS="--allcpus"
export GIT_DISCOVERY_ACROSS_FILESYSTEM=false
export MANPAGER="nvim +Man!"

# Fetch
nitch

# Custom Prompt 
PROMPT='%B%F{yellow}   %B%F{cyan}%~ %B%F{red}  %F{white}'
RPROMPT='%B%F{red}$(parse_git_branch)%F{magenta}$(parse_git_dirty) %B%F{red} %T'
precmd() {print""}

# Git Status
parse_git_dirty() {
  STATUS="$(git status 2> /dev/null)"
  if [[ $? -ne 0 ]]; then printf ""; return; else printf " ["; fi
  if echo ${STATUS} | grep -c "renamed:"         &> /dev/null; then printf " Renamed "; else printf ""; fi
  if echo ${STATUS} | grep -c "branch is ahead:" &> /dev/null; then printf " Ahead"; else printf ""; fi
  if echo ${STATUS} | grep -c "new file::"       &> /dev/null; then printf " Added "; else printf ""; fi
  if echo ${STATUS} | grep -c "Untracked files:" &> /dev/null; then printf " Untracked "; else printf ""; fi
  if echo ${STATUS} | grep -c "modified:"        &> /dev/null; then printf " Modified "; else printf ""; fi
  if echo ${STATUS} | grep -c "deleted:"         &> /dev/null; then printf " Deleted "; else printf ""; fi
  printf "] "
}

parse_git_branch() {
  # Long form
  git rev-parse --abbrev-ref HEAD 2> /dev/null
  # Short form
  # git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/.*\/\(.*\)/\1/'
}

# Git Caching

export USE_CCACHE=1
export CCACHE_COMPRESS=1
export CCACHE_MAXSIZE=50G # 50 GB

# Tab Completion
autoload -Uz compinit
setopt PROMPT_SUBST
compinit
zstyle ':completion:*' menu select 
_comp_options+=(globdots)

zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;197;1'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:warnings' format "%B%F{red}No matches for:%f %F{magenta}%d%b"
zstyle ':completion:*:descriptions' format '%F{yellow}[-- %d --]%f'
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'

# Tab Completion for pipx
autoload -U bashcompinit
bashcompinit
eval "$(register-python-argcomplete pipx)"

# Source Previous Commands
SAVEHIST=100000
HISTFILE=$HOME/.config/zsh/.zsh_history
HISTSIZE=100000
HISTCONTROL=ignorespace

## Notify that a backround command has finished
setopt notify

## Clear the entire backbuffer
function clear-screen-and-scrollback() {
  clear && printf '\e[3J'
  zle && zle .reset-prompt && zle -R
}
zle -N clear-screen-and-scrollback

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

# Zsh Options
setopt AUTOCD       
setopt PROMPT_SUBST 
setopt MENU_COMPLETE
setopt LIST_PACKED	
setopt AUTO_LIST    
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt COMPLETE_IN_WORD    

# Keybindings Fix 
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~" delete-char 
bindkey '^L' clear-screen-and-scrollback
bindkey '^O' clear-screen-and-scrollback
bindkey "^[[F" end-of-line
bindkey "^[[H" beginning-of-line
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


# Source Aliases (if exists) 
if [[ -f "$HOME/.config/zsh/.zsh_aliases" ]]; then
  source "$HOME/.config/zsh/.zsh_aliases"
fi

# Source Zsh Syntax Highlighting (if exists) 
if [[ -f "$HOME/.config/zsh/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh" 2>/dev/null
  fast-theme -q catppuccin-mocha
fi

# Source Zsh Auto completion (if exists)
if [[ -f "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=10
fi

# Soure Sub-String Search (if exists)
if [[ -f "$HOME/.config/zsh/plugins/zsh-history-substring-search.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-history-substring-search.zsh" 2>/dev/null
fi
