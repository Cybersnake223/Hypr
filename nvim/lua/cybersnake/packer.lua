--- Packer Plugin manager ---
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    --- Telescope ---
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.2',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    --- Ayu-Dark Colorscheme ---
    use ({ 
        'Shatur/neovim-ayu',
        as = 'ayu-dark',
        config = function()
            vim.cmd('colorscheme ayu-dark')
        end })

        --- Treesitter ---
        use( 'nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'} )
        
        --- Harpoon ----		
        use ('ThePrimeagen/harpoon')
        
        --- Lsp ---		
        use {  'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            {'neovim/nvim-lspconfig'},             -- Required
            {'williamboman/mason.nvim'},           -- Optional
            {'williamboman/mason-lspconfig.nvim'}, -- Optional
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'L3MON4D3/LuaSnip'},     -- Required
        }
    }
    
    --- Lualine ---
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    --- Mkdir ---
    use {
        'jghauser/mkdir.nvim'
    }
    --- Whichkey ---
    use {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup {
            }
        end
    }
end)
