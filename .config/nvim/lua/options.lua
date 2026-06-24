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
opt.wrap = true
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
opt.updatetime = 500
opt.inccommand = "split"
opt.diffopt:append "linematch:60"
opt.confirm = true
opt.shortmess:append "filnxtToOFIc"
opt.winminwidth = 10
opt.smoothscroll = true
opt.sessionoptions:append { "globals", "folds", "localoptions" }
opt.numberwidth = 2

-- ── Search ───────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true

-- ── Undo / ShaDA (persistent across restarts) ───────────
opt.undofile = true
opt.shada = "!,'100,<50,s10,h"

-- ── Indentation ──────────────────────────────────────────
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- ── Python / Neovim provider ─────────────────────────────
local venv = os.getenv "VIRTUAL_ENV"
if venv and vim.fn.executable(venv .. "/bin/python3") == 1 then
  g.python3_host_prog = venv .. "/bin/python3"
elseif vim.fn.executable(vim.fn.expand "~/.venv/bin/python3") == 1 then
  g.python3_host_prog = vim.fn.expand "~/.venv/bin/python3"
end

-- ── Appearance ───────────────────────────────────────────
g.have_nerd_font = true

-- ── Mason → PATH ─────────────────────────────────────────
local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. sep .. vim.env.PATH
end
