return {
  { "nvim-lua/plenary.nvim", lazy = true },

  { "nvim-tree/nvim-web-devicons", opts = {} },
  { "echasnovski/mini.statusline", opts = {} },
  { "lewis6991/gitsigns.nvim", opts = {} },

  "EdenEast/nightfox.nvim",

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup {
          ensure_installed = { "lua", "vim", "bash", "javascript", "python", "sql" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
          incremental_selection = { enable = true },
        }
      end
    end,
  },
{
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
},

{
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
    }
},

  {
    "akinsho/bufferline.nvim",
    opts = require "plugins.configs.bufferline",
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "L3MON4D3/LuaSnip",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      { "windwp/nvim-autopairs", opts = {} },
    },
    opts = function()
      return require "plugins.configs.blink"
    end,
  },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall" },
    opts = { ui = {
      border = "rounded",
      winblend = 0,  -- 0 = fully transparent
    },
  },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = require "plugins.configs.conform",
  },

  {
    "nvimdev/indentmini.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    opts = require "plugins.configs.telescope",
  },

  -- SQL Database Client
  {
    "kndndrj/nvim-dbee",
    dependencies = { "MunifTanjim/nui.nvim" },
    build = function()
      require("dbee").install()
    end,
    config = function()
      local queries_dir = vim.fn.expand("~/Sql/.queries/")
      vim.fn.mkdir(queries_dir, "p")
      require("dbee").setup({
        sources = {
          require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
          require("dbee.sources").FileSource:new(queries_dir .. "persistence.json")
        }
      })
    end,
  },

  { "kristijanhusak/vim-dadbod-completion" },

  -- Snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  -- Transparency
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
  },

  -- Colorizer
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    config = function()
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })
    end,
  },
  -- Jupiter notebook

-- Convert .ipynb <-> markdown automatically (lazy=false prevents raw JSON)
{
  "GCBallesteros/jupytext.nvim",
  lazy = false,
  opts = {
    style = "markdown",
    output_extension = "md",
    force_ft = "markdown",
  },
},

-- Images in terminal (for Molten outputs)
{
  "3rd/image.nvim",
  opts = {
    backend = "kitty",
    integrations = {
      markdown = { enabled = true },
      molten = { enabled = true },
    },
    max_width = 150,
    max_height = 20,
    max_height_window_percentage = math.huge,
    max_width_window_percentage = math.huge,
    window_overlap_clear_enabled = true,
  },
},

-- Molten (Jupyter kernel runner)
{
  "benlubas/molten-nvim",
  version = "^1.0.0",
  lazy = false,
  build = ":UpdateRemotePlugins",
  dependencies = { "3rd/image.nvim" },
  init = function()
    vim.g.molten_auto_open_output = false
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_wrap_output = true
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true
  end,
  config = function()
    -- Cell evaluation keybinds (Molten docs recommended)
    vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
    vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
    vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
    vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection", silent = true })

    -- NO MoltenImportOutput autocmd (avoids known crashes)

    -- NewNotebook command with valid metadata for jupytext
    local default_notebook = [[
{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [""]
    }
  ],
  "metadata": {
    "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
    },
    "language_info": {
      "codemirror_mode": { "name": "ipython" },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
]]

    local function new_notebook(filename)
      local path = filename .. ".ipynb"
      local file = io.open(path, "w")
      if not file then
        vim.notify("Error: could not write " .. path, vim.log.levels.ERROR)
        return
      end
      file:write(default_notebook)
      file:close()
      vim.cmd("edit " .. path)
    end

    vim.api.nvim_create_user_command("NewNotebook", function(opts)
      new_notebook(opts.args)
    end, { nargs = 1, complete = "file", desc = "Create a new .ipynb" })
  end,
},

-- Quarto (LSP-in-markdown + molten runner)
{
  "quarto-dev/quarto-nvim",
  dependencies = {
    "jmbuhr/otter.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
  ft = { "quarto", "markdown" },
  config = function()
    require("quarto").setup({
      lspFeatures = {
        enabled = true,
        chunks = "all",
        languages = { "python" },
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    })

    -- New python chunk below cursor
    local function quarto_new_chunk_below(lang)
      lang = lang or "python"
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local lines = {
        ("```{%s}"):format(lang),
        "",
        "```",
        "",
      }
      vim.api.nvim_buf_set_lines(0, row, row, false, lines)
      vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
      vim.cmd("startinsert")
    end

    vim.keymap.set("n", "<leader>nb", function()
      quarto_new_chunk_below("python")
    end, { desc = "New python chunk below", buffer = true, silent = true })

    local runner = require("quarto.runner")
    vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "run cell", silent = true })
    vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "run cell and above", silent = true })
    vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "run all cells", silent = true })
    vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "run line", silent = true })
    vim.keymap.set("v", "<leader>r", runner.run_range, { desc = "run visual range", silent = true })
  end,
},

-- Render markdown (keeps code blocks visible for cells)
{
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'rmd' },  -- Lazy-load on these filetypes
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'echasnovski/mini.icons',
  },
  opts = {
    enabled = true,
    file_types = { 'markdown' },  -- Enables for markdown (rmd may need explicit addition)
    win_options = {
      conceallevel = { default = 0, rendered = 0 },
    },
    conceal = {
      links = true,
      code_blocks = false,
      inline_code = true,
    },
    -- Consolidated heading options (no top-level 'sign'; use per-component if needed)
    heading = {
      enabled = true,
      width = 'block',
      left_pad = 2,
      right_pad = 4,
      icons = { '󰼏 ', '󰎨 ' },
    },
    -- Consolidated code options
    code = {
      enabled = true,
      width = 'block',
      left_pad = 2,
      right_pad = 4,
      language_border = ' ',
      language_left = '',
      language_right = '',
    },
    bullet = { enabled = true },
    pipe_table = { preset = 'round' },
    checkbox = {
      unchecked = { icon = '✘ ' },
      checked = { icon = '✔ ' },
      custom = { todo = { rendered = '◯ ' } },
    },
  },
},
-- Markdown preview (browser/webview)
{
  'toppair/peek.nvim',
  event = { 'VeryLazy' },
  config = function()
    require('peek').setup({
      auto_load = true,
      syntax = true,
      theme = 'dark',
      update_on_change = true,
      app = 'webview',
      filetype = { 'markdown' },
    })
  end
},
}
