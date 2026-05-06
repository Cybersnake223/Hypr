local exclude = { "markdown", "quarto", "ipynb" }
return {
  options = {
    theme = "nightfox",
    globalstatus = true,
    refresh = { statusline = 3000, tabline = 3000, winbar = 1000 },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = { "filename" },
  },
  tabline = {
    lualine_a = {
      {
        "buffers",
        filetype_name = function(ft)
          return vim.tbl_contains(exclude, ft) and "" or ft
        end,
        show_filename_only = true,
        show_modified_status = true,
        mode = 0,
        max_length = vim.o.columns * 2 / 3,
      },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  extensions = { "oil" },
}
