return {
  options = {
    -- THEMEABLE: Allows your colorscheme (Nightfox) to automatically
    -- set the colors for the tabs, ensuring a consistent look.
    themable = true,

    -- OFFSETS: This prevents the tab line from appearing over sidebars.
    -- It "pushes" the tabs to the right when NvimTree is open.
    offsets = {
      {
        filetype = "NvimTree",
        -- Text that appears above the explorer (optional, could add text = "File Explorer")
        highlight = "NvimTreeNormal",
      },
    },

    -- UI Style (Optional suggestion for your setup)
    -- separator_style = "slant",
    -- diagnostics = "nvim_lsp",
  },
}
