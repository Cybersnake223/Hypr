-- ############################
-- ## Environment Variables  ##
-- ############################

-- Hyprland
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE",  "38")

-- XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- GTK / GTK4
hl.env("GDK_BACKEND", "wayland,x11")

-- Qt
hl.env("QT_QPA_PLATFORM",                "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME",           "qt5ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",    "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Video
hl.env("SDL_VIDEODRIVER",  "wayland")
hl.env("CLUTTER_BACKEND",  "wayland")

-- Intel GPU
hl.env("LIBVA_DRIVER_NAME",      "iHD")
hl.env("MESA_LOADER_DRIVER_NAME", "iris")

-- Zen
hl.env("MOZ_ENABLE_WAYLAND", "1")
