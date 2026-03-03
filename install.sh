#!/bin/bash
# ############################################################################################################
# ##   ______  __      __  _______   ________  _______    ______   __    __   ______   __    __  ________   ##
# ##  /      \|  \    /  \|       \ |        \|       \  /      \ |  \  |  \ /      \ |  \  /  \|        \  ##
# ## |  $$$$$$\\$$\  /  $$| $$$$$$$\| $$$$$$$$| $$$$$$$\|  $$$$$$\| $$\ | $$|  $$$$$$\| $$ /  $$| $$$$$$$$  ##
# ## | $$   \$$ \$$\/  $$ | $$__/ $$| $$__    | $$__| $$| $$___\$$| $$$\| $$| $$__| $$| $$/  $$ | $$__      ##
# ## | $$        \$$  $$  | $$    $$| $$  \   | $$    $$ \$$    \ | $$$$\ $$| $$    $$| $$  $$  | $$  \     ##
# ## | $$   __    \$$$$   | $$$$$$$\| $$$$$   | $$$$$$$\ _\$$$$$$\| $$\$$ $$| $$$$$$$$| $$$$$\  | $$$$$     ##
# ## | $$__/  \   | $$    | $$__/ $$| $$_____ | $$  | $$|  \__| $$| $$ \$$$$| $$  | $$| $$ \$$\ | $$_____   ##
# ##  \$$    $$   | $$    | $$    $$| $$     \| $$  | $$ \$$    $$| $$  \$$$| $$  | $$| $$  \$$\| $$     \  ##
# ##   \$$$$$$     \$$     \$$$$$$$  \$$$$$$$$ \$$   \$$  \$$$$$$  \$$   \$$ \$$   \$$ \$$   \$$ \$$$$$$$$  ##
# ##                                                                                                        ##
# ## Vicious Viper Config Installer                                                                         ##
# ## Created by Cybersnake                                                                                  ##
# ############################################################################################################

set -Eeuo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Hypr dotfiles installer — https://github.com/Cybersnake223/Hypr
# ─────────────────────────────────────────────────────────────────────────────

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +"%Y%m%d-%H%M%S")"
BACKUP_BASE="${XDG_DATA_HOME:-$HOME/.local/share}/hypr-dotfiles-backups"
BACKUP_DIR="$BACKUP_BASE/$TS"
INSTALL_MANIFEST="$BACKUP_DIR/.manifest"

YES=0
DO_BACKUP=1
DRY_RUN=0
UNINSTALL=0

# ─── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
  CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
else
  RED=''; YELLOW=''; GREEN=''; CYAN=''; BOLD=''; RESET=''
fi

info()    { echo -e "${CYAN}[info]${RESET}   $*"; }
success() { echo -e "${GREEN}[ok]${RESET}     $*"; }
warn()    { echo -e "${YELLOW}[warn]${RESET}   $*"; }
error()   { echo -e "${RED}[error]${RESET}  $*" >&2; }
die()     { error "$*"; exit 1; }
step()    { echo -e "\n${BOLD}$*${RESET}"; }

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}Usage:${RESET} $(basename "$0") [options]

${BOLD}Options:${RESET}
  --yes          Non-interactive, skip all prompts
  --no-backup    Skip backup step (dangerous, blocks uninstall)
  --dry-run      Show what would happen, make no changes
  --uninstall    Restore originals from the latest backup
  -h, --help     Show this help

${BOLD}Examples:${RESET}
  ./install.sh                   # interactive install with backup
  ./install.sh --yes             # non-interactive install
  ./install.sh --dry-run         # preview without prompting
  ./install.sh --yes --dry-run   # preview without prompting or interaction
  ./install.sh --uninstall       # restore backed-up originals
EOF
}

# ─── Args ────────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)       YES=1;        shift ;;
    --no-backup) DO_BACKUP=0;  shift ;;
    --dry-run)   DRY_RUN=1;    shift ;;
    --uninstall) UNINSTALL=1;  shift ;;
    -h|--help)   usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

# Conflict guard
if [[ "$UNINSTALL" -eq 1 && "$DO_BACKUP" -eq 0 ]]; then
  die "--uninstall and --no-backup cannot be used together."
fi

# ─── Core helpers ────────────────────────────────────────────────────────────
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo -e "  ${YELLOW}[dry-run]${RESET} $*"
  else
    "$@"
  fi
}

confirm() {
  [[ "$YES" -eq 1 ]] && return 0
  read -r -p "$1 [y/N] " ans || true
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: '$1'. Please install it first."
}

record() {
  [[ "$DRY_RUN" -eq 1 ]] && return 0
  echo "$1" >> "$INSTALL_MANIFEST"
}

# ─── Dependency check ────────────────────────────────────────────────────────
check_deps() {
  step "[deps]"
  local missing=()
  for cmd in cp mkdir find date; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    die "Missing required commands: ${missing[*]}"
  fi

  success "All required dependencies present."

  # fc-cache is optional (fontconfig)
  command -v fc-cache >/dev/null 2>&1 \
    && success "fc-cache found." \
    || warn "fc-cache not found — font cache rebuild will be skipped. Install fontconfig to enable."
}

# ─── Sanity check ────────────────────────────────────────────────────────────
[[ -f "$REPO_DIR/README.md" ]] || die "README.md not found. Run this script from inside the repo."

# ─── Uninstall ───────────────────────────────────────────────────────────────
uninstall() {
  step "[uninstall]"

  local latest_manifest
  latest_manifest="$(find "$BACKUP_BASE" -name '.manifest' -print0 \
    | sort -z | tr '\0' '\n' | tail -1)"

  [[ -f "$latest_manifest" ]] \
    || die "No install manifest found in $BACKUP_BASE. Cannot uninstall."

  local backup_root
  backup_root="$(dirname "$latest_manifest")"

  # Refuse if backup dir is empty (was installed with --no-backup)
  local backup_count
  backup_count="$(find "$backup_root" -not -name '.manifest' -not -path "$backup_root" | wc -l)"
  if [[ "$backup_count" -eq 0 ]]; then
    die "Backup directory is empty — install was likely run with --no-backup.\nRefusing to uninstall to avoid data loss."
  fi

  warn "Restoring from backup: $backup_root"
  warn "Files with no backup will be LEFT AS-IS (never deleted)."
  confirm "Proceed with uninstall?" || { echo "Aborted."; exit 0; }

  local restored=0 skipped=0

  while IFS= read -r target; do
    [[ -z "$target" ]] && continue

    local rel="${target#"$HOME/"}"
    local backup_copy="$backup_root/$rel"

    if [[ -e "$backup_copy" ]]; then
      info "Restoring : $backup_copy → $target"
      run mkdir -p "$(dirname "$target")"
      run cp -a "$backup_copy" "$target"
      (( restored++ )) || true
    else
      warn "No backup  : $target — skipping (left as-is)"
      (( skipped++ )) || true
    fi
  done < "$latest_manifest"

  echo
  success "Uninstall complete."
  info "$restored item(s) restored from backup."
  [[ "$skipped" -gt 0 ]] \
    && warn "$skipped item(s) had no prior backup and were left untouched."
  info "Backup root: $backup_root"
}

if [[ "$UNINSTALL" -eq 1 ]]; then
  uninstall
  exit 0
fi

# ─── Backup helper ───────────────────────────────────────────────────────────
backup_if_exists() {
  local home_target="$1"
  local repo_source="$2"

  [[ "$DO_BACKUP" -eq 0 ]] && return 0
  [[ -e "$repo_source" ]]  || return 0   
  [[ -e "$home_target" ]]  || return 0   

  local rel="${home_target#"$HOME/"}"
  local dest="$BACKUP_DIR/$rel"

  [[ "$DRY_RUN" -eq 0 ]] && mkdir -p "$(dirname "$dest")"
  info "Backup  : $home_target → $dest"
  run cp -a "$home_target" "$dest"
}

# ─── Copy helpers ────────────────────────────────────────────────────────────
copy_tree_into() {
  local src="$1" dest="$2"
  [[ -d "$src" ]] || return 0
  run mkdir -p "$dest"
  run cp -a "$src/." "$dest/"
  success "Copied  : $src → $dest"
}

copy_file() {
  local src="$1" dest="$2"
  [[ -f "$src" ]] || return 0
  run cp -a "$src" "$dest"
  record "$dest"
  success "Copied  : $src → $dest"
}

# ─── Banner ──────────────────────────────────────────────────────────────────
check_deps

echo
echo -e "${BOLD}  Hypr Dotfiles Installer${RESET}"
echo -e "  Repo   : $REPO_DIR"
echo -e "  Target : $HOME"
[[ "$DRY_RUN"   -eq 1 ]] && echo -e "  Mode   : ${YELLOW}dry-run${RESET}"
[[ "$DO_BACKUP" -eq 0 ]] && echo -e "  Backup : ${RED}disabled${RESET}"
echo

confirm "Copy dotfiles into your home directory?" || { echo "Aborted."; exit 0; }

# Init manifest (real run only)
if [[ "$DO_BACKUP" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$BACKUP_DIR"
  touch "$INSTALL_MANIFEST"
fi

# ─── 1. .config subdirs ──────────────────────────────────────────────────────
step "[.config]"
if [[ -d "$REPO_DIR/.config" ]]; then
  while IFS= read -r -d '' repo_subdir; do
    name="$(basename "$repo_subdir")"
    backup_if_exists "$HOME/.config/$name" "$repo_subdir"
    record "$HOME/.config/$name"
  done < <(find "$REPO_DIR/.config" -mindepth 1 -maxdepth 1 -print0)
  copy_tree_into "$REPO_DIR/.config" "$HOME/.config"
fi

# ─── 2. Scripts ──────────────────────────────────────────────────────────────
step "[scripts]"
if [[ -d "$REPO_DIR/.local/bin/scripts" ]]; then
  while IFS= read -r -d '' repo_script; do
    name="$(basename "$repo_script")"
    backup_if_exists "$HOME/.local/bin/scripts/$name" "$repo_script"
    record "$HOME/.local/bin/scripts/$name"
  done < <(find "$REPO_DIR/.local/bin/scripts" -mindepth 1 -maxdepth 1 -print0)
  run mkdir -p "$HOME/.local/bin"
  copy_tree_into "$REPO_DIR/.local/bin/scripts" "$HOME/.local/bin/scripts"
  [[ "$DRY_RUN" -eq 0 ]] && find "$HOME/.local/bin/scripts" -type f -exec chmod +x {} +
  success "Scripts marked executable."
fi

# ─── 3. Icons / Themes / Fonts ───────────────────────────────────────────────
for d in .icons .themes .fonts; do
  step "[$d]"
  if [[ -d "$REPO_DIR/$d" ]]; then
    while IFS= read -r -d '' repo_item; do
      name="$(basename "$repo_item")"
      backup_if_exists "$HOME/$d/$name" "$repo_item"
      record "$HOME/$d/$name"
    done < <(find "$REPO_DIR/$d" -mindepth 1 -maxdepth 1 -print0)
    copy_tree_into "$REPO_DIR/$d" "$HOME/$d"
  fi
done

# ─── 4. Root dotfiles ────────────────────────────────────────────────────────
step "[dotfiles]"
for f in .Xresources .gtkrc-2.0; do
  backup_if_exists "$HOME/$f" "$REPO_DIR/$f"
  copy_file "$REPO_DIR/$f" "$HOME/$f"
done

# ─── 5. Font cache ───────────────────────────────────────────────────────────
step "[fonts]"
if command -v fc-cache >/dev/null 2>&1; then
  info "Rebuilding font cache..."
  run fc-cache -f
  success "Font cache rebuilt."
else
  warn "fc-cache not found — skipping."
fi

# ─── 6. PATH check ───────────────────────────────────────────────────────────
step "[PATH]"
ZSHRC="$HOME/.zshrc"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  warn "~/.local/bin is not in your PATH."
  if confirm "Append PATH export to $ZSHRC?"; then
    if [[ "$DRY_RUN" -eq 0 ]]; then
      { echo ""; echo "# Added by Hypr dotfiles installer"; echo "$PATH_LINE"; } >> "$ZSHRC"
    else
      echo -e "  ${YELLOW}[dry-run]${RESET} Would append to $ZSHRC: $PATH_LINE"
    fi
    success "Added to $ZSHRC — reload with: source ~/.zshrc"
  else
    warn "Add manually to ~/.zshrc:  $PATH_LINE"
  fi
else
  success "~/.local/bin is already in PATH."
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo -e "${YELLOW}Dry-run complete. No files were changed.${RESET}"
elif [[ "$DO_BACKUP" -eq 1 ]]; then
  echo -e "${GREEN}✓ Done.${RESET} Backup saved to: $BACKUP_DIR"
  echo -e "  Uninstall anytime: ${BOLD}./install.sh --uninstall${RESET}"
else
  echo -e "${GREEN}✓ Done.${RESET} (No backup was created.)"
fi
