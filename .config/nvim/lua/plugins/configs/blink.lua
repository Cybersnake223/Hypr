return {
  -- SNIPPETS: Uses LuaSnip as the engine for code templates
  snippets = { preset = "luasnip" },

  -- CMDLINE: Enables completion while typing commands (e.g., :e or :Mason)
  cmdline = { enabled = true },

  -- APPEARANCE: Adjusts icon padding for Nerd Fonts
  appearance = { nerd_font_variant = "normal" },

  -- FUZZY MATCHING: Forces the Rust backend for blazing fast search/sorting
  fuzzy = { implementation = "prefer_rust" },

  -- SOURCES: Defines where the suggestions come from
  sources = {
    -- Global defaults
    default = { "lsp", "snippets", "buffer", "path" },

    -- Specialized sources for Database work
    per_filetype = {
      sql = { "dadbod", "snippets", "buffer" }, -- dadbod first for SQL tables/columns
      mysql = { "dadbod", "snippets", "buffer" },
      plsql = { "dadbod", "snippets", "buffer" },
    },

    -- Providers: Configuration for external completion sources
    providers = {
      dadbod = {
        name = "Dadbod",
        module = "vim_dadbod_completion.blink", -- Bridge for vim-dadbod
        min_keyword_length = 2, -- Don't trigger on 1 letter
        score_offset = 30, -- Boost SQL suggestions to the top
      },
    },
  },

  -- KEYMAPS: How you interact with the completion menu
  keymap = {
    preset = "default",
    -- <CR> (Enter) accepts the suggestion; 'fallback' means it behaves normally if menu is closed
    ["<CR>"] = { "accept", "fallback" },
    -- Scroll the documentation window with Ctrl+b and Ctrl+f
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  },

  -- COMPLETION UI
  completion = {
    -- Ghost text: Shows a faint preview of the completion inside the line
    ghost_text = { enabled = true },

    -- Documentation window setup (the box that explains what a function does)
    documentation = {
      auto_show = true, -- Show docs automatically
      auto_show_delay_ms = 150, -- Slight delay to prevent flickering while typing fast
      window = { border = "single" },
    },
  },
}
