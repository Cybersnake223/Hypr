return {
  snippets = {
    preset = "luasnip",
    expand = function(snippet)
      require("luasnip").lsp_expand(snippet)
    end,
    active = function()
      local luasnip = require("luasnip")
      return luasnip.active and luasnip.active()
    end,
    jump = function(direction)
      require("luasnip").jump(direction)
    end,
  },
  cmdline = { enabled = false },
  appearance = { nerd_font_variant = "normal" },
  fuzzy = { implementation = "prefer_rust" },
  sources = {
    default = { "lsp", "snippets", "buffer", "path" },
    per_filetype = {
      sql = { "lsp", "snippets", "dadbod", "buffer" },
      mysql = { "lsp", "snippets", "dadbod", "buffer" },
      plsql = { "lsp", "snippets", "dadbod", "buffer" },
    },
    providers = {
      dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      lsp = { min_keyword_length = 2 },
      snippets = { min_keyword_length = 2 },
      buffer = { min_keyword_length = 3 },
    },
  },

  keymap = {
    preset = "default",
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<C-j>"] = { "snippet_forward", "select_next", "fallback" },
    ["<C-k>"] = { "snippet_backward", "select_prev", "fallback" },
    ["<C-space>"] = { "show", "fallback" },
    ["<C-e>"] = { "hide", "fallback" },
  },

  completion = {
    list = {
      selection = { preselect = true, auto_insert = false },
    },
    menu = {
      auto_show = true,
      draw = {
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "source_name", width = { max = 12 } },
        },
        components = {
          source_name = {
            text = function(ctx)
              local map = { snippets = "Snip", buffer = "Buf", path = "Path", dadbod = "DB" }
              return map[ctx.source_name] or ctx.source_name
            end,
          },
        },
      },
    },
    ghost_text = { enabled = true },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
      window = { border = "rounded" },
    },
  },
}
