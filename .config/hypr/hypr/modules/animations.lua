-- ########################
-- ## ANIMATIONS         ##
-- ########################

hl.config({
    animations = {
        enabled = true,
    }
})

-- Bezier curves
hl.curve("quint",  { type = "bezier", points = { {0.23, 1.0},   {0.32, 1.0}   } })
hl.curve("pop",    { type = "bezier", points = { {0.175, 0.885},{0.32, 1.275} } })
hl.curve("almost", { type = "bezier", points = { {0.5, 0.5},    {0.75, 1.0}   } })

-- Animations
hl.animation({ leaf = "windowsIn",        enabled = true,  speed = 4, bezier = "quint",  style = "popin 87%" })
hl.animation({ leaf = "windowsOut",       enabled = true,  speed = 2, bezier = "quint",  style = "popin 87%" })
hl.animation({ leaf = "windowsMove",      enabled = true,  speed = 3, bezier = "quint"  })
hl.animation({ leaf = "workspaces",       enabled = true,  speed = 4, bezier = "quint",  style = "slide"     })
hl.animation({ leaf = "specialWorkspace", enabled = true,  speed = 3, bezier = "pop",    style = "slidevert" })
hl.animation({ leaf = "fadeIn",           enabled = true,  speed = 2, bezier = "quint"  })
hl.animation({ leaf = "fadeOut",          enabled = true,  speed = 1, bezier = "almost" })
hl.animation({ leaf = "fadeDim",          enabled = true,  speed = 3, bezier = "quint"  })
hl.animation({ leaf = "fadeLayers",       enabled = true,  speed = 2, bezier = "almost" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true,  speed = 2, bezier = "almost" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true,  speed = 1, bezier = "almost" })
hl.animation({ leaf = "fadeSwitch",       enabled = true,  speed = 2, bezier = "quint"  })
hl.animation({ leaf = "layersIn",         enabled = true,  speed = 3, bezier = "pop",    style = "slide"     })
hl.animation({ leaf = "layersOut",        enabled = true,  speed = 2, bezier = "quint",  style = "fade"      })
