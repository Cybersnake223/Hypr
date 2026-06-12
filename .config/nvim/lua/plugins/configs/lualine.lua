local exclude = { "markdown", "quarto", "ipynb" }
return {
  options = {
    theme = "nightfox",
    globalstatus = true,
  },
  extensions = {},
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "filetype", "progress" },
    lualine_y = { "location" },
    lualine_z = { "fileformat", "encoding" },
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
        mode = 4,
        max_length = vim.o.columns * 2 / 3,
      },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}
