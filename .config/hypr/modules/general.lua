-- ########################
-- ## GENERAL            ##
-- ########################

local colors = require("colors.colors")

hl.config({
    general = {
        gaps_in                    = 2,
        gaps_out                   = 0,
        layout                     = "dwindle",
        border_size                = 2,
        ["col.active_border"]      = colors.tertiary,
        ["col.inactive_border"]    = colors.shadow,
        resize_on_border           = true,
        allow_tearing              = false,
        extend_border_grab_area    = 0,
    }
})
