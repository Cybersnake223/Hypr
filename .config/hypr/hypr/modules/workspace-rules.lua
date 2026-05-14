-- ########################
-- ## WORKSPACE RULES    ##
-- ########################

-- Workspace rules: gaps
hl.workspace_rule({
    workspace = "w[tv1]",
    gaps_out  = 0,
    gaps_in   = 0,
})

hl.workspace_rule({
    workspace = "f[1]",
    gaps_out  = 0,
    gaps_in   = 0,
})

-- Window rules: remove border and rounding in tiled/fullscreen workspaces
hl.window_rule({
    match       = { workspace = "w[tv1]" },
    border_size = 0,
    rounding    = false,
})

hl.window_rule({
    match       = { workspace = "f[1]" },
    border_size = 0,
    rounding    = false,
})
