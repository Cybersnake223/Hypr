local M = {}

M.parsers = {
  "lua", "luadoc",
  "vim", "vimdoc", "query",
  "python",
  "sql",
  "bash",
  "markdown", "markdown_inline",
  "toml", "yaml", "json", "jsonc",
  "diff", "gitcommit", "gitignore",
  "regex",
}

-- Filetypes where TS highlight is deferred (avoids startup spike)
M.skip_ft = {
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
  local ts = require "nvim-treesitter"

  -- Register ft → parser name for known mismatches
  vim.treesitter.language.register("bash", "sh")    -- vim ft=sh → bash parser
  vim.treesitter.language.register("bash", "zsh")   -- zsh → bash parser (close enough)

  -- Install parsers; no-op if already present
  ts.install(M.parsers, { summary = false }):wait(30000)

  -- Treesitter-based folding (start with folds open)
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
  vim.opt.foldenable = false   -- folds available but open by default; zi to toggle
  vim.opt.foldlevel  = 99

  -- Per-FileType highlighting
  vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("treesitter_ft", { clear = true }),
    pattern  = "*",
    callback = function(ev)
      local ft = ev.match

      -- Skip special/ignored buffers
      if M.ignore_ft[ft] then return end

      -- Skip if big-file guard set in commands.lua BufReadPre autocmd
      if vim.b[ev.buf].treesitter_enabled == false then return end

      -- Defer markdown to avoid 29ms FileType spike seen in startup profiles
      if M.skip_ft[ft] then
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
