return {
  'pmizio/typescript-tools.nvim',
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = {},
  config = function()
    local utils = require 'utils'

    -- typescript-tools needs the classic `tsserver` binary, which TS 7 dropped
    -- (it's the native Go rewrite; setting it up there throws). Only enable it
    -- for TS <= 6 projects; TS 7 gets the native server below.
    if utils.ts_major(vim.api.nvim_buf_get_name(0)) ~= 7 then
      require('typescript-tools').setup {}
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('tsgo-native', { clear = true }),
      pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      callback = function(args)
        if utils.ts_major(vim.api.nvim_buf_get_name(args.buf)) == 7 then
          utils.start_tsgo(args.buf)
        end
      end,
    })

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
            if vim.fn.exists(':' .. item.cmd) == 2 then
              vim.cmd(item.cmd)
            else
              vim.notify(item.cmd .. ' is not available (typescript-tools is disabled in TS 7 projects)', vim.log.levels.WARN)
            end
          else
            vim.notify('TypeScript Tools commands only work in TypeScript/JavaScript files', vim.log.levels.WARN)
          end
        end,
      }
    end, {})

    vim.keymap.set('n', '<leader>ts', '<cmd>TSTools<cr>', { desc = '[T]ype[S]cript Tools' })
    vim.keymap.set('n', '<leader>tf', function()
      if vim.fn.exists ':TSToolsRenameFile' == 2 then
        vim.cmd 'TSToolsRenameFile sync'
      else
        vim.notify('typescript-tools is disabled in TS 7 projects', vim.log.levels.WARN)
      end
    end, { desc = 'TypeScript Rename [F]ile' })
  end,
}
