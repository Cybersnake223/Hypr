#!/usr/bin/env bash

declare -A accents
accents=( ["Rosewater"]="245, 224, 220"
          ["Flamingo"]="242, 205, 205"
          ["Pink"]="245, 194, 231"
          ["Mauve"]="203, 166, 247"
          ["Red"]="243, 139, 168"
          ["Maroon"]="235, 160, 172"
          ["Peach"]="250, 179, 135"
          ["Yellow"]="249, 226, 175"
          ["Green"]="166, 227, 161"
          ["Teal"]="148, 226, 213"
          ["Sky"]="137, 220, 235"
          ["Sapphire"]="116, 199, 236"
          ["Blue"]="137, 180, 250"
          ["Lavender"]="180, 190, 254"
          ["Google-Store"]="205, 214, 244"
        )
for color in "${!accents[@]}"; do
  rm -rf $color
  cp -r Template $color
  sd 'ACCENT' $color $color/manifest.json
  sd -s 'COLOR' "${accents[$color]}" $color/manifest.json
  sd ' Google-Store' "" Google-Store/manifest.json
done
