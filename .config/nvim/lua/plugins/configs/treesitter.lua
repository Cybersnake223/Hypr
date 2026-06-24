local M = {}

M.parsers = {
  "lua", "luadoc",
  "vim", "vimdoc", "query",
  "python",
  "sql",
  "bash",
  "markdown", "markdown_inline",
  "regex",
}

-- Filetypes where TS highlight is deferred (avoids startup spike)
M.defer_ft = {
  markdown        = true,
  markdown_inline = true,
}

-- Special buffers where TS should never start
M.ignore_ft = {
  [""] = true,
  TelescopePrompt    = true,
  snacks_picker_input = true,
  snacks_notif       = true,
  lazy               = true,
  mason              = true,
  dbee               = true,
}

function M.setup()
  -- Register ft → parser name for known mismatches
  vim.treesitter.language.register("bash", "sh")
  vim.treesitter.language.register("bash", "zsh")

  -- Ensure parsers are installed (async, no-op if already present)
  vim.defer_fn(function()
    pcall(require("nvim-treesitter.install").ensure_installed, M.parsers)
  end, 0)

  -- Folding handled by nvim-ufo (LSP + treesitter hybrid)

  -- Per-FileType highlighting
  vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("treesitter_ft", { clear = true }),
    pattern  = "*",
    callback = function(ev)
      local ft = ev.match

      -- Skip special/ignored buffers
      if M.ignore_ft[ft] then return end

      -- Skip if big-file guard (set by snacks.bigfile)
      if vim.b.bigfile then return end

      -- Defer markdown to avoid 29ms FileType spike seen in startup profiles
      if M.defer_ft[ft] then
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then
            pcall(vim.treesitter.start, ev.buf)
          end
        end, 50)
        return
      end

      pcall(vim.treesitter.start, ev.buf)
    end,
  })
end

return M
