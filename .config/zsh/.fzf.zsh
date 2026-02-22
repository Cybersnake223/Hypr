# Enable fzf completion (Tab after **, etc.)
[[ $- == *i* ]] && source /usr/share/fzf/completion.zsh 2>/dev/null

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || head -100 {}'"

# Enable fzf key bindings: Ctrl+T, Ctrl+R, Alt+C
source /usr/share/fzf/key-bindings.zsh 2>/dev/null
