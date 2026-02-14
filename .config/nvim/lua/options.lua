local o = vim.o
local g = vim.g

-- Leader Keys
g.mapleader = " "
g.maplocalleader = ","

-----------------------------------------------------------
-- General Neovim Settings
-----------------------------------------------------------
o.laststatus = 3 -- Global statusline (one for all windows)
o.showmode = false -- Don't show mode (e.g. -- INSERT --) as Lualine handles it
o.clipboard = "unnamedplus" -- Use system clipboard
o.mouse = "a" -- Enable mouse support
o.undofile = true -- Persistent undo
o.timeoutlen = 100 -- Time to wait for a mapped sequence (lower for snappier menus)
o.scrolloff = 10 -- Keep 10 lines above/below cursor
o.cursorline = true -- Highlight current line
o.termguicolors = true -- True color support

-- Search
o.ignorecase = true -- Case insensitive search...

-- Numbers & UI
o.number = true -- Show line numbers
o.signcolumn = "yes" -- Always show sign column (prevents "jumping" text)
o.splitbelow = true -- Split horizontal windows below
o.splitright = true -- Split vertical windows right
vim.opt.fillchars = { eob = " " } -- Hide the '~' on empty lines

-----------------------------------------------------------
-- Indentation
-----------------------------------------------------------
o.expandtab = true -- Use spaces instead of tabs
o.shiftwidth = 2 -- Size of an indent
o.tabstop = 2 -- Number of spaces tabs count for
o.softtabstop = 2
o.smartindent = true -- Insert indents automatically

-----------------------------------------------------------
-- Python / Molten / Data Science
-----------------------------------------------------------
-- Path to your dedicated neovim python venv
g.python3_host_prog = "/home/cybersnake/.venv/neovim/bin/python3"

-- Molten Settings
g.molten_auto_open_output = false
g.molten_image_provider = "image.nvim"
g.molten_wrap_output = false
g.molten_virt_text_output = true
g.molten_virt_lines_off_by_1 = false

-----------------------------------------------------------
-- Path & Environment
-----------------------------------------------------------
-- Add Mason binaries to system path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
local separator = is_windows and ";" or ":"
vim.env.PATH = vim.env.PATH .. separator .. vim.fn.stdpath "data" .. "/mason/bin"

-----------------------------------------------------------
-- Appearance & Highlights
-----------------------------------------------------------
g.have_nerd_font = true
vim.api.nvim_set_hl(0, "IndentLine", { link = "Comment" })
