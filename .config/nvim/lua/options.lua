local opt = vim.opt
local g = vim.g

-- ── Leader ───────────────────────────────────────────────
g.mapleader = " "
g.maplocalleader = ","

-- ── UI ───────────────────────────────────────────────────
opt.laststatus = 3
opt.showmode = false
opt.termguicolors = true
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.fillchars = { eob = " " }
opt.wrap = false
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── Behavior ─────────────────────────────────────────────
opt.mouse = "a"
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.timeoutlen = 500
opt.updatetime = 250
opt.inccommand = "split"
opt.completeopt = "menuone,noselect,noinsert"
opt.diffopt:append "linematch:60"

-- ── Search ───────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true

-- ── Undo (persistent across restarts) ───────────────────
opt.undofile = true

-- ── Indentation ──────────────────────────────────────────
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- ── Python / Neovim provider ─────────────────────────────
g.python3_host_prog = "/home/cybersnake/.venv/bin/python3"

-- ── Appearance ───────────────────────────────────────────
g.have_nerd_font = true
vim.api.nvim_set_hl(0, "IndentLine", { link = "Comment" })

-- ── Mason → PATH ─────────────────────────────────────────
local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. sep .. vim.env.PATH
end
