local map = vim.keymap.set

-- general mappings
map("n", "<C-s>", "<cmd> w <CR>")
map("i", "jk", "<ESC>")
map("n", "<C-c>", "<cmd> %y+ <CR>") -- copy whole filecontent

-- nvimtree
map("n", "<C-n>", "<cmd> NvimTreeToggle <CR>")
map("n", "<C-h>", "<cmd> NvimTreeFocus <CR>")

-- telescope
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
map("n", "<leader>fw", "<cmd> Telescope live_grep <CR>")
map("n", "<leader>gt", "<cmd> Telescope git_status <CR>")

-- bufferline, cycle buffers
map("n", "<Tab>", "<cmd> BufferLineCycleNext <CR>")
map("n", "<S-Tab>", "<cmd> BufferLineCyclePrev <CR>")
map("n", "<C-q>", "<cmd> bd <CR>")

-- comment.nvim
map("n", "<leader>/", "gcc", { remap = true })
map("v", "<leader>/", "gc", { remap = true })

-- format
map("n", "<leader>fm", function()
  require("conform").format()
end)

-- Custom Mappings
-- map("n", "<leader>r", [[:%s/\v^.+\.mkv/\=printf("Ep-%d.mkv", line('.'))/g]])
map("n", "<leader>p", [[:%s/\v^.+\.png/\=printf("Wall-%d.png", line('.'))/g]])
map("v", "J", ":move '>+1<CR>gv=gv")
map("v", "K", ":move '<-2<CR>gv=gv")
map('n', '<C-h>', '<C-w><', { desc = 'Decrease pane width' })
map('n', '<C-l>', '<C-w>>', { desc = 'Increase pane width' })
map('n', '<C-j>', '<C-w>+', { desc = 'Increase pane height' })
map('n', '<C-k>', '<C-w>-', { desc = 'Decrease pane height' })

-- Sql
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",  -- Or omit for all
  callback = function()
    if vim.bo.filetype == "dbee_result" or vim.bo.buftype == "nofile" then  -- Tune after checking
      vim.keymap.set("n", "<leader>dc", function()  -- Your export function here
        local timestamp = os.date("%Y%m%d_%H%M%S")
        local default = vim.fn.expand("~/Sql/csv/output_" .. timestamp .. ".csv")
        vim.ui.input({ prompt = "CSV filename: ", default = default }, function(filename)
          if filename then
            require("dbee").store("csv", "file", {extra_arg = vim.fn.expand(filename)})
          end
        end)
      end, { buffer = true, desc = "Save as CSV" })
    end
  end,
})

-- Molten 
-- map("n", "<leader>mi", ":MoltenInit<CR>", { desc = "molten init", silent = false })
map("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
map("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
map("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection", silent = true })
map("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
map("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
map("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })

vim.keymap.set("n", "<leader>mi", function()
  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv ~= nil then
    -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
    venv = string.match(venv, "/.+/(.+)")
    vim.cmd(("MoltenInit %s"):format(venv))
  else
    vim.cmd("MoltenInit python3")
  end
end, { desc = "Initialize Molten for python3", silent = true })

map("n", "<leader>q", ":QuartoActivate<CR>", {desc = "Quarto Activated" , silent = false})
-- map("n", "<leader>d", [[:g/<C-r><C-w>/d]])
