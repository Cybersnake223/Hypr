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

vim.o.conceallevel = 0
vim.opt.shada = "!,'100,<50,s10,h"
vim.lsp.set_log_level "off"
vim.g.db_ui_save_location = vim.fn.getcwd() .. "/.sql_queries"

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

  performance = {
    cache = { enabled = true }, 
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        -- "rplugin",         
        "netrwPlugin",
        "matchit",
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

-- Molten: Auto-import output only if molten has actually loaded
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MoltenSetup", { clear = true }),
  pattern = { "markdown", "quarto", "ipynb" },
  callback = function()
    if package.loaded["molten"] then
      vim.schedule(function()
        pcall(vim.cmd, "MoltenImportOutput")
      end)
    end
  end,
})

-- Quarto/Markdown: force conceal off (render-markdown handles visuals)
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("MarkdownUIFix", { clear = true }),
  pattern = { "quarto", "qmd", "markdown" },
  callback = function()
    vim.wo.conceallevel = 0
    vim.wo.concealcursor = ""
  end,
})

-- Big file guard: disable treesitter for files over 500KB
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("BigFileGuard", { clear = true }),
  callback = function(ev)
    if vim.fn.getfsize(ev.file) > 1024 * 500 then
      vim.b.treesitter_enabled = false
    end
  end,
})

-- ─────────────────────────────────────────────────────────
-- 6. User Commands
-- ─────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("PeekOpen", function()
  local ok, peek = pcall(require, "peek")
  if ok then
    peek.open()
  else
    vim.notify("peek.nvim is not loaded. Uncomment it in plugins/.", vim.log.levels.WARN)
  end
end, { desc = "Open Peek markdown preview" })

vim.api.nvim_create_user_command("PeekClose", function()
  local ok, peek = pcall(require, "peek")
  if ok then
    peek.close()
  else
    vim.notify("peek.nvim is not loaded. Uncomment it in plugins/.", vim.log.levels.WARN)
  end
end, { desc = "Close Peek markdown preview" })
