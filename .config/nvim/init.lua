-----------------------------------------------------------
--  Absolute Early Disable (Performance)
-----------------------------------------------------------
-- Disable providers you don't use
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
-- vim.g.loaded_remote_plugins = 1
-----------------------------------------------------------
-- 0. Performance: Disable Built-in Neovim Plugins
-----------------------------------------------------------
local disabled_builtins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "zip",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
}

for _, plugin in ipairs(disabled_builtins) do
  vim.g["loaded_" .. plugin] = 1
end

-----------------------------------------------------------
-- 1. Experimental
-----------------------------------------------------------

if vim.loader then
  vim.loader.enable()
end


-----------------------------------------------------------
-- 2. Configuration & Keymaps
-----------------------------------------------------------
require "options" -- Load your settings first
require "mappings" -- Load your keybindings
require "commands" -- Load custom user commands

-- Global/Window tweaks for Data Science
vim.o.conceallevel = 0 -- Ensure code blocks/symbols aren't hidden by default
vim.g.db_ui_save_location = vim.fn.getcwd() .. "/.sql_queries"
-----------------------------------------------------------
-- 3. Plugin Bootstrapping (Lazy.nvim)
-----------------------------------------------------------
-- Define where Lazy.nvim will be installed on your system
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- Check if Lazy.nvim is already installed; if not, clone it from GitHub
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none", -- Efficient cloning (doesn't download every single file's history)
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end

-- Add the Lazy.nvim path to the Neovim runtime path (RTP)
vim.opt.rtp:prepend(lazypath)

-- Setup Lazy.nvim
-- Performance Tip: Pass a table of options directly or ensure your 'lazy_config'
-- includes performance-specific flags.
require("lazy").setup("plugins", {
  -- PERFORMANCE OPTIMIZATION:
  -- Byte-compile and cache Lua modules for nearly instant loading.
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      -- Disable built-in plugins you don't use to save load time
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
      checker = { enabled = false},
      change_detection = { notify = false },
      defaults = { lazy = true },
    },
  },
  -- Use a separate file for your plugin specs to keep init.lua clean
  -- change_detection = { notify = false }, -- Stop the "Config Change Detected" notification
})

-- Defer clipboard
vim.opt.clipboard = ""
if vim.fn.executable("wl-copy") == 1 or vim.fn.executable("xclip") == 1 then
  vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"
  end)
end

-- Shorter timeout for LSP shutdown (default is often 5000ms)
vim.lsp.set_log_level("off")

-- Limits the size of the ShaDa file (registers, marks, etc.)
vim.opt.shada = "!,'100,<50,s10,h"

-----------------------------------------------------------
-- 4. Autocommands (Automated Behavior)
-----------------------------------------------------------

-- CLEANUP ON EXIT: Stops Molten and LSPs immediately to prevent :wq lag
local cleanup_group = vim.api.nvim_create_augroup("ExitCleanup", { clear = true })

-- Indentation for py files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "sql" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})


--
-- Molten: Auto-import output when opening notebooks
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MoltenSetup", { clear = true }),
  pattern = { "markdown", "quarto", "ipynb" },
  callback = function()
    vim.schedule(function()
      pcall(vim.cmd, "MoltenImportOutput")
    end)
  end,
})

-- Quarto/Markdown UI Fixes
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("MarkdownUIFix", { clear = true }),
  pattern = { "quarto", "qmd", "markdown" },
  callback = function()
    vim.wo.conceallevel = 0
    vim.wo.concealcursor = ""
  end,
})

-- Disable heavy features for massive data files
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(ev)
    local size = vim.fn.getfsize(ev.file)
    if size > 1024 * 500 then -- 500KB limit
      vim.b.treesitter_enabled = false
    end
  end,
})
-----------------------------------------------------------
-- 5. User Commands
-----------------------------------------------------------
-- Simple shortcuts for the Markdown Previewer
vim.api.nvim_create_user_command("PeekOpen", function()
  require("lazy").load({plugins = {"peek.nvim"}})
  require("peek").open()
end, {})

vim.api.nvim_create_user_command("PeekClose", function()
  require("lazy").load({plugins = {"peek.nvim"}})
  require("peek").close()
end, {})
