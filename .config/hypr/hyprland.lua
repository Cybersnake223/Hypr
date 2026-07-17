-- ############################################################################################################
-- ##   ______  __      __  _______   ________  _______    ______   __    __   ______   __    __  ________   ##
-- ##  /      \|  \    /  \|       \ |        \|       \  /      \ |  \  |  \ /      \ |  \  /  \|        \  ##
-- ## |  $$$$$$\\$$\  /  $$| $$$$$$$\| $$$$$$$$| $$$$$$$\|  $$$$$$\| $$\ | $$|  $$$$$$\| $$ /  $$| $$$$$$$$  ##
-- ## | $$   \$$ \$$\/  $$ | $$__/ $$| $$__    | $$__| $$| $$___\$$| $$$\| $$| $$__| $$| $$/  $$ | $$__      ##
-- ## | $$        \$$  $$  | $$    $$| $$  \   | $$    $$ \$$    \ | $$$$\ $$| $$    $$| $$  $$  | $$  \     ##
-- ## | $$   __    \$$$$   | $$$$$$$\| $$$$$   | $$$$$$$\ _\$$$$$$\| $$\$$ $$| $$$$$$$$| $$$$$\  | $$$$$     ##
-- ## | $$__/  \   | $$    | $$__/ $$| $$_____ | $$  | $$|  \__| $$| $$ \$$$$| $$  | $$| $$ \$$\ | $$_____   ##
-- ##  \$$    $$   | $$    | $$    $$| $$     \| $$  | $$ \$$    $$| $$  \$$$| $$  | $$| $$  \$$\| $$     \  ##
-- ##   \$$$$$$     \$$     \$$$$$$$  \$$$$$$$$ \$$   \$$  \$$$$$$  \$$   \$$ \$$   \$$ \$$   \$$ \$$$$$$$$  ##
-- ##                                                                                                        ##
-- ## Vicious Viper Config                                                                                   ##
-- ## Created by Cybersnake                                                                                  ##
-- ############################################################################################################

-- ## Sourcing Modules

-- colors must load first — everything else depends on it
local ok, colors = pcall(require, "colors.colors")
if not ok then
	colors = {}
end

local modules = {
	"modules.startup",
	"modules.general",
	"modules.deco",
	"modules.input",
	"modules.animations",
	"modules.misc",
	"modules.layout",
	"modules.xwayland",
	"modules.ecosystem",
	"modules.env-var",
	"modules.monitors",
	"modules.keybinds",
	"modules.window-rules",
	"modules.workspace-rules",
	"modules.layer-rules",
}

for _, mod in ipairs(modules) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Warning: failed to load " .. mod .. " — " .. tostring(err))
	end
end
