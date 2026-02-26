return {
  -- ─────────────────────────────────────────────────────────
  -- Colorscheme
  -- ─────────────────────────────────────────────────────────
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    lazy = false,
    opts = require "plugins.configs.nightfox",
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd "colorscheme nightfox"
    end,
  },
  -- ─────────────────────────────────────────────────────────
  -- Core async Lua library
  -- ─────────────────────────────────────────────────────────
  { "nvim-lua/plenary.nvim", lazy = true },

  -- ─────────────────────────────────────────────────────────
  -- Icons
  -- ─────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "echasnovski/mini.icons", lazy = true },

  -- ─────────────────────────────────────────────────────────
  -- UI: Statusline + Git signs
  -- ─────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = require "plugins.configs.lualine",
  },

  -- ─────────────────────────────────────────────────────────
  -- Syntax + Treesitter
  -- ─────────────────────────────────────────────────────────

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("plugins.configs.treesitter").setup()
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Keymaps helper
  -- ─────────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show { global = false }
        end,
        desc = "Buffer Local Keymaps",
      },
    },
  },

  -- ─────────────────────────────────────────────────────────
  -- Completion + Snippets + Autopairs
  -- ─────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    config = function()
      vim.schedule(function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end)
    end,
  },

  {
    "saghen/blink.cmp",
    build = "cargo build --release",
    event = "InsertEnter",
    dependencies = { "L3MON4D3/LuaSnip", "rafamadriz/friendly-snippets" },
    opts = function()
      local conf = require "plugins.configs.blink_conf"
      conf.sources = conf.sources or {}
      conf.sources.per_filetype = {
        sql = { "snippets", "dadbod", "buffer" },
        mysql = { "snippets", "dadbod", "buffer" },
        plsql = { "snippets", "dadbod", "buffer" },
      }
      conf.sources.providers = vim.tbl_extend("keep", conf.sources.providers or {}, {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      })
      return conf
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- LSP
  -- ─────────────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall" },
    event = "BufReadPost",
    opts = { ui = { border = "rounded", winblend = 0 } },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufReadPost",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls", "pyright", "sqls", "bashls" },
      automatic_enable = true,
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require "plugins.configs.lspconfig"
    end,
  },

  -- Better Lua API completion
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyPlugin" } },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────
  -- Formatting + Linting
  -- ─────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = require "plugins.configs.conform",
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        python = { "ruff" },
        sh = { "shellcheck" },
        sql = { "sqlfluff" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Diagnostics + TODOs
  -- ─────────────────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" },
    },
  },

  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next TODO",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Prev TODO",
      },
    },
  },

  -- ─────────────────────────────────────────────────────────
  -- Indent guides
  -- ─────────────────────────────────────────────────────────
  {
    "nvimdev/indentmini.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- ─────────────────────────────────────────────────────────
  -- Surround
  -- ─────────────────────────────────────────────────────────
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        replace = "gsr",
        find = "gsf",
        find_prev = "gsF",
        highlight = "gsh",
        update_n_lines = "gsn",
      },
    },
  },

  -- ─────────────────────────────────────────────────────────
  -- File Explorer
  -- ─────────────────────────────────────────────────────────
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = { view_options = { show_hidden = true } },
  },

  -- ─────────────────────────────────────────────────────────
  -- SQL Database Client
  -- ─────────────────────────────────────────────────────────
  {
    "kndndrj/nvim-dbee",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = { "Dbee" },
    build = function()
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup(require "plugins.configs.dbee")
    end,
  },

  { "tpope/vim-dadbod", lazy = true },

  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    dependencies = { "tpope/vim-dadbod" },
  },

  -- ─────────────────────────────────────────────────────────
  -- Snacks.nvim
  -- ─────────────────────────────────────────────────────────

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = require "plugins.configs.snacks",
  },
  -- ─────────────────────────────────────────────────────────
  -- Colorizer
  -- ─────────────────────────────────────────────────────────
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    config = function()
      local hp = require "mini.hipatterns"
      hp.setup { highlighters = { hex_color = hp.gen_highlighter.hex_color() } }
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Jupyter / Notebook workflow
  -- ─────────────────────────────────────────────────────────
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    lazy = true,
    config = true,
    opts = {
      luarocks_build_args = {
        "--with-lua-interpreter=lua5.1",
        "--with-lua-include=/usr/include/luajit-2.1",
      },
    },
  },

  {
    "3rd/image.nvim",
    lazy = true,
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      integrations = {
        markdown = { enabled = true, only_render_image_at_cursor = true },
        molten = { enabled = true },
      },
      max_width = 100,
      max_height = 15,
      max_height_window_percentage = 50,
      editor_only_render_when_focused = true,
      tmux_show_only_in_active_window = true,
      window_overlap_clear_enabled = true,
      hi_res_rendering = false,
    },
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    ft = { "python", "markdown", "quarto" },
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_wrap_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_tick_rate = 142 -- ~7fps, less CPU than 100
      vim.g.molten_output_show_more = true
      vim.g.molten_limit_output_chars = 5000
      vim.g.molten_virt_text_max_lines = 100
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
    end,
    config = function()
      local default_notebook = [[
{
  "cells": [{"cell_type":"markdown","metadata":{},"source":[""]}],
  "metadata": {
    "kernelspec": {"display_name":"Python 3","language":"python","name":"python3"},
    "language_info": {
      "codemirror_mode":{"name":"ipython"},"file_extension":".py",
      "mimetype":"text/x-python","name":"python",
      "nbconvert_exporter":"python","pygments_lexer":"ipython3"
    }
  },
  "nbformat": 4, "nbformat_minor": 5
}
]]
      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        local path = opts.args .. ".ipynb"
        local f = io.open(path, "w")
        if not f then
          vim.notify("Error: could not write " .. path, vim.log.levels.ERROR)
          return
        end
        f:write(default_notebook)
        f:close()
        vim.cmd("edit " .. path)
      end, { nargs = 1, complete = "file", desc = "Create a new .ipynb" })
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Quarto
  -- ─────────────────────────────────────────────────────────
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "benlubas/molten-nvim", -- ensures load order for codeRunner
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    config = function()
      require("quarto").setup {
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
          ft_runners = { python = "molten" },
        },
      }

      -- <leader>n: buffer-local (uses cursor position)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "markdown" },
        group = vim.api.nvim_create_augroup("QuartoKeymaps", { clear = true }),
        callback = function(ev)
          vim.keymap.set("n", "<leader>n", function()
            local row = vim.api.nvim_win_get_cursor(0)[1]
            local lines = { "```{python}", "", "```", "" }
            vim.api.nvim_buf_set_lines(0, row, row, false, lines)
            vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
            vim.cmd "startinsert"
          end, { buffer = ev.buf, desc = "New python chunk below", silent = true })
        end,
      })

      -- runner keymaps: global (quarto.runner handles buffer context internally)
      local runner = require "quarto.runner"
      vim.keymap.set("n", "<leader>r", runner.run_cell, { desc = "Run cell", silent = true })
      vim.keymap.set("n", "<leader>ra", runner.run_all, { desc = "Run all cells", silent = true })
      vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "Run line", silent = true })
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Markdown rendering
  -- ─────────────────────────────────────────────────────────
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "rmd", "quarto" },
    cmd = "RenderMarkdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Rendering" },
    },
    opts = {
      enabled = false,
      render_modes = { "n", "c" },
      anti_conceal = { enabled = false },
      file_types = { "markdown", "quarto" },
      win_options = {
        conceallevel = { default = 0, rendered = 0 },
      },
      conceal = { links = true, code_blocks = false, inline_code = true },
      heading = {
        enabled = true,
        width = "block",
        left_pad = 2,
        right_pad = 4,
        icons = { "󰼏 ", "󰎨 " },
      },
      code = {
        enabled = true,
        width = "block",
        left_pad = 2,
        right_pad = 4,
        language_border = " ",
        language_left = "",
        language_right = "",
      },
      bullet = { enabled = true },
      pipe_table = { preset = "round" },
      checkbox = {
        unchecked = { icon = "✘ " },
        checked = { icon = "✔ " },
        custom = { todo = { rendered = "◯ " } },
      },
    },
  },
}
