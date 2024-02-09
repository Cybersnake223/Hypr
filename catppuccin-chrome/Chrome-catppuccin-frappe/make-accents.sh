#!/usr/bin/env bash

declare -A accents
accents=( ["Rosewater"]="242, 213, 207"
          ["Flamingo"]="238, 190, 190"
          ["Pink"]="244, 184, 228"
          ["Mauve"]="202, 158, 230"
          ["Red"]="231, 130, 132"
          ["Maroon"]="234, 153, 156"
          ["Peach"]="239, 159, 118"
          ["Yellow"]="229, 200, 144"
          ["Green"]="166, 209, 137"
          ["Teal"]="129, 200, 190"
          ["Sky"]="153, 209, 219"
          ["Sapphire"]="133, 193, 220"
          ["Blue"]="140, 170, 238"
          ["Lavender"]="186, 187, 241"
          ["Google-Store"]="198, 208, 245"
        )
for color in "${!accents[@]}"; do
  rm -rf $color
  cp -r Template $color
  sd 'ACCENT' $color $color/manifest.json
  sd -s 'COLOR' "${accents[$color]}" $color/manifest.json
  sd ' Google-Store' "" Google-Store/manifest.json
done
