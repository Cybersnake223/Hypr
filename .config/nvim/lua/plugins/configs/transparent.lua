local transparent = require("transparent")

transparent.setup({
  groups = { 'all' },  -- Nukes ALL backgrounds (safest)
  extra_groups = {}, 
  exclude_groups = {},
})

-- Global winblend = 0 (CRITICAL for floats)
vim.o.winblend = 0
vim.o.pumblend = 0

-- FORCE transparent on EVERY colorscheme change + filetype
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.cmd("hi clear")
    transparent.clear()
    vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
    vim.cmd("hi NormalFloat guibg=NONE ctermbg=NONE")
    vim.cmd("hi FloatBorder guibg=NONE ctermbg=NONE")
    vim.cmd("hi Pmenu guibg=NONE ctermbg=NONE")
  end,
})

-- TARGET Mason/Lazy SPECIFICALLY on open
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "Mason", "lazy" },
  callback = function()
    vim.opt_local.winblend = 0
    vim.cmd("hi! default MasonNormal guibg=NONE ctermbg=NONE")
    vim.cmd("hi! default LazyNormal guibg=NONE ctermbg=NONE")
    vim.cmd("hi! default link MasonNormal NormalFloat")
    vim.cmd("hi! default link LazyNormal NormalFloat")
  end,
})

-- Nightfox conflict fix (runs AFTER theme)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
      vim.cmd("hi NormalFloat guibg=NONE ctermbg=NONE")
    end, 100)
  end,
})
