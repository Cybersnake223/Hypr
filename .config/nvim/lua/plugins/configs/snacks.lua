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
  explorer = { enabled = true, replace_netrw = true },
  indent = { enabled = true, indent = { only_scope = false, animate = { enabled = false } } },
  input = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = false },
  session = { enabled = true },
  scroll = { enabled = false },
  statuscolumn = { enabled = false },
  terminal = { enabled = true },
  words = { enabled = true },
}
