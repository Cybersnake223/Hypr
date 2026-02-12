-- Keymaps + buffer-local settings when an LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local ft = vim.bo[buf].filetype

    -- Keep dadbod omnifunc for SQL if you set it elsewhere (recommended).
    -- vim-dadbod-completion uses: vim_dadbod_completion#omni [web:34]
    if not (ft == "sql" or ft == "mysql" or ft == "plsql") then
      vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    local opts = { buffer = buf, silent = true }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)

    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
  end,
})

-- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Optional: keep your explicit completionItem capability block
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.completion = capabilities.textDocument.completion or {}
capabilities.textDocument.completion.completionItem = vim.tbl_deep_extend(
  "force",
  capabilities.textDocument.completion.completionItem or {},
  {
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
  }
)

-- Merge blink.cmp capabilities if available
-- blink’s author shows this exact merge pattern as a common approach. [web:70]
local ok, blink = pcall(require, "blink.cmp")
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- IMPORTANT: configure first, then enable. [web:15]
vim.lsp.config("*", { capabilities = capabilities })

-- Enable the servers you actually want running
vim.lsp.enable({
  "lua_ls",
  "pyright",
  -- "bashls",
  "marksman",
  -- "html",
  -- "cssls",
})
