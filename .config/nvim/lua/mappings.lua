local map = vim.keymap.set

-----------------------------------------------------------
-- 1. General Editing & Essentials
-----------------------------------------------------------
map("n", "<C-s>", "<cmd>w<CR>", { desc = "File: Save" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "<leader>Y", "<cmd>%y+<CR>", { desc = "File: Copy all" })
map("n", "<leader>/", "gcc", { remap = true, desc = "Comment: Line" })
map("v", "<leader>/", "gc", { remap = true, desc = "Comment: Selection" })
-----------------------------------------------------------
-- 2. Navigation (Buffers & Windows)
-----------------------------------------------------------
-- Switch Buffers
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Buffer: Next" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Buffer: Prev" })
map("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Buffer: Close" })

-- Window movement (Alt + hjkl for speed)
map("n", "<A-h>", "<C-w>h", { desc = "Window: Left" })
map("n", "<A-j>", "<C-w>j", { desc = "Window: Down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window: Up" })
map("n", "<A-l>", "<C-w>l", { desc = "Window: Right" })
map("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal: Window Left" })
map("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal: Window Down" })
map("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal: Window Up" })
map("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal: Window Right" })

-- Resize Windows (Ctrl + Arrows)
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Resize: Increase Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Resize: Decrease Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize: Decrease Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize: Increase Width" })

-----------------------------------------------------------
-- 3. Data Science (Molten & Quarto)
-----------------------------------------------------------
-- Initialization
map("n", "<leader>mi", function()
  vim.cmd "MoltenInit python3"
end, { desc = "Molten: Init python3" })
map("n", "<leader>ms", function()
  vim.cmd "MoltenInit shared python3"
end, { desc = "Molten: Share python3 kernel" })

-- Lifecycle
map("n", "<leader>mR", "<cmd>MoltenRestart<CR>", { desc = "Molten: Restart kernel" })
map("n", "<leader>mI", "<cmd>MoltenInterrupt<CR>", { desc = "Molten: Interrupt" })
map("n", "<leader>mD", "<cmd>MoltenDeactivate<CR>", { desc = "Molten: Deactivate" })
map("n", "<leader>mO", function()
  vim.cmd "MoltenShowOutput"
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "molten_output" then
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end, { desc = "Molten: Open output & enter" })
map("n", "<leader>me", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "molten_output" then
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end, { desc = "Molten: Enter output window" })
map("n", "<leader>mc", "<cmd>MoltenReevaluateCell<CR>", { desc = "Molten: Re-run cell" })

-- Quarto
map("n", "<leader>qa", ":QuartoActivate<CR>", { desc = "Quarto: Activate" })

-----------------------------------------------------------
-- 5. Database (Dbee)
-----------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dbee_result",
  group = vim.api.nvim_create_augroup("DbeeResultMappings", { clear = true }),
  callback = function()
    map("n", "<leader>dc", function()
      local timestamp = os.date "%Y%m%d_%H%M%S"
      local default = vim.fn.expand("~/Sql/csv/output_" .. timestamp .. ".csv")
      vim.ui.input({ prompt = "CSV filename: ", default = default }, function(filename)
        if filename then
          require("dbee").store("csv", "file", { extra_arg = vim.fn.expand(filename) })
        end
      end)
    end, { buffer = true, desc = "DB: Export CSV" })
  end,
})

-- map("v", "<leader>b", ":lua require('dbee').execute()<CR>", { desc = "Execute SQL" })

-----------------------------------------------------------
-- 6. Plugin Management
-----------------------------------------------------------
map("n", "<leader>P", "<cmd>Lazy<CR>", { desc = "Lazy Menu" })
map("n", "<leader>M", "<cmd>Mason<CR>", { desc = "Mason Menu" })

-----------------------------------------------------------
-- 7. Terminal (Snacks)
-----------------------------------------------------------
map("n", "<leader>tt", function()
  require("snacks").terminal()
end, { desc = "Terminal: Toggle" })
map("n", "<leader>tR", function()
  require("snacks").terminal("R")
end, { desc = "Terminal: R" })

-----------------------------------------------------------
-- 8. Database (Dbee) — global toggle
-----------------------------------------------------------
map("n", "<leader>db", "<cmd>Dbee<CR>", { desc = "DB: Open dbee" })

-----------------------------------------------------------
-- 9. Git (Gitsigns)
-----------------------------------------------------------
map("n", "<leader>gb", function()
  require("gitsigns").blame_line { full = true }
end, { desc = "Git: Blame line", silent = true })
map("n", "<leader>gh", function() require("gitsigns").preview_hunk() end, { desc = "Git: Preview hunk" })
map("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "Git: Reset hunk" })
map("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Git: Stage hunk" })
map("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Git: Undo stage" })
map("n", "<leader>gd", function() require("gitsigns").diffthis() end, { desc = "Git: Diff this" })
map({ "n", "v" }, "]h", function() require("gitsigns").next_hunk() end, { desc = "Git: Next hunk" })
map({ "n", "v" }, "[h", function() require("gitsigns").prev_hunk() end, { desc = "Git: Prev hunk" })

-----------------------------------------------------------
-- 10. LSP — global
-----------------------------------------------------------
map("n", "<leader>li", "<cmd>LspClients<CR>", { desc = "LSP: Clients" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP: Rename" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
map("x", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP: Code action (range)" })
map("n", "<leader>lf", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "LSP: Format" })
map("n", "<leader>ls", function()
  require("snacks").picker.lsp_symbols()
end, { desc = "LSP: Symbols (buffer)" })
map("n", "<leader>lS", function()
  require("snacks").picker.lsp_workspace_symbols()
end, { desc = "LSP: Symbols (workspace)" })
map("n", "<leader>ld", function()
  vim.diagnostic.open_float(nil, { focus = false, border = "rounded" })
end, { desc = "LSP: Hover diagnostic" })
map("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(
    not vim.lsp.inlay_hint.is_enabled { bufnr = vim.api.nvim_get_current_buf() },
    { bufnr = vim.api.nvim_get_current_buf() }
  )
end, { desc = "LSP: Toggle inlay hints" })

-----------------------------------------------------------
-- 11. Quickfix / Location List
-----------------------------------------------------------
map("n", "]q", "<cmd>cnext<CR>", { desc = "Quickfix: Next" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Quickfix: Prev" })
map("n", "]l", "<cmd>lnext<CR>", { desc = "Location: Next" })
map("n", "[l", "<cmd>lprev<CR>", { desc = "Location: Prev" })
map("n", "<leader>qq", "<cmd>copen<CR>", { desc = "Quickfix: Open" })
map("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Quickfix: Close" })

-----------------------------------------------------------
-- 12. Session (Snacks)
-----------------------------------------------------------
map("n", "<leader>Ss", function()
  require("snacks").session.save()
end, { desc = "Session: Save" })
map("n", "<leader>Sl", function()
  require("snacks").session.load()
end, { desc = "Session: Load" })

-----------------------------------------------------------
-- 13. Visual Mode Utility
-----------------------------------------------------------
map("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move block down" })
map("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move block up" })
