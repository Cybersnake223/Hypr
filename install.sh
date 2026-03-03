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

info()    { echo -e "${CYAN}[info]${RESET}  $*"; }
success() { echo -e "${GREEN}[ok]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[warn]${RESET}  $*"; }
error()   { echo -e "${RED}[error]${RESET} $*" >&2; }
die()     { error "$*"; exit 1; }

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}Usage:${RESET} $(basename "$0") [options]

${BOLD}Options:${RESET}
  --yes          Non-interactive, skip all prompts
  --no-backup    Skip backup step (dangerous)
  --dry-run      Show what would happen, make no changes
  --uninstall    Remove installed files using latest backup manifest
  -h, --help     Show this help

${BOLD}Examples:${RESET}
  ./install.sh                   # interactive install with backup
  ./install.sh --yes --dry-run   # preview without prompting
  ./install.sh --uninstall       # remove last installed dotfiles
EOF
}

# ─── Args ────────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)       YES=1;       shift ;;
    --no-backup) DO_BACKUP=0; shift ;;
    --dry-run)   DRY_RUN=1;   shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

# ─── Helpers ─────────────────────────────────────────────────────────────────
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
  # Record installed destination path into manifest for uninstall
  [[ "$DRY_RUN" -eq 1 ]] && return 0
  echo "$1" >> "$INSTALL_MANIFEST"
}

# ─── Dependency check ────────────────────────────────────────────────────────
check_deps() {
  info "Checking dependencies..."
  local missing=()
  for cmd in cp mkdir find date fc-cache; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "Missing optional/required commands: ${missing[*]}"
    warn "fc-cache is optional (fontconfig); others are required."
    # Only hard-fail on truly required ones
    for cmd in cp mkdir find date; do
      need_cmd "$cmd"
    done
  else
    success "All dependencies present."
  fi
}

# ─── Sanity check ────────────────────────────────────────────────────────────
[[ -f "$REPO_DIR/README.md" ]] || die "README.md not found. Run this script from inside the repo."

# ─── Uninstall mode ──────────────────────────────────────────────────────────
uninstall() {
  # Find the most recent backup with a manifest
  local latest_manifest
  latest_manifest="$(find "$BACKUP_BASE" -name '.manifest' -print0 \
    | sort -z | tr '\0' '\n' | tail -1)"

  [[ -f "$latest_manifest" ]] || die "No install manifest found in $BACKUP_BASE. Cannot uninstall."

  local backup_root
  backup_root="$(dirname "$latest_manifest")"

  warn "This will remove all files listed in: $latest_manifest"
  warn "Backed-up originals are in: $backup_root"
  confirm "Proceed with uninstall?" || { echo "Aborted."; exit 0; }

  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    local rel="${target#"$HOME/"}"
    local backup_copy="$backup_root/$rel"

    if [[ -e "$backup_copy" ]]; then
      info "Restoring: $backup_copy → $target"
      run cp -a "$backup_copy" "$target"
    else
      info "Removing (no backup): $target"
      run rm -rf "$target"
    fi
  done < "$latest_manifest"

  success "Uninstall complete. Originals restored from $backup_root."
}

if [[ "$UNINSTALL" -eq 1 ]]; then
  uninstall
  exit 0
fi

# ─── Backup helper ───────────────────────────────────────────────────────────
backup_if_exists() {
  local home_target="$1"
  local repo_source="$2"

  [[ "$DO_BACKUP" -eq 0 ]]  && return 0
  [[ -e "$repo_source" ]]   || return 0  
  [[ -e "$home_target" ]]   || return 0  

  local rel="${home_target#"$HOME/"}"
  local dest="$BACKUP_DIR/$rel"

  [[ "$DRY_RUN" -eq 0 ]] && mkdir -p "$(dirname "$dest")"
  info "Backup : $home_target → $dest"
  run cp -a "$home_target" "$dest"
}

# ─── Copy helpers ────────────────────────────────────────────────────────────
copy_tree_into() {
  local src="$1" dest="$2"
  [[ -d "$src" ]] || return 0
  run mkdir -p "$dest"
  run cp -a "$src/." "$dest/"
  success "Copied : $src → $dest"
}

copy_file() {
  local src="$1" dest="$2"
  [[ -f "$src" ]] || return 0
  run cp -a "$src" "$dest"
  record "$dest"
  success "Copied : $src → $dest"
}

# ─── Install ─────────────────────────────────────────────────────────────────
check_deps
echo
echo -e "${BOLD}Repo   :${RESET} $REPO_DIR"
echo -e "${BOLD}Target :${RESET} $HOME"
[[ "$DRY_RUN" -eq 1 ]] && echo -e "${BOLD}Mode   :${RESET} ${YELLOW}dry-run${RESET}"
echo

confirm "Copy dotfiles into your home directory?" || { echo "Aborted."; exit 0; }

# Initialise manifest early (only if not dry-run)
if [[ "$DO_BACKUP" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$BACKUP_DIR"
  touch "$INSTALL_MANIFEST"
fi

# 1) .config subdirs
echo -e "\n${BOLD}[.config]${RESET}"
if [[ -d "$REPO_DIR/.config" ]]; then
  while IFS= read -r -d '' repo_subdir; do
    name="$(basename "$repo_subdir")"
    backup_if_exists "$HOME/.config/$name" "$repo_subdir"
    record "$HOME/.config/$name"
  done < <(find "$REPO_DIR/.config" -mindepth 1 -maxdepth 1 -print0)
  copy_tree_into "$REPO_DIR/.config" "$HOME/.config"
fi

# 2) Scripts
echo -e "\n${BOLD}[scripts]${RESET}"
if [[ -d "$REPO_DIR/.local/bin/scripts" ]]; then
  while IFS= read -r -d '' repo_script; do
    name="$(basename "$repo_script")"
    backup_if_exists "$HOME/.local/bin/scripts/$name" "$repo_script"
    record "$HOME/.local/bin/scripts/$name"
  done < <(find "$REPO_DIR/.local/bin/scripts" -mindepth 1 -maxdepth 1 -print0)
  run mkdir -p "$HOME/.local/bin"
  copy_tree_into "$REPO_DIR/.local/bin/scripts" "$HOME/.local/bin/scripts"
  # Make scripts executable
  [[ "$DRY_RUN" -eq 0 ]] && find "$HOME/.local/bin/scripts" -type f -exec chmod +x {} +
  info "Scripts marked executable."
fi

# 3) Icons / Themes / Fonts
for d in .icons .themes .fonts; do
  echo -e "\n${BOLD}[$d]${RESET}"
  if [[ -d "$REPO_DIR/$d" ]]; then
    while IFS= read -r -d '' repo_item; do
      name="$(basename "$repo_item")"
      backup_if_exists "$HOME/$d/$name" "$repo_item"
      record "$HOME/$d/$name"
    done < <(find "$REPO_DIR/$d" -mindepth 1 -maxdepth 1 -print0)
    copy_tree_into "$REPO_DIR/$d" "$HOME/$d"
  fi
done

# 4) Root-level dotfiles
echo -e "\n${BOLD}[dotfiles]${RESET}"
for f in .Xresources .gtkrc-2.0; do
  backup_if_exists "$HOME/$f" "$REPO_DIR/$f"
  copy_file "$REPO_DIR/$f" "$HOME/$f"
done

# 5) Font cache
echo -e "\n${BOLD}[fonts]${RESET}"
if command -v fc-cache >/dev/null 2>&1; then
  info "Rebuilding font cache..."
  run fc-cache -f
  success "Font cache rebuilt."
else
  warn "fc-cache not found — skipping. Install fontconfig to enable."
fi

# 6) PATH check + auto-fix
echo -e "\n${BOLD}[PATH]${RESET}"
ZSHRC="$HOME/.zshrc"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  warn "$HOME/.local/bin is not in your PATH."
  if confirm "Append PATH export to $ZSHRC?"; then
    if [[ "$DRY_RUN" -eq 0 ]]; then
      echo "" >> "$ZSHRC"
      echo "# Added by Hypr dotfiles installer" >> "$ZSHRC"
      echo "$PATH_LINE" >> "$ZSHRC"
    else
      echo -e "  ${YELLOW}[dry-run]${RESET} Would append to $ZSHRC: $PATH_LINE"
    fi
    success "Added to $ZSHRC. Reload with: source ~/.zshrc"
  else
    warn "Add manually to ~/.zshrc:  $PATH_LINE"
  fi
else
  success "$HOME/.local/bin is already in PATH."
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo -e "${YELLOW}Dry-run complete. No files were changed.${RESET}"
elif [[ "$DO_BACKUP" -eq 1 ]]; then
  echo -e "${GREEN}✓ Done.${RESET} Backup → $BACKUP_DIR"
  echo -e "  To uninstall: ${BOLD}./install.sh --uninstall${RESET}"
else
  echo -e "${GREEN}✓ Done.${RESET} (No backup was created.)"
fi
