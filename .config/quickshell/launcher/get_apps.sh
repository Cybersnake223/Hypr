#!/usr/bin/env bash
set -euo pipefail

resolve_icon() {
    local name="${1-}"

    [[ -z "$name" ]] && return 0
    if [[ "$name" == /* && -f "$name" ]]; then
        printf '%s\n' "$name"
        return 0
    fi

    printf '%s\n' "$name"
}

sanitize_exec() {
    local exec_value="$1"

    exec_value="$(printf '%s' "$exec_value" | sed -E 's/[[:space:]]+%[fFuUdDnNickvm]//g; s/[[:space:]]+@@[^[:space:]]*//g; s/[[:space:]]+--file-forwarding//g; s/[[:space:]]+--([[:space:]]*)$//; s/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
    printf '%s\n' "$exec_value"
}

parse_desktop() {
    local file="$1"
    local name=""
    local exec_value=""
    local icon=""
    local nodisplay=""
    local type=""
    local categories=""
    local terminal="false"
    local in_entry=0
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        case "$line" in
            "[Desktop Entry]")
                in_entry=1
                continue
                ;;
            "["*"]")
                if (( in_entry == 1 )); then
                    break
                fi
                ;;
        esac

        (( in_entry == 0 )) && continue

        case "$line" in
            Type=*)
                type="${line#Type=}"
                ;;
            Name=*)
                [[ -z "$name" ]] && name="${line#Name=}"
                ;;
            Exec=*)
                [[ -z "$exec_value" ]] && exec_value="${line#Exec=}"
                ;;
            Icon=*)
                [[ -z "$icon" ]] && icon="${line#Icon=}"
                ;;
            NoDisplay=*)
                nodisplay="${line#NoDisplay=}"
                ;;
            Categories=*)
                [[ -z "$categories" ]] && categories="${line#Categories=}"
                ;;
            Terminal=*)
                terminal="${line#Terminal=}"
                ;;
        esac
    done < "$file"

    [[ "$type" == "Application" ]] || return 0
    [[ "$nodisplay" != "true" ]] || return 0
    [[ "$categories" != *"AudioPlugin"* ]] || return 0
    [[ "$(basename "$file")" != in.lsp_plug.* ]] || return 0
    [[ -n "$name" ]] || return 0
    [[ -n "$exec_value" ]] || return 0

    exec_value="$(sanitize_exec "$exec_value")"
    [[ -n "$exec_value" ]] || return 0

    local icon_path
    icon_path="$(resolve_icon "$icon")"

    printf '%s\t%s\t%s\t%s\t%s\n' \
        "$name" \
        "$exec_value" \
        "$icon_path" \
        "$(basename "$file" .desktop)" \
        "$terminal"
}

scan_dir() {
    local dir="$1"
    [[ -d "$dir" ]] || return 0

    local file
    shopt -s nullglob
    for file in "$dir"/*.desktop; do
        [[ -f "$file" ]] && parse_desktop "$file"
    done
    shopt -u nullglob
}

scan_dir "/usr/share/applications"
scan_dir "$HOME/.local/share/applications"
scan_dir "/var/lib/flatpak/exports/share/applications"
scan_dir "$HOME/.local/share/flatpak/exports/share/applications"
