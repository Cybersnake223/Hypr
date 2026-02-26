local create_cmd = vim.api.nvim_create_user_command
local create_au = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ── 1. Mason ─────────────────
create_cmd("MasonInstallAll", function()
  local tools = {
    "lua-language-server",
    "pyright",
    "ruff",
    "sqls",
    "sqlfluff",
    "marksman",
    "bash-language-server",
    "prettier",
    "stylua",
  }
  vim.cmd("MasonInstall " .. table.concat(tools, " "))
end, { desc = "Install all required LSP/formatters/linters" })

-- ── 2. Highlight on yank ─────────────────────────────────
create_au("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
  end,
})

-- ── 3. Auto-resize splits on terminal resize ─────────────
create_au("VimResized", {
  group = augroup("WindowResize", { clear = true }),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext " .. tab)
  end,
})

-- ── 4. Remove trailing whitespace on save ────────────────
-- Skips binary files and diffs
create_au("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  callback = function()
    if not vim.bo.binary and vim.bo.filetype ~= "diff" then
      local view = vim.fn.winsaveview()
      vim.cmd [[%s/\s\+$//e]]
      vim.fn.winrestview(view)
    end
  end,
})

-- ── 5. Return to last cursor position on file open ───────
-- create_au("BufReadPost", {
--   group = augroup("RestoreCursor", { clear = true }),
--   callback = function()
--     local mark = vim.api.nvim_buf_get_mark(0, '"')
--     local line_count = vim.api.nvim_buf_line_count(0)
--     if mark[1] > 0 and mark[1] <= line_count then
--       pcall(vim.api.nvim_win_set_cursor, 0, mark)
--     end
--   end,
-- })
