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
-- ## Created by Cybersnake                                                                                  ##
-- ############################################################################################################

local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
	return
end

local dashboard = require("alpha.themes.dashboard")
dashboard.section.header.val = {

[[ ______     __  __     ______     ______     ______     ______     __   __     ______     __  __     ______   ]],
[[/\  ___\   /\ \_\ \   /\  == \   /\  ___\   /\  == \   /\  ___\   /\ "-.\ \   /\  __ \   /\ \/ /    /\  ___\  ]],
[[\ \ \____  \ \____ \  \ \  __<   \ \  __\   \ \  __<   \ \___  \  \ \ \-.  \  \ \  __ \  \ \  _"-.  \ \  __\  ]],
[[ \ \_____\  \/\_____\  \ \_____\  \ \_____\  \ \_\ \_\  \/\_____\  \ \_\\"\_\  \ \_\ \_\  \ \_\ \_\  \ \_____\]],
[[  \/_____/   \/_____/   \/_____/   \/_____/   \/_/ /_/   \/_____/   \/_/ \/_/   \/_/\/_/   \/_/\/_/   \/_____/]],
[[                                                                                                              ]],

}
dashboard.section.buttons.val = {
	dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
	dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("p", "  Find project", ":Telescope projects <CR>"),
	dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
	dashboard.button("t", "󱎸  Find text", ":Telescope live_grep <CR>"),
	dashboard.button("c", "  Configuration", ":e $MYVIMRC <CR>"),
	dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

local function footer()
	return "CREATED BY CYBERSNAKE"
end

dashboard.section.footer.val = footer()

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)
