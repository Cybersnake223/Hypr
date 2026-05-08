<div align="center">

![Cybersnake Logo](assets/cslogo.png)

![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Righteous&weight=600&size=75&duration=1200&pause=1000&color=A024F7&center=true&vCenter=true&random=false&width=600&height=80&lines=Vicious+Viper)

*A Hyprland dotfiles setup for Arch Linux — dynamic theming, clean workflows, curated tools.*

[![Last Commit](https://img.shields.io/github/last-commit/Cybersnake223/Hypr/main?style=for-the-badge&label=last%20commit&color=A024F7)](https://github.com/Cybersnake223/Hypr/commits/main)
[![Repo Size](https://img.shields.io/github/repo-size/Cybersnake223/Hypr?style=for-the-badge&label=size&color=A024F7)](https://github.com/Cybersnake223/Hypr)
[![Stars](https://img.shields.io/github/stars/Cybersnake223/Hypr?style=for-the-badge&color=A024F7)](https://github.com/Cybersnake223/Hypr/stargazers)
[![License](https://img.shields.io/github/license/Cybersnake223/Hypr?style=for-the-badge&color=A024F7)](LICENSE)
[![Forks](https://img.shields.io/github/forks/Cybersnake223/Hypr?style=for-the-badge&color=A024F7)](https://github.com/Cybersnake223/Hypr/network/members)

[Preview](#-preview) • [Stack](#-stack) • [Prerequisites](#-prerequisites) • [Installation](#-installation) • [Flags](#-installer-flags) • [Theming](#-theming) • [Troubleshooting](#-troubleshooting) • [Security](#-security) • [License](#-license)

</div>

---

> [!NOTE]
> This setup is **primarily tuned for laptops**. Desktop users should review `auto-cpufreq` settings and Waybar's battery module before installing.

---

## 🖼 Preview

| | |
|---|---|
| ![Desktop 1](assets/asset1.png) | ![Desktop 2](assets/asset10.png) |
| ![Desktop 3](assets/asset11.png) | ![Desktop 4](assets/asset12.png) |
| ![Desktop 5](assets/asset2.png) | ![Desktop 6](assets/asset3.png) |
| ![Desktop 7](assets/asset4.png) | ![Desktop 8](assets/asset5.png) |
| ![Desktop 9](assets/asset6.png) | ![Desktop 10](assets/asset7.png) |
| ![Desktop 11](assets/asset8.png) | ![Desktop 12](assets/asset9.png) |

---

## 🧩 Stack

| Role | Tool |
|---|---|
| 🏗 Base | [Arch Linux](https://archlinux.org/) |
| 🪟 Compositor | [Hyprland](https://hyprland.org/) |
| 📊 Bar | [Waybar](https://github.com/Alexays/Waybar) |
| 🖥 Terminal | [Foot](https://github.com/DanteAlighierin/foot) |
| 🐚 Shell | [Zsh](https://zsh.sourceforge.io/) + [Starship](https://starship.rs/) |
| 🔔 Notifications | [Mako](https://github.com/emersion/mako) |
| 🚀 Launcher | [Rofi (lbonn/wayland fork)](https://github.com/lbonn/rofi) |
| 🖼 Wallpaper | [Aww](https://codeberg.org/LGFae/awww) |
| 🌐 Browser | [Zen Browser](https://zen-browser.app/) |
| 🔒 Locker | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| 📁 File Manager | [Nautilus](https://gitlab.gnome.org/GNOME/nautilus) (GUI) / [Yazi](https://yazi-rs.github.io/) (TUI) |
| 📝 Editor | [Neovim](https://neovim.io/) |
| 🎨 Theming | [Matugen](https://github.com/InioX/matugen) (Material You — wallpaper-based) |
| 📡 System Info | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| 🎵 Audio | [cmus](https://cmus.github.io/) + [Cava](https://github.com/karlstav/cava) + [mpv](https://mpv.io/) |
| 📈 Monitor | [btop](https://github.com/aristocratos/btop) |
| ⬇ Downloads | [aria2](https://aria2.github.io/) |

---

## 📦 Prerequisites

> [!IMPORTANT]
> The installer checks for ecosystem packages and warns about anything missing, but **it won't stop the install**. Ensure the packages below are present before running `install.sh` for a fully working desktop on first boot.

### Core Packages

```bash
yay -S hyprland waybar foot zsh rofi-lbonn-wayland-git mako swww advcpmv \
        hyprlock thunar yazi zen-browser-bin fastfetch matugen-bin \
        btop cava cmus mpv aria2 starship neovim
```

### Required Supporting Packages

| Package | Purpose |
|---|---|
| `matugen` | Wallpaper-based dynamic color palette (Material You) |
| `xdg-desktop-portal-hyprland` | Wayland portal — screenshare, file picker |
| `polkit-gnome` | Authentication agent for GUI prompts |
| `grim` + `slurp` + `wl-clipboard` | Screenshot toolchain |
| `brightnessctl` | Monitor and keyboard brightness control |
| `pavucontrol` | PulseAudio / PipeWire volume GUI |
| `xorg-xwayland` | Legacy X11 app compatibility |
| `pipewire` + `pipewire-pulse` + `pipewire-alsa` | Audio stack |
| `wireplumber` | PipeWire session manager |
| `bleachbit` | Required by the system cleaner script |
| `networkmanager` + `nmcli` | Network management |
| `bluez` + `bluez-tools` | Bluetooth support |
| `advcpmv` *(AUR)* | `cp`/`mv` with progress bars |
| `eza` | Modern `ls` replacement |
| `fd` | Fast `find` replacement |
| `bat` | `cat` with syntax highlighting |

### Fonts

The `.fonts/` directory is bundled in this repo and installed automatically by `install.sh`. To install manually:

```bash
yay -S ttf-jetbrains-mono-nerd ttf-font-awesome nerd-fonts-symbols-only
```

**Required fonts:**
- **JetBrains Mono Nerd Font** — primary monospace
- **Awesome Fonts** — icon font for Waybar / Rofi
- **Icomoon Feather** — supplementary icon set
- **Nerd Font Symbols** — fallback glyph coverage

---

## ⚡ Installation

> [!CAUTION]
> The installer backs up existing files before overwriting them, but **only for paths present in this repo**. No unrelated configs are touched. Always run with `--dry-run` first if you're unsure.

### Quick Install

```bash
git clone https://github.com/Cybersnake223/Hypr
cd Hypr
chmod +x install.sh
./install.sh
```

**The installer will:**

1. ✅ Verify core system utilities are available
2. 🔍 Check all Hyprland ecosystem packages and warn about anything missing
3. 🗂 Back up every existing file it will overwrite into a **timestamped directory**
4. 📁 Copy configs, scripts, icons, themes, and fonts into `$HOME`
5. 🔑 Mark all scripts in `~/.local/bin/scripts` as executable
6. 🔤 Rebuild the font cache via `fc-cache -f`
7. 🛤 Detect your shell and optionally patch `PATH` in the correct rc file
8. 📋 Print a full install summary with counts and log path

**Backups are saved to:**

```
~/.local/share/hypr-dotfiles-backups/<YYYYMMDD-HHMMSS>/
```

Or `$XDG_DATA_HOME/hypr-dotfiles-backups/<timestamp>/` if `$XDG_DATA_HOME` is set. A `.manifest` file inside each backup records every installed path — used by `--uninstall` to restore originals precisely.

---

### Manual Install

If you prefer not to use the script:

```bash
cp -r .config/* "$HOME/.config"
cp -r .local/bin/scripts "$HOME/.local/bin"
cp -r .icons "$HOME/.icons"
cp -r .themes "$HOME/.themes"
cp -r .fonts "$HOME/.fonts"
cp .Xresources "$HOME/.Xresources"
cp .gtkrc-2.0 "$HOME/.gtkrc-2.0"
find "$HOME/.local/bin/scripts" -type f -exec chmod +x {} +
fc-cache -f
```

Add `~/.local/bin` to your PATH (adjust for your shell):

```bash
# zsh / bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# fish
fish_add_path $HOME/.local/bin
```

> [!NOTE]
> `nwg-look` may silently overwrite `.gtkrc-2.0`. If GTK 2 theming breaks after running it, re-copy from the repo:
> ```bash
> cp /path/to/Hypr/.gtkrc-2.0 ~/.gtkrc-2.0
> ```

---

## 🚩 Installer Flags

| Flag | Description |
|---|---|
| `--dry-run` | Preview every action — **zero changes made** |
| `--yes` | Non-interactive, auto-confirm all prompts |
| `--select` | Interactively toggle which modules to install |
| `--no-backup` | Skip backup step (**dangerous** — disables `--uninstall`) |
| `--uninstall` | Restore originals from the most recent backup |
| `--list-backups` | Show all backups with timestamps, file counts, and sizes |
| `--skip-deps` | Skip the ecosystem dependency check |
| `-h`, `--help` | Show usage |

### Usage Examples

```bash
# Preview everything before committing — recommended for first-timers
./install.sh --dry-run

# Non-interactive install (great for scripted setups)
./install.sh --yes

# Choose only specific modules (configs, scripts, fonts, etc.)
./install.sh --select

# Fast re-install — skip dep check, auto-confirm
./install.sh --yes --skip-deps

# See all available backups before restoring
./install.sh --list-backups

# Undo the last install and restore your original configs
./install.sh --uninstall
```

### Modular Install — `--select`

The `--select` flag opens an interactive TUI letting you toggle individual modules before committing:

```
[✓]  1  .config       Application configs (hypr, waybar, rofi, nvim, zsh…)
[✓]  2  scripts       Custom scripts → ~/.local/bin/scripts
[ ]  3  .icons        Icon theme
[✓]  4  .themes       GTK/Qt themes
[✓]  5  .fonts        Custom fonts (triggers fc-cache rebuild)
[✓]  6  dotfiles      Root dotfiles (.Xresources, .gtkrc-2.0)
```

Type a number to toggle, then press Enter to confirm.

### Shell-Aware PATH Patching

| Shell | File patched |
|---|---|
| `zsh` | `~/.zshrc` |
| `bash` | `~/.bashrc` |
| `fish` | `~/.config/fish/conf.d/hypr_path.fish` |
| `ksh` / `mksh` | `~/.kshrc` |
| Other | `~/.profile` (POSIX fallback) |

Re-running the installer won't stack duplicate `export PATH=` lines — it guards against this automatically.

---

## 🎨 Theming

Color theming is powered by **[Matugen](https://github.com/InioX/matugen)** — a Material You color extraction tool that derives a full palette from your active wallpaper. Every component that supports it (Waybar, Rofi, Mako, Hyprlock, GTK apps, terminal) recolors automatically whenever you change wallpaper.

### Changing Wallpaper

```bash
swww img /path/to/wallpaper.jpg --transition-type grow --transition-pos center
matugen image /path/to/wallpaper.jpg
```

### Force Regenerate Colors

If colors fall out of sync after a config update:

```bash
matugen image ~/.config/hyprwat/current_wallpaper
```

Matugen templates live in `.config/matugen/` and map Material You color tokens to each app's config format. Edit these to customize per-app color application.

---

## 🔧 Troubleshooting

**Waybar / Rofi / Mako not launching**

Run the installer's built-in ecosystem check:

```bash
./install.sh --dry-run
```

Or verify manually:

```bash
which hyprland waybar rofi mako swww hyprlock matugen foot zsh
```

---

**Scripts not working (`command not found`)**

`~/.local/bin` is not in your `$PATH`. Add it manually:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

---

**GTK 2 theming broken after `nwg-look`**

`nwg-look` silently overwrites `.gtkrc-2.0`. Re-apply from the repo:

```bash
cp /path/to/Hypr/.gtkrc-2.0 ~/.gtkrc-2.0
```

---

**Colors didn't update after wallpaper change**

Regenerate the Matugen palette manually:

```bash
matugen image /path/to/your/wallpaper
```

---

**Font icons showing as boxes**

Fonts aren't installed or the cache needs rebuilding:

```bash
yay -S ttf-font-awesome nerd-fonts-symbols-only
fc-cache -f
```

---

**`--uninstall` says "No install manifest found"**

The installer was never run from this repo, or the backup directory was deleted. See the [Wiki → Uninstalling](https://github.com/Cybersnake223/Hypr/wiki/Uninstalling) for the full manual file list.

---

**Something went wrong mid-install**

Every run writes a plain-text log to `/tmp/hypr-install-<timestamp>.log`:

```bash
cat /tmp/hypr-install-*.log | tail -50
```

---

## 🔐 Security

Please **do not open a public GitHub issue** to report security vulnerabilities. See [SECURITY.md](SECURITY.md) for the responsible disclosure process.

---

## 📄 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

---

<div align="center">

![Footer](https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.png)

Made with 💜 by [Cybersnake](https://github.com/Cybersnake223)

</div>
