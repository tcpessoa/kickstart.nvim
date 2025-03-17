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

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'TypeScript Tools Commands',
          finder = require('telescope.finders').new_table {
            results = ts_commands,
          },
          sorter = require('telescope.config').values.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            local actions = require 'telescope.actions'
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry()

              -- Make sure we're in a TypeScript/JavaScript buffer where the commands will work
              local bufnr = vim.api.nvim_get_current_buf()
              local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

              if vim.tbl_contains({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }, ft) then
                vim.cmd(selection.value)
              else
                vim.notify('TypeScript Tools commands only work in TypeScript/JavaScript files', vim.log.levels.WARN)
              end
            end)
            return true
          end,
        })
        :find()
    end, {})

    -- vim.keymap.set('n', '<leader>ts', '<cmd>TSTools<cr>', { desc = 'TypeScript [T]ool[S]' })
  end,
}
