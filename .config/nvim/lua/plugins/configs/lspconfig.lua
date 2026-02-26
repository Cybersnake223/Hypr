-- ─────────────────────────────────────────────────────────
-- plugins/configs/lspconfig.lua
-- ─────────────────────────────────────────────────────────

-- ── 1. Global capabilities (blink.cmp) ──────────────────
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- ── 2. Per-server configuration ─────────────────────────

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = {
        globals = { "vim" },
      },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        typeCheckingMode = "standard",
        diagnosticMode = "workspace",
      },
    },
  },
})

vim.lsp.config("sqls", {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

vim.lsp.config("bashls", {
  filetypes = { "sh", "bash", "zsh" }, -- extend to zsh if you use it
})

-- ── 3. Enable all servers ────────────────────────────────
-- Servers attach automatically when the matching filetype opens.
vim.lsp.enable { "lua_ls", "pyright", "sqls", "bashls" }

-- ── 4. Diagnostics display ──────────────────────────────
vim.diagnostic.config {
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
}

-- Show diagnostics float on cursor hold instead of inline virtual text
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

-- ── 5. LspAttach keymaps ─────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gt", vim.lsp.buf.type_definition, "Go to Type Definition")

    -- Docs / Info
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

    -- Actions
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("x", "<leader>ca", vim.lsp.buf.code_action, "Code Action (range)")

    -- Diagnostics
    -- map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
    -- map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
    -- map("n", "<leader>e", vim.diagnostic.open_float, "Show Diagnostic Float")
    -- map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to Loclist")

    -- Workspace (kept from your original, rarely used but harmless)
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List Workspace Folders")

    -- Format (via conform.nvim if loaded, fallback to LSP)
    map("n", "<leader>f", function()
      local ok, conform = pcall(require, "conform")
      if ok then
        conform.format { bufnr = ev.buf, lsp_fallback = true }
      else
        vim.lsp.buf.format { bufnr = ev.buf }
      end
    end, "Format Buffer")

    -- Inlay hints toggle (Neovim 0.10+)
    if vim.lsp.inlay_hint then
      map("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf }, { bufnr = ev.buf })
      end, "Toggle Inlay Hints")
    end
  end,
})
