# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et


local __first_call="$1" __start_pos="$3" __end_pos="$4"

[[ "$__arg_type" = 3 ]] && return 2

(( __first_call )) && {
  (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) \
    && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}precommand]}")
  (( next_word = (next_word & ~2) | 4 | 1 ))
} || {
  return 1
}

(( this_word = next_word ))
_start_pos=$_end_pos
return 0
