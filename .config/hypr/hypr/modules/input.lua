-- ################
-- ## INPUT      ##
-- ################

hl.config({
    input = {
        kb_layout          = "us",
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0.3,
        repeat_rate        = 60,
        repeat_delay       = 400,
        scroll_method      = "2fg",

        touchpad = {
            natural_scroll          = false,
            disable_while_typing    = true,
            middle_button_emulation = false,
            drag_lock               = 0,
            tap_to_click            = true,
            scroll_factor           = 0.8,
        },
    },

    cursor = {
        sync_gsettings_theme = false,
        enable_hyprcursor    = true,
        no_hardware_cursors  = 0,
    },
})
