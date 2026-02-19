require("nvim-treesitter.configs").setup {
  ensure_installed = { "lua", "sql", "regex" },

  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
}
