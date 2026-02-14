local create_cmd = vim.api.nvim_create_user_command
local create_au = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-----------------------------------------------------------
-- 1. Mason Automation
-----------------------------------------------------------
-- One command to rule them all. Added Ruff and Pyright for your Python work.
create_cmd("MasonInstallAll", function()
  local tools = {
    "lua-language-server",
    "pyright",
    "ruff",
    "marksman",
    "bash-language-server",
    "prettier",
  }
  vim.cmd("MasonInstall " .. table.concat(tools, " "))
end, { desc = "Install all required LSP/Formatters" })

-----------------------------------------------------------
-- 2. Jupyter Notebook (.ipynb) Workflow
-----------------------------------------------------------
-- This ensures that when you open an .ipynb file, Neovim
-- immediately treats it as a Markdown file for Molten/Quarto.
create_au("FileType", {
  group = augroup("IpynbWorkflow", { clear = true }),
  pattern = "json",
  callback = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name:match "%.ipynb$" then
      -- Convert view to markdown to enable LSP + Molten
      vim.bo.filetype = "markdown"

      -- Schedule the Quarto activation to ensure the buffer is ready
      vim.schedule(function()
        vim.cmd "QuartoActivate"
        -- Optional: Notify that we've switched modes
        vim.notify("Notebook detected: Markdown mode activated", vim.log.levels.INFO)
      end)
    end
  end,
})

-- Auto-sync Jupytext
-- When you save a markdown file associated with a notebook,
-- this keeps the actual .ipynb file updated in the background.
create_au("BufWritePost", {
  group = augroup("JupytextSync", { clear = true }),
  pattern = "*.ipynb.md",
  callback = function()
    if vim.fn.exists ":JupytextSync" > 0 then
      vim.cmd "JupytextSync"
    end
  end,
})

-----------------------------------------------------------
-- 3. General Quality of Life
-----------------------------------------------------------
-- Highlight on yank (Very helpful to see what you just copied)
create_au("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 }
  end,
})

-- Auto-resize splits when the terminal window is resized
create_au("VimResized", {
  group = augroup("WindowResize", { clear = true }),
  command = "tabdo wincmd =",
})
