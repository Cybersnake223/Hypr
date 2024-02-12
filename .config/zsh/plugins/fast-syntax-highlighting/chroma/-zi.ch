# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Chroma function for command `zi'. It colorizes the part of command line that holds `zi' invocation.

(( FAST_HIGHLIGHT[-zi.ch-chroma-def] )) && return 1

FAST_HIGHLIGHT[-zi.ch-chroma-def]=1

typeset -gA fsh__zi__chroma__def
fsh__zi__chroma__def=(
    ##
    ## No subcommand
    ##
    ## {{{

    subcmd:NULL "NULL_0_opt"
    NULL_0_opt "(-help|--help|-h)
                   <<>> NO-OP // ::chroma/main-chroma-std-aopt-action"
    "subcommands" "(help|subcmds|icemods|analytics|man|self-update|times|zstatus|load|light|unload|snippet|ls|ice|<ice|specification>|update|status|report|delete|loaded|list|cd|create|edit|glance|stress|changes|recently|clist|completions|cclear|cdisable|cenable|creinstall|cuninstall|csearch|compinit|dtrace|dstart|dstop|dunload|dreport|dclear|compile|uncompile|compiled|cdlist|cdreplay|cdclear|srv|recall|env-whitelist|bindkeys|module|add-fpath|run)"

    ## }}}

    # Generic actions
    NO_MATCH_\#_opt "* <<>> __style=\${FAST_THEME_NAME}incorrect-subtle // NO-OP"
    NO_MATCH_\#_arg "__style=\${FAST_THEME_NAME}incorrect-subtle // NO-OP"


    ##
    ## `ice'
    ##
    ## {{{

    subcmd:ice "ICE_#_arg // NO_MATCH_#_opt"

    "ICE_#_arg" "NO-OP // ::chroma/-zi-check-ice-mod"

    ##
    ## `snippet'
    ##
    ## {{{

    subcmd:snippet "SNIPPET_0_opt // SNIPPET_1_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    SNIPPET_0_opt "(-h|--help|-f|--force|--command|-x)
                        <<>> NO-OP // ::chroma/main-chroma-std-aopt-action"

    SNIPPET_1_arg "NO-OP // ::chroma/-zi-verify-snippet"

    ## }}}

    ##
    ## `load'
    ##
    ## {{{

    "subcmd:load" "LOAD_1_arg // LOAD_2_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    LOAD_1_arg "NO-OP // ::chroma/-zi-verify-plugin"

    LOAD_2_arg "NO-OP // ::chroma/-zi-verify-plugin"

    ## }}}

    ##
    ## `compile|uncompile|stress|edit|glance|recall|status|cd|changes`
    ##
    ## {{{

    "subcmd:(compile|uncompile|stress|edit|glance|recall|status|cd|changes)"
        "PLGSNP_1_arg // PLGSNP_2_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    PLGSNP_1_arg "NO-OP // ::chroma/-zi-verify-plugin-or-snippet"

    PLGSNP_2_arg "NO-OP // ::chroma/-zi-verify-plugin-or-snippet"

    ## }}}

    ##
    ## `update'
    ##
    ## {{{

    subcmd:update "UPDATE_0_opt // PLGSNP_1_arg // PLGSNP_2_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    UPDATE_0_opt "
            (-L|--plugins|-s|--snippets|-p|--parallel|-a|--all|-q|--quiet|-r|--reset|-u|--urge|-n|--no-pager|-v|--verbose|-h|--help)
                    <<>> NO-OP // ::chroma/main-chroma-std-aopt-action"

    ## }}}

    ##
    ## `light'
    ##
    ## {{{

    subcmd:light "LIGHT_0_opt // LOAD_1_arg // LOAD_2_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    LIGHT_0_opt "-h|--help|-b
                    <<>> NO-OP // ::chroma/main-chroma-std-aopt-action"

    ## }}}

    ##
    ## `unload'
    ##
    ## {{{

    subcmd:unload "UNLOAD_0_opt // UNLOAD_1_arg // UNLOAD_2_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    UNLOAD_0_opt "-h|--help|-q|--quiet
                    <<>> NO-OP // ::chroma/main-chroma-std-aopt-action"

    UNLOAD_1_arg "NO-OP // ::chroma/-zi-verify-loaded-plugin"

    UNLOAD_2_arg "NO-OP // ::chroma/-zi-verify-loaded-plugin"

    ## }}}

    ##
    ## `report'
    ##
    ## {{{

    subcmd:report "REPORT_0_opt // UNLOAD_1_arg // UNLOAD_2_arg // NO_MATCH_#_opt //
                  NO_MATCH_#_arg"

    REPORT_0_opt "--all
                    <<>> NO-OP // ::chroma/main-chroma-std-aopt-action"

    ## }}}

    ##
    ## `delete'
    ##
    ## {{{

    "subcmd:delete"
        "DELETE_0_opt // PLGSNP_1_arg // PLGSNP_2_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    DELETE_0_opt "
            (-a|--all|-c|--clean|-y|--yes|-q|--quiet|-h|--help)
                    <<>> NO-OP // ::chroma/main-chroma-std-aopt-action"

    ## }}}

    ##
    ## `cenable'
    ##
    ## {{{

    subcmd:cenable "COMPLETION_1_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    COMPLETION_1_arg "NO-OP // ::chroma/-zi-verify-disabled-completion"

    ## }}}

    ##
    ## `cdisable'
    ##
    ## {{{

    subcmd:cdisable "DISCOMPLETION_1_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    DISCOMPLETION_1_arg "NO-OP // ::chroma/-zi-verify-completion"

    ## }}}


    ##
    ## `uncompile'
    ##
    ## {{{

    subcmd:uncompile "UNCOMPILE_1_arg // NO_MATCH_#_opt // NO_MATCH_#_arg"

    UNCOMPILE_1_arg "NO-OP // ::chroma/-zi-verify-compiled-plugin"

    ## }}}

    ##
    ## `*'
    ##
    ## {{{

    "subcmd:*" "CATCH_ALL_#_opt"
    "CATCH_ALL_#_opt" "* <<>> NO-OP // ::chroma/main-chroma-std-aopt-SEMI-action"

    ## }}}
)

#chroma/-zi-first-call() {
    # This is being done in the proper place - in -fast-highlight-process
    #FAST_HIGHLIGHT[chroma-zi-ice-elements-svn]=0
#}

chroma/-zi-verify-plugin() {
    local _scmd="$1" _wrd="$4"

    [[ -d "$_wrd" ]] && { __style=${FAST_THEME_NAME}correct-subtle; return 0; }

    typeset -a plugins
    plugins=( "${ZI[PLUGINS_DIR]}"/*(N:t) )
    plugins=( "${plugins[@]//---//}" )
    plugins=( "${plugins[@]:#_local/zi}" )
    plugins=( "${plugins[@]:#custom}" )

    [[ -n "${plugins[(r)$_wrd]}" ]] && __style=${FAST_THEME_NAME}correct-subtle || return 1
        #__style=${FAST_THEME_NAME}incorrect-subtle
    return 0
}

chroma/-zi-verify-plugin-or-snippet() {
    chroma/-zi-verify-plugin "$1" "" "" "$4" || chroma/-zi-verify-snippet "$1" "" "" "$4"
    return $?
}

chroma/-zi-verify-loaded-plugin() {
    local _scmd="$1" _wrd="$4"
    typeset -a plugins absolute1 absolute2 absolute3 normal
    plugins=( "${ZI_REGISTERED_PLUGINS[@]:#_local/zi}" )
    normal=( "${plugins[@]:#%*}" )
    absolute1=( "${(M)plugins[@]:#%*}" )
    absolute1=( "${absolute1[@]/\%\/\//%/}" )
    local hm="${HOME%/}"
    absolute2=( "${absolute1[@]/$hm/HOME}" )
    absolute3=( "${absolute1[@]/\%/}" )
    plugins=( $absolute1 $absolute2 $absolute3 $normal )

    [[ -n "${plugins[(r)$_wrd]}" ]] && \
        __style=${FAST_THEME_NAME}correct-subtle || \
        return 1
        #__style=${FAST_THEME_NAME}incorrect-subtle

    return 0
}

chroma/-zi-verify-completion() {
    local _scmd="$1" _wrd="$4"
    # Find enabled completions
    typeset -a completions
    completions=( "${ZI[COMPLETIONS_DIR]}"/_*(N:t) )
    completions=( "${completions[@]#_}" )

    [[ -n "${completions[(r)${_wrd#_}]}" ]] && \
        __style=${FAST_THEME_NAME}correct-subtle || \
        return 1

    return 0
}

chroma/-zi-verify-disabled-completion() {
    local _scmd="$1" _wrd="$4"
    # Find enabled completions
    typeset -a completions
    completions=( "${ZI[COMPLETIONS_DIR]}"/[^_]*(N:t) )

    [[ -n "${completions[(r)${_wrd#_}]}" ]] && \
        __style=${FAST_THEME_NAME}correct-subtle || \
        return 1

    return 0
}

chroma/-zi-verify-compiled-plugin() {
    local _scmd="$1" _wrd="$4"

    typeset -a plugins
    plugins=( "${ZI[PLUGINS_DIR]}"/*(N) )

    typeset -a show_plugins p matches
    for p in "${plugins[@]}"; do
        matches=( $p/*.zwc(N) )
        if [ "$#matches" -ne "0" ]; then
            p="${p:t}"
            [[ "$p" = (_local---zi|custom) ]] && continue
            p="${p//---//}"
            show_plugins+=( "$p" )
        fi
    done

    [[ -n "${show_plugins[(r)$_wrd]}" ]] && \
        { __style=${FAST_THEME_NAME}correct-subtle; return 0; } || \
        return 1
}

chroma/-zi-verify-snippet() {
    local _scmd="$1" url="$4" dirname local_dir
    url="${${url#"${url%%[! $'\t']*}"}%/}"
    id_as="${FAST_HIGHLIGHT[chroma-zi-ice-elements-id-as]:-${ZI_ICE[id-as]:-$url}}"

    filename="${${id_as%%\?*}:t}"
    dirname="${${id_as%%\?*}:t}"
    local_dir="${${${id_as%%\?*}:h}/:\/\//--}"
    [[ "$local_dir" = "." ]] && local_dir="" || local_dir="${${${${${local_dir#/}//\//--}//=/--EQ--}//\?/--QM--}//\&/--AMP--}"
    local_dir="${ZI[SNIPPETS_DIR]}${local_dir:+/$local_dir}"

    (( ${+ZI_ICE[svn]} || ${FAST_HIGHLIGHT[chroma-zi-ice-elements-svn]} )) && {
        # TODO: #11 handle the SVN path's specifics
        [[ -d "$local_dir/$dirname" ]] && \
            { __style=${FAST_THEME_NAME}correct-subtle; return 0; } || \
            return 1
    } || {
        # TODO: #12 handle the non-SVN path's specifics
        [[ -d "$local_dir/$dirname" ]] && \
            { __style=${FAST_THEME_NAME}correct-subtle; return 0; } || \
            return 1
    }
}

chroma/-zi-check-ice-mod() {
  local _scmd="$1" _wrd="$4"
  [[ "$_wrd" = (svn(\'|\")*|svn) ]] && FAST_HIGHLIGHT[chroma-zi-ice-elements-svn]=1
  [[ "$_wrd" = (#b)(id-as(:|)(\'|\")(*)(\'|\")|id-as:(*)|id-as(*)) ]] && \
  FAST_HIGHLIGHT[chroma-zi-ice-elements-id-as]="${match[4]}${match[6]}${match[7]}"

    # .zi-recall
    local -a ice_order nval_ices ext_val_ices
    ext_val_ices=( ${(@)${(@Akons:|:u)${ZI_EXTS[ice-mods]//\'\'/}}/(#s)<->-/} )

    ice_order=(
      ${${(s.|.)ZI[ice-list]}}
      # Include all additional ices – after stripping them from the possible: ''
      ${(@)${(@Akons:|:u)${ZI_EXTS[ice-mods]//\'\'/}}/(#s)<->-/}
    )
    nval_ices=(
      ${(s.|.)ZI[nval-ice-list]}
      # Include only those additional ices,
      # don't have the '' in their name, i.e. aren't designed to hold value
      ${(@)${(@)${(@Akons:|:u)${ZI_EXTS[ice-mods]//\'\'/}}/(#s)<->-/}}
      # Must be last
      svn
    )

    if [[ "$_wrd" = (#b)(${(~j:|:)${ice_order[@]:#(${(~j:|:)nval_ices[@]:#(${(~j:|:)ext_val_ices[@]})})}})(*) ]]; then
        reply+=("$(( __start )) $(( __start+${mend[1]} )) ${FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}double-hyphen-option]}")
        reply+=("$(( __start+${mbegin[2]} )) $(( __end )) ${FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}optarg-string]}")
        -fast-highlight-string
        return 0
    elif [[ "$_wrd" = (#b)(${(~j:|:)nval_ices[@]}) ]]; then
        __style=${FAST_THEME_NAME}single-hyphen-option
        return 0
    else
        __style=${FAST_THEME_NAME}incorrect-subtle
        return 1
    fi
}

return 0
