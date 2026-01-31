return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    -- dashboard = { enabled = true }, -- startup dashboard
    -- explorer = { enabled = true }, -- file explorer
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = { enabled = true },
    -- quickfile = { enabled = true }, -- load fast when doing nvim some_file, before loading plugins
    scope = { enabled = true },
    -- scroll = { enabled = true }, -- smooth scrolling
    -- statuscolumn = { enabled = true },
    -- words = { enabled = true }, -- quickly navigate between LSP references (words)
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      },
    },
  },
  keys = {
    -- Search (matching old Telescope keymaps)
    {
      '<leader>sa',
      function()
        Snacks.picker.smart()
      end,
      desc = '[S]earch Sm[a]rt',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = '[S]earch current [W]ord',
      mode = { 'n', 'x' },
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>sn',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = '[S]earch [N]eovim files',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = '[S]earch Recent Files ("." for repeat)',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[ ] Find existing buffers',
    },
    -- Git
    {
      '<leader>gl',
      function()
        Snacks.lazygit()
      end,
      desc = '[G]it [L]azygit',
    },
    {
      '<leader>gB',
      function()
        Snacks.gitbrowse()
      end,
      desc = '[G]it [B]rowse',
      mode = { 'n', 'v' },
    },
    -- Other
    {
      '<leader>z',
      function()
        Snacks.zen()
      end,
      desc = 'Toggle [Z]en Mode',
    },
    {
      '<leader>Z',
      function()
        Snacks.zen.zoom()
      end,
      desc = 'Toggle [Z]oom',
    },
    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>S',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = '[B]uffer [D]elete',
    },
    {
      '<leader>cR',
      function()
        Snacks.rename.rename_file()
      end,
      desc = '[C]ode [R]ename File',
    },
    {
      '<leader>un',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<leader>tt',
      function()
        Snacks.terminal()
      end,
      desc = '[T]oggle [T]erminal',
    },
    -- Words navigation is commented out since you disabled words
    -- {
    --   '<leader>m]]',
    --   function()
    --     Snacks.words.jump(vim.v.count1)
    --   end,
    --   desc = 'Next Reference',
    --   mode = { 'n', 't' },
    -- },
    -- {
    --   '<leader>m[[',
    --   function()
    --     Snacks.words.jump(-vim.v.count1)
    --   end,
    --   desc = 'Prev Reference',
    --   mode = { 'n', 't' },
    -- },
    {
      '<leader>mN',
      desc = 'Neovim News',
      function()
        Snacks.win {
          file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = 'yes',
            statuscolumn = ' ',
            conceallevel = 3,
          },
        }
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>mus'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>muw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>muL'
        Snacks.toggle.diagnostics():map '<leader>mud'
        Snacks.toggle.line_number():map '<leader>mul'
        Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>muc'
        Snacks.toggle.treesitter():map '<leader>muT'
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>mub'
        Snacks.toggle.inlay_hints():map '<leader>muh'
        Snacks.toggle.indent():map '<leader>mug'
        Snacks.toggle.dim():map '<leader>muD'
      end,
    })
  end,
}
