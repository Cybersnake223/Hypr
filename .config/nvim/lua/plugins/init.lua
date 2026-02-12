return {

  -- Colorscheme
  { "EdenEast/nightfox.nvim" },

  -- Core async Lua library (dependency for many plugins)
  { "nvim-lua/plenary.nvim", lazy = true },

  -- UI : statusline , Git signs, Command Prompt
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
    config = function()
      require("lualine").setup {
        options = {
          theme = "onedark",
          icons_enabled = true,
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
        },
      }
    end,
  },

  -- Syntax, indent, selection (disables on large files)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    textobjects = {
      select = { enable = true },
    },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup {
          ensure_installed = { "lua", "vim", "bash", "javascript", "python", "sql" },
          sync_install = true,
          highlight = { enable = true },
          indent = { enable = true },
          incremental_selection = { enable = true },
          disable = function(lang, buf)
            local max = 500 * 1024
            return vim.api.nvim_buf_get_lines(buf, 0, -1, false) > max
          end,
        }
      end
    end,
  },

  -- Keymaps helper
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

  -- Buffet tabs
  {
    "akinsho/bufferline.nvim",
    event = { "BufAdd", "BufEnter" },
    opts = require "plugins.configs.bufferline",
  },

  -- Completion + snippets/autopairs
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter" },
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

  -- LSP Manager
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall" },
    opts = { ui = { border = "rounded", winblend = 0 } },
  },

  -- LSP config + Mason integrations
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      {
        "mason-org/mason-lspconfig.nvim",
        event = "LspAttach",
        opts = {
          automatic_enable = true,
          ensure_installed = {
            "lua_ls",
            "bashls",
            "pyright",
            "marksman",
          },
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "tree-sitter-cli",
        "jupytext",
      },
    },
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    opts = require "plugins.configs.conform",
  },

  -- Indentation
  {
    "nvimdev/indentmini.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- SQL Database Client + Completion
  {
    "kndndrj/nvim-dbee",
    cmd = "Dbee",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    build = function()
      require("dbee").install()
    end,
    config = function()
      local queries_dir = vim.fn.expand "~/Sql/.queries/"
      vim.fn.mkdir(queries_dir, "p")
      require("dbee").setup {
        sources = {
          require("dbee.sources").EnvSource:new "DBEE_CONNECTIONS",
          require("dbee.sources").FileSource:new(queries_dir .. "persistence.json"),
        },
      }
    end,
  },

  { "kristijanhusak/vim-dadbod-completion" },

  -- Snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = true,
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
          -- Buffers
          buffers = {
            name = "Buffers",
            items = function()
              local bufs = vim.fn.getbufinfo { buflisted = 1 }
              return vim.tbl_map(function(buf)
                return {
                  text = vim.fn.fnamemodify(buf.name, ":t") .. (buf.name == "" and " [No Name]" or ""),
                  path = buf.name,
                  bufnr = buf.bufnr,
                  cwd = vim.fn.getcwd(),
                }
              end, bufs)
            end,
            action = function(item)
              vim.api.nvim_set_current_buf(item.bufnr)
            end,
          },
          -- Files (frecency style)
          files = {
            name = "Files",
            hidden = true,
            dirs = { vim.loop.cwd() },
            items = function()
              local opts = {
                cwd = vim.loop.cwd(),
                hidden = true,
                no_ignore = false,
              }
              local results = vim.fs.find(function(name, path)
                return vim.endswith(path, ".git") == false
              end, opts)
              return vim.tbl_map(function(path)
                return { text = vim.fn.fnamemodify(path, ":t"), path = path }
              end, results)
            end,
            action = function(item)
              vim.cmd.edit(item.path)
            end,
          },
        },
      },
      -- Keep your other snacks features
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = true, replace_netrw = yes },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = {
        enabled = false,
        left = { "signs", "git" },
        right = { "fold" },
      },
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
      require("mini.hipatterns").setup {
        highlighters = {
          hex_color = require("mini.hipatterns").gen_highlighter.hex_color { fg = true },
        },
      }
    end,
  },
  -- NOTEBOOK SETUP

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    ft = { "ipynb", "markdown", "quarto" },
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  -- Images in terminal (for Molten outputs)
  {
    "3rd/image.nvim",
    lazy = true,
    -- event = "VeryLazy",
    -- ft = { "markdown", "quarto", "ipynb" },
    -- opts = {
    --   backend = "kitty",
    --   integrations = {
    --     markdown = { enabled = true },
    --     molten = { enabled = true },
    --   },
    max_width = 20,
    max_height = 50,
    max_height_window_percentage = math.huge,
    max_width_window_percentage = math.huge,
    window_overlap_clear_enabled = true,
  },

  -- Molten (Jupyter kernel runner)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    lazy = false,
    build = ":UpdateRemotePlugins",
    dependencies = {
      "3rd/image.nvim",
      ft = { "markdown", "quarto", "ipynb" },
      opts = { backend = "kitty", integrations = { markdown = { enabled = true }, molten = { enabled = true } } },
    },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_wrap_output = false
      vim.g.molten_virt_text_output = false
      vim.g.molten_output_show_more = true
      vim.g.molten_output_virt_lines = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_output_win_border = { "", "━", "", "" }
      vim.g.molten_limit_output_chars = 1000000
      vim.g.molten_virt_text_max_lines = 10000
      vim.g.molten_output_win_zindex = 100
      vim.g.molten_use_border_highlights = true
      -- vim.g.molten_split_direction = "right"
      vim.g.molten_output_win_max_height = 1000
      vim.g.molten_output_win_max_width = 1000
      vim.g.molten_tick_rate = 200
    end,
    config = function()
      -- === default_notebook + NewNotebook ===
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
        if file then
          file:write(default_notebook)
          file:close()
          vim.cmd("edit " .. path)
        else
          vim.notify("Error: could not write " .. path, vim.log.levels.ERROR)
        end
      end

      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        new_notebook(opts.args)
      end, { nargs = 1, complete = "file", desc = "Create a new .ipynb" })

      -- === Molten keymaps ===
      vim.keymap.set(
        "n",
        "<localleader>e",
        ":MoltenEvaluateOperator<CR>",
        { desc = "evaluate operator", silent = true }
      )
      vim.keymap.set(
        "n",
        "<localleader>os",
        ":noautocmd MoltenEnterOutput<CR>",
        { desc = "open output window", silent = true }
      )
      vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
      vim.keymap.set(
        "v",
        "<localleader>r",
        ":<C-u>MoltenEvaluateVisual<CR>gv",
        { desc = "execute visual selection", silent = true }
      )
    end,
  },

  -- Quarto (LSP-in-markdown + molten runner)
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
      "3rd/image.nvim",
    },
    lazy = true,
    ft = { "quarto", "markdown", "ipynb" },
    config = function()
      vim.g.molten_output_win_max_height = 1000
      vim.g.molten_output_win_max_width = 1000
      vim.g.molten_wrap_output = false
      -- vim.api.nvim_create_autocmd("FileType", {
      --   pattern = "markdown",
      --   callback = function()
      --     require("quarto").activate()
      --   end,
      -- })
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
        vim.cmd "startinsert"
      end

      vim.keymap.set("n", "<leader>n", function()
        quarto_new_chunk_below "python"
      end, { desc = "New python chunk below", buffer = true, silent = true })

      local runner = require "quarto.runner"
      vim.keymap.set("n", "<leader>r", runner.run_cell, { desc = "run cell", silent = true })
      vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "run cell and above", silent = true })
      vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "run all cells", silent = true })
      vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "run line", silent = true })
      vim.keymap.set("v", "<leader>rr", runner.run_range, { desc = "run visual range", silent = true })
    end,
  },

  ---- MARKDOWN PLUGINS

  -- Render markdown (keeps code blocks visible for cells)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = true,
    ft = { "markdown", "quarto" }, -- Lazy-load on these filetypes
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
    opts = {
      enabled = true,
      file_types = { "markdown" }, -- Enables for markdown (rmd may need explicit addition)
      win_options = {
        conceallevel = { default = 0, rendered = 0 },
      },
      conceal = {
        links = true,
        code_blocks = false,
        inline_code = false,
      },
      heading = {
        enabled = true,
        width = "block",
        left_pad = 2,
        right_pad = 4,
        icons = { "󰼏 ", "󰎨 " },
      },
      -- Consolidated code options
      code = {
        enabled = true,
        width = "block",
        left_pad = 2,
        right_pad = 4,
        language_border = " ",
        language_left = "",
        language_right = "",
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
  -- Markdown preview (browser/webview)
  {
    "toppair/peek.nvim",
    lazy = true,
    ft = { "markdown", "quarto" },
    event = { "VeryLazy" },
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

  --   -- Copilot
    -- { "github/copilot.vim" },
}
