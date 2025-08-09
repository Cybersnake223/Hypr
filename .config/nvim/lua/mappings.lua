require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>r", [[:%s/\v^.+\.mkv/\=printf("Ep-%d.mkv", line('.'))/g]])
map("n", "<leader>p", [[:%s/\v^.+\.png/\=printf("Wall-%d.png", line('.'))/g]])
map("v", "J", ":move '>+1<CR>gv=gv")
map("v", "K", ":move '<-2<CR>gv=gv")
map("n", "<leader>d", [[:g/<C-r><C-w>/d]])

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
