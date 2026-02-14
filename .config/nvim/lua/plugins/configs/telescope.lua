return {
  defaults = {
    -- SORTING_STRATEGY: Displays the best matches at the top of the list.
    -- This works in tandem with the 'top' prompt position for a cohesive UI.
    sorting_strategy = "ascending",

    -- LAYOUT_CONFIG: Controls the visual architecture of the picker.
    layout_config = {
      horizontal = {
        -- PROMPT_POSITION: Places the typing area at the top of the window.
        -- This is widely considered more ergonomic as it mimics modern app launchers.
        prompt_position = "top",
      },
    },
  },
}
