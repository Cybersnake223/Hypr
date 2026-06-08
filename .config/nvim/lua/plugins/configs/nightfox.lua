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
      treesitter = true,
      gitsigns = true,
      whichkey = true,
      lualine = true,
      mini = true,
    },
  },

  palettes = {
    nightfox = {
      -- comment = "#6e7f9f",
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

      -- ── Indent guides (snacks.indent) ────────────────────
      SnacksIndent = { link = "Comment" },
      SnacksIndentScope = { fg = "palette.blue.dim" },

      -- ── Snacks picker ────────────────────────────────────
      SnacksPickerBorder = { bg = "NONE" },
      SnacksPickerTitle = { fg = "palette.blue.base", style = "bold" },
      SnacksPickerDir = { fg = "palette.comment.base" },

      -- ── Which-key ────────────────────────────────────────
      WhichKeyBorder = { bg = "NONE" },
      WhichKeyFloat = { bg = "NONE" },

      -- ── Render-markdown ──────────────────────────────────
      -- Headings: subtle blended background bars + bright accent fg/icon
      RenderMarkdownH1Bg = { bg = "diff.change" },
      RenderMarkdownH2Bg = { bg = "diff.text" },
      RenderMarkdownH3Bg = { bg = "diff.add" },
      RenderMarkdownH4Bg = { bg = "diag_bg.warn" },
      RenderMarkdownH5Bg = { bg = "diag_bg.error" },
      RenderMarkdownH6Bg = { bg = "diff.delete" },
      RenderMarkdownH1 = { fg = "palette.blue.bright", style = "bold" },
      RenderMarkdownH2 = { fg = "palette.cyan.bright", style = "bold" },
      RenderMarkdownH3 = { fg = "palette.green.bright", style = "bold" },
      RenderMarkdownH4 = { fg = "palette.yellow.base", style = "bold" },
      RenderMarkdownH5 = { fg = "palette.red.base", style = "bold" },
      RenderMarkdownH6 = { fg = "palette.magenta.base", style = "bold" },

      -- Code blocks: sunken panel slightly darker than editor bg
      RenderMarkdownCode = { bg = "palette.bg0.base" },
      RenderMarkdownCodeInline = { bg = "palette.bg3.base", fg = "palette.fg1.base" },
      RenderMarkdownCodeBorder = { fg = "palette.bg0.base", bg = "palette.bg0.base" },
      RenderMarkdownCodeInfo = { fg = "palette.comment.base", bg = "palette.bg0.base", style = "italic" },
      RenderMarkdownCodeFallback = { bg = "palette.bg0.base" },

      -- General markdown elements
      RenderMarkdownDash = { fg = "palette.fg3.base" },
      RenderMarkdownBullet = { fg = "palette.blue.bright" },
      RenderMarkdownQuote = { fg = "palette.green.base", style = "italic" },
      RenderMarkdownLink = { fg = "palette.blue.bright", style = "underline" },
      RenderMarkdownWikiLink = { fg = "palette.cyan.base", style = "underline" },
      RenderMarkdownTableHead = { fg = "palette.blue.bright", style = "bold" },
      RenderMarkdownTableRow = { fg = "palette.fg2.base" },
      RenderMarkdownSign = { bg = "NONE" },
      RenderMarkdownMath = { fg = "palette.yellow.base", style = "italic" },
    },
  },
}
