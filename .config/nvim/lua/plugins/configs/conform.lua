return {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_fix" },
    sql = { "sqlfluff" },
    markdown = { "prettier" },
    quarto = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    sh = { "shfmt" },
  },
  format_on_save = {
    lsp_format = "fallback",
    timeout_ms = 1500,
    exclude = {
      function(bufnr)
        return vim.b[bufnr].jupytext == true
          or vim.api.nvim_buf_get_name(bufnr):match("%.ipynb%.md$") ~= nil
      end,
    },
  },
}
