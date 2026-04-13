return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup {}

    -- Install parsers (no-op if already installed)
    require('nvim-treesitter').install {
      'bash',
      'c',
      'cpp',
      'css',
      'diff',
      'dockerfile',
      'go',
      'html',
      'javascript',
      'jsdoc',
      'json',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'ruby',
      'sql',
      'toml',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'xml',
      'yaml',
    }

    -- Treesitter highlighting is now built into Neovim.
    -- Enable it via FileType autocmd.
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- Treesitter-based indentation
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'ruby' },
      callback = function()
        vim.bo.indentexpr = ''
      end,
    })
  end,
}
