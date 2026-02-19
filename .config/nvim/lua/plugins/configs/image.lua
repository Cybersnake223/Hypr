require("image").setup {
  -- BACKEND: The protocol used to draw pixels.
  -- "kitty" is the gold standard for performance if your terminal supports it.
  backend = "kitty",

  -- PROCESSOR: How images are resized/manipulated.
  -- "magick_cli" uses your system's 'convert' command (ImageMagick).
  processor = "magick_cli",

  integrations = {
    -- Enables image rendering within standard Markdown files.
    markdown = {
      enabled = true,
    },
    -- CRITICAL: This allows Molten (Jupyter) to display plots inside Neovim.
    molten = {
      enabled = true,
    },
  },

  -- DIMENSIONS: Constraints to prevent images from taking over the whole screen.
  max_width = 200,
  max_height = 50,
  max_width_window_percentage = 50, -- Caps image width to half the window width
  max_height_window_percentage = nil,
  scale_factor = 1.5, -- Adjusts resolution/DPI (useful for high-res displays)

  -- OVERLAP MANAGEMENT: Prevents "ghost" images when windows stack.
  window_overlap_clear_enabled = true,
  -- IGNORE LIST: Don't hide images just because these small UI elements pop up.
  window_overlap_clear_ft_ignore = {
    "cmp_menu",
    "cmp_docs",
    "snacks_notif",
    "scrollview",
    "scrollview_sign",
  },

  -- FOCUS LOGIC: Performance optimization.
  -- Only render images when you are actually looking at the Neovim window.
  editor_only_render_when_focused = true,

  -- TMUX SUPPORT:
  -- If you use Tmux, this helps manage image visibility across different panes.
  tmux_show_only_in_active_window = false,

  -- FILE HIJACKING:
  -- If you open a .png or .jpg file directly, Neovim will show the image
  -- instead of the binary "text" data.
  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
}
