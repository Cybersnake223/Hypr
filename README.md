<div align="center">
  <img src="assets/cslogo.png" alt="Cybersnake Logo" width="120"/>

  <img src="https://readme-typing-svg.herokuapp.com?font=Righteous&weight=600&size=75&duration=1200&pause=1000&color=A024F7&center=true&vCenter=true&random=false&width=600&height=80&lines=Vicious+Viper">

  <p><em>A Hyprland dotfiles setup for Arch Linux — dynamic theming, clean workflows, curated tools.</em></p>

  <p>
    <img src="https://img.shields.io/github/last-commit/Cybersnake223/Hypr/main?style=for-the-badge&label=last%20commit&color=A024F7">
    <img src="https://img.shields.io/github/repo-size/Cybersnake223/Hypr?style=for-the-badge&label=size&color=A024F7">
    <img src="https://img.shields.io/github/stars/Cybersnake223/Hypr?style=for-the-badge&color=A024F7">
    <img src="https://img.shields.io/github/license/Cybersnake223/Hypr?style=for-the-badge&color=A024F7">
    <img src="https://img.shields.io/github/forks/Cybersnake223/Hypr?style=for-the-badge&color=A024F7">
  </p>

  <p>
    <a href="#-preview">Preview</a> •
    <a href="#-stack">Stack</a> •
    <a href="#-prerequisites">Prerequisites</a> •
    <a href="#-installation">Installation</a> •
    <a href="#-theming">Theming</a> •
    <a href="#-troubleshooting">Troubleshooting</a>
  </p>
</div>

---

## 🖼 Preview

![Desktop 1](assets/asset1.png)
![Desktop 2](assets/asset10.png)

| ![](assets/asset11.png) | ![](assets/asset12.png) |
|---|---|
| ![](assets/asset2.png) | ![](assets/asset3.png) |
| ![](assets/asset4.png) | ![](assets/asset5.png) |
| ![](assets/asset6.png) | ![](assets/asset7.png) |
| ![](assets/asset8.png) | ![](assets/asset9.png) |

<div align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.png"/>
</div>

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
| 🖼 Wallpaper | [Swww](https://github.com/LGFae/swww) |
| 🌐 Browser | [Zen Browser](https://zen-browser.app/) |
| 🔒 Locker | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| 📁 File Manager | [Thunar](https://gitlab.xfce.org/xfce/thunar) (GUI) / [Yazi](https://yazi-rs.github.io/) (TUI) |
| 📝 Editor | [Neovim](https://neovim.io/) |
| 🎨 Theming | [Matugen](https://github.com/InioX/matugen) (Material You — wallpaper-based) |
| 📡 System Info | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| 🎵 Audio | [cmus](https://cmus.github.io/) + [Cava](https://github.com/karlstav/cava) + [mpv](https://mpv.io/) |
| 📈 Monitor | [btop](https://github.com/aristocratos/btop) |
| ⬇ Downloads | [aria2](https://aria2.github.io/) |

> [!NOTE]
> This setup is **primarily tuned for laptops**. Desktop users should review `auto-cpufreq` settings and Waybar's battery module.

---

## 📦 Prerequisites

> [!IMPORTANT]
> The installer **does not** check for Hyprland ecosystem packages. Install all dependencies below **before** running `install.sh`.

### Core Packages

```bash
yay -S hyprland waybar foot zsh rofi-lbonn-wayland-git mako swww \
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

The `.fonts/` directory is included in this repo and installed automatically. To install manually via the AUR:

```bash
yay -S ttf-jetbrains-mono-nerd ttf-font-awesome nerd-fonts-symbols-only
```

Required fonts:
- **JetBrains Mono Nerd Font** — primary monospace
- **Awesome Fonts** — icon font for Waybar / Rofi
- **Icomoon Feather** — supplementary icon set
- **Nerd Font Symbols** — fallback glyph coverage

---

## ⚡ Installation

> [!CAUTION]
> The installer backs up existing files before overwriting them, but **only for paths present in this repo**. No unrelated configs are touched. Back up your own files first if you're unsure.

### Quick Install (Recommended)

```bash
git clone https://github.com/Cybersnake223/Hypr
cd Hypr
chmod +x install.sh
./install.sh
```

The installer will:

- ✅ Check for required system utilities
- 🗂 Back up any existing files it will overwrite into a **timestamped directory**
- 📁 Copy configs, scripts, icons, themes, and fonts into `$HOME`
- 🔑 Mark all scripts in `~/.local/bin/scripts` as executable
- 🔤 Rebuild the font cache via `fc-cache -f`
- 🛤 Optionally add `~/.local/bin` to your `PATH` in `~/.zshrc`

**Backups are saved to:**
```
~/.local/share/hypr-dotfiles-backups/<YYYYMMDD-HHMMSS>/
# or $XDG_DATA_HOME/hypr-dotfiles-backups/<timestamp>/ if $XDG_DATA_HOME is set
```

### Installer Flags

| Flag | Description |
|---|---|
| `--dry-run` | Preview all actions — no changes made |
| `--yes` | Non-interactive, skip all prompts |
| `--no-backup` | Skip backup (**dangerous** — disables uninstall) |
| `--uninstall` | Restore originals from the most recent backup |
| `-h`, `--help` | Show usage information |

```bash
# Preview without changing anything
./install.sh --dry-run

# Fully non-interactive install
./install.sh --yes

# Restore backed-up configs
./install.sh --uninstall
```

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

Then ensure `~/.local/bin` is in your `PATH`. Add to `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

> [!NOTE]
> `nwg-look` may silently overwrite `.gtkrc-2.0`. If GTK 2 theming breaks after running it, re-copy the file from the repo.

---

## 🎨 Theming

Color theming is powered by **[Matugen](https://github.com/InioX/matugen)** — a Material You color extraction tool that generates a full palette from your current wallpaper. Every time you change wallpaper, the entire desktop recolors: Waybar, Rofi, Mako, Hyprlock, GTK apps, and terminal colors all update automatically.

To change your wallpaper and regenerate the theme:

```bash
swww img /path/to/wallpaper.jpg --transition-type grow --transition-pos center
matugen image /path/to/wallpaper.jpg
```

If colors get out of sync after an app config update, regenerate manually:

```bash
matugen image ~/.config/hyprwat/current_wallpaper
```

Matugen templates live in `.config/matugen/` and define how Material You color variables map to each app's config format.

---

## 🔧 Troubleshooting

**Waybar / Rofi not launching**
The installer doesn't check for Hyprland ecosystem tools. Verify they're installed:
```bash
which waybar rofi mako swww hyprlock matugen
```

**Scripts not working (`command not found`)**
`~/.local/bin` is not in your `$PATH`. Add to `~/.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
source ~/.zshrc
```

**GTK 2 theming broken after `nwg-look`**
Re-apply the config from the repo:
```bash
cp /path/to/Hypr/.gtkrc-2.0 ~/.gtkrc-2.0
```

**Colors didn't update after wallpaper change**
Manually regenerate the Matugen palette:
```bash
matugen image /path/to/your/wallpaper
```

**Font icons showing as boxes**
Fonts aren't cached. Reinstall and rebuild:
```bash
yay -S ttf-font-awesome nerd-fonts-symbols-only
fc-cache -f
```

**Uninstall says "No install manifest found"**
The backup directory was deleted or the install was run outside this repo. Manually remove installed files — refer to the [Wiki](https://github.com/Cybersnake223/Hypr/wiki/Uninstalling) for the full file list.

---

## 📄 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

<div align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.png"/>
  <br/>
  <sub>Made with 💜 by <a href="https://github.com/Cybersnake223">Cybersnake</a></sub>
</div>
