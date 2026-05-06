local capabilities = require("blink.cmp").get_lsp_capabilities()

-- ── 1. Base config for ALL servers ───────────────────────
vim.lsp.config("*", { capabilities = capabilities })

-- ── 2. LspAttach: keymaps + per-client overrides ─────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    -- sqls: disable formatting (let conform/sqlfluff handle it)
    if client.name == "sqls" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
    end

    map("n", "gd",    vim.lsp.buf.definition,      "Go to Definition")
    map("n", "gD",    vim.lsp.buf.declaration,      "Go to Declaration")
    map("n", "gi",    vim.lsp.buf.implementation,   "Go to Implementation")
    map("n", "gr",    vim.lsp.buf.references,       "References")
    map("n", "gt",    vim.lsp.buf.type_definition,  "Go to Type Definition")
    map("n", "K",     vim.lsp.buf.hover,            "Hover Documentation")
    map("n", "<C-k>", vim.lsp.buf.signature_help,   "Signature Help")
    map("i", "<C-k>", vim.lsp.buf.signature_help,   "Signature Help")
    map("n", "<leader>rn", vim.lsp.buf.rename,      "Rename Symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("x", "<leader>ca", vim.lsp.buf.code_action, "Code Action (range)")
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder,    "Add Workspace Folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List Workspace Folders")

    map("n", "<leader>f", function()
      local ok, conform = pcall(require, "conform")
      if ok then
        conform.format { bufnr = ev.buf, lsp_fallback = true }
      else
        vim.lsp.buf.format { bufnr = ev.buf }
      end
    end, "Format Buffer")

    if vim.lsp.inlay_hint then
      map("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf },
          { bufnr = ev.buf }
        )
      end, "Toggle Inlay Hints")
    end
  end,
})

-- ── 3. Per-server settings ────────────────────────────────
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime     = { version = "LuaJIT" },
      workspace   = { checkThirdParty = false },
      diagnostics = { globals = { "vim" } },
      telemetry   = { enable = false },
      hint        = { enable = true },
    },
  },
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoSearchPaths        = true,
        useLibraryCodeForTypes = true,
        typeCheckingMode       = "standard",
        diagnosticMode         = "openFilesOnly",
      },
    },
  },
})

vim.lsp.config("bashls", {
  filetypes = { "sh", "bash", "zsh" },
})

-- ── 4. Enable servers ─────────────────────────────────────
vim.lsp.enable { "lua_ls", "pyright", "sqls", "bashls", "vtsls", "cssls", "beautysh", "html" }

-- ── 5. Diagnostics ────────────────────────────────────────
vim.diagnostic.config {
  virtual_text     = false,
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float = { border = "rounded", source = true, header = "", prefix = "" },
}

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    if #vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() } == 0 then return end
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
