require "options"
require "mappings"
require "commands"

-- bootstrap plugins & lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim" -- path where its going to be installed

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

local plugins = require "plugins"

require("lazy").setup(plugins, require "lazy_config")

vim.cmd "colorscheme nightfox"
vim.o.fsync = false
vim.g.python3_host_prog = vim.fn.expand("~/.venv/neovim/bin/python3")
vim.g.db_ui_save_location = vim.fn.expand('~/Sql/.queries')
vim.g.nightfox_transparent = true
vim.wo.relativenumber = true
vim.o.conceallevel = 0

-- Molten

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    if vim.bo.filetype == "markdown" then
      vim.schedule(function() vim.cmd("MoltenImportOutput") end)
    end
  end,
})

-- markdown
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  pattern = { "quarto", "qmd" },
  callback = function()
    vim.wo.conceallevel = 0      -- ← window-local (not buffer-local)
    vim.wo.concealcursor = ""    -- ← window-local
  end,
  group = vim.api.nvim_create_augroup("FixRenderMarkdownBug", { clear = true }),
})

vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
