<div align="center">

![Cybersnake Logo](assets/cslogo.png)

![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Righteous&weight=600&size=75&duration=1200&pause=1000&color=A024F7&center=true&vCenter=true&random=false&width=600&height=80&lines=Vicious+Viper)

**A wallpaper-synced Hyprland setup for Arch Linux with automated backups, modular installs, curated tools, and a clean daily workflow.**

[![Last Commit](https://img.shields.io/github/last-commit/Cybersnake223/Hypr/main?style=for-the-badge&label=last%20commit&color=A024F7)](https://github.com/Cybersnake223/Hypr/commits/main)
[![Repo Size](https://img.shields.io/github/repo-size/Cybersnake223/Hypr?style=for-the-badge&label=size&color=A024F7)](https://github.com/Cybersnake223/Hypr)
[![Stars](https://img.shields.io/github/stars/Cybersnake223/Hypr?style=for-the-badge&color=A024F7)](https://github.com/Cybersnake223/Hypr/stargazers)
[![Forks](https://img.shields.io/github/forks/Cybersnake223/Hypr?style=for-the-badge&color=A024F7)](https://github.com/Cybersnake223/Hypr/network/members)
[![Issues](https://img.shields.io/github/issues/Cybersnake223/Hypr?style=for-the-badge&color=A024F7)](https://github.com/Cybersnake223/Hypr/issues)
[![License](https://img.shields.io/github/license/Cybersnake223/Hypr?style=for-the-badge&color=A024F7)](LICENSE)

[Preview](#-preview) • [Features](#-features) • [Stack](#-stack) • [Prerequisites](#-prerequisites) • [Installation](#-installation) • [File Layout](#-file-layout) • [Flags](#-installer-flags) • [Keybinds](#-keybinds) • [Theming](#-theming) • [Zen Browser](#-zen-browser) • [Updating](#-updating) • [Troubleshooting](#-troubleshooting) • [Security](#-security) • [License](#-license)

</div>

---

> [!NOTE]
> This setup is primarily tuned for laptops. Desktop users should review battery, brightness, and power-related modules before installing.

## 🖼 Preview

A few snapshots from the current setup.

| ![Desktop 1](assets/asset1.png) | ![Desktop 2](assets/asset10.png) |
| ![Desktop 3](assets/asset11.png) | ![Desktop 4](assets/asset12.png) |
| ![Desktop 5](assets/asset2.png) | ![Desktop 6](assets/asset3.png) |
| ![Desktop 7](assets/asset4.png) | ![Desktop 8](assets/asset5.png) |
| ![Desktop 9](assets/asset6.png) | ![Desktop 10](assets/asset7.png) |
| ![Desktop 11](assets/asset8.png) | ![Desktop 12](assets/asset9.png) |


## ✨ Features

- Safe installer with timestamped backups before overwriting files
- Dry-run mode for previewing every action
- Selective install mode for modules like configs, scripts, fonts, and themes
- Automatic font cache rebuild after font installation
- Shell-aware `PATH` patching
- Material You-style wallpaper-driven theming with Matugen
- Curated CLI + GUI workflow for Hyprland on Arch Linux
- Custom configs for Hyprland, Waybar, Rofi, Neovim, Zsh, Yazi, Kitty, Foot, Mako, MPV, Zen, and more

---

## 🧩 Stack

| Role | Tool |
|---|---|
| Base | [Arch Linux](https://archlinux.org/) |
| Compositor | [Hyprland](https://hyprland.org/) |
| Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Terminals | [Kitty](https://sw.kovidgoyal.net/kitty/) + [Foot](https://codeberg.org/dnkl/foot) |
| Shell | [Zsh](https://zsh.sourceforge.io/) + [Starship](https://starship.rs/) |
| Notifications | [Mako](https://github.com/emersion/mako) |
| Launcher | [Rofi Wayland fork](https://github.com/lbonn/rofi) |
| Browser | [Zen Browser](https://zen-browser.app/) |
| Locker | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| File Managers | [Nautilus](https://gitlab.gnome.org/GNOME/nautilus) + [Yazi](https://yazi-rs.github.io/) |
| Editor | [Neovim](https://neovim.io/) |
| Theming | [Matugen](https://github.com/InioX/matugen) |
| System Info | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| Audio | [cmus](https://cmus.github.io/) + [Cava](https://github.com/karlstav/cava) + [mpv](https://mpv.io/) |
| Monitoring | [btop](https://github.com/aristocratos/btop) |
| Downloads | [aria2](https://aria2.github.io/) |

---

## 📦 Prerequisites

> [!IMPORTANT]
> The installer checks core utilities and warns about missing ecosystem packages, but it does not block installation unless critical system tools are missing.

### Core packages

```bash
yay -S hyprland waybar foot kitty zsh rofi-lbonn-wayland-git mako \
  hyprlock matugen-bin btop yazi fastfetch neovim starship \
  cava cmus mpv nautilus zen-browser-bin aria2
```

### Supporting packages

| Package | Purpose |
|---|---|
| `xdg-desktop-portal-hyprland` | Wayland portal support |
| `polkit-gnome` | GUI authentication agent |
| `grim` + `slurp` + `wl-clipboard` | Screenshots and clipboard |
| `brightnessctl` | Brightness control |
| `pavucontrol` | Audio control GUI |
| `pipewire` + `pipewire-pulse` + `pipewire-alsa` | Audio stack |
| `wireplumber` | PipeWire session manager |
| `networkmanager` | Networking |
| `bluez` + `bluez-tools` | Bluetooth |
| `xorg-xwayland` | X11 compatibility |
| `eza` | Modern `ls` replacement |
| `fd` | Fast file search |
| `bat` | Syntax-highlighted `cat` |
| `advcpmv` | `cp` and `mv` with progress |
| `bleachbit` | Used by the cleaner script |

### Fonts

This repo ships a `.fonts/` directory and the installer rebuilds the font cache automatically. If you want to install fonts manually:

```bash
yay -S ttf-jetbrains-mono-nerd ttf-font-awesome nerd-fonts-symbols-only
```

Recommended fonts:

- JetBrains Mono Nerd Font
- Font Awesome
- Nerd Font Symbols
- Icomoon Feather

---

## ⚡ Installation

> [!CAUTION]
> Run the installer in `--dry-run` mode first if you are unsure. It is designed to back up overwritten files before copying new ones into place.

### Quick install

```bash
git clone https://github.com/Cybersnake223/Hypr
cd Hypr
chmod +x install.sh
./install.sh --dry-run
./install.sh
```

### What the installer does

1. Checks core system utilities
2. Warns about missing desktop ecosystem packages
3. Creates a timestamped backup for files it may overwrite
4. Copies selected modules into your home directory
5. Marks scripts in `~/.local/bin/scripts` as executable
6. Rebuilds the font cache
7. Optionally patches your shell config to add `~/.local/bin` to `PATH`
8. Prints a summary with log location and backup information

### Backup location

```text
~/.local/share/hypr-dotfiles-backups/<YYYYMMDD-HHMMSS>/
```

If `XDG_DATA_HOME` is set, that location is used instead. Each backup contains a `.manifest` file used by `--uninstall`.

### Manual install

If you prefer to install without the script:

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

Add `~/.local/bin` to your shell `PATH` if needed:

```bash
# bash / zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# fish
fish_add_path $HOME/.local/bin
```

---

## 📂 File Layout

This is the rough install layout used by the repo:

```text
~
├── .config/
│   ├── hypr/
│   ├── waybar/
│   ├── rofi/
│   ├── nvim/
│   ├── zsh/
│   ├── mako/
│   ├── kitty/
│   ├── foot/
│   ├── yazi/
│   ├── mpv/
│   └── ...
├── .local/
│   └── bin/
│       └── scripts/
├── .fonts/
├── .icons/
├── .themes/
├── .Xresources
└── .gtkrc-2.0
```

### Install modules

The installer can selectively install these modules:

- `.config`
- `scripts`
- `.icons`
- `.themes`
- `.fonts`
- `dotfiles`

---

## 🚩 Installer Flags

| Flag | Description |
|---|---|
| `--dry-run` | Preview actions without changing files |
| `--yes` | Skip confirmation prompts |
| `--select` | Interactively choose which modules to install |
| `--no-backup` | Disable backups |
| `--uninstall` | Restore files from the most recent backup |
| `--list-backups` | Show available backups |
| `--skip-deps` | Skip the ecosystem dependency check |
| `-h`, `--help` | Show help |

### Usage examples

```bash
# safest first run
./install.sh --dry-run

# normal interactive install
./install.sh

# non-interactive install
./install.sh --yes

# choose modules manually
./install.sh --select

# reinstall quickly
./install.sh --yes --skip-deps

# inspect previous backups
./install.sh --list-backups

# restore originals from latest backup
./install.sh --uninstall
```

### Shell-aware PATH patching

The installer detects your shell and updates the appropriate file when needed.

| Shell | File |
|---|---|
| `zsh` | `~/.zshrc` |
| `bash` | `~/.bashrc` |
| `fish` | `~/.config/fish/conf.d/hypr_path.fish` |
| `ksh` / `mksh` | `~/.kshrc` |
| Other | `~/.profile` |

---

## ⌨️ Keybinds

> [!NOTE]
> The setup uses `ALT` as the main modifier.

> [!IMPORTANT]
> Some web shortcuts are personal convenience binds. Review and edit them in your Hyprland config before adopting this setup as-is.

### System

| Keybind | Action |
|---|---|
| `F1` | Toggle mute (speakers) |
| `F2` | Volume down |
| `F3` | Volume up |
| `F4` | Toggle mute (microphone) |
| `F7` | Toggle Wi-Fi |
| `F9` | Lock screen |
| `F11` | Brightness down |
| `F12` | Brightness up |
| `Print` | Screenshot |

### Apps and launchers

| Keybind | Action |
|---|---|
| `ALT + Enter` | Terminal |
| `ALT + D` | App launcher |
| `ALT + R` | Yazi |
| `ALT + N` | Neovim |
| `ALT + M` | cmus |
| `ALT + H` | btop |
| `ALT + T` | aerc |
| `ALT + S` | LocalSend |
| `ALT + E` | Emoji picker |
| `ALT + X` | Power menu |
| `ALT + B` | Bluetooth menu |
| `ALT + L` | AirPods TUI |
| `ALT + Y` | YouTube downloader |
| `ALT + V` | Clipboard history |
| `ALT + W` | Change wallpaper |
| `ALT + K` | Kill a window |
| `ALT + C` | Dismiss notifications |
| `ALT SHIFT + T` | Nautilus |
| `ALT SHIFT + P` | Audio mixer |
| `ALT SHIFT + V` | Watch video |
| `ALT SHIFT + S` | Universal snip |
| `ALT SHIFT + K` | System cleaner |
| `ALT SHIFT + D` | aria2 manager |
| `ALT SHIFT + C` | Script editor |
| `ALT SHIFT + E` | Config editor |
| `ALT SHIFT + N` | Wi-Fi menu |

### Web

| Keybind | Action |
|---|---|
| `ALT SHIFT + B` | Zen Browser |
| `ALT SHIFT + I` | Zen private window |
| `ALT + G` | GitHub |
| `ALT SHIFT + Y` | YouTube |
| `ALT SHIFT + G` | Gemini |
| `ALT SHIFT + W` | Wallhaven |
| `ALT SHIFT + O` | ChatGPT |
| `ALT SHIFT + R` | Reddit |

### Window management

| Keybind | Action |
|---|---|
| `ALT + Q` | Close active window |
| `ALT + F` | Toggle fullscreen |
| `ALT + P` | Toggle floating |
| `ALT + J` | Toggle split |
| `ALT + ↑ ↓ ← →` | Move focus |
| `ALT SHIFT + ↑ ↓ ← →` | Swap window |
| `ALT CTRL + ↑ ↓ ← →` | Resize window |
| `ALT + Mouse drag (LMB)` | Move window |
| `ALT + Mouse drag (RMB)` | Resize window |

### Workspaces

| Keybind | Action |
|---|---|
| `ALT + 1–0` | Switch to workspace 1–10 |
| `ALT SHIFT + 1–0` | Move window to workspace 1–10 |
| `ALT + Scroll up` | Next workspace |
| `ALT + Scroll down` | Previous workspace |
| `ALT + \`` | Toggle scratchpad |
| `ALT SHIFT + \`` | Move window to scratchpad |

---

## 🎨 Theming

This setup uses [Matugen](https://github.com/InioX/matugen) for wallpaper-driven dynamic colors. The goal is to keep Waybar, Rofi, Mako, Hyprlock, GTK apps, and terminal colors visually consistent after a wallpaper change.

### Typical wallpaper flow

```bash
aww set /path/to/wallpaper.jpg
matugen image /path/to/wallpaper.jpg
```

### Force a palette refresh

```bash
matugen image ~/.config/hypr/wallpaper/current.png
```

> [!NOTE]
> Matugen templates live in `.config/matugen/`. Edit them if you want to change how colors are applied across individual apps.

---

## 🌐 Zen Browser

This repo includes custom Zen Browser styling under `.zen/chrome/` for a more cohesive look.

### Included files

| File | Purpose |
|---|---|
| `.zen/chrome/userChrome.css` | Browser chrome styling |
| `.zen/chrome/userContent.css` | Internal page styling |
| `.zen/chrome/zen-logo-mocha.svg` | Custom logo asset |

### Important

The main installer currently does **not** install `.zen/` automatically. Apply it manually.

```bash
cp -r .zen/chrome "$HOME/.zen/chrome"
```

### Enable custom CSS in Zen

Open `about:config` and set:

```text
toolkit.legacyUserProfileCustomizations.stylesheets = true
```

Then restart Zen.

### If your profile is elsewhere

Zen can use Firefox-style profile directories. If `~/.zen/chrome/` is not your active profile path:

1. Open `about:support`
2. Find **Profile Directory**
3. Open it
4. Create a `chrome/` directory if missing
5. Copy the files there

---

## 🔄 Updating

To update your local install after pulling new changes:

```bash
git pull
./install.sh --dry-run
./install.sh
```

A new timestamped backup is created on each normal install run, so you can roll back to the latest state with:

```bash
./install.sh --uninstall
```

To inspect old backups:

```bash
./install.sh --list-backups
```

---

## 🔧 Troubleshooting

### Missing bars, launchers, or notifications

Run the dependency check again:

```bash
./install.sh --dry-run
```

Or verify manually:

```bash
which hyprland waybar rofi mako hyprlock matugen kitty foot zsh
```

### Scripts fail with `command not found`

Your shell likely does not include `~/.local/bin` in `PATH`.

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### GTK 2 theme looks broken

Some tools can overwrite `.gtkrc-2.0`. Reapply it:

```bash
cp /path/to/Hypr/.gtkrc-2.0 ~/.gtkrc-2.0
```

### Colors did not update

Regenerate them manually:

```bash
matugen image /path/to/your/wallpaper
```

### Icon glyphs show as boxes

Reinstall fonts and refresh cache:

```bash
yay -S ttf-font-awesome nerd-fonts-symbols-only
fc-cache -f
```

### `--uninstall` cannot find a manifest

That usually means the installer was never run successfully before, or the backup directory was removed.

### Something failed mid-install

Check the latest log:

```bash
cat /tmp/hypr-install-*.log | tail -50
```

---

## 🔐 Security

Please **do not open a public issue** for security vulnerabilities. See [SECURITY.md](SECURITY.md) for responsible disclosure instructions.

---

## 🤝 Contributing

Small fixes, documentation improvements, and setup refinements are welcome. If you open a PR, include a short description of the change and screenshots when the UI is affected.

---

## 📄 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<div align="center">

Made with 💜 by [Cybersnake](https://github.com/Cybersnake223)

</div>
