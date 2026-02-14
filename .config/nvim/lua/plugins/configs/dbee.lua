local config = {}

---@mod dbee.ref.config Dbee Configuration
-- This file acts as the internal blueprint for Dbee's behavior.

-----------------------------------------------------------
-- 1. DATA SOURCES & CORE SETTINGS
-----------------------------------------------------------
config.default = {
  -- Active connection on startup (set to a string ID if desired)
  default_connection = nil,

  -- Where Dbee looks for your databases.
  sources = {
    -- Looks for environment variables (secure way to store passwords)
    require("dbee.sources").EnvSource:new "DBEE_CONNECTIONS",
    -- Loads from your local JSON file (convenient for static connections)
    require("dbee.sources").FileSource:new(vim.fn.expand "~/Sql/.queries/connections.json"),
  },

  -- Custom SQL templates. You can add "Select Top 10" or "Count Rows" here.
  extra_helpers = {},

  -----------------------------------------------------------
  -- 2. THE DRAWER (The Left-Side Connection Tree)
  -----------------------------------------------------------
  drawer = {
    disable_help = false, -- Set to true to hide the keybinding hints
    mappings = {
      { key = "r", mode = "n", action = "refresh" }, -- Reload DB tree
      { key = "<CR>", mode = "n", action = "action_1" }, -- Primary action (Expand/Connect)
      { key = "cw", mode = "n", action = "action_2" }, -- Rename/Activate
      { key = "dd", mode = "n", action = "action_3" }, -- Delete node
      { key = "o", mode = "n", action = "toggle" }, -- Open/Close folder
    },

    -- CANDIES (The Icons and Visual Highlights)
    -- This section maps specific DB objects (Tables, Views, Columns) to icons.
    disable_candies = false,
    candies = {
      history = { icon = "", icon_highlight = "Constant" },
      connection = { icon = "󱘖", icon_highlight = "SpecialChar" },
      database_switch = { icon = "", icon_highlight = "Character" },
      table = { icon = "", icon_highlight = "Conditional" },
      column = { icon = "󰠵", icon_highlight = "WarningMsg" },
      -- ... (other icons omitted for brevity, but they control the UI's look)
    },
  },

  -----------------------------------------------------------
  -- 3. THE RESULTS WINDOW (Bottom/Right Panel for Data)
  -----------------------------------------------------------
  result = {
    page_size = 1000, -- How many rows to load at once (increase for big datasets)
    focus_result = false, -- Auto-jump cursor to result panel after running SQL

    progress = {
      spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      text_prefix = "Executing...",
    },

    mappings = {
      { key = "L", mode = "", action = "page_next" }, -- Pagination: Next
      { key = "H", mode = "", action = "page_prev" }, -- Pagination: Previous
      -- YANKING: Exporting data to clipboard as JSON/CSV
      { key = "yaj", mode = "n", action = "yank_current_json" },
      { key = "yac", mode = "n", action = "yank_current_csv" },
      { key = "<C-c>", mode = "", action = "cancel_call" }, -- Stop slow query
    },
  },

  -----------------------------------------------------------
  -- 4. THE EDITOR (Where you write SQL)
  -----------------------------------------------------------
  editor = {
    mappings = {
      { key = "BB", mode = "v", action = "run_selection" }, -- Highlight and run
      { key = "BB", mode = "n", action = "run_file" }, -- Run entire buffer
      { key = "<CR>", mode = "n", action = "run_under_cursor" }, -- Run single line
    },
  },

  -----------------------------------------------------------
  -- 5. THE CALL LOG (History of executed queries)
  -----------------------------------------------------------
  call_log = {
    mappings = {
      { key = "<CR>", mode = "", action = "show_result" }, -- Re-open previous result
    },
    -- Status icons for queries (Executing, Success, Failed)
    candies = {
      executing = { icon = "󰑐", icon_highlight = "Constant" },
      retrieving = { icon = "", icon_highlight = "String" },
      archived = { icon = "", icon_highlight = "Title" },
    },
  },

  -- LAYOUT: Controls how the windows split on your screen
  window_layout = require("dbee.layouts").Default:new(),
}

-- INTERNAL LOGIC: Validation and merging functions (You rarely need to touch these)
-- ...
return config
