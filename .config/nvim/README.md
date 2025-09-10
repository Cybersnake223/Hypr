# TinyVim
- Minimal Neovim config meant to be a starting point for new neovim users.

![2023-09-26-133901_2560x1440_scrot](https://github.com/NvChad/tinyvim/assets/59060246/ce143ca2-07f1-4d54-971d-0f8304c50b58)

# Install
- Linux or MacOS
```bash
git clone https://github.com/NvChad/tinyvim ~/.config/nvim && nvim
```

Run `:MasonInstallAll` command after lazy.nvim finishes downloading plugins

- Windows
```bash
git clone https://github.com/NvChad/tinyvim $HOME\AppData\Local\nvim --depth 1 && nvim
```

Run `:MasonInstallAll` command after lazy.nvim finishes downloading plugins

# Reset
```bash
rm -rf ~/.local/share/nvim && rm -rf ~/.config/nvim/lazy-lock.json
```

# Dir structure
```bash
├── init.lua
├── lua
    ├── commands.lua
    ├── mappings.lua
    ├── options.lua
    └── plugins
        ├── init.lua
        ├── configs
            ├── blink.lua
            ├── telescope.lua
            └── ( more ... )
```

# About
- Dont expect this config to be beautiful or blazing fast (no hardcore lazyloading is done)! 
- I'm just using some plugins with their default configs
- This config only uses only lesser plugins which I think are important for any config.

# Important Plugins used
Below is the list of some very important plugins which I think should be must for any neovim config.

| Name             | Description                                  |
|-------------------------|----------------------------------------------|
| nvim-tree.lua           | File tree                                    |
| Nvim-web-devicons       | Icons provider                               |
| nvim-treesitter         | Configure treesitter                         |
| bufferline.nvim         | Tab + bufferline plugin                      |
| blink.cmp               | Autocompletion                               |
| Luasnip & friendly snippets               | Snippets                                      |
| mason.nvim              | Download binaries of various lsps, formatters, debuggers, etc. |
| gitsigns.nvim                | Git-related features                         |
| comment.nvim            | Commenting                                   |
| telescope.nvim          | Fuzzy finder                                 |
| conform.nvim            | Formatter                                    |
