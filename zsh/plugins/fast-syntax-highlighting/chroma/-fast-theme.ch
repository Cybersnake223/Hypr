# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

(( next_word = 2 | 8192 ))
[[ "$__arg_type" = 3 ]] && return 2

local __first_call="$1" __wrd="${(Q)2}" __start_pos="$3" __end_pos="$4"
local __style

if (( __first_call )); then
  FAST_HIGHLIGHT[chroma-fast-theme-first]=0
  return 1
elif (( in_redirection > 0 || this_word & 128 )) || [[ $__wrd == "<<<" ]]; then
  return 1
elif (( ${FAST_HIGHLIGHT[chroma-fast-theme-first]} )) || [[ $__wrd = -* ]]; then
  return 1
else
  FAST_HIGHLIGHT[chroma-fast-theme-first]=1
fi

if [[ "$__wrd" = */* || "$__wrd" = (CONFIG|CACHE|LOCAL|HOME|OPT):* ]]; then
  __wrd="${${__wrd/(#s)CONFIG:/${${XDG_CONFIG_HOME:-$HOME/.config}%/}/f-sy-h/}%.ini}.ini"
  __wrd="${${__wrd/(#s)CACHE:/${${XDG_CACHE_HOME:-$HOME/.cache}%/}/f-sy-h/}%.ini}.ini"
  __wrd="${${__wrd/(#s)LOCAL://usr/local/share/f-sy-h/}%.ini}.ini"
  __wrd="${${__wrd/(#s)HOME:/$HOME/.f-sy-h/}%.ini}.ini"
  __wrd="${${__wrd/(#s)OPT://opt/local/share/f-sy-h/}%.ini}.ini"
  __wrd=${~__wrd} # allow user to quote ~
else
  __wrd="$FAST_BASE_DIR/themes/$__wrd.ini"
fi

if [[ -f $__wrd ]]; then
  __style=${FAST_THEME_NAME}path
else
  __style=${FAST_THEME_NAME}incorrect-subtle
fi

(( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) \
  && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[$__style]}")
(( this_word = next_word ))
_start_pos=$_end_pos

return 0
