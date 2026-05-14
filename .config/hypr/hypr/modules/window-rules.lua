-- ########################
-- ## WINDOW RULES       ##
-- ########################

hl.window_rule({
    name  = "media-viewer-float",
    match = { title = "^(Media viewer)$" },
    float = true,
})

hl.window_rule({
    name  = "wiremix-float",
    match = { class = "^(kitty)$", title = "^(wiremix)$" },
    float = true,
    size  = {1000, 800},
})

hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = "^(org.pulseaudio.pavucontrol)$", title = "^(Volume Control)$" },
    float = true,
    size  = {1000, 800},
})

hl.window_rule({
    name  = "airpods-float",
    match = { class = "^(kitty)$", title = "^(airpods-tui)$" },
    float = true,
    size  = {1000, 800},
})

hl.window_rule({
    name             = "pip-float",
    match            = { title = "^(Picture-in-Picture)$" },
    float            = true,
    pin              = true,
    keep_aspect_ratio = true,
})

hl.window_rule({
    name  = "open-files-size",
    match = { title = "^(Open Files)$" },
    float = true,
    size  = {1000, 800},
})

hl.window_rule({
    name  = "save-file-size",
    match = { title = "^(Save File)$" },
    size  = {1000, 800},
})

hl.window_rule({
    name  = "localsend-open-float",
    match = { class = "^(localsend)$" },
    float = true,
    size  = {1000, 800},
})

hl.window_rule({
    name  = "zen-twilight-open-float",
    match = { class = "^(zen-browser)$", title = "^(Open Files)$" },
    float = true,
})

hl.window_rule({
    name  = "zen-upload-float",
    match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(File Upload)$" },
    float = true,
})

hl.window_rule({
    name  = "zen-twilight-save-float",
    match = { class = "^(zen-browser)$", title = "^(Save File)$" },
    float = true,
})

hl.window_rule({
    name  = "zen-twilight-download-float",
    match = { class = "^(zen-browser)$", title = "^(Library)$" },
    float = true,
    size  = {1000, 700},
})
