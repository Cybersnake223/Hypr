###########################
# CYBERSNAKE CUSTOM ZSHRC #
########################### 

# Custom Prompt
PROMPT='%B%F{red} %~ %B%F{cyan}  %F{white}'
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

# Source Zsh Syntax Highlighting
source ~/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Source Zsh Auto completion
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
