return require("dbee.config").merge_with_default {
  sources = {
    require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
    require("dbee.sources").FileSource:new(vim.fn.expand("~/Sql/.queries/persistence.json")),
  },
  drawer = {
    disable_help = true,
  },
  result = {
    page_size = 1000,
    focus_result = false,
  },
  call_log = {
    mappings = {},
    disable_candies = true,
    window_options = { winbar = "" },
  },
}
