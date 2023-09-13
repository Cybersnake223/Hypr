###########################
# CYBERSNAKE CUSTOM ZSHRC #
########################### 

# Custom Prompt
PROMPT='%B%F{red} %~ %B%F{cyan}  %F{white}'
RPROMPT='%B%F{red}%t'
precmd() { print "" }
autoload -Uz compinit
setopt PROMPT_SUBST
compinit
zstyle ':completion:*' menu select 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'


# Source Previous Commands
SAVEHIST=10000
HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE

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

# Source Aliases 
source ~/.config/zsh/.zsh_aliases

# Source Zsh Syntax Highlighting
source ~/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

# Source Zsh Auto completion
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
