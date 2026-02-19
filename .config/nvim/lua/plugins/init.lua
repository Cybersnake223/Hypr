return {
  -- Colorscheme
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   lazy = false,
  --   opts = {
  --     flavour = "mocha",
  --     transparent_background = true,
  --     show_end_of_buffer = false,
  --     integrations = {
  --       cmp = true,
  --       gitsigns = true,
  --       nvimtree = true,
  --       treesitter = true,
  --       mason = true,
  --       telescope = true,
  --       notify = true,
  --       lsp_trouble = true,
  --     },
  --     custom_highlights = function(colors)
  --       return {
  --         NormalFloat = { bg = colors.none },
  --         FloatBorder = { bg = colors.none },
  --         FloatTitle = { bg = colors.none },
  --       }
  --     end,
  --   },
  --   config = function(_, opts)
  --     require("catppuccin").setup(opts)
  --     vim.cmd.colorscheme "catppuccin"
  --   end,
  -- },
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
      -- This is where we tell Nightfox to ignore backgrounds for Snacks
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
  -- Core async Lua library (dependency for many plugins)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- UI : statusline , Git signs, Command Prompt
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      notify = {
        enabled = true,
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          background_colour = "#000000",
          -- Optional: Add other notify settings
          stages = "fade",
          render = "compact",
          top_down = true,
          max_width = 80,
          max_height = 10,
          fps = 60,
          timeout = 3000,
        },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
    config = function()
      local exclude = { "markdown", "quarto", "ipynb" }
      local function is_excluded()
        return vim.tbl_contains(exclude, vim.bo.filetype)
      end

      require("lualine").setup {
        options = {
          theme = "onedark",
          icons_enabled = true,
          globalstatus = true,
          themable = true,
          refresh = {
            statusline = 1000, -- Refresh every 1 second instead of every 50ms
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { "filename" },
        },
        extensions = {
          -- optional: add NvimTree if you’re using it
          "nvim-tree",
        },
      }
    end,
  },

  -- Syntax, indent, selection (disables on large files)
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
    event = { "VeryLazy" },
    opts = require "plugins.configs.bufferline",
  },

  -- Completion + snippets/autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "saghen/blink.cmp",
    build = "cargo build --release",
    -- version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
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
    opts = {
      ui = {
        border = "rounded",
        winblend = 0, -- 0 = fully transparent
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
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

  -- SQL Database Client
  {
    "kndndrj/nvim-dbee",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = { "Dbee" },
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
      indent = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = false },
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

  -- Colorizer
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

  -- Jupiter notebook

  -- Convert .ipynb <-> markdown automatically (lazy=false prevents raw JSON)
  {
    "GCBallesteros/jupytext.nvim",
    ft = { "ipynb", "julia", "quarto", "markdown" },
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
    dependencies = { "vhyrro/luarocks.nvim" },
    build = "luarocks install magick",
    lazy = true,
    opts = {
      backend = "sixel",
      processor = "magick_rock",
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
  -- Molten (Jupyter kernel runner)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    ft = { "python", "markdown", "quarto" },
    -- build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_wrap_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_tick_rate = 200
      vim.g.molten_output_show_more = true
      vim.g.molten_limit_output_chars = 5000
      vim.g.molten_virt_text_max_lines = 100
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
    end,
    config = function()
      -- Cell evaluation keybinds (Molten docs recommended)
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
      {
        "jmbuhr/otter.nvim",
        dependencies = {
          { "saghen/blink.cmp", event = "InsertEnter" },
        },
      },
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
      vim.keymap.set("n", "<leader>rA", runner.run_above, { desc = "run cell and above", silent = true })
      vim.keymap.set("n", "<leader>ra", runner.run_all, { desc = "run all cells", silent = true })
      vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "run line", silent = true })
      vim.keymap.set("v", "<leader>r", runner.run_range, { desc = "run visual range", silent = true })
    end,
  },

  -- Render markdown (keeps code blocks visible for cells)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "rmd" },
    keys = { -- Add manual trigger
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Rendering" },
    },
    cmd = "RenderMarkdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
    opts = {
      render_modes = { "n", "c" }, -- Only render in Normal and Command mode
      anti_conceal = { enabled = false }, -- Significant speed boost in large files
      enabled = true,
      file_types = { "markdown" }, -- Enables for markdown (rmd may need explicit addition)
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
}
