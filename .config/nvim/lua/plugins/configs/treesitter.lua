require("nvim-treesitter.configs").setup {
  ensure_installed = { "lua", "vim", "vimdoc", "html", "css", "typescript", "javascript", "sql", "regex" },

  highlight = {
    enable = true,
    use_languagetree = true,
  },
  indent = { enable = true },
}
