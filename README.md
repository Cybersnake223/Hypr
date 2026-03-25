<div align="center">
  <p></p>
  <p><b><i> <img src="assets/cslogo.png" </i></b></p> 
  <img src="https://readme-typing-svg.herokuapp.com?font=Righteous&weight=600&size=75&duration=1200&pause=1000&color=A024F7&center=true&vCenter=true&random=false&width=600&height=80&lines=Vicious+Viper"> 
</div>
<p></p>


<div align="center">
  <img src="https://img.shields.io/github/last-commit/Cybersnake223/Hypr/main?style=for-the-badge&label=last%20commit&color=A024F7">
  <img src="https://img.shields.io/github/repo-size/Cybersnake223/Hypr?style=for-the-badge&label=size&color=A024F7">
  <img src="https://img.shields.io/github/stars/Cybersnake223/Hypr?style=for-the-badge&color=A024F7">
  <img src="https://img.shields.io/github/license/Cybersnake223/Hypr?style=for-the-badge&color=A024F7">
  <img src="https://img.shields.io/github/forks/Cybersnake223/Hypr?style=for-the-badge&color=A024F7">
</div>

![1](assets/asset1.png)
![10](assets/asset10.png)

| ![11](assets/asset11.png) | ![12](assets/asset12.png)
|---|---|
| ![2](assets/asset2.png) | ![3](assets/asset3.png) |
| ![4](assets/asset4.png) | ![5](assets/asset5.png) |
| ![6](assets/asset6.png) | ![7](assets/asset7.png) |
| ![8](assets/asset8.png) | ![9](assets/asset9.png) |

<div align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.png"></div>

---

## _Basic Info_

<div align="center">

- 🍀 **Base** — [Arch](https://archlinux.org/)
- 🌼 **Wayland Compositor** — [Hyprland](https://hyprland.org/)
- ✨ **Bar** — [Waybar](https://github.com/Alexays/Waybar)
- 💦 **GUI File Manager** — [Thunar](https://gitlab.xfce.org/xfce/thunar)
- 🗄️ **CLI File Manager** — [Yazi](https://yazi-rs.github.io/docs/installation/)
- 🌷 **Terminal** — [Foot](https://github.com/DanteAlighierin/foot)
- 🍄 **Shell** — [Zsh](https://zsh.sourceforge.io/)
- 🪵 **Notifications** — [Mako](https://github.com/emersion/mako)
- 🌻 **Launcher** — [Rofi (Lbonn Fork)](https://github.com/lbonn/rofi)
- 🚀 **Dmenu Program** — [Rofi (Lbonn Fork)](https://github.com/lbonn/rofi)
- 🍁 **Wallpaper** — [Swww](https://github.com/LGFae/swww.git)
- 🌐 **Browser** — [Zen Browser](https://zen-browser.app/)
- ❄️ **Screen Locker** — [Hyprlock](https://github.com/hyprwm/hyprlock)
- ⏬ **Download Manager** — [Aria2](https://github.com/aria2/aria2)
- 🤖 **System Fetch** — [Nitch](https://github.com/ssleert/nitch)

</div>

---

## _Required Packages_

Install all components listed above, then the following:

| Package | Purpose |
|---|---|
| `matugen` | Wallpaper-based color palette generation |
| `xdg-desktop-portal-hyprland` | Better Wayland compatibility |
| `cava` | Audio visualizer |
| `polkit-gnome` | Authentication agent |
| `grimblast-git` + `wl-clipboard` | Screenshot utility |
| `brightnessctl` | Monitor and keyboard brightness control |
| `mpv` | Media player |
| `pavucontrol` | Volume control panel |
| `xorg-xwayland` | Support for non-Wayland apps and games |
| `pipewire` + `pipewire-pulse` + `pipewire-alsa` | Audio playback |
| `wireplumber` | Session manager for Pipewire |
| `bleachbit` | Required for the cleaner script |
| `cmus` | Terminal audio player |
| `btop` | Resource monitor |
| `nmcli` | Network connection manager |
| `bluez-tools` | Bluetooth manager |
| `advcpmv` _(AUR)_ | Improved `cp` and `mv` with progress |
| `eza` | Modern replacement for `ls` |
| `fd` | Fast alternative to `find` |

**Fonts:** JetBrains Mono Nerd Font, Awesome Fonts, Icomoon Feather, Nerd Font Symbols

> [!NOTE]
> **Colorscheme changes dynamically based on your wallpaper** via Matugen. 😉

---

# Install Instructions

> [!CAUTION]
> The installer backs up existing files before overwriting, but **only for paths
> present in this repo**. No unrelated configs are touched. I am not responsible
> for any lost configs — back up your own stuff first if you're unsure.

## Quick Install (Recommended)

```bash
git clone https://github.com/Cybersnake223/Hypr
cd Hypr
chmod +x install.sh
./install.sh
```

The installer will:

- ✅ Check for required dependencies (`cp`, `mkdir`, `find`, `date`)
- 🗂️ Back up any existing files it will overwrite into a timestamped folder
- 📁 Copy configs, scripts, icons, themes, fonts and root dotfiles into `$HOME`
- 🔒 Mark all scripts in `~/.local/bin/scripts` as executable
- 🔤 Rebuild the font cache via `fc-cache -f`
- 🛤️ Optionally add `~/.local/bin` to your PATH in `~/.zshrc`

> [!NOTE]
> Backups are saved to:
> `~/.local/share/hypr-dotfiles-backups/<timestamp>/`
> (or `$XDG_DATA_HOME/hypr-dotfiles-backups/<timestamp>/` if `$XDG_DATA_HOME` is set)

---

### Options

| Flag | Description |
|---|---|
| `--dry-run` | Preview all actions without making any changes |
| `--yes` | Non-interactive, skip all prompts |
| `--no-backup` | Skip backup entirely (**dangerous**) |
| `--uninstall` | Remove installed files and restore originals from the latest backup |

**Examples:**

```bash
# Preview without changing anything
./install.sh --dry-run

# Non-interactive install
./install.sh --yes

# Install without backup
./install.sh --yes --no-backup

# Uninstall and restore previous configs
./install.sh --uninstall
```

---

## Manual Install

If you prefer not to use the installer:

```bash
cp -r .config/* "$HOME/.config"
cp -r .local/bin/scripts "$HOME/.local/bin"
cp -r .icons "$HOME/.icons"
cp -r .themes "$HOME/.themes"
cp -r .fonts "$HOME/.fonts"
cp .Xresources "$HOME/.Xresources"
cp .gtkrc-2.0 "$HOME/.gtkrc-2.0"
fc-cache -f
```

> [!IMPORTANT]
> Make sure `~/.local/bin` is in your **PATH**, otherwise the custom scripts
> (wallpaper switching, media downloads, etc.) won't work as intended.
> Add this to your `~/.zshrc`:
>
> ```bash
> export PATH="$HOME/.local/bin:$PATH"
> ```

> [!NOTE]
> `.gtkrc-2.0` may be silently overwritten by `nwg-look`. Re-copy it from the
> repo if your GTK 2 theming breaks after running it.

> [!NOTE]
> This setup is primarily tuned for **laptops**. Desktop users may want to
> review and adjust `auto-cpufreq` settings in `.config/`.

---

# LICENSE

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.
