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
local colors = require("colors.colors")

-- pass colors into modules that need it
require("modules.startup")
require("modules.general")
require("modules.deco")
require("modules.input")
require("modules.animations")
require("modules.misc")
require("modules.layout")
require("modules.xwayland")
require("modules.ecosystem")
require("modules.env-var")
require("modules.monitors")
require("modules.keybinds")
require("modules.window-rules")
require("modules.workspace-rules")
require("modules.layer-rules")
