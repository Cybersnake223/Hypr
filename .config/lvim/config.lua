--- keymaps ---
local opts = { noremap = true, silent = true }

local keymap = vim.keymap.set

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


keymap("n", "<leader>m", "<cmd>Mason<CR> ")
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")
keymap({ "n", "v" }, "<leader>y", [["+y]])
keymap("n", "<leader>Y", [["+Y]])
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
keymap("v", "J", ":move '>+1<CR>gv=gv")
keymap("v", "K", ":move '<-2<CR>gv=gv")
keymap("n", "<leader>d", [[:g/<C-r><C-w>/d]])
keymap("n", "<leader>r", [[:%s/\v^.+\.mkv/\=printf("Ep-%d.mkv", line('.'))/g]])


--- Skeleton ---
vim.api.nvim_create_autocmd({"BufNewFile"}, { command = '0r ~/Templates/Cybersnake/Temp' })

--- Colorscheme ---
vim.cmd.colorscheme "catppuccin"
