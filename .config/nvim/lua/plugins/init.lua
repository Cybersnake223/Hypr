return {
  -- ─────────────────────────────────────────────────────────
  -- Colorscheme
  -- ─────────────────────────────────────────────────────────
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      options = {
        transparent = true,
        compile_path = vim.fn.stdpath "cache" .. "/nightfox",
        compile_file_suffix = "_compiled",
      },
      groups = {
        all = {
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          FloatTitle = { bg = "NONE" },
        },
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd "colorscheme nightfox"
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Core async Lua library
  -- ─────────────────────────────────────────────────────────
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- ─────────────────────────────────────────────────────────
  -- UI: Statusline, Git signs
  -- ─────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { { "nvim-tree/nvim-web-devicons", lazy = true } },
    opts = require "plugins.configs.lualine",
  },

  -- ─────────────────────────────────────────────────────────
  -- Syntax, indent, selection
  -- ─────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end
      configs.setup {
        auto_install = false,
        ensure_installed = { "lua", "bash", "python", "sql" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
      }
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
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  -- ─────────────────────────────────────────────────────────
  -- Buffer tabs
  -- ─────────────────────────────────────────────────────────
  -- {
  --   "akinsho/bufferline.nvim",
  --   event = "VeryLazy",
  --   opts = require "plugins.configs.bufferline_conf",
  -- },

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
    dependencies = { "rafamadriz/friendly-snippets" },
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
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    opts = require "plugins.configs.blink_conf",
  },

  -- ─────────────────────────────────────────────────────────
  -- LSP
  -- ─────────────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall" },
    opts = {
      ui = {
        border = "rounded",
        winblend = 0,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "plugins.configs.lspconfig"
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Formatting
  -- ─────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = require "plugins.configs.conform",
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

  -- {
  --   "tpope/vim-dadbod",
  --   lazy = true,
  -- },
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
    opts = {
      picker = {
        enabled = true,
        hidden = true,
        layout = {
          ivy = {
            max_height = 0.8,
            width = 0.8,
          },
        },
        matcher = {
          frecency = true,
        },
        sources = {
          -- Buffers: list all open listed buffers
          buffers = {
            name = "Buffers",
            items = function()
              local bufs = vim.fn.getbufinfo { buflisted = 1 }
              return vim.tbl_map(function(buf)
                local name = buf.name ~= "" and buf.name or "[No Name]"
                return {
                  text = vim.fn.fnamemodify(name, ":t"),
                  path = buf.name,
                  bufnr = buf.bufnr,
                  cwd = vim.fn.getcwd(), -- evaluated at picker-open time
                }
              end, bufs)
            end,
            action = function(item)
              if item.bufnr then
                vim.api.nvim_set_current_buf(item.bufnr)
              end
            end,
          },

          -- Files
          files = {
            name = "Files",
            hidden = true,
            items = function()
              local cwd = vim.fn.getcwd() -- evaluated at picker-open time
              local output =
                vim.fn.systemlist "rg --files --hidden --no-ignore-vcs --glob '!.git' --glob '!node_modules' ."
              return vim.tbl_map(function(path)
                local abs = cwd .. "/" .. path
                return {
                  text = vim.fn.fnamemodify(path, ":t"),
                  path = abs,
                }
              end, output)
            end,
            action = function(item)
              if item.path and item.path ~= "" then
                vim.cmd.edit(item.path)
              end
            end,
          },
        },
      },
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = true, replace_netrw = true },
      indent = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = true },
    },
  },

  -- ─────────────────────────────────────────────────────────
  -- Colorizer
  -- ─────────────────────────────────────────────────────────
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    config = function()
      local hipatterns = require "mini.hipatterns"
      hipatterns.setup {
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Jupyter / Notebook workflow
  -- ─────────────────────────────────────────────────────────

  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
    opts = {
      luarocks_build_args = { "--with-lua-interpreter=lua5.1", "--with-lua-include=/usr/include/luajit-2.1" },
    },
  },
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    -- build = "luarocks install magick",
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          only_render_image_at_cursor = true,
        },
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
      vim.g.molten_tick_rate = 100
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

  -- ─────────────────────────────────────────────────────────
  -- Quarto
  -- ─────────────────────────────────────────────────────────
  {
    "quarto-dev/quarto-nvim",
    dependencies = { "jmbuhr/otter.nvim" },
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
        },
      }

      local function quarto_new_chunk_below(lang)
        lang = lang or "python"
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local lines = { ("```{%s}"):format(lang), "", "```", "" }
        vim.api.nvim_buf_set_lines(0, row, row, false, lines)
        vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
        vim.cmd "startinsert"
      end

      vim.keymap.set("n", "<leader>n", function()
        quarto_new_chunk_below "python"
      end, { desc = "New python chunk below", buffer = true, silent = true })

      local runner = require "quarto.runner"
      vim.keymap.set("n", "<leader>r", runner.run_cell, { desc = "Run cell", silent = true })
      vim.keymap.set("n", "<leader>ra", runner.run_all, { desc = "Run all cells", silent = true })
      vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "Run line", silent = true })
    end,
  },

  -- ─────────────────────────────────────────────────────────
  -- Markdown rendering + preview
  -- ─────────────────────────────────────────────────────────
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "rmd" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Rendering" },
    },
    cmd = "RenderMarkdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
    opts = {
      render_modes = { "n", "c" },
      anti_conceal = { enabled = false },
      enabled = true,
      file_types = { "markdown" },
      win_options = {
        conceallevel = { default = 0, rendered = 0 },
      },
      conceal = {
        links = true,
        code_blocks = false,
        inline_code = true,
      },
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

  {
    "toppair/peek.nvim",
    ft = { "markdown" },
    keys = {
      {
        "<leader>mp",
        function()
          require("peek").open()
        end,
        desc = "Peek: Open preview",
      },
      {
        "<leader>mc",
        function()
          require("peek").close()
        end,
        desc = "Peek: Close preview",
      },
    },
    config = function()
      require("peek").setup {
        auto_load = true,
        syntax = true,
        theme = "dark",
        update_on_change = true,
        app = "webview",
        filetype = { "markdown" },
      }
    end,
  },
}
