# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

(( next_word = 2 | 8192 ))
[[ "$__arg_type" = 3 ]] && return 2

local __first_call="$1" __wrd="$2" __start_pos="$3" __end_pos="$4"

if (( __first_call )) || [[ "$__wrd" = -* ]]; then
  return 1
else
  if (( in_redirection > 0 || this_word & 128 )) || [[ $__wrd == "<<<" ]]; then
    return 1
  fi
  if [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/autorandr/$__wrd" ]] then
    (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) \
      && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}correct-subtle]}")
  fi
fi

(( this_word = next_word ))
_start_pos=$_end_pos

return 0
