return {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    -- sql uses LSP (sqls)
    -- markdown/quarto format manually via <leader>lf (prettier is slow)
    -- json/yaml/sh use LSP fallback (faster than external formatters)
  },
  format_on_save = {
    lsp_format = "fallback",
    timeout_ms = 2000,
    exclude = {
      function(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        return vim.b[bufnr].jupytext == true
          or name:match("%.ipynb%.md$") ~= nil
      end,
    },
  },
}
