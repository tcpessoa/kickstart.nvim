return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  opts = {
    -- add any opts here
    provider = 'claude',
  },
  -- if you want to download pre-built binary, then pass source=false. Make sure to follow instruction above.
  -- Also note that downloading prebuilt binary is a lot faster comparing to compiling from source.
  build = 'make',
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- Make sure to setup it properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
