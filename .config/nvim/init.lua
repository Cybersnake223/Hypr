-----------------------------------------------------------
-- 0. Experimental
-----------------------------------------------------------

if vim.loader then
  vim.loader.enable()
end

-----------------------------------------------------------
-- 1. Performance: Disable Built-in Neovim Plugins
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
-- 2. Configuration & Keymaps
-----------------------------------------------------------
require "options" -- Load your settings first
require "mappings" -- Load your keybindings
require "commands" -- Load custom user commands

-- Global/Window tweaks for Data Science
vim.wo.relativenumber = true -- Hybrid line numbers (great for jumping)
vim.o.conceallevel = 0 -- Ensure code blocks/symbols aren't hidden by default
vim.g.db_ui_save_location = vim.fn.expand "~/Sql/.queries"

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
require("lazy").setup(require "plugins", {
  -- PERFORMANCE OPTIMIZATION:
  -- Byte-compile and cache Lua modules for nearly instant loading.
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true, -- Resets the package path to improve startup time
    rtp = {
      -- Disable built-in plugins you don't use to save load time
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  -- Use a separate file for your plugin specs to keep init.lua clean
  -- change_detection = { notify = false }, -- Stop the "Config Change Detected" notification
})

-----------------------------------------------------------
-- 4. Autocommands (Automated Behavior)
-----------------------------------------------------------

-- Molten: Auto-import output when opening notebooks
-- This makes your saved charts and results appear automatically
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
-- Prevents text from disappearing/hiding while editing
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("MarkdownUIFix", { clear = true }),
  pattern = { "quarto", "qmd", "markdown" },
  callback = function()
    vim.wo.conceallevel = 0
    vim.wo.concealcursor = ""
  end,
})

-----------------------------------------------------------
-- 5. User Commands
-----------------------------------------------------------
-- Simple shortcuts for the Markdown Previewer
vim.api.nvim_create_user_command("PeekOpen", function()
  require("peek").open()
end, {})
vim.api.nvim_create_user_command("PeekClose", function()
  require("peek").close()
end, {})
