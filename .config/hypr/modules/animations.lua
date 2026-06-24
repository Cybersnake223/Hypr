-- ########################
-- ## ANIMATIONS         ##
-- ########################

hl.config({
	animations = {
		enabled = true,
	},
})

-- Curves
hl.curve("smoothOut", { type = "bezier", points = { { 0.22, 1.0 }, { 0.36, 1.0 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.12, 0.0 }, { 0.39, 0.0 } } })
hl.curve("soft", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })

-- Animations
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "smoothOut", style = "popin 93%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "smoothIn", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "smoothOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "soft", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "soft", style = "slidevert" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.5, bezier = "smoothOut" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 1.5, bezier = "smoothOut" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 1.5, bezier = "smoothOut" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.5, bezier = "smoothOut" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "smoothIn" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.5, bezier = "smoothOut" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "soft", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "smoothIn", style = "fade" })
