-- ==========================================================
-- 1. LSP ATTACH: Buffer-local settings & Keymaps
-- ==========================================================
-- This autocmd runs every time an LSP connects to a file.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local ft = vim.bo[buf].filetype

    -- SQL PROTECTION:
    -- We prevent the LSP from taking over the 'omnifunc' in SQL files.
    -- This ensures that vim-dadbod-completion stays in charge of your DB tables.
    if not (ft == "sql" or ft == "mysql" or ft == "plsql") then
      vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    -- NAVIGATION & REFACTORING KEYMAPS
    local opts = { buffer = buf, silent = true }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- Go to Declaration
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- Go to Definition
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Show documentation popup
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts) -- Smart Rename (across files)
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts) -- Quick fixes

    -- WORKSPACE MANAGEMENT (useful for multi-folder projects)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
  end,
})

-- ==========================================================
-- 2. CAPABILITIES: Teaching the LSP what Neovim can do
-- ==========================================================
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- ENHANCED COMPLETION:
-- We tell the LSP that we support snippets, markdown docs, and label details.
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.completion = capabilities.textDocument.completion or {}
capabilities.textDocument.completion.completionItem =
  vim.tbl_deep_extend("force", capabilities.textDocument.completion.completionItem or {}, {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" },
    },
  })

-- BLINK.CMP INTEGRATION:
-- If blink.cmp is installed, we merge its highly optimized capabilities.
-- This is what makes completion feel "instant."
local ok, blink = pcall(require, "blink.cmp")
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- ==========================================================
-- 3. SERVER ACTIVATION
-- ==========================================================
-- Apply the capabilities globally to all servers configured via lspconfig.
vim.lsp.config("*", { capabilities = capabilities })

-- ENABLE SERVERS:
-- These strings must match the names in Mason (e.g., pyright, lua_ls).
vim.lsp.enable {
  "lua_ls", -- Lua (for Neovim config)
  "pyright", -- Python (for Data Science)
  "marksman", -- Markdown (for Notebooks/Quarto)
}
