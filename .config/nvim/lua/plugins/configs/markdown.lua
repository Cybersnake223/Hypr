-- Only auto-activate Quarto for jupytext notebook markdown buffers
local name = vim.api.nvim_buf_get_name(0)
if name:match("%.ipynb%.md$") or name:match("%.md$") and vim.b.jupytext then
  require("quarto").activate()
end
