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
})
