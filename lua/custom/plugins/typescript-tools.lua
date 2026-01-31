return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = {},
  config = function()
    require('typescript-tools').setup {}

    vim.api.nvim_create_user_command('TSTools', function()
      local ts_commands = {
        'TSToolsAddMissingImports',
        'TSToolsFileReferences',
        'TSToolsGoToSourceDefinition',
        'TSToolsOrganizeImports',
        'TSToolsRemoveUnused',
        'TSToolsRemoveUnusedImports',
        'TSToolsRenameFile',
        'TSToolsSortImports',
      }

      local items = {}
      for _, cmd in ipairs(ts_commands) do
        table.insert(items, { text = cmd, cmd = cmd })
      end

      Snacks.picker {
        prompt = 'TypeScript Tools Commands',
        items = items,
        format = function(item)
          return { { item.text, 'Normal' } }
        end,
        confirm = function(picker, item)
          picker:close()
          if not item then
            return
          end

          -- Make sure we're in a TypeScript/JavaScript buffer where the commands will work
          local bufnr = vim.api.nvim_get_current_buf()
          local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

          if vim.tbl_contains({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }, ft) then
            vim.cmd(item.cmd)
          else
            vim.notify('TypeScript Tools commands only work in TypeScript/JavaScript files', vim.log.levels.WARN)
          end
        end,
      }
    end, {})

    vim.keymap.set('n', '<leader>ts', '<cmd>TSTools<cr>', { desc = '[T]ype[S]cript Tools' })
    vim.keymap.set('n', '<leader>tf', '<cmd>TSToolsRenameFile sync<cr>', { desc = 'TypeScript Rename [F]ile' })
  end,
}
