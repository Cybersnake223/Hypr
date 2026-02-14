return {
  -- Colorscheme
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
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd "colorscheme nightfox"
    end,
  },

  -- Core async Lua library (dependency for many plugins)
  { "nvim-lua/plenary.nvim", lazy = true },

  -- UI : statusline , Git signs, Command Prompt
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- Change this from false to true
      notify = {
        enabled = true,
      },
      -- Also add these to fix the other 2 warnings in your healthcheck
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
      -- Optional: "rcarriga/nvim-notify"
      -- Add nvim-notify if you want the pretty animated corner bubbles
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
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
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { "filename" },
          lualine_x = {
            function()
              return is_excluded() and "" or "diagnostics"
            end,
          },
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
    context_commentstring = { enable = false },
    textobjects = {
      select = { enable = true },
    },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup {
          ensure_installed = { "lua", "vim", "bash", "javascript", "python", "sql" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true, disable = { "python", "yaml" } },
          incremental_selection = { enable = true },
          disable = function(lang, buf)
            local max_lines = 1000
            local max_bytes = 500 * 1024
            if vim.api.nvim_buf_line_count(buf) > max_lines then
              return true
            end
            local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local total = 0
            for _, line in ipairs(content) do
              total = total + #line
              if total > max_bytes then
                return true
              end
            end
            return false
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
    event = "InsertEnter",
    -- enabled = true,
    build = "cargo build --release",
    -- lazy = false,
    dependencies = {
      { "rafamadriz/friendly-snippets", lazy = true },
      { "Kaiser-Yang/blink-cmp-git", lazy = true },
      {
        "saghen/blink.compat",
        lazy = true,
        opts = { impersonate_nvim_cmp = true, enable_events = true },
      },
    },
    opts = {
      keymap = {
        preset = "enter",
        ["<c-y>"] = { "show", "show_documentation", "hide_documentation" },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 00 },
        menu = { auto_show = true },
      },
      signature = { enabled = true },
    },
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- LSP Manager
  -- {
  --   "williamboman/mason.nvim",
  --   build = ":MasonUpdate",
  --   cmd = { "Mason", "MasonInstall" },
  --   opts = { ui = { border = "rounded", winblend = 0 } },
  -- },

  -- LSP config + Mason integrations
  {
    "neovim/nvim-lspconfig",
    -- event = "VeryLazy",
    dependencies = {
      { "williamboman/mason.nvim", config = true, opts = {} },
      {
        "williamboman/mason-lspconfig.nvim",
        event = "LspAttach",
      },
      config = function()
        local mlsp = require "mason-lspconfig"

        -- Setup mason-lspconfig first
        mlsp.setup {
          ensure_installed = { "lua_ls", "pyright", "marksman" },
        }

        -- Then setup your servers
        local lspconfig = require "lspconfig"
        mlsp.setup_handlers {
          function(server_name)
            lspconfig[server_name].setup {}
          end,
        }
      end,
    },
  },

  -- {
  --   "WhoIsSethDaniel/mason-tool-installer.nvim",
  --   cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
  --   event = "VeryLazy",
  --   opts = {
  --     ensure_installed = {
  --       "tree-sitter-cli",
  --       "jupytext",
  --       "black",
  --       "insort",
  --     },
  --   },
  -- },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "plugins.configs.conform",
  },

  -- Indentation
  {
    "nvimdev/indentmini.nvim",
    event = { "VeryLazy" },
    opts = {},
  },

  -- SQL Database Client + Completion
  {
    "kndndrj/nvim-dbee",
    cmd = { "Dbee" },
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
  -- Transparency
  -- {
  --   "xiyaowong/transparent.nvim",
  --   lazy = false,
  --   event = "VimEnter",
  -- },

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
    lazy = false, -- Keep it false to prevent double-loading buffers
    config = function()
      require("jupytext").setup {
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown", -- Explicitly setting this prevents FT detection loops
      }
    end,
  },
  -- Images in terminal (for Molten outputs)
  {
    "3rd/image.nvim",
    -- lazy = true,
    ft = { "python", "ipynb", "quarto", "markdown" },
    -- opts = { backend = "kitty", integrations = { markdown = { enabled = true }, molten = { enabled = true } } },
  },

  -- Molten (Jupyter kernel runner)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    -- This ensures it ONLY loads for these files
    ft = { "python", "ipynb" },
    dependencies = { "3rd/image.nvim" },
    init = function()
      -- These variables MUST be in init for Molten to pick them up
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_wrap_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_show_more = true
      vim.g.molten_output_virt_lines = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_output_win_border = { "", "━", "", "" }
      vim.g.molten_limit_output_chars = 10000
      vim.g.molten_virt_text_max_lines = 12
      vim.g.molten_output_win_zindex = 100
      vim.g.molten_use_border_highlights = true
      vim.g.molten_tick_rate = 50

      -- OPTIONAL: Add an autocmd to only initialize the kernel environment
      -- when entering a buffer of these types.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "quarto", "ipynb", "markdown" },
        callback = function()
          -- This ensures the remote plugin host is ready
          vim.fn["remote#host#Require"] "python3"
        end,
      })
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
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "quarto", "python", "ipynb" }, -- Added python/ipynb for safety
        callback = function()
          vim.schedule(function()
            pcall(vim.cmd, "MoltenImportOutput")
          end)
        end,
      })
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
    -- lazy = true,
    ft = { "quarto", "markdown", "ipynb" },
    dependencies = {
      "jmbuhr/otter.nvim",
      opts = { lsp = { hover = { border = "rounded" } } },
      "nvim-treesitter/nvim-treesitter",
      "3rd/image.nvim",
    },
    config = function()
      require("quarto").setup {
        lspFeatures = {
          enabled = true,
          chunks = "all",
          languages = { "python" },
          diagnostics = { enabled = false, triggers = { "BufWritePost" } },
          completion = { enabled = false },
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
    -- lazy = true,
    ft = { "markdown", "quarto", "ipynb" }, -- Lazy-load on these filetypes
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
    opts = {
      render_modes = { "n", "c" },
      latex = { enabled = false },
      max_file_size = 1.0,
      anti_conceal = { enabled = false },
      enabled = true,
      file_types = { "markdown", "ipynb" }, -- Enables for markdown (rmd may need explicit addition)
      win_options = {
        conceallevel = { default = 0, rendered = 0 },
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
        auto_load = false,
        syntax = true,
        theme = "dark",
        update_on_change = true,
        app = "webview",
        filetype = { "markdown" },
      }
    end,
  },
  --
  --   -- Copilot
  -- { "github/copilot.vim" },
}
