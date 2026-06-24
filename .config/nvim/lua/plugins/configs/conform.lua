return {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    sql = { "lsp" },
    json = { "lsp" },
    yaml = { "lsp" },
    sh = { "lsp" },
    zsh = { "lsp" },
    -- markdown/quarto format manually via <leader>lf (prettier is slow)
  },
  format_on_save = {
    timeout_ms = 2000,
    lsp_format = "fallback",
    exclude = {
      function(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        return vim.b[bufnr].jupytext == true
          or name:match("%.ipynb%.md$") ~= nil
      end,
    },
  },
  default_format_opts = {
    trim_whitespace = true,
  },
}
