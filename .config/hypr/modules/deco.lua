-- ########################
-- ## DECORATION         ##
-- ########################

local colors = require("colors.colors")

hl.config({
	decoration = {
		rounding = 5,
		rounding_power = 5,
		inactive_opacity = 1.0,
		active_opacity = 1.0,
		fullscreen_opacity = 1.0,

		shadow = {
			enabled = false,
			range = 50,
			render_power = 3,
			scale = 1.0,
			color = colors.shadow,
			color_inactive = colors.shadow,
		},

		blur = {
			enabled = true,
			size = 6,
			passes = 2,
			brightness = 0.8,
			contrast = 1.0,
			vibrancy = 0.00,
			vibrancy_darkness = 0,
			noise = 0,
			xray = false,
			popups = false,
			ignore_opacity = true,
			new_optimizations = true,
		},
	},
})
