-- ─────────────────────────────────────────────────────────
-- 0. Provider Disables
-- ─────────────────────────────────────────────────────────
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- ─────────────────────────────────────────────────────────
-- 1. Core Options
-- ─────────────────────────────────────────────────────────
require "options"
require "mappings"
require "commands"

vim.lsp.log.set_level(vim.log.levels.WARN)

-- ─────────────────────────────────────────────────────────
-- 2. Clipboard detection
-- ─────────────────────────────────────────────────────────
if vim.fn.executable "wl-copy" == 1 or vim.fn.executable "xclip" == 1 or vim.fn.executable "xsel" == 1 then
  vim.opt.clipboard = "unnamedplus"
end

-- ─────────────────────────────────────────────────────────
-- 3. Direct gf in lua
-- ─────────────────────────────────────────────────────────

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.keymap.set("n", "gf", function()
      local cfile = vim.fn.expand "<cfile>"
      local target = cfile:gsub("%.", "/")
      if target:match "^modules/" then
        vim.cmd("edit " .. vim.fn.expand "~/.config/hypr/" .. target .. ".lua")
      else
        vim.cmd "normal! gf"
      end
    end, { buffer = true, silent = true })
  end,
})

-- ─────────────────────────────────────────────────────────
-- 4. Lazy.nvim Bootstrap
-- ─────────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

-- ─────────────────────────────────────────────────────────
-- 5. Lazy.nvim Setup
-- ─────────────────────────────────────────────────────────
require("lazy").setup("plugins", {
  checker = { enabled = false },
  change_detection = { notify = false },
  defaults = { lazy = true },
  concurrency = 8,

  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "rplugin",
        "netrwPlugin",
        "matchit",
        "matchparen",
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
      },
    },
  },
})

-- lazy.nvim sets loadplugins=false, which prevents Neovim's
-- built-in rplugin.vim from sourcing the rplugin manifest.
-- Source it manually so Python rplugin commands (Molten, etc.) work.
vim.cmd [[
  if filereadable(stdpath('data') . '/rplugin.vim')
    execute 'source' fnameescape(stdpath('data') . '/rplugin.vim')
  endif
]]

-- ─────────────────────────────────────────────────────────
-- 6. Autocommands
-- ─────────────────────────────────────────────────────────

-- Indentation overrides for Python and SQL
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("IndentOverrides", { clear = true }),
  pattern = { "python", "sql" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("MoltenSetup", { clear = true }),
  pattern = { "*.md", "*.qmd", "*.ipynb" },
  callback = function()
    if package.loaded["molten"] then
      vim.cmd.MoltenImportOutput()
    end
  end,
})

-- Quarto/Markdown: force conceal off (render-markdown handles visuals)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MarkdownUIFix", { clear = true }),
  pattern = { "quarto", "qmd", "markdown" },
  callback = function()
    vim.wo.conceallevel = 0
    vim.wo.concealcursor = ""
  end,
})
