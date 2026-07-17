#!/usr/bin/env bash
# pkg_updates.sh — report pending package updates as JSON.
# Combines official repo updates (checkupdates / pacman -Qu) and AUR updates (yay -Qua).
# Output: {"count":N,"packages":[{"name":"foo","oldver":"1.0","newver":"1.1"}, ...]}

set -uo pipefail

CHECKUPDATES="$HOME/.local/bin/scripts/checkupdates"
YAY="$(command -v yay 2>/dev/null || true)"

pkgs_json="[]"

add_packages() {
    local src="$1"
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        name=$(awk '{print $1}' <<<"$line")
        oldver=$(awk '{print $2}' <<<"$line")
        newver=$(awk '{print $4}' <<<"$line")
        pkgs_json=$(jq --arg n "$name" --arg o "$oldver" --arg v "$newver" \
            '. + [{name: $n, oldver: $o, newver: $v}]' <<<"$pkgs_json")
    done < <(eval "$src" 2>/dev/null)
}

# Official repositories
if [ -x "$CHECKUPDATES" ]; then
    add_packages "$CHECKUPDATES"
fi

# AUR (yay)
if [ -n "$YAY" ]; then
    add_packages "$YAY -Qua"
fi

jq -n --argjson packages "$pkgs_json" '{count: ($packages | length), packages: $packages}'
