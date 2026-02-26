return {
  options = {
    transparent = true,
    compile_path = vim.fn.stdpath "cache" .. "/nightfox",
    compile_file_suffix = "_compiled",
    dim_inactive = false,
    module_default = true,
    modules = {
      diagnostic = {
        enable = true,
        background = false,
      },
      native_lsp = {
        enable = true,
        background = false,
      },
      treesitter = true,
      gitsigns = true,
      whichkey = true,
      lualine = true,
      mini = true,
      render_markdown = true,
    },
  },

  palettes = {
    nightfox = {
      comment = "#6e7f9f",
    },
  },

  specs = {
    all = {
      syntax = {
        keyword = "magenta",
        builtin0 = "red",
        builtin2 = "blue.dim",
      },
    },
  },

  groups = {
    all = {
      -- ── Transparent floats ───────────────────────────────
      NormalFloat = { bg = "NONE" },
      FloatBorder = { bg = "NONE" },
      FloatTitle = { bg = "NONE" },

      -- ── Diagnostic virtual text (no bg, colored fg) ──────
      DiagnosticVirtualTextError = { fg = "palette.red.base", bg = "NONE" },
      DiagnosticVirtualTextWarn = { fg = "palette.yellow.base", bg = "NONE" },
      DiagnosticVirtualTextInfo = { fg = "palette.blue.base", bg = "NONE" },
      DiagnosticVirtualTextHint = { fg = "palette.cyan.base", bg = "NONE" },

      -- ── Diagnostic underlines (undercurl with sp color) ──
      DiagnosticUnderlineError = { sp = "palette.red.base", style = "undercurl" },
      DiagnosticUnderlineWarn = { sp = "palette.yellow.base", style = "undercurl" },
      DiagnosticUnderlineInfo = { sp = "palette.blue.base", style = "underline" },
      DiagnosticUnderlineHint = { sp = "palette.cyan.base", style = "underline" },

      -- ── LSP reference highlights (snacks words.enabled) ──
      LspReferenceText = { bg = "palette.bg3.base" },
      LspReferenceRead = { bg = "palette.bg3.base" },
      LspReferenceWrite = { bg = "palette.bg3.base", style = "bold" },

      -- ── Inlay hints ──────────────────────────────────────
      LspInlayHint = { fg = "palette.comment.base", style = "italic" },

      -- ── Indent guides (indentmini) ───────────────────────
      IndentLine = { link = "Comment" },
      IndentLineCurrent = { fg = "palette.blue.dim" },

      -- ── Snacks picker ────────────────────────────────────
      SnacksPickerBorder = { bg = "NONE" },
      SnacksPickerTitle = { fg = "palette.blue.base", style = "bold" },
      SnacksPickerDir = { fg = "palette.comment.base" },

      -- ── Trouble.nvim ─────────────────────────────────────
      TroubleNormal = { bg = "NONE" },

      -- ── Which-key ────────────────────────────────────────
      WhichKeyBorder = { bg = "NONE" },
      WhichKeyFloat = { bg = "NONE" },

      -- ── Render-markdown ──────────────────────────────────
      RenderMarkdownCode = { bg = "palette.bg2.base" },
      RenderMarkdownCodeInline = { bg = "palette.bg2.base" },
      RenderMarkdownH1Bg = { bg = "palette.blue.dim" },
      RenderMarkdownH2Bg = { bg = "palette.cyan.dim" },
    },
  },
}
