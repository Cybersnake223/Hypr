#!/usr/bin/env bash

declare -A accents
accents=( ["Lavender"]="180, 190, 254")

for color in "${!accents[@]}"; do
  rm -rf $color
  cp -r Template $color
  sd 'ACCENT' $color $color/manifest.json
  sd -s 'COLOR' "${accents[$color]}" $color/manifest.json
  sd ' Google-Store' "" Google-Store/manifest.json
done
