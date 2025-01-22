# Neovim Configuration Conventions

A simple set of conventions for Neovim configuration based on kickstart.nvim principles.


## Plugin Management

- Use lazy.nvim for plugin management
- Keep plugin specs simple and clear:
```lua
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
}
```

## Coding Style

- Use two spaces for indentation
- Prefer local variables
- Keep config files under 100 lines when possible
- Add empty line between plugin specs for readability

## Comments

- Comment only when necessary
- Document non-obvious keymaps
- Maintain simple headers for sections:
```lua
-- Basic settings
vim.opt.number = true

-- Key mappings
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
```

## Git Workflow

- Keep commits small and focused
- Use descriptive commit messages:
  - "add: telescope config"
  - "fix: lsp keybindings"
  - "update: plugin versions"

## Custom Additions

When adding your own configurations:
1. Create new files in `lua/custom/`
2. Require them in `init.lua`
3. Follow kickstart.nvim's minimalist approach
