#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                                                                              ║
# ║              V I C I O U S   V I P E R   —   D O T F I L E S                 ║
# ║                   https://github.com/Cybersnake223/Hypr                      ║
# ║                                                                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# A safe, idempotent dotfiles installer with full backup/restore support.
# Designed for Arch Linux + Hyprland. Works on any POSIX-ish shell environment.
#
# Usage: ./install.sh [--yes] [--dry-run] [--no-backup] [--uninstall]
#                     [--list-backups] [--select] [--skip-deps] [-h]

set -Eeuo pipefail

# ══════════════════════════════════════════════════════════════════════════════
# GLOBALS
# ══════════════════════════════════════════════════════════════════════════════

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_VERSION="2.0.0"
TS="$(date +"%Y%m%d-%H%M%S")"
BACKUP_BASE="${XDG_DATA_HOME:-$HOME/.local/share}/hypr-dotfiles-backups"
BACKUP_DIR="$BACKUP_BASE/$TS"
INSTALL_MANIFEST="$BACKUP_DIR/.manifest"
LOG_FILE="/tmp/hypr-install-${TS}.log"

# Flags
OPT_YES=0
OPT_BACKUP=1
OPT_DRY_RUN=0
OPT_UNINSTALL=0
OPT_LIST_BACKUPS=0
OPT_SELECT=0
OPT_SKIP_DEPS=0

# Counters
COPIED=0
BACKED_UP=0
SKIPPED=0
ERRORS=0

# ══════════════════════════════════════════════════════════════════════════════
# COLORS & OUTPUT
# ══════════════════════════════════════════════════════════════════════════════

if [[ -t 1 ]]; then
  R='\033[0;31m'   # Red
  Y='\033[1;33m'   # Yellow
  G='\033[0;32m'   # Green
  C='\033[0;36m'   # Cyan
  M='\033[0;35m'   # Magenta
  B='\033[0;34m'   # Blue
  W='\033[1;37m'   # White Bold
  D='\033[2m'      # Dim
  BOLD='\033[1m'
  RESET='\033[0m'
else
  R=''; Y=''; G=''; C=''; M=''; B=''; W=''; D=''; BOLD=''; RESET=''
fi

# Logging — write plain text to log, colored to terminal
_log_plain() { echo "$*" >> "$LOG_FILE" 2>/dev/null || true; }

info()    { local msg="[info]   $*"; echo -e "${C}${msg}${RESET}"; _log_plain "$msg"; }
success() { local msg="[ok]     $*"; echo -e "${G}${msg}${RESET}"; _log_plain "$msg"; }
warn()    { local msg="[warn]   $*"; echo -e "${Y}${msg}${RESET}"; _log_plain "$msg"; }
error()   { local msg="[error]  $*"; echo -e "${R}${msg}${RESET}" >&2; _log_plain "$msg"; }
die()     { error "$*"; exit 1; }
step()    { echo -e "\n${BOLD}━━━  $* ${RESET}"; _log_plain "--- $* ---"; }
dim()     { echo -e "${D}$*${RESET}"; }

# ══════════════════════════════════════════════════════════════════════════════
# USAGE
# ══════════════════════════════════════════════════════════════════════════════

usage() {
  cat <<EOF

${BOLD}  Vicious Viper Dotfiles Installer${RESET}  ${D}v${SCRIPT_VERSION}${RESET}

${BOLD}Usage:${RESET}
  $(basename "$0") [options]

${BOLD}Options:${RESET}
  ${G}--yes${RESET}            Non-interactive — skip all prompts (auto-confirm)
  ${G}--dry-run${RESET}        Preview every action without making any changes
  ${G}--no-backup${RESET}      Skip backup step ${R}(dangerous — disables uninstall)${RESET}
  ${G}--uninstall${RESET}      Restore originals from the most recent backup
  ${G}--list-backups${RESET}   Show all available backups with file counts
  ${G}--select${RESET}         Interactively choose which modules to install
  ${G}--skip-deps${RESET}      Skip the Hyprland ecosystem dependency check
  ${G}-h, --help${RESET}       Show this message

${BOLD}Examples:${RESET}
  ${D}# Interactive install with full backup${RESET}
  ./install.sh

  ${D}# Preview everything — zero changes${RESET}
  ./install.sh --dry-run

  ${D}# Fully non-interactive CI install${RESET}
  ./install.sh --yes --skip-deps

  ${D}# Pick only the modules you want${RESET}
  ./install.sh --select

  ${D}# Undo the last install${RESET}
  ./install.sh --uninstall

  ${D}# Show all available backups${RESET}
  ./install.sh --list-backups

EOF
}

# ══════════════════════════════════════════════════════════════════════════════
# ARGUMENT PARSING
# ══════════════════════════════════════════════════════════════════════════════

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)           OPT_YES=1;          shift ;;
    --no-backup)     OPT_BACKUP=0;       shift ;;
    --dry-run)       OPT_DRY_RUN=1;      shift ;;
    --uninstall)     OPT_UNINSTALL=1;    shift ;;
    --list-backups)  OPT_LIST_BACKUPS=1; shift ;;
    --select)        OPT_SELECT=1;       shift ;;
    --skip-deps)     OPT_SKIP_DEPS=1;    shift ;;
    -h|--help)       usage; exit 0 ;;
    *) die "Unknown option: '$1'  —  run with --help for usage." ;;
  esac
done

# Conflict guards
[[ "$OPT_UNINSTALL" -eq 1 && "$OPT_BACKUP" -eq 0 ]] \
  && die "--uninstall and --no-backup cannot be used together."
[[ "$OPT_UNINSTALL" -eq 1 && "$OPT_SELECT" -eq 1 ]] \
  && die "--uninstall and --select cannot be used together."
[[ "$OPT_DRY_RUN" -eq 1 && "$OPT_UNINSTALL" -eq 1 ]] \
  && die "--dry-run and --uninstall cannot be used together."

# Sanity: must run from inside the repo
[[ -f "$REPO_DIR/README.md" ]] \
  || die "README.md not found. Run this script from inside the cloned repo directory."

# ══════════════════════════════════════════════════════════════════════════════
# CORE HELPERS
# ══════════════════════════════════════════════════════════════════════════════

# run: execute a command, or print it in dry-run mode
run() {
  if [[ "$OPT_DRY_RUN" -eq 1 ]]; then
    echo -e "  ${Y}[dry]${RESET} $*"
    _log_plain "[dry] $*"
  else
    "$@"
  fi
}

# confirm: prompt user unless --yes is set
confirm() {
  [[ "$OPT_YES" -eq 1 ]] && return 0
  local prompt="$1"
  local default="${2:-n}"
  local hint="[y/N]"
  [[ "${default,,}" == "y" ]] && hint="[Y/n]"
  read -r -p "$(echo -e "  ${W}?${RESET} ${prompt} ${D}${hint}${RESET} ")" ans || true
  ans="${ans:-$default}"
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

# record: append a destination path to the install manifest
record() {
  [[ "$OPT_DRY_RUN" -eq 1 ]] && return 0
  echo "$1" >> "$INSTALL_MANIFEST"
}

# safe_copy: backup then copy a single file, with error handling
safe_copy() {
  local src="$1" dest="$2"
  [[ -f "$src" ]] || return 0

  # Backup existing file
  if [[ "$OPT_BACKUP" -eq 1 && -e "$dest" ]]; then
    local rel="${dest#"$HOME/"}"
    local bkp="$BACKUP_DIR/$rel"
    if [[ "$OPT_DRY_RUN" -eq 0 ]]; then
      mkdir -p "$(dirname "$bkp")"
      cp -a "$dest" "$bkp" && (( BACKED_UP++ )) || true
    fi
    dim "    backup  : $dest"
  fi

  run mkdir -p "$(dirname "$dest")"
  if run cp -a "$src" "$dest"; then
    record "$dest"
    success "  ✓  $(basename "$src")"
    (( COPIED++ )) || true
  else
    error "  ✗  Failed to copy: $src → $dest"
    (( ERRORS++ )) || true
  fi
}

# safe_copy_tree: backup then merge a directory tree into dest,
# recording every individual file path into the manifest
safe_copy_tree() {
  local src="$1" dest="$2" label="${3:-$(basename "$src")}"
  [[ -d "$src" ]] || return 0

  # Backup existing target tree
  if [[ "$OPT_BACKUP" -eq 1 && -d "$dest" ]]; then
    local rel="${dest#"$HOME/"}"
    local bkp="$BACKUP_DIR/$rel"
    if [[ "$OPT_DRY_RUN" -eq 0 ]]; then
      mkdir -p "$(dirname "$bkp")"
      cp -a "$dest" "$bkp" && (( BACKED_UP++ )) || true
    fi
    dim "    backup  : $dest"
  fi

  run mkdir -p "$dest"
  if run cp -a "$src/." "$dest/"; then
    success "  ✓  $label"
    # Record every installed file individually for accurate uninstall
    if [[ "$OPT_DRY_RUN" -eq 0 ]]; then
      while IFS= read -r -d '' f; do
        local rel="${f#"$src/"}"
        record "$dest/$rel"
        (( COPIED++ )) || true
      done < <(find "$src" -mindepth 1 -type f -print0)
    fi
  else
    error "  ✗  Failed to copy tree: $src → $dest"
    (( ERRORS++ )) || true
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# LIST BACKUPS
# ══════════════════════════════════════════════════════════════════════════════

cmd_list_backups() {
  step "Available Backups"
  if [[ ! -d "$BACKUP_BASE" ]]; then
    warn "No backup directory found at: $BACKUP_BASE"
    return 0
  fi

  local count=0
  while IFS= read -r -d '' manifest; do
    local dir ts file_count size
    dir="$(dirname "$manifest")"
    ts="$(basename "$dir")"
    file_count="$(wc -l < "$manifest" 2>/dev/null || echo 0)"
    size="$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "?")"
    printf "  ${C}%s${RESET}  ${D}%s files  %s${RESET}\n    ${D}→ %s${RESET}\n" \
      "$ts" "$file_count" "$size" "$dir"
    (( count++ )) || true
  done < <(find "$BACKUP_BASE" -name '.manifest' -print0 2>/dev/null | sort -z)

  echo
  if [[ "$count" -eq 0 ]]; then
    warn "No backups found."
  else
    success "$count backup(s) found."
    dim "  To restore: ./install.sh --uninstall"
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# DEPENDENCY CHECK
# ══════════════════════════════════════════════════════════════════════════════

# Ecosystem tools this dotfiles setup depends on
ECOSYSTEM_DEPS=(
  "hyprland:Wayland compositor"
  "waybar:Status bar"
  "foot:Terminal emulator"
  "zsh:Shell"
  "rofi:App launcher (lbonn/wayland fork)"
  "mako:Notification daemon"
  "swww:Wallpaper daemon"
  "hyprlock:Screen locker"
  "matugen:Dynamic color theming"
  "fc-cache:Font cache (fontconfig)"
  "btop:Resource monitor"
  "yazi:TUI file manager"
  "fastfetch:System info fetch"
)

cmd_check_deps() {
  step "Dependency Check"

  # Core system tools — hard requirement
  local core_missing=()
  for cmd in cp mkdir find date sort; do
    command -v "$cmd" >/dev/null 2>&1 || core_missing+=("$cmd")
  done
  [[ ${#core_missing[@]} -gt 0 ]] \
    && die "Missing core system utilities: ${core_missing[*]}"
  success "  ✓  Core utilities (cp, mkdir, find, date)"

  [[ "$OPT_SKIP_DEPS" -eq 1 ]] && { warn "  Ecosystem check skipped (--skip-deps)"; return 0; }

  # Ecosystem tools — advisory
  echo
  local eco_missing=()
  local col_w=20
  for entry in "${ECOSYSTEM_DEPS[@]}"; do
    local cmd="${entry%%:*}"
    local desc="${entry#*:}"
    if command -v "$cmd" >/dev/null 2>&1; then
      printf "  ${G}✓${RESET}  %-${col_w}s ${D}%s${RESET}\n" "$cmd" "$desc"
    else
      printf "  ${Y}✗${RESET}  %-${col_w}s ${Y}not found — %s${RESET}\n" "$cmd" "$desc"
      eco_missing+=("$cmd")
    fi
  done

  echo
  if [[ ${#eco_missing[@]} -gt 0 ]]; then
    warn "${#eco_missing[@]} ecosystem package(s) not installed: ${eco_missing[*]}"
    warn "Configs will install, but the desktop won't work until these are present."
    warn "See README Prerequisites or run with --skip-deps to bypass this check."
    echo
    confirm "Continue with missing packages?" || { echo "Aborted."; exit 0; }
  else
    success "All ecosystem dependencies found."
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# UNINSTALL
# ══════════════════════════════════════════════════════════════════════════════

cmd_uninstall() {
  step "Uninstall — Restore from Backup"

  # Find the most recent manifest
  local latest_manifest
  latest_manifest="$(find "$BACKUP_BASE" -name '.manifest' -print0 2>/dev/null \
    | sort -z | tr '\0' '\n' | tail -1)" || true

  [[ -f "$latest_manifest" ]] \
    || die "No install manifest found in:\n  $BACKUP_BASE\n\nHas the installer been run before?"

  local backup_root
  backup_root="$(dirname "$latest_manifest")"
  local ts
  ts="$(basename "$backup_root")"
  local manifest_lines
  manifest_lines="$(wc -l < "$latest_manifest")"

  # Guard against empty backups (installed with --no-backup)
  local file_count
  file_count="$(find "$backup_root" -not -name '.manifest' -not -path "$backup_root" \
    -type f 2>/dev/null | wc -l)"
  if [[ "$file_count" -eq 0 ]]; then
    die "Backup at $backup_root is empty.\nInstall was likely run with --no-backup — refusing to restore to avoid data loss."
  fi

  echo
  info "Backup timestamp : $ts"
  info "Backup location  : $backup_root"
  info "Manifest entries : $manifest_lines"
  info "Backed-up files  : $file_count"
  echo
  warn "Files that were NEW (no prior backup) will be LEFT in place — they are never deleted."
  echo
  confirm "Restore from this backup?" || { echo "Aborted."; exit 0; }

  local restored=0 skipped=0

  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    local rel="${target#"$HOME/"}"
    local bkp="$backup_root/$rel"

    if [[ -e "$bkp" ]]; then
      run mkdir -p "$(dirname "$target")"
      run cp -a "$bkp" "$target"
      success "  ✓  Restored: $rel"
      (( restored++ )) || true
    else
      dim "  –  No backup for: $rel — left as-is"
      (( skipped++ )) || true
    fi
  done < "$latest_manifest"

  echo
  success "Uninstall complete."
  info "$restored file(s) restored."
  [[ "$skipped" -gt 0 ]] \
    && warn "$skipped file(s) had no prior backup and were left untouched."
}

# ══════════════════════════════════════════════════════════════════════════════
# SELECTIVE MODULE PICKER
# ══════════════════════════════════════════════════════════════════════════════

# Module registry — each entry: "key:label:description"
declare -a MODULES=(
  "config:.config      Application configs (hypr, waybar, rofi, nvim, zsh…)"
  "scripts:scripts     Custom scripts → ~/.local/bin/scripts"
  "icons:.icons        Icon theme"
  "themes:.themes      GTK/Qt themes"
  "fonts:.fonts        Custom fonts (triggers fc-cache rebuild)"
  "dotfiles:dotfiles   Root dotfiles (.Xresources, .gtkrc-2.0)"
)

# Which modules are enabled (default: all)
declare -A MODULE_ENABLED
for entry in "${MODULES[@]}"; do
  MODULE_ENABLED["${entry%%:*}"]=1
done

cmd_select_modules() {
  echo
  echo -e "${BOLD}  Select modules to install${RESET}  ${D}(toggle with number, Enter to confirm)${RESET}"
  echo

  local keys=()
  for entry in "${MODULES[@]}"; do
    keys+=("${entry%%:*}")
  done

  while true; do
    local i=1
    for entry in "${MODULES[@]}"; do
      local key="${entry%%:*}"
      local rest="${entry#*:}"
      local label="${rest%%  *}"
      local desc="${rest#*  }"
      local state
      if [[ "${MODULE_ENABLED[$key]}" -eq 1 ]]; then
        state="${G}[✓]${RESET}"
      else
        state="${D}[ ]${RESET}"
      fi
      printf "  %s  ${BOLD}%d${RESET}  ${C}%-14s${RESET}  ${D}%s${RESET}\n" \
        "$state" "$i" "$label" "$desc"
      (( i++ )) || true
    done

    echo
    read -r -p "$(echo -e "  ${W}?${RESET} Toggle module number (or ${G}Enter${RESET} to confirm): ")" choice || true

    if [[ -z "$choice" ]]; then
      # Check at least one module is selected
      local any=0
      for k in "${keys[@]}"; do
        [[ "${MODULE_ENABLED[$k]}" -eq 1 ]] && any=1 && break
      done
      [[ "$any" -eq 0 ]] && { warn "Select at least one module."; continue; }
      break
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#keys[@]} )); then
      local idx=$(( choice - 1 ))
      local key="${keys[$idx]}"
      if [[ "${MODULE_ENABLED[$key]}" -eq 1 ]]; then
        MODULE_ENABLED["$key"]=0
      else
        MODULE_ENABLED["$key"]=1
      fi
      # Clear lines to re-draw
      printf '\033[%dA\033[J' "$(( ${#MODULES[@]} + 3 ))"
    else
      warn "Invalid choice: '$choice'"
    fi
  done
}

# ══════════════════════════════════════════════════════════════════════════════
# INSTALL MODULES
# ══════════════════════════════════════════════════════════════════════════════

install_config() {
  [[ "${MODULE_ENABLED[config]:-0}" -eq 0 ]] && return 0
  step ".config — Application Configs"
  [[ -d "$REPO_DIR/.config" ]] || { warn "No .config directory found in repo."; return 0; }

  while IFS= read -r -d '' subdir; do
    local name
    name="$(basename "$subdir")"
    safe_copy_tree "$subdir" "$HOME/.config/$name" ".config/$name"
  done < <(find "$REPO_DIR/.config" -mindepth 1 -maxdepth 1 -type d -print0)

  # Handle lone files at the top of .config (e.g. starship.toml)
  while IFS= read -r -d '' f; do
    safe_copy "$f" "$HOME/.config/$(basename "$f")"
  done < <(find "$REPO_DIR/.config" -mindepth 1 -maxdepth 1 -type f -print0)
}

install_scripts() {
  [[ "${MODULE_ENABLED[scripts]:-0}" -eq 0 ]] && return 0
  step "Scripts — ~/.local/bin/scripts"
  local src="$REPO_DIR/.local/bin/scripts"
  [[ -d "$src" ]] || { warn "No scripts directory found in repo."; return 0; }

  safe_copy_tree "$src" "$HOME/.local/bin/scripts" "scripts"

  if [[ "$OPT_DRY_RUN" -eq 0 ]]; then
    local chmod_count
    chmod_count="$(find "$HOME/.local/bin/scripts" -type f | wc -l)"
    find "$HOME/.local/bin/scripts" -type f -exec chmod +x {} +
    success "  ✓  $chmod_count script(s) marked executable"
  else
    run echo "chmod +x $HOME/.local/bin/scripts/*"
  fi
}

install_icons() {
  [[ "${MODULE_ENABLED[icons]:-0}" -eq 0 ]] && return 0
  step "Icons — ~/.icons"
  [[ -d "$REPO_DIR/.icons" ]] || { warn "No .icons directory found in repo."; return 0; }
  safe_copy_tree "$REPO_DIR/.icons" "$HOME/.icons" ".icons"
}

install_themes() {
  [[ "${MODULE_ENABLED[themes]:-0}" -eq 0 ]] && return 0
  step "Themes — ~/.themes"
  [[ -d "$REPO_DIR/.themes" ]] || { warn "No .themes directory found in repo."; return 0; }
  safe_copy_tree "$REPO_DIR/.themes" "$HOME/.themes" ".themes"
}

install_fonts() {
  [[ "${MODULE_ENABLED[fonts]:-0}" -eq 0 ]] && return 0
  step "Fonts — ~/.fonts"
  [[ -d "$REPO_DIR/.fonts" ]] || { warn "No .fonts directory found in repo."; return 0; }
  safe_copy_tree "$REPO_DIR/.fonts" "$HOME/.fonts" ".fonts"

  # Rebuild font cache
  if command -v fc-cache >/dev/null 2>&1; then
    info "  Rebuilding font cache…"
    run fc-cache -f
    success "  ✓  Font cache rebuilt"
  else
    warn "  fc-cache not found — install fontconfig and run: fc-cache -f"
  fi
}

install_dotfiles() {
  [[ "${MODULE_ENABLED[dotfiles]:-0}" -eq 0 ]] && return 0
  step "Root Dotfiles — $HOME"
  local files=(.Xresources .gtkrc-2.0)
  local found=0
  for f in "${files[@]}"; do
    if [[ -f "$REPO_DIR/$f" ]]; then
      safe_copy "$REPO_DIR/$f" "$HOME/$f"
      (( found++ )) || true
    fi
  done
  [[ "$found" -eq 0 ]] && warn "No root dotfiles found in repo."
}

# ══════════════════════════════════════════════════════════════════════════════
# PATH PATCHER
# ══════════════════════════════════════════════════════════════════════════════

patch_path() {
  step "PATH — ~/.local/bin"
  local bin_dir="$HOME/.local/bin"

  if [[ ":$PATH:" == *":$bin_dir:"* ]]; then
    success "  ✓  ~/.local/bin is already in PATH."
    return 0
  fi

  warn "  ~/.local/bin is not in your PATH."

  # Detect shell and pick appropriate rc file + syntax
  local shell_name rc_file path_line
  shell_name="$(basename "${SHELL:-sh}")"

  case "$shell_name" in
    zsh)
      rc_file="$HOME/.zshrc"
      path_line='export PATH="$HOME/.local/bin:$PATH"'
      ;;
    bash)
      rc_file="$HOME/.bashrc"
      path_line='export PATH="$HOME/.local/bin:$PATH"'
      ;;
    fish)
      rc_file="$HOME/.config/fish/conf.d/hypr_path.fish"
      path_line='fish_add_path $HOME/.local/bin'
      ;;
    ksh|mksh)
      rc_file="$HOME/.kshrc"
      path_line='export PATH="$HOME/.local/bin:$PATH"'
      ;;
    *)
      # POSIX fallback — sourced by most login shells
      rc_file="$HOME/.profile"
      path_line='export PATH="$HOME/.local/bin:$PATH"'
      ;;
  esac

  info "  Detected shell : $shell_name"
  info "  Target rc file : $rc_file"

  if confirm "  Append PATH export to $rc_file?"; then
    if [[ "$OPT_DRY_RUN" -eq 0 ]]; then
      mkdir -p "$(dirname "$rc_file")"
      # Guard against duplicates on re-runs
      if grep -qF ".local/bin" "$rc_file" 2>/dev/null; then
        success "  ✓  $rc_file already references ~/.local/bin — skipping."
      else
        {
          echo ""
          echo "# Added by Hypr dotfiles installer ($(date +"%Y-%m-%d"))"
          echo "$path_line"
        } >> "$rc_file"
        success "  ✓  Written to $rc_file"
        info "  Reload now with: source $rc_file"
      fi
    else
      run echo "append to $rc_file: $path_line"
    fi
  else
    warn "  Add manually to $rc_file:"
    echo -e "      ${D}$path_line${RESET}"
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# BANNER
# ══════════════════════════════════════════════════════════════════════════════

print_banner() {
  echo
  echo -e "${M}${BOLD}  ╔══════════════════════════════════════════╗${RESET}"
  echo -e "${M}${BOLD}  ║   Vicious Viper Dotfiles Installer       ║${RESET}"
  echo -e "${M}${BOLD}  ╚══════════════════════════════════════════╝${RESET}"
  echo
  printf "  ${D}%-16s${RESET} %s\n"  "Repo"    "$REPO_DIR"
  printf "  ${D}%-16s${RESET} %s\n"  "Target"  "$HOME"
  printf "  ${D}%-16s${RESET} %s\n"  "Version" "$SCRIPT_VERSION"
  printf "  ${D}%-16s${RESET} %s\n"  "Log"     "$LOG_FILE"
  [[ "$OPT_DRY_RUN"    -eq 1 ]] && printf "  ${Y}%-16s${RESET} ${Y}%s${RESET}\n" "Mode"   "DRY RUN — no changes will be made"
  [[ "$OPT_BACKUP"     -eq 0 ]] && printf "  ${R}%-16s${RESET} ${R}%s${RESET}\n" "Backup" "DISABLED"
  [[ "$OPT_SKIP_DEPS"  -eq 1 ]] && printf "  ${Y}%-16s${RESET} ${Y}%s${RESET}\n" "Deps"   "check skipped"
  echo
}

# ══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

print_summary() {
  echo
  echo -e "${BOLD}  ─────────────────────────────────────────────${RESET}"
  echo -e "${BOLD}  Install Summary${RESET}"
  echo -e "${BOLD}  ─────────────────────────────────────────────${RESET}"
  printf "  ${G}%-20s${RESET} %d\n" "Files copied"     "$COPIED"
  printf "  ${C}%-20s${RESET} %d\n" "Files backed up"  "$BACKED_UP"
  printf "  ${D}%-20s${RESET} %d\n" "Files skipped"    "$SKIPPED"
  [[ "$ERRORS" -gt 0 ]] \
    && printf "  ${R}%-20s${RESET} %d\n" "Errors"      "$ERRORS"
  echo

  if [[ "$OPT_DRY_RUN" -eq 1 ]]; then
    echo -e "  ${Y}Dry-run complete — no files were changed.${RESET}"
  elif [[ "$ERRORS" -gt 0 ]]; then
    warn "Install completed with $ERRORS error(s). Check the log: $LOG_FILE"
  elif [[ "$OPT_BACKUP" -eq 1 ]]; then
    echo -e "  ${G}${BOLD}✓ Done.${RESET}"
    echo
    info "Backup saved to  : $BACKUP_DIR"
    info "Undo anytime     : ./install.sh --uninstall"
    info "List backups     : ./install.sh --list-backups"
    info "Full log         : $LOG_FILE"
  else
    echo -e "  ${G}${BOLD}✓ Done.${RESET}  ${D}(no backup was created)${RESET}"
    info "Full log : $LOG_FILE"
  fi
  echo
}

# ══════════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ══════════════════════════════════════════════════════════════════════════════

# Dispatch simple commands first
[[ "$OPT_LIST_BACKUPS" -eq 1 ]] && { cmd_list_backups; exit 0; }
[[ "$OPT_UNINSTALL"    -eq 1 ]] && { cmd_uninstall;    exit $?; }

# Main install flow
print_banner
cmd_check_deps

# Module selection (interactive)
[[ "$OPT_SELECT" -eq 1 ]] && cmd_select_modules

echo
confirm "Install dotfiles into $HOME?" || { echo "  Aborted."; exit 0; }

# Initialise manifest and log
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/dev/null"
if [[ "$OPT_BACKUP" -eq 1 && "$OPT_DRY_RUN" -eq 0 ]]; then
  mkdir -p "$BACKUP_DIR"
  touch "$INSTALL_MANIFEST"
fi

# Run modules
install_config
install_scripts
install_icons
install_themes
install_fonts
install_dotfiles
patch_path

# Final summary
print_summary
