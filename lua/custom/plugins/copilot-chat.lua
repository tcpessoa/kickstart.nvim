return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim' },
    },
    opts = {
      mappings = {
        complete = {
          detail = 'Use <C-y> to insert the selected completion',
          insert = 'C-y',
        },
        close = {
          normal = 'q',
          insert = '<C-c>',
        },
        reset = {
          normal = '<C-x>',
          insert = '<C-x>',
        },
        submit_prompt = {
          normal = '<CR>',
          insert = '<C-m>',
        },
        accept_diff = {
          normal = '<C-i>',
          insert = '<C-i>',
        },
        yank_diff = {
          normal = 'gy',
        },
        show_diff = {
          normal = 'gd',
        },
        show_info = {
          normal = 'gp',
        },
        show_context = {
          normal = 'gs',
        },
      },
    },
  },
}
