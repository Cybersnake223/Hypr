export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || head -100 {}'"

# Lazy-load fzf on first prompt (not at shell start)
_load_fzf() {
  source /usr/share/fzf/completion.zsh 2>/dev/null
  source /usr/share/fzf/key-bindings.zsh 2>/dev/null
  add-zsh-hook -d precmd _load_fzf
}
add-zsh-hook precmd _load_fzf
