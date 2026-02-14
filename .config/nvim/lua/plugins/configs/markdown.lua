-- ==========================================================
-- QUARTO AUTO-ACTIVATION LOGIC
-- ==========================================================

-- Get the full path of the current file
local name = vim.api.nvim_buf_get_name(0)
if name:match "%.ipynb%.md$" or (name:match "%.md$" and vim.b.jupytext) then
  -- schedule moves the 'heavy' activation out of the startup blocking path
  vim.schedule(function()
    require("quarto").activate()
  end)
end
