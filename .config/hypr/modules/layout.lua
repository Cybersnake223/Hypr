-- ########################
-- ## LAYOUT             ##
-- ########################

hl.config({
    dwindle = {
        -- pseudotile        = true,
        preserve_split     = true,
        force_split        = 1,
        default_split_ratio = 1,
    },

    master = {
        new_status = "dwindle",
    },

    scrolling = {
        column_width             = 0.9,
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        follow_focus             = true,
        follow_min_visible       = 0.9,
        wrap_focus               = true,
        wrap_swapcol             = true,
        direction                = "right",
    }
})
