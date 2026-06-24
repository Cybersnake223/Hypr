return {
  -- ─────────────────────────────────────────────────────────
  -- Colorscheme
  -- ─────────────────────────────────────────────────────────
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    event = "UIEnter",
    opts = function()
      return require "plugins.configs.nightfox"
    end,
    config = function(_, opts)
      require("nightfox").setup(opts)
      local compile_file = vim.fn.stdpath "cache" .. "/nightfox/nightfox_compiled"
      if not (vim.uv or vim.loop).fs_stat(compile_file) then
        require("nightfox").compile()
      end
      vim.cmd "colorscheme nightfox"
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Icons
  -- ─────────────────────────────────────────────────────────
  { "echasnovski/mini.icons", event = "VeryLazy" },

  -- ─────────────────────────────────────────────────────────
  -- UI: Statusline + Git signs
  -- ─────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame = false,
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
    opts = function()
      return require "plugins.configs.lualine"
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Syntax + Treesitter
  -- ─────────────────────────────────────────────────────────

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
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
    opts = {
      timeout = 300,
    },
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
        -- { "<leader>c", group = "code/lsp" },
        { "<leader>d", group = "database" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>m", group = "molten" },
        { "<leader>r", group = "run" },
        { "<leader>S", group = "session" },
        { "<leader>t", group = "terminal" },
        { "<leader>w", group = "workspace" },
      }
    end,
  },

  { "sam4llis/nvim-lua-gf" },

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
    keys = {
      {
        "<C-j>",
        function()
          require("luasnip").jump(1)
        end,
        mode = { "i", "s" },
        desc = "Snippet: Next",
      },
      {
        "<C-k>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
        desc = "Snippet: Prev",
      },
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").load { paths = "~/.config/nvim/snippets" }
    end,
  },

  {
    "saghen/blink.cmp",
    -- build = "cargo build --release",
    version = "^1",
    event = "InsertEnter",
    dependencies = { "L3MON4D3/LuaSnip", "rafamadriz/friendly-snippets", "saghen/blink.lib" },
    opts = function()
      return require "plugins.configs.blink_conf"
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- LSP
  -- ─────────────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall" },
    opts = { ui = { border = "rounded", winblend = 0 } },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls", "ruff", "sqls", "bashls", "marksman", "cssls", "html", "jsonls", "yamlls" },
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
    opts = function()
      return require "plugins.configs.conform"
    end,
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
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = lint_group,
        callback = function()
          if vim.b._lint_changedtick == vim.b.changedtick then
            return
          end
          vim.b._lint_changedtick = vim.b.changedtick
          lint.try_lint()
        end,
      })
    end,
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
  -- Flash (fast screen cursor motion)
  -- ─────────────────────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash: Jump Forward",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump { backward = true }
        end,
        desc = "Flash: Jump Backward",
      },
    },
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
    event = "VeryLazy",
    keys = {
      {
        "<leader>e",
        function()
          require("snacks").explorer()
        end,
        desc = "Explorer",
      },
      {
        "<leader>ff",
        function()
          require("snacks").picker.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<C-\\>",
        function()
          require("snacks").terminal(nil, { toggle = true })
        end,
        desc = "Terminal: Toggle last",
      },
      {
        "<leader>fb",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Find: Buffers",
      },
      {
        "<leader>fr",
        function()
          require("snacks").picker.recent()
        end,
        desc = "Find: Recent",
      },
      {
        "<leader>fh",
        function()
          require("snacks").picker.help()
        end,
        desc = "Find: Help",
      },
      {
        "<leader>fk",
        function()
          require("snacks").picker.keymaps()
        end,
        desc = "Find: Keymaps",
      },
      {
        "<leader>fc",
        function()
          require("snacks").picker.commands()
        end,
        desc = "Find: Commands",
      },
      {
        "<leader>fw",
        function()
          require("snacks").picker.grep { search = vim.fn.expand "<cword>" }
        end,
        desc = "Find: Word Under Cursor",
      },
    },
    opts = function()
      return require "plugins.configs.snacks"
    end,
  },
  -- ─────────────────────────────────────────────────────────
  -- Colorizer
  -- ─────────────────────────────────────────────────────────
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPost",
    config = function()
      local hp = require "mini.hipatterns"
      hp.setup { highlighters = { hex_color = hp.gen_highlighter.hex_color() } }
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Better folding (LSP + treesitter hybrid)
  -- ─────────────────────────────────────────────────────────
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    config = function(_, opts)
      require("ufo").setup(opts)
      vim.opt.foldenable = true
      vim.opt.foldlevel = 99
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zp", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.notify("No fold under cursor", vim.log.levels.INFO)
        end
      end, { desc = "Peek folded lines" })
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
    "3rd/image.nvim",
    lazy = true,
    dependencies = {
      {
        "vhyrro/luarocks.nvim",
        opts = {
          rocks = { "magick" },
          luarocks_build_args = {
            "--with-lua-interpreter=lua5.1",
            "--with-lua-include=/usr/include/luajit-2.1",
          },
        },
        config = true,
      },
    },
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
    ft = { "markdown", "quarto", "ipynb" },
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_wrap_output = false
      vim.g.molten_output_virt_lines = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_win_max_height = 99999
      vim.g.molten_output_win_max_width = 99999
      vim.g.molten_tick_rate = 200
      vim.g.molten_split_size = 100
      vim.g.molten_output_show_more = true
      vim.g.molten_limit_output_chars = 25000
      vim.g.molten_virt_text_max_lines = 3000
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
    end,
    keys = {
      { "<leader>mos", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten: Enter output", silent = true },
    },
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
