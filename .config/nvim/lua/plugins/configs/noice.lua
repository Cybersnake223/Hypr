require("noice").setup {
  lsp = {
    -- OVERRIDES: This section tells Neovim to use Noice (and Treesitter)
    -- to render the hover windows and documentation.
    -- This makes the popups look like actual formatted markdown rather than plain text.
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      -- This ensures that documentation from your completion engine (Blink/Cmp)
      -- is also styled beautifully by Noice.
      ["cmp.entry.get_documentation"] = true,
    },
  },

  -- PRESETS: These are "bundles" of settings that define the UI layout.
  presets = {
    -- Puts the search bar (/) at the bottom instead of a floating box in the middle.
    bottom_search = true,

    -- COMMAND PALETTE: Centers the command line (:) at the top-middle of the screen.
    -- It also groups the suggestion menu right underneath it.
    command_palette = true,

    -- Keeps your screen clean by moving very long messages
    -- (like errors or logs) into a separate side-split.
    long_message_to_split = true,

    -- Since you aren't using inc-rename.nvim, this is kept false.
    inc_rename = false,

    -- Set this to true if you want a box border around your LSP 'K' hover windows.
    lsp_doc_border = false,
  },
}
