#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob

resolve_icon() {
    local name="${1:-}"
    [[ -z "$name" ]] && return 0

    if [[ -f "$name" ]]; then
        printf '%s\n' "$name"
        return 0
    fi

    local dirs=(
        "$HOME/.local/share/icons/hicolor/48x48/apps"
        "$HOME/.local/share/icons/hicolor/scalable/apps"
        "/usr/share/icons/hicolor/48x48/apps"
        "/usr/share/icons/hicolor/scalable/apps"
        "/usr/share/icons/hicolor/256x256/apps"
        "/usr/share/icons/hicolor/128x128/apps"
        "/usr/share/icons/hicolor/64x64/apps"
        "/usr/share/pixmaps"
        "/var/lib/flatpak/exports/share/icons/hicolor/scalable/apps"
        "/var/lib/flatpak/exports/share/icons/hicolor/128x128/apps"
        "/var/lib/flatpak/exports/share/icons/hicolor/64x64/apps"
        "$HOME/.local/share/flatpak/exports/share/icons/hicolor/scalable/apps"
    )

    local d
    for d in "${dirs[@]}"; do
        [[ -f "$d/$name.png" ]] && { printf '%s\n' "$d/$name.png"; return 0; }
        [[ -f "$d/$name.svg" ]] && { printf '%s\n' "$d/$name.svg"; return 0; }
        [[ -f "$d/$name.xpm" ]] && { printf '%s\n' "$d/$name.xpm"; return 0; }
    done
}

cleanup_exec() {
    local exec_line="${1:-}"
    exec_line="${exec_line//%u/}"
    exec_line="${exec_line//%U/}"
    exec_line="${exec_line//%f/}"
    exec_line="${exec_line//%F/}"
    exec_line="${exec_line//%i/}"
    exec_line="${exec_line//%c/}"
    exec_line="${exec_line//%k/}"
    exec_line="${exec_line//%%/%}"
    printf '%s\n' "$exec_line" | xargs -r echo
}

parse_desktop() {
    local f="$1"
    local name="" exec="" icon="" nodisplay="" type="" categories="" terminal="false"
    local inentry=0 line key value

    while IFS= read -r line || [[ -n "$line" ]]; do
        case "$line" in
            "[Desktop Entry]")
                inentry=1
                continue
                ;;
            "["*)
                (( inentry == 1 )) && break
                continue
                ;;
        esac

        (( inentry == 0 )) && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" != *=* ]] && continue

        key="${line%%=*}"
        value="${line#*=}"

        case "$key" in
            Type) [[ -z "$type" ]] && type="$value" ;;
            Name) [[ -z "$name" ]] && name="$value" ;;
            Exec) [[ -z "$exec" ]] && exec="$value" ;;
            Icon) [[ -z "$icon" ]] && icon="$value" ;;
            NoDisplay) [[ -z "$nodisplay" ]] && nodisplay="$value" ;;
            Categories) [[ -z "$categories" ]] && categories="$value" ;;
            Terminal) [[ "$value" == "true" ]] && terminal="true" ;;
        esac
    done < "$f"

    [[ "$type" == "Application" ]] || return 0
    [[ "$nodisplay" == "true" ]] && return 0
    [[ "$categories" == *"AudioPlugin"* ]] && return 0
    [[ -n "$name" && -n "$exec" ]] || return 0

    case "$(basename "$f")" in
        *.lsp-plug.*) return 0 ;;
    esac

    local iconpath cleaned_exec
    iconpath="$(resolve_icon "$icon" || true)"
    cleaned_exec="$(cleanup_exec "$exec")"

    printf '%s\t%s\t%s\t%s\t%s\n' \
        "$name" \
        "$cleaned_exec" \
        "$iconpath" \
        "$(basename "$f" .desktop)" \
        "$terminal"
}

collect_files() {
    local f
    for f in /usr/share/applications/*.desktop; do
        [[ -f "$f" ]] && parse_desktop "$f"
    done
    for f in "$HOME/.local/share/applications"/*.desktop; do
        [[ -f "$f" ]] && parse_desktop "$f"
    done
    for f in /var/lib/flatpak/exports/share/applications/*.desktop; do
        [[ -f "$f" ]] && parse_desktop "$f"
    done
    for f in "$HOME/.local/share/flatpak/exports/share/applications"/*.desktop; do
        [[ -f "$f" ]] && parse_desktop "$f"
    done
}

collect_files | sort -f -u
