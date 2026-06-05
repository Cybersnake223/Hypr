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

vim.opt.shada = "!,'100,<50,s10,h"
vim.lsp.set_log_level = "off"

-- ─────────────────────────────────────────────────────────
-- 2. Clipboard detection
-- ─────────────────────────────────────────────────────────
vim.opt.clipboard = ""
vim.schedule(function()
  if vim.fn.executable "wl-copy" == 1 then
    vim.opt.clipboard = "unnamedplus"
  end
end)

-- ─────────────────────────────────────────────────────────
-- 3. Lazy.nvim Bootstrap
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
-- 4. Lazy.nvim Setup
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
        -- "rplugin",
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

-- ─────────────────────────────────────────────────────────
-- 5. Autocommands
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

-- Molten: Auto-import output on initial buffer load (not on every file type change)
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("MoltenSetup", { clear = true }),
  pattern = { "*.md", "*.qmd", "*.ipynb" },
  callback = function()
    if package.loaded["molten"] then
      pcall(vim.cmd, "MoltenImportOutput")
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

-- Big file guard: skip data extensions always; disable treesitter for files over 2 MB
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("BigFileGuard", { clear = true }),
  callback = function(ev)
    local ext = vim.fn.fnamemodify(ev.file, ":e")
    if vim.tbl_contains({ "csv", "tsv", "parquet", "arrow", "feather", "log", "json", "xml" }, ext) then
      vim.b.treesitter_enabled = false
    elseif vim.fn.getfsize(ev.file) > 1024 * 1024 * 2 then
      vim.b.treesitter_enabled = false
    end
  end,
})
