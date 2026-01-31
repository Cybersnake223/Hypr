return {
  snippets = { preset = "luasnip" },
  cmdline = { enabled = true },
  appearance = { nerd_font_variant = "normal" },
  fuzzy = { implementation = "prefer_rust" },
  sources = {
    default = { "lsp", "snippets", "buffer", "path" },
    per_filetype = {
      sql = { "snippets", "dadbod", "buffer" },  -- dadbod first for SQL tables/columns
      mysql = { "snippets", "dadbod", "buffer" },
      plsql = { "snippets", "dadbod", "buffer" },
    },
    providers = {
      dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
    },
  },

  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f"] = { "scroll_documentation_down", "fallback" },
  },

  completion = {
    ghost_text = { enabled = true },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { border = "single" },
    },
  },
}
