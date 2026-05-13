-- ######################
-- ## Startup Services ##
-- ######################

hl.exec_cmd("sleep 1 && xdg-portal-hyprland")

-- Bluetooth
hl.exec_cmd("rfkill block bluetooth")

-- Auth agent
hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

-- Import env for Qt/systemd services
hl.exec_cmd("systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP WAYLAND_DISPLAY QT_QPA_PLATFORMTHEME")

-- Wallpaper daemon, restore last wallpaper, bar + notifications
hl.exec_cmd("awww-daemon --format xrgb")
hl.exec_cmd("sleep 0.3 && restore-wall")
hl.exec_cmd("waybar")
hl.exec_cmd("mako")

-- Clipboard
hl.exec_cmd("wl-clip-persist -c both")
hl.exec_cmd("wl-paste --type text --watch cliphist store")

-- Keyring + idle daemon
hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
hl.exec_cmd("hypridle")
