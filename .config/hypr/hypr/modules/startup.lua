-- ######################
-- ## Startup Services ##
-- ######################

hl.on("hyprland.start", function()
    hl.exec_cmd("rfkill block bluetooth")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("awww-daemon --format xrgb")
    hl.exec_cmd("sleep 0.3 && restore-wall")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("wl-clip-persist -c both")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
    hl.exec_cmd("hypridle")
end)
