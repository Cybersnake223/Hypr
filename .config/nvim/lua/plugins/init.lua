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
      require("nightfox").compile()
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
  -- { "nvim-tree/nvim-web-devicons", lazy = true },
  { "echasnovski/mini.icons", lazy = true },

  -- ─────────────────────────────────────────────────────────
  -- UI: Statusline + Git signs
  -- ─────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
        ignore_whitespace = false,
      },
      signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "󰍵" } },
      signs_staged_enable = true,
      preview_config = { border = "rounded" },
    },
  },

  -- ─────────────────────────────────────────────────────────
  -- Git UI (Neogit)
  -- ─────────────────────────────────────────────────────────
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    opts = {
      kind = "tab",
      integrations = { diffview = true },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit: Status" },
      { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "Neogit: Commit" },
      { "<leader>gl", "<cmd>Neogit log<CR>", desc = "Neogit: Log" },
      { "<leader>gP", "<cmd>Neogit pull<CR>", desc = "Neogit: Pull" },
      { "<leader>gpu", "<cmd>Neogit push<CR>", desc = "Neogit: Push" },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
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
    opts = { timeout = 300 },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show { global = false }
        end,
        desc = "Buffer Local Keymaps",
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      local wk = require "which-key"
      wk.add {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code/lsp" },
        { "<leader>d", group = "database" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>gc", desc = "Neogit: Commit" },
        { "<leader>gg", desc = "Neogit: Status" },
        { "<leader>gl", desc = "Neogit: Log" },
        { "<leader>gP", desc = "Neogit: Pull" },
        { "<leader>gpu", desc = "Neogit: Push" },
        { "<leader>l", group = "lsp" },
        { "<leader>m", group = "molten" },
        { "<leader>r", group = "run" },
        { "<leader>t", group = "terminal" },
        { "<leader>w", group = "workspace" },
      }
    end,
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
    -- build = "cargo build --release",
    version = "^1",
    event = "InsertEnter",
    dependencies = { "L3MON4D3/LuaSnip", "rafamadriz/friendly-snippets", "saghen/blink.lib" },
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
      ensure_installed = { "lua_ls", "ruff", "sqls", "bashls", "cssls", "html", "marksman", "taplo", "jsonls" },
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
      local lint_group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = lint_group,
        callback = function()
          if vim.b._lint_changedtick == vim.b.changedtick then return end
          vim.b._lint_changedtick = vim.b.changedtick
          lint.try_lint()
        end,
      })
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Diagnostics + TODOs
  -- ─────────────────────────────────────────────────────────
  -- {
  --   "folke/trouble.nvim",
  --   cmd = "Trouble",
  --   opts = { focus = true },
  --   keys = {
  --     { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
  --     { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
  --     { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
  --     { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
  --     { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" },
  --   },
  -- },
  --
  -- {
  --   "folke/todo-comments.nvim",
  --   event = "BufReadPost",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = { signs = false },
  --   keys = {
  --     {
  --       "]t",
  --       function()
  --         require("todo-comments").jump_next()
  --       end,
  --       desc = "Next TODO",
  --     },
  --     {
  --       "[t",
  --       function()
  --         require("todo-comments").jump_prev()
  --       end,
  --       desc = "Prev TODO",
  --     },
  --   },
  -- },

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
  -- Textobjects (mini.ai)
  -- ─────────────────────────────────────────────────────────
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require "mini.ai"
      return {
        n_lines = 50,
        custom_textobjects = {
          o = ai.gen_spec.treesitter {
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          },
          f = ai.gen_spec.treesitter { a = "@function.outer", i = "@function.inner" },
          c = ai.gen_spec.treesitter { a = "@class.outer", i = "@class.inner" },
          t = { { "%b()" }, { "^%s*()[(%s])().-[^()]())[^()]*", "^%s*()[(%s])().-[^()]())[^()]*" } },
        },
      }
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- File Explorer
  -- ─────────────────────────────────────────────────────────
  -- {
  --   "stevearc/oil.nvim",
  --   lazy = false,
  --   opts = { view_options = { show_hidden = true } },
  -- },

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

  -- { "tpope/vim-dadbod", lazy = true },

  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
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
    event = { "BufReadPost", "BufNewFile" },
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
      backend = "kitty",
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
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_tick_rate = 142
      vim.g.molten_output_show_more = true
      vim.g.molten_limit_output_chars = 100000
      vim.g.molten_virt_text_max_lines = 5000
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_enter_output_behavior = "open_no_enter"
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Quarto
  -- ─────────────────────────────────────────────────────────
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "benlubas/molten-nvim",
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

      -- <leader>n + runner keymaps: buffer-local
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "markdown" },
        group = vim.api.nvim_create_augroup("QuartoKeymaps", { clear = true }),
        callback = function(ev)
          -- <leader>n: new python chunk below
          vim.keymap.set("n", "<leader>n", function()
            local row = vim.api.nvim_win_get_cursor(0)[1]
            local lines = { "```python", "", "```", "" }
            vim.api.nvim_buf_set_lines(0, row, row, false, lines)
            vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
            vim.cmd "startinsert"
          end, { buffer = ev.buf, desc = "New python chunk below", silent = true })

          -- runner keymaps
          local runner = require "quarto.runner"
          vim.keymap.set("n", "<leader>r", runner.run_cell, { buffer = ev.buf, desc = "Run cell", silent = true })
          vim.keymap.set("n", "<leader>ra", runner.run_all, { buffer = ev.buf, desc = "Run all cells", silent = true })
          vim.keymap.set("n", "<leader>rl", runner.run_line, { buffer = ev.buf, desc = "Run line", silent = true })
        end,
      })

      -- Auto-activate Quarto for jupytext notebook markdown buffers
      vim.api.nvim_create_autocmd("BufReadPost", {
        group = vim.api.nvim_create_augroup("QuartoJupytext", { clear = true }),
        callback = function(ev)
          local name = vim.api.nvim_buf_get_name(ev.buf)
          if name:match "%.ipynb%.md$" or (name:match "%.md$" and vim.b[ev.buf].jupytext) then
            require("quarto").activate()
          end
        end,
      })
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
