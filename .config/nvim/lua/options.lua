local o = vim.o
local g = vim.g

g.mapleader = " "

o.laststatus = 3 -- global statusline
o.showmode = true

o.clipboard = "unnamedplus"

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

vim.opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

o.number = true

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.termguicolors = true
o.timeoutlen = 400
o.undofile = true
o.cursorline = true

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath "data" .. "/mason/bin"

vim.api.nvim_set_hl(0, "IndentLine", { link = "Comment" })

-- I find auto open annoying, keep in mind setting this option will require setting
-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
g.molten_auto_open_output = false

-- this guide will be using image.nvim
-- Don't forget to setup and install the plugin if you want to view image outputs
g.molten_image_provider = "image.nvim"

-- optional, I like wrapping. works for virt text and the output window
g.molten_wrap_output = true

-- Output as virtual text. Allows outputs to always be shown, works with images, but can
-- be buggy with longer images
g.molten_virt_text_output = true

-- this will make it so the output shows up below the \`\`\` cell delimiter
g.molten_virt_lines_off_by_1 = true


-- enable the servers
-- vim.lsp.enable 'r_language_server'
-- vim.lsp.enable 'cssls'
-- vim.lsp.enable 'html'
-- vim.lsp.enable 'emmet_language_server'
-- vim.lsp.enable 'svelte'
-- vim.lsp.enable 'jsonls'
-- vim.lsp.enable 'texlab'
-- vim.lsp.enable 'dotls'
vim.lsp.enable 'ts_ls'
-- vim.lsp.enable 'yamlls'
-- vim.lsp.enable 'clangd'
-- vim.lsp.enable 'ltex'
-- vim.lsp.enable 'marksman'
-- vim.lsp.enable 'sqlls'
-- vim.lsp.enable 'hls'
-- vim.lsp.enable 'julia-lsp'
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'bashls'
vim.lsp.enable 'pyright'
-- vim.lsp.enable 'rust_analyzer'
-- vim.lsp.enable 'ruff_lsp'

-- android development
-- vim.lsp.enable 'kotlin_language_server'
-- vim.lsp.enable 'jdtls'
