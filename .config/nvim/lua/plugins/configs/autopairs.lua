require("nvim-autopairs").setup {
  -- check_ts: Uses Treesitter to check for the context of the pair.
  -- For example, it won't add a closing bracket if you are inside a string or comment.
  check_ts = true,

  -- ts_config: Specific language settings for Treesitter integration.
  ts_config = {
    lua = { "string" }, -- Don't add pairs in lua string nodes
    javascript = { "template_string" }, -- Don't add pairs in JS template strings
  },

  -- disable_filetype: Keep it off for specific views where it might be annoying.
  disable_filetype = { "TelescopePrompt", "spectre_panel" },

  -- fast_wrap: Allows you to "wrap" existing text in pairs.
  -- Press <M-e> (Alt+e) while the cursor is inside a pair to move the closing bracket.
  fast_wrap = {
    map = "<M-e>",
    chars = { "{", "[", "(", '"', "'" },
    pattern = [=[[%'%"%)%>%]%]%}%,]]=],
    end_key = "$",
    keys = "qwertyuiopzxcvbnmasdfghjkl",
    check_comma = true,
    highlight = "Search",
    highlight_grey = "Comment",
  },
}

-- INTEGRATION WITH COMPLETION
-- This part ensures that when you accept a completion item from blink.cmp,
-- autopairs handles the parenthesis insertion correctly.
local cmp_autopairs = require "nvim-autopairs.completion.cmp"
-- Note: If you were using nvim-cmp, you'd link it here.
-- Since you use blink.cmp, blink handles most of this natively,
-- but keeping autopairs configured ensures manual typing is smooth.
