local create_cmd = vim.api.nvim_create_user_command
local create_au  = vim.api.nvim_create_autocmd
local augroup    = vim.api.nvim_create_augroup

-- ── 1. Mason ─────────────────────────────────────────────
create_cmd("MasonInstallAll", function()
  local tools = {
    "lua-language-server", "pyright", "ruff", "sqls",
    "sqlfluff", "marksman", "bash-language-server",
    "prettier", "stylua",
  }
  local registry = require "mason-registry"
  registry.refresh(function()
    for _, name in ipairs(tools) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok then
        if not pkg:is_installed() then
          pkg:install()
          vim.notify("Mason: installing " .. name, vim.log.levels.INFO)
        end
      else
        vim.notify("Mason: unknown package — " .. name, vim.log.levels.WARN)
      end
    end
  end)
end, { desc = "Install all required LSP/formatters/linters" })

-- ── 2. LspInfo ───────────────────────────────────────────
create_cmd("LspInfo", function()
  local clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
  local lines = { "  LSP Clients", string.rep("─", 50) }
  if #clients == 0 then
    table.insert(lines, "  No clients attached to this buffer")
  end
  for _, c in ipairs(clients) do
    table.insert(lines, string.format("  ● %-20s id: %d", c.name, c.id))
    table.insert(lines, string.format("    root : %s", c.root_dir or "—"))
    table.insert(lines, string.format("    cmd  : %s", vim.inspect(c.config.cmd or {})))
    table.insert(lines, "")
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "lspinfo"

  local width  = 60
  local height = math.min(#lines, math.floor(vim.o.lines * 0.8))
  vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = math.floor((vim.o.lines - height) / 2),
    col       = math.floor((vim.o.columns - width) / 2),
    style     = "minimal",
    border    = "rounded",
    title     = " LSP Info ",
    title_pos = "center",
  })
  vim.keymap.set("n", "q",   "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end, { desc = "Show attached LSP clients" })

-- ── 3. Highlight on yank ─────────────────────────────────
create_au("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
  end,
})

-- ── 4. Auto-resize splits on terminal resize ─────────────
create_au("VimResized", {
  group = augroup("WindowResize", { clear = true }),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext " .. tab)
  end,
})

-- ── 5. Remove trailing whitespace on save ────────────────
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

-- ── 6. Return to last cursor position on file open ───────
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
