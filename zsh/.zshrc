###########################
# CYBERSNAKE CUSTOM ZSHRC #
########################### 

# Custom Prompt
PROMPT='%B%F{red} %~ %B%F{cyan}  %F{white}'
RPROMPT='%B%F{red}$(parse_git_branch)%F{cyan}$(parse_git_dirty) %B%F{red}%t'
precmd() { print "" }
autoload -Uz compinit
setopt PROMPT_SUBST
compinit
zstyle ':completion:*' menu select 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Source Aliases
source ~/.config/zsh/.zsh_aliases

# Source Previous Commands
SAVEHIST=1000
HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=1000

# Git Status
function parse_git_dirty {
  STATUS="$(git status 2> /dev/null)"
  if [[ $? -ne 0 ]]; then printf ""; return; else printf " ["; fi
  if echo "${STATUS}" | grep -c "renamed:"         &> /dev/null; then printf " >"; else printf ""; fi
  if echo "${STATUS}" | grep -c "branch is ahead:" &> /dev/null; then printf " !"; else printf ""; fi
  if echo "${STATUS}" | grep -c "new file::"       &> /dev/null; then printf " +"; else printf ""; fi
  if echo "${STATUS}" | grep -c "Untracked files:" &> /dev/null; then printf " ?"; else printf ""; fi
  if echo "${STATUS}" | grep -c "modified:"        &> /dev/null; then printf " *"; else printf ""; fi
  if echo "${STATUS}" | grep -c "deleted:"         &> /dev/null; then printf " -"; else printf ""; fi
  printf " ]"
}

parse_git_branch() {
  # Long form
  # git rev-parse --abbrev-ref HEAD 2> /dev/null
 # Short form
   git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/.*\/\(.*\)/\1/'
}


# Source Zsh Syntax Highlighting
source ~/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Source Zsh Auto completion
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
