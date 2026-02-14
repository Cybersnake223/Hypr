local map = vim.keymap.set

-----------------------------------------------------------
-- 1. General Editing & Essentials
-----------------------------------------------------------
map("n", "<C-s>", "<cmd>w<CR>", { desc = "File: Save" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "File: Copy all" })
map("n", "<leader>fm", function()
  require("conform").format()
end, { desc = "Code: Format" })
map("n", "<leader>/", "gcc", { remap = true, desc = "Comment: Line" })
map("v", "<leader>/", "gc", { remap = true, desc = "Comment: Selection" })

-----------------------------------------------------------
-- 2. Navigation (Buffers & Windows)
-----------------------------------------------------------
-- Switch Buffers
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Buffer: Next" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Buffer: Prev" })
map("n", "<C-q>", "<cmd>bd<CR>", { desc = "Buffer: Close" })

-- Window movement (Alt + hjkl for speed)
map("n", "<A-h>", "<C-w>h", { desc = "Window: Left" })
map("n", "<A-j>", "<C-w>j", { desc = "Window: Down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window: Up" })
map("n", "<A-l>", "<C-w>l", { desc = "Window: Right" })

-- Resize Windows (Ctrl + Arrows)
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Resize: Increase Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Resize: Decrease Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize: Decrease Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize: Increase Width" })

-----------------------------------------------------------
-- 3. Search & File Management (Snacks)
-----------------------------------------------------------
map("n", "<leader>ff", function()
  require("snacks").picker.files()
end, { desc = "Find: Files" })
map("n", "<leader>fg", function()
  require("snacks").picker.grep()
end, { desc = "Find: Live Grep" })
map("n", "<leader>fb", function()
  require("snacks").picker.buffers()
end, { desc = "Find: Buffers" })
map("n", "<leader>fr", function()
  require("snacks").picker.recent()
end, { desc = "Find: Recent" })
map("n", "<leader>e", function()
  require("snacks").explorer()
end, { desc = "Explorer" })

-----------------------------------------------------------
-- 4. Data Science (Molten & Quarto)
-----------------------------------------------------------
-- Initialization
map("n", "<leader>mi", function()
  local venv = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"
  if venv ~= nil then
    venv = string.match(venv, "/.+/(.+)")
    vim.cmd(("MoltenInit %s"):format(venv))
  else
    vim.cmd "MoltenInit python3"
  end
end, { desc = "Molten: Init" })

-- Execution (Unified under <leader>r)
map("n", "<leader>rr", ":MoltenReevaluateCell<CR>", { desc = "Run: Cell", silent = true })
-- map("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Run: Visual Selection", silent = true })
map("n", "<leader>rd", ":MoltenDelete<CR>", { desc = "Run: Delete Cell", silent = true })
map("n", "<leader>rh", ":MoltenHideOutput<CR>", { desc = "Run: Hide Output", silent = true })
map("n", "<leader>ro", ":noautocmd MoltenEnterOutput<CR>", { desc = "Run: Show Output Window", silent = true })

-- Quarto
map("n", "<leader>q", ":QuartoActivate<CR>", { desc = "Quarto: Activate" })

-----------------------------------------------------------
-- 5. Database (Dbee)
-----------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dbee_result",
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

-----------------------------------------------------------
-- 6. Plugin Management
-----------------------------------------------------------
map("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy Menu" })
map("n", "<leader>M", "<cmd>Mason<CR>", { desc = "Mason Menu" })

-----------------------------------------------------------
-- 7. Visual Mode Utility
-----------------------------------------------------------
map("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move block down" })
map("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move block up" })
