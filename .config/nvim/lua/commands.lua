-- mason, write correct names only
vim.api.nvim_create_user_command("MasonInstallAll", function()
  vim.cmd "MasonInstall css-lsp html-lsp lua-language-server typescript-language-server stylua prettier"
end, {})



vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":e") == "ipynb" then
      -- Convert .ipynb JSON → editable markdown
      vim.bo.filetype = "markdown"  -- LSP + molten ready
      vim.cmd("doautocmd User QuartoActivate")  -- Quarto LSP
    end
  end,
})

-- Auto-save back to .ipynb
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.ipynb.md",
  callback = function()
    vim.cmd("JupytextSync")
  end,
})
