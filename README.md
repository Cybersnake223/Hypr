<div align="center">
  <p></p>
  <p><b><i> <img src="assets/cslogo.png" </i></b></p> 
  <img src="https://readme-typing-svg.herokuapp.com?font=Righteous&weight=600&size=75&duration=1200&pause=1000&color=A024F7&center=true&vCenter=true&random=false&width=600&height=80&lines=Vicious+Viper"> 
</div>
<p></p>

<div align="center">
  <p></p>
  <p><b><i> <img src="https://img.shields.io/github/last-commit/Cybersnake223/Hypr?style=for-the-badge"> <img src="https://shields.io/maintenance/yes/2025?style=for-the-badge"> </i></b></p>
  <img src="https://img.shields.io/github/languages/code-size/Cybersnake223/Hypr">
  <img src="https://img.shields.io/github/stars/Cybersnake223/Hypr">
  <img src="https://img.shields.io/github/license/Cybersnake223/Hypr">
</div>
<p></p>



![1](assets/asset1.png)
![10](assets/asset10.png)

| ![2](assets/asset2.png) | ![3](assets/asset3.png) |
|---|---|
| ![4](assets/asset4.png) | ![5](assets/asset5.png) |
| ![6](assets/asset6.png) | ![7](assets/asset7.png) |
| ![8](assets/asset8.png) | ![9](assets/asset9.png) |


<div align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.png"></div>


## _Basic Info_ 

<div align="center">
  <p> </p>

  
  - 🍀 ** Base ** - [Arch](https://archlinux.org/) 
  - 🌼 ** Wayland compositor ** - [Hyprland](https://hyprland.org/) 
  - ✨ ** Bar ** - [Waybar](https://github.com/Alexays/Waybar) 
  - 💦 ** GUI File Manager ** - [Thunar](https://gitlab.xfce.org/xfce/thunar) 
  - 🗄️ ** CLI File Manager ** - [Yazi](https://yazi-rs.github.io/docs/installation/) 
  - 🌷 ** Terminal ** - [Foot](https://github.com/DanteAlighierin/foot) 
  - 🍄 ** Shell ** - [Zsh](https://zsh.sourceforge.io/) 
  - 🪵 ** Notifications ** - [Mako](https://github.com/emersion/mako) 
  - 🌻 ** Launcher ** - [Rofi (Lbonn Fork)](https://github.com/lbonn/rofi) 
  - 🚀 ** Dmenu Program ** - [Rofi (Lbonn Fork)](https://github.com/lbonn/rofi)
  - 🍁 ** Wallpaper ** - [Hyprpaper](https://github.com/hyprwm/hyprpaper)
  - 🌐 ** Browser ** - [Brave](https://brave.com/linux) 
  - ❄️  ** Screen locker ** - [Hyprlock](https://github.com/hyprwm/hyprlock) 
  - ⏬ ** Download Manager ** - [Aria2](https://github.com/aria2/aria2)
  - 🤖 ** System Fetch ** - [Nitch](https://github.com/ssleert/nitch)

</div>  

### _Needed packages:_

- (all of the above components) plus
- `xdg-desktop-portal-hyprland` - For Better Functionality and Compatiblity 
- `Cava` - Audio Visualizer 
- `Polkit-Gnome` - Authentication Agent
- `Grimblast-git` `wl-clipboard` - Screenshot Utility
- `Brightnessctl`  - Monitor and Keyboard Brightness Control 
- `Mpv` - Media Player
- `Pavucontrol` - Volume Control Panel. 
- `Xorg-Xwayland` - For Non-Wayland Apps and Games.
- `Fonts` - JetBrains Mono Nerd Fonts, Awesome Fonts, Icomoon Feather and Nerd Font Symbols
- `Pipewire` - Audio Playback (pipewire, pipewire-pulse, pipewire-alsa)
- `Wireplumber` - Session Manager for Pipewire
- `Bleachbit` - Needed for the cleaner script
- `Cmus` - Terminal Audio Player
- `Btop` - Resource Monitor
- `Nmcli` - Connection Manager
- `Bluetoothctl` - Bluetooth Manager
- `Advcpmv(AUR)` - Alternate to cp and mv commands
- `Eza` - Alternative to ls command
- `Fd` - Fast Alternative to Find command


> [!NOTE]
> ### **_Colorscheme used is inspired by Catppuccin Mocha as i absolutely love it._** 😉😉


# **Install Instructions**

> [!CAUTION] 
> DO BACKUP YOUR CURRENT CONFIGS BEFORE PROCEEDING FURTHER . I WILL NOT BE HELD RESPONSIBLE IF YOU LOSE YOUR OLD CONFIGS .



```
git clone https://github.com/Cybersnake223/Hypr
```

```
cd Hypr
```

```
cp -r .config/* $HOME/.config
```

```
cp -r .local/bin/scripts $HOME/.local/bin
```

```
cp -r .icons $HOME/.icons
```

```
cp -r .themes $HOME/.themes
```

```
cp -r .fonts $HOME/.fonts
```
Then Rebuild Font Cache with

```
fc-cache -f
```

> [!NOTE]
> This setup is more focused on laptops rather than desktops soo i'm keeping it super simple but yeahh you can also use it with desktops.    

> [!IMPORTANT]
> _This Repo also contains my custom scripts that i use with this setup for Misc things like downloading videos and audios from different platforms, switching wallpaper in hyprland with keyboard shortcuts._  
> _Make sure to copy the scripts folder in `$HOME/.local/bin` and also add it to your PATH variable otherwise the setup won't work as intended._


# LICENSE  
This Project is licensed under MIT License - see LICENSE for more details.   
