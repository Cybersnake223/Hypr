return {
  picker = {
    enabled = true,
    hidden = true,
    layout = { ivy = { max_height = 0.8, width = 0.8 } },
    matcher = { frecency = true },
    sources = {
      files = {
        hidden = true,
      },
      grep = {
        hidden = true,
      },
    },
  },

  bigfile = { enabled = true },
  dashboard = { enabled = false },
  explorer = { enabled = false, replace_netrw = true },
  indent = { enabled = false },
  input = { enabled = true },
  notifier = { enabled = false },
  quickfile = { enabled = true },
  scope = { enabled = false },
  scroll = { enabled = false },
  statuscolumn = { enabled = false },
  words = { enabled = true },
}
