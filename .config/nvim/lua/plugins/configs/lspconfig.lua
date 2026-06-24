-- ── 1. LspAttach: keymaps + per-client overrides ─────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gt", vim.lsp.buf.type_definition, "Go to Type Definition")
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List Workspace Folders")
    map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
    map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
  end,
})

-- ── 2. Per-server settings ────────────────────────────────
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
      diagnostics = { globals = { "vim" } },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
})

vim.lsp.config("ruff", {
  settings = {
    settings = {
      lineLength = 120,
      lint = { respectGitignore = true },
      format = { quoteStyle = "double", indentWidth = 4 },
    },
  },
})

-- ── 3. Filetype aliases (for marksman + .mdx) ────────────
vim.filetype.add { extension = { mdx = "markdown" } }

-- ── 4. Enable servers ─────────────────────────────────────
vim.lsp.enable { "lua_ls", "ruff", "sqls", "bashls", "marksman", "cssls", "html", "jsonls", "yamlls" }

-- ── 5. Diagnostics ────────────────────────────────────────
vim.diagnostic.config {
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  float = { border = "rounded", source = true, header = "", prefix = "" },
}

vim.lsp.inlay_hint.enable(true)

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local ft = vim.bo.filetype
    if
      vim.tbl_contains({ "dbee", "lazy", "mason", "TelescopePrompt", "snacks_picker_input", "snacks_terminal", "lspinfo", "help", "neo-tree", "noice" }, ft)
    then
      return
    end
    if #vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() } == 0 then
      return
    end
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
