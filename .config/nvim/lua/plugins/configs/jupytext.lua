require("jupytext").setup {
  -- STYLE: Defines the flavor of markdown used for the conversion.
  -- "markdown" is the standard choice for compatibility with Quarto and Molten.
  style = "markdown",

  -- OUTPUT_EXTENSION: When Jupytext "opens" a notebook, it creates a
  -- temporary paired file. Setting this to "md" ensures it uses
  -- Markdown as the intermediate format.
  output_extension = "md",

  -- FORCE_FT: This tells Neovim to treat the buffer specifically as
  -- a "markdown" filetype. This is crucial because it triggers your
  -- Markdown LSP (marksman), Molten, and render-markdown.nvim.
  force_ft = "markdown",
}
