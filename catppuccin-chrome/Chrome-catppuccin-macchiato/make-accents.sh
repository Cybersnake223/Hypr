#!/usr/bin/env bash

declare -A accents
accents=( ["Rosewater"]="244, 219, 214"
          ["Flamingo"]="240, 198, 198"
          ["Pink"]="245, 189, 230"
          ["Mauve"]="198, 160, 246"
          ["Red"]="237, 135, 150"
          ["Maroon"]="238, 153, 160"
          ["Peach"]="245, 169, 127"
          ["Yellow"]="238, 212, 159"
          ["Green"]="166, 218, 149"
          ["Teal"]="139, 213, 202"
          ["Sky"]="145, 215, 227"
          ["Sapphire"]="125, 196, 228"
          ["Blue"]="138, 173, 244"
          ["Lavender"]="183, 189, 248"
          ["Google-Store"]="202, 211, 245"
        )
for color in "${!accents[@]}"; do
  rm -rf $color
  cp -r Template $color
  sd 'ACCENT' $color $color/manifest.json
  sd -s 'COLOR' "${accents[$color]}" $color/manifest.json
  sd ' Google-Store' "" Google-Store/manifest.json
done
