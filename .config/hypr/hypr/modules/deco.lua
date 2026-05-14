-- ########################
-- ## DECORATION         ##
-- ########################

local colors = require("colors.colors")

hl.config({
    decoration = {
        rounding           = 10,
        rounding_power     = 5,
        inactive_opacity   = 0.90,
        active_opacity     = 1.0,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled        = false,
            range          = 50,
            render_power   = 3,
            scale          = 1.0,
            color          = colors.shadow,
            color_inactive = colors.shadow,
        },

        blur = {
            enabled           = true,
            size              = 15,
            passes            = 3,
            brightness        = 0.7,
            contrast          = 1.0,
            vibrancy          = 0.50,
            vibrancy_darkness = 0.3,
            noise             = 0.0,
            xray              = false,
            popups            = true,
            ignore_opacity    = true,
            new_optimizations = true,
        },
    }
})
