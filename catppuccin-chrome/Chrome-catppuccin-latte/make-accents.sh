#!/usr/bin/env bash

declare -A accents
accents=( ["Rosewater"]="220, 138, 120"
          ["Flamingo"]="221, 120, 120"
          ["Pink"]="234, 118, 203"
          ["Mauve"]="136, 57, 239"
          ["Red"]="210, 15, 57"
          ["Maroon"]="230, 69, 83"
          ["Peach"]="254, 100, 11"
          ["Yellow"]="223, 142, 29"
          ["Green"]="64, 160, 43"
          ["Teal"]="23, 146, 153"
          ["Sky"]="4, 165, 229"
          ["Sapphire"]="32, 159, 181"
          ["Blue"]="30, 102, 245"
          ["Lavender"]="114, 135, 253"
          ["Google-Store"]="76, 79, 105"
        )
for color in "${!accents[@]}"; do
  rm -rf $color
  cp -r Template $color
  sd 'ACCENT' $color $color/manifest.json
  sd -s 'COLOR' "${accents[$color]}" $color/manifest.json
  sd ' Google-Store' "" Google-Store/manifest.json
done
