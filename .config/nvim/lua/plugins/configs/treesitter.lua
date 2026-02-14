require("nvim-treesitter.configs").setup {
  -- ENSURE_INSTALLED: A list of language parsers that should always be present.
  -- Having "sql", "javascript", and "lua" here is essential for your
  -- data science and configuration workflow.
  ensure_installed = {
    "lua",
    "python",
    "markdown",
    "vim",
    "vimdoc",
    -- "html",
    -- "css",
    -- "typescript",
    -- "javascript",
    "sql",
    "regex",
  },

  -- HIGHLIGHTING: The core feature of Treesitter.
  highlight = {
    enable = true, -- Turns on rich, grammar-aware syntax highlighting

    -- USE_LANGUAGETREE: This is crucial for your Quarto/Markdown work.
    -- It allows Treesitter to recognize and highlight different languages
    -- nested inside one file (e.g., Python code inside a Markdown file).
    use_languagetree = true,
  },

  -- INDENTATION: Uses the syntax tree to decide where your cursor
  -- should land when you press 'Enter'.
  indent = { enable = true },
}
