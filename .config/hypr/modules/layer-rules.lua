-- ########################
-- ## LAYER RULES        ##
-- ########################

hl.layer_rule({
    name         = "notify-slide",
    match        = { namespace = "notifications" },
    animation    = "slide",
    blur         = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name      = "hyprwat-slide",
    match     = { namespace = "popup_menu" },
    animation = "slide",
    -- blur   = true,
})

hl.layer_rule({
    name       = "rofi-slide",
    match      = { namespace = "rofi" },
    animation  = "slide",
    dim_around = true,
    -- blur    = true,
})

hl.layer_rule({
    name         = "waybar-slide",
    match        = { namespace = "waybar" },
    animation    = "slide",
    blur         = true,
    xray         = false,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name      = "hyprlock-slide",
    match     = { namespace = "hyprlock" },
    animation = "slide",
})

hl.layer_rule({
    name      = "pavucontrol-slide",
    match     = { namespace = "org.pulseaudio.pavucontrol" },
    animation = "slide",
})
