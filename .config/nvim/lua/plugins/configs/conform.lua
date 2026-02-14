return {
  -- FORMATTERS_BY_FT: Maps filetypes to specific formatting tools.
  -- These tools must be installed via Mason (e.g., :MasonInstall black stylua).
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff" },
    javascript = { "prettier" },
  },

  -- FORMAT_ON_SAVE: Automatically runs the formatter when you write the file (:w).
  format_on_save = {
    -- Time in ms to wait for the formatter before giving up.
    -- 500ms is standard, but large Python files might occasionally need 1000ms.
    timeout_ms = 500,

    -- LSP_FALLBACK: If the specific formatter (like black) isn't found,
    -- it will try to use the formatting capability of your active LSP.
    lsp_fallback = true,
  },
}
