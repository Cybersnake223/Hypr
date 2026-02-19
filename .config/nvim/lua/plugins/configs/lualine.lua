local exclude = { "markdown", "quarto", "ipynb" }
return {
  options = {
    theme = "onedark",
    globalstatus = true,
    refresh = { statusline = 1000, tabline = 1000, winbar = 1000 },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = { "filename" },
  },
  extensions = { "nvim-tree" },
}
