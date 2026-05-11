<div align="center">

<img src="assets/cslogo.png" width="120" alt="Vicious Viper Logo"/>

<br/>

![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Righteous&weight=600&size=80&duration=1200&pause=1000&color=A024F7&center=true&vCenter=true&random=false&width=700&height=90&lines=Vicious+Viper)

<p>
  <img src="https://img.shields.io/badge/OS-Arch_Linux-A024F7?style=for-the-badge&logo=archlinux&logoColor=white"/>
  <img src="https://img.shields.io/badge/WM-Hyprland-A024F7?style=for-the-badge&logo=wayland&logoColor=white"/>
  <img src="https://img.shields.io/badge/Shell-Zsh-A024F7?style=for-the-badge&logo=zsh&logoColor=white"/>
  <img src="https://img.shields.io/badge/Editor-Neovim-A024F7?style=for-the-badge&logo=neovim&logoColor=white"/>
  <img src="https://img.shields.io/badge/Browser-Zen-A024F7?style=for-the-badge&logo=firefox&logoColor=white"/>
</p>

<p>
  <a href="https://github.com/Cybersnake223/Hypr/commits/main">
    <img src="https://img.shields.io/github/last-commit/Cybersnake223/Hypr/main?style=for-the-badge&label=last%20commit&color=A024F7"/>
  </a>
  <a href="https://github.com/Cybersnake223/Hypr/stargazers">
    <img src="https://img.shields.io/github/stars/Cybersnake223/Hypr?style=for-the-badge&color=A024F7"/>
  </a>
  <a href="https://github.com/Cybersnake223/Hypr/network/members">
    <img src="https://img.shields.io/github/forks/Cybersnake223/Hypr?style=for-the-badge&color=A024F7"/>
  </a>
  <a href="https://github.com/Cybersnake223/Hypr/issues">
    <img src="https://img.shields.io/github/issues/Cybersnake223/Hypr?style=for-the-badge&color=A024F7"/>
  </a>
  <a href="https://github.com/Cybersnake223/Hypr/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/Cybersnake223/Hypr?style=for-the-badge&color=A024F7"/>
  </a>
  <a href="https://github.com/Cybersnake223/Hypr">
    <img src="https://img.shields.io/github/repo-size/Cybersnake223/Hypr?style=for-the-badge&label=size&color=A024F7"/>
  </a>
</p>

<p><i>A wallpaper-synced Hyprland rice for Arch Linux.<br/>Material You theming · Automated backups · Modular installer · Clean daily workflow.</i></p>

<br/>


<br/>

**[🖼 Preview](#-preview) · [✨ Features](#-features) · [🧩 Stack](#-stack) · [📦 Prerequisites](#-prerequisites) · [⚡ Installation](#-installation) · [📂 Layout](#-file-layout) · [🚩 Flags](#-installer-flags) · [⌨️ Keybinds](#️-keybinds) · [🎨 Theming](#-theming) · [🌐 Zen](#-zen-browser) · [🔄 Updating](#-updating) · [🔧 Troubleshoot](#-troubleshooting)**

</div>

<br/>

---

## 🖼 Preview

<div align="center">

<table>
  <tr>
    <td><img src="assets/asset1.png"/></td>
    <td><img src="assets/asset10.png"/></td>
  </tr>
  <tr>
    <td><img src="assets/asset11.png"/></td>
    <td><img src="assets/asset12.png"/></td>
  </tr>
  <tr>
    <td><img src="assets/asset2.png"/></td>
    <td><img src="assets/asset3.png"/></td>
  </tr>
  <tr>
    <td><img src="assets/asset4.png"/></td>
    <td><img src="assets/asset5.png"/></td>
  </tr>
  <tr>
    <td><img src="assets/asset6.png"/></td>
    <td><img src="assets/asset7.png"/></td>
  </tr>
  <tr>
    <td><img src="assets/asset8.png"/></td>
    <td><img src="assets/asset9.png"/></td>
  </tr>
</table>

</div>

<br/>

---

## ✨ Features

<div align="center">

| | |
|:---:|:---|
| 🔮 | **Material You theming** — Matugen derives a full palette from your wallpaper and applies it to every component |
| 💾 | **Safe installer** — every file that would be overwritten is backed up to a timestamped directory first |
| 🎛 | **Modular installs** — choose exactly which modules to deploy: configs, scripts, icons, themes, fonts, dotfiles |
| 🪄 | **Dry-run mode** — preview every single action without touching a single file |
| 🐚 | **Shell-aware PATH patching** — detects Zsh, Bash, Fish, Ksh, and falls back to POSIX `.profile` |
| ↩️ | **One-command undo** — restore all your originals with `./install.sh --uninstall` |
| 🔤 | **Bundled fonts** — JetBrains Mono Nerd, Font Awesome, Icomoon Feather, Nerd Symbols — installed and cached |
| 🌐 | **Zen Browser CSS** — custom `userChrome.css` and `userContent.css` tuned to match the Viper aesthetic |
| 📜 | **50+ custom scripts** — automatically marked executable and patched into `PATH` |

</div>

<br/>

---

## 🧩 Stack

<div align="center">

| Role | Tool |
|:---:|:---|
| 🏗 **Base** | [Arch Linux](https://archlinux.org/) |
| 🪟 **Compositor** | [Hyprland](https://hyprland.org/) |
| 📊 **Bar** | [Waybar](https://github.com/Alexays/Waybar) |
| 🖥 **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) + [Foot](https://codeberg.org/dnkl/foot) |
| 🐚 **Shell** | [Zsh](https://zsh.sourceforge.io/) + [Starship](https://starship.rs/) |
| 🔔 **Notifications** | [Mako](https://github.com/emersion/mako) |
| 🚀 **Launcher** | [Rofi Wayland fork](https://github.com/lbonn/rofi) |
| 🌐 **Browser** | [Zen Browser](https://zen-browser.app/) |
| 🔒 **Locker** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| 📁 **Files** | [Nautilus](https://gitlab.gnome.org/GNOME/nautilus) + [Yazi](https://yazi-rs.github.io/) |
| 📝 **Editor** | [Neovim](https://neovim.io/) |
| 🎨 **Theming** | [Matugen](https://github.com/InioX/matugen) |
| 📡 **System Info** | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| 🎵 **Audio** | [cmus](https://cmus.github.io/) + [Cava](https://github.com/karlstav/cava) + [mpv](https://mpv.io/) |
| 📈 **Monitor** | [btop](https://github.com/aristocratos/btop) |
| ⬇ **Downloads** | [aria2](https://aria2.github.io/) |

</div>

<br/>

---

## 📦 Prerequisites

> [!IMPORTANT]
> The installer checks for these and warns about anything missing. It will not block installation unless core system utilities like `cp` or `find` are absent.

### Tested On

| | |
|:---:|:---|
| 🖥 **OS** | Arch Linux (latest) |
| GPU | Intel / AMD / NVIDIA (all supported via Hyprland) |
| 🪟 **Display** | Wayland (Hyprland) |

### Core packages

```bash
yay -S hyprland waybar foot kitty zsh rofi-lbonn-wayland-git mako       \
        hyprlock matugen-bin btop yazi fastfetch neovim starship          \
        cava cmus mpv nautilus zen-browser-bin aria2 advcpmv
```

### Supporting packages

<details>
<summary>Click to expand</summary>

<br/>

| Package | Purpose |
|---|---|
| `xdg-desktop-portal-hyprland` | Wayland portal — screenshare, file picker |
| `polkit-gnome` | GUI authentication agent |
| `grim` + `slurp` + `wl-clipboard` | Screenshot toolchain |
| `brightnessctl` | Brightness control |
| `pavucontrol` | Audio volume GUI |
| `pipewire` + `pipewire-pulse` + `pipewire-alsa` | Audio stack |
| `wireplumber` | PipeWire session manager |
| `networkmanager` | Networking |
| `bluez` + `bluez-tools` | Bluetooth |
| `xorg-xwayland` | X11 app compatibility |
| `eza` | Better `ls` |
| `fd` | Better `find` |
| `bat` | Better `cat` |
| `bleachbit` | System cleaner script dependency |

</details>

### Fonts

The `.fonts/` directory is bundled and installed automatically. To install manually:

```bash
yay -S ttf-jetbrains-mono-nerd ttf-font-awesome nerd-fonts-symbols-only
fc-cache -f
```

<br/>

---

## ⚡ Installation

> [!CAUTION]
> Run `--dry-run` first on an existing setup. The installer backs up every file it will overwrite, but you should always confirm what it touches before committing.

### Quick start

```bash
git clone https://github.com/Cybersnake223/Hypr
cd Hypr
chmod +x install.sh
./install.sh --dry-run   # preview first
./install.sh             # install when ready
```

### What happens during install

```
[1] ✅  Verify core system utilities
[2] 🔍  Check Hyprland ecosystem packages
[3] 💾  Backup all files that will be overwritten
[4] 📁  Copy selected modules into $HOME
[5] 🔑  chmod +x all scripts in ~/.local/bin/scripts
[6] 🔤  Rebuild font cache via fc-cache -f
[7] 🛤  Detect shell and optionally patch PATH
[8] 📋  Print install summary with log path
```

Backups land here:

```
~/.local/share/hypr-dotfiles-backups/<YYYYMMDD-HHMMSS>/
```

Each backup contains a `.manifest` of every installed path — used by `--uninstall` to restore precisely.

### Manual install (no script)

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
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

<br/>

---

## 📂 File Layout

```
$HOME
├── .config/
│   ├── hypr/             ← Hyprland compositor
│   ├── waybar/           ← Status bar
│   ├── rofi/             ← App launcher
│   ├── nvim/             ← Neovim
│   ├── zsh/              ← Zsh (uses $ZDOTDIR)
│   ├── kitty/            ← Kitty terminal
│   ├── foot/             ← Foot terminal
│   ├── mako/             ← Notifications
│   ├── yazi/             ← TUI file manager
│   ├── mpv/              ← Media player
│   ├── btop/             ← System monitor
│   ├── matugen/          ← Color templates
│   ├── fastfetch/        ← System info
│   ├── cava/             ← Audio visualizer
│   └── ...
├── .local/bin/scripts/   ← 50+ custom shell scripts
├── .fonts/               ← Bundled fonts
├── .icons/               ← Icon theme
├── .themes/              ← GTK/Qt themes
├── .Xresources
└── .gtkrc-2.0
```

<br/>

---

## 🚩 Installer Flags

<div align="center">

| Flag | What it does |
|:---:|:---|
| `--dry-run` | 🔍 Preview every action — zero changes made |
| `--yes` | ✅ Skip all confirmation prompts |
| `--select` | 🎛 Interactively pick which modules to install |
| `--no-backup` | ⚠️ Skip backup — also disables `--uninstall` |
| `--uninstall` | ↩️ Restore originals from the most recent backup |
| `--list-backups` | 📋 Show all backups with timestamps and sizes |
| `--skip-deps` | 🚀 Skip the ecosystem dependency check |
| `-h / --help` | 📖 Show usage |

</div>

```bash
# First-timer recommended flow
./install.sh --dry-run

# Standard install
./install.sh

# Non-interactive (CI / scripted)
./install.sh --yes --skip-deps

# Pick only what you want
./install.sh --select

# Undo the last install
./install.sh --uninstall

# See all saved backups
./install.sh --list-backups
```

### `--select` module picker

```
[✓]  1  .config       Application configs (hypr, waybar, rofi, nvim, zsh…)
[✓]  2  scripts       Custom scripts → ~/.local/bin/scripts
[ ]  3  .icons        Icon theme
[✓]  4  .themes       GTK/Qt themes
[✓]  5  .fonts        Custom fonts (triggers fc-cache rebuild)
[✓]  6  dotfiles      Root dotfiles (.Xresources, .gtkrc-2.0)
```

Toggle a number, press Enter to confirm.

### Shell-aware PATH patching

| Shell | File patched |
|---|---|
| `zsh` | `~/.zshrc` |
| `bash` | `~/.bashrc` |
| `fish` | `~/.config/fish/conf.d/hypr_path.fish` |
| `ksh / mksh` | `~/.kshrc` |
| Other | `~/.profile` |

<br/>

---

## ⌨️ Keybinds

> [!NOTE]
> `ALT` is the primary modifier across the entire setup.

<details open>
<summary>🔧 System</summary>

<br/>

| Keybind | Action |
|---|---|
| `F1` | Toggle mute (speakers) |
| `F2` / `F3` | Volume −/+ 10% |
| `F4` | Toggle mute (mic) |
| `F7` | Toggle Wi-Fi |
| `F9` | Lock screen |
| `F11` / `F12` | Brightness −/+ 10% |
| `Print` | Screenshot |

</details>

<details open>
<summary>🚀 Apps & Launchers</summary>

<br/>

| Keybind | Action |
|---|---|
| `ALT + Enter` | Terminal (Kitty) |
| `ALT + D` | App launcher (Rofi) |
| `ALT + R` | Yazi (TUI file manager) |
| `ALT + N` | Neovim |
| `ALT + M` | cmus |
| `ALT + H` | btop |
| `ALT + T` | aerc (email) |
| `ALT + E` | Emoji picker |
| `ALT + X` | Power menu |
| `ALT + B` | Bluetooth menu |
| `ALT + L` | AirPods TUI |
| `ALT + Y` | YouTube downloader |
| `ALT + V` | Clipboard history |
| `ALT + W` | Change wallpaper |
| `ALT + K` | Kill window |
| `ALT + C` | Dismiss notifications |
| `ALT SHIFT + T` | Nautilus (GUI files) |
| `ALT SHIFT + P` | Audio mixer (wiremix) |
| `ALT SHIFT + V` | Watch video |
| `ALT SHIFT + S` | Universal snip (QuickShell) |
| `ALT SHIFT + K` | System cleaner |
| `ALT SHIFT + D` | aria2 downloader |
| `ALT SHIFT + C` | Script editor |
| `ALT SHIFT + E` | Config editor |
| `ALT SHIFT + N` | Wi-Fi menu |

</details>

<details>
<summary>🌐 Web shortcuts <i>(personal — edit before use)</i></summary>

<br/>

> [!NOTE]
> These open personal bookmarks hardcoded in the Hyprland config. Edit them before adopting this setup.

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

</details>

<details>
<summary>🪟 Window management</summary>

<br/>

| Keybind | Action |
|---|---|
| `ALT + Q` | Close window |
| `ALT + F` | Toggle fullscreen |
| `ALT + P` | Toggle floating |
| `ALT + J` | Toggle split |
| `ALT + ↑ ↓ ← →` | Move focus |
| `ALT SHIFT + ↑ ↓ ← →` | Swap window |
| `ALT CTRL + ↑ ↓ ← →` | Resize window |
| `ALT + LMB drag` | Move window |
| `ALT + RMB drag` | Resize window |

</details>

<details>
<summary>🗂 Workspaces</summary>

<br/>

| Keybind | Action |
|---|---|
| `ALT + 1–0` | Switch to workspace 1–10 |
| `ALT SHIFT + 1–0` | Move window to workspace 1–10 |
| `ALT + Scroll up/down` | Cycle workspaces |
| `ALT + `` ` `` ` | Toggle scratchpad |
| `ALT SHIFT + `` ` `` ` | Move window to scratchpad |

</details>

<br/>

---

## 🎨 Theming

<div align="center">
<i>Every color, everywhere — driven by your wallpaper.</i>
</div>

<br/>

This setup uses **[Matugen](https://github.com/InioX/matugen)** — a Material You color extraction engine. Change your wallpaper, run Matugen, and Waybar, Rofi, Mako, Hyprlock, GTK apps, and the terminal all recolor automatically.

```bash
# Set wallpaper and regenerate palette
aww set /path/to/wallpaper.jpg
matugen image /path/to/wallpaper.jpg
```

```bash
# Force a refresh from the cached wallpaper
matugen image ~/.config/hypr/wallpaper/current.png
```

> [!NOTE]
> Matugen templates live in `.config/matugen/`. Edit them to control exactly how color tokens map to each app's config format.

<br/>

---

## 🌐 Zen Browser

Custom styling for [Zen Browser](https://zen-browser.app/) is included under `.zen/chrome/` to match the Viper aesthetic.

| File | Purpose |
|---|---|
| `.zen/chrome/userChrome.css` | Browser chrome — sidebar, tab bar, toolbar |
| `.zen/chrome/userContent.css` | Internal pages — new tab, `about:` pages |
| `.zen/chrome/zen-logo-mocha.svg` | Custom logo asset |

> [!IMPORTANT]
> The installer does **not** copy `.zen/` automatically. Apply it manually:

```bash
cp -r .zen/chrome "$HOME/.zen/chrome"
```

Then enable custom CSS in `about:config`:

```
toolkit.legacyUserProfileCustomizations.stylesheets = true
```

Restart Zen. If your profile is not at `~/.zen/` (e.g. Flatpak installs use `~/.var/app/`), find the correct path via `about:support → Profile Directory`.

<br/>

---

## 🔄 Updating

```bash
git pull
./install.sh --dry-run   # preview what changed
./install.sh             # apply
```

Each run creates a fresh backup. To roll back after an update:

```bash
./install.sh --uninstall      # restore most recent backup
./install.sh --list-backups   # or inspect all available backups
```

<br/>

---

## 🔧 Troubleshooting

<details>
<summary>Waybar / Rofi / Mako not launching</summary>

```bash
./install.sh --dry-run
which hyprland waybar rofi mako hyprlock matugen kitty foot zsh
```

</details>

<details>
<summary>Scripts fail with <code>command not found</code></summary>

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

</details>

<details>
<summary>GTK 2 theme broken after nwg-look</summary>

```bash
cp /path/to/Hypr/.gtkrc-2.0 ~/.gtkrc-2.0
```

</details>

<details>
<summary>Colors didn't update after wallpaper change</summary>

```bash
matugen image /path/to/your/wallpaper
```

</details>

<details>
<summary>Icon glyphs showing as boxes</summary>

```bash
yay -S ttf-font-awesome nerd-fonts-symbols-only
fc-cache -f
```

</details>

<details>
<summary>--uninstall says "No install manifest found"</summary>

The installer was never run, or the backup directory was deleted. Restore files manually from the repo tree.

</details>

<details>
<summary>Something went wrong mid-install</summary>

```bash
cat /tmp/hypr-install-*.log | tail -50
```

</details>

<br/>

---

## 🔐 Security

Do **not** open a public GitHub issue for vulnerabilities. See [SECURITY.md](SECURITY.md) for responsible disclosure.

---

## 🤝 Contributing

PRs are welcome for fixes, improvements, and documentation updates. Include screenshots when UI is affected.

### 💬 Getting Help

Need help or have questions? Start a discussion:
- **[GitHub Discussions](https://github.com/Cybersnake223/Hypr/discussions)** — ask questions, share setups, get help

For bugs and issues, use the **[Issue Tracker](https://github.com/Cybersnake223/Hypr/issues)**.

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">

<img src="assets/cslogo.png" width="48"/>

<br/>

*Crafted with* 💜 *by* [**Cybersnake**](https://github.com/Cybersnake223)

<br/>

![footer](https://capsule-render.vercel.app/api?type=waving&color=A024F7&height=100&section=footer)

</div>
