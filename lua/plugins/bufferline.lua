return {
  'akinsho/bufferline.nvim',
  event = 'BufReadPre',
  config = function()
    require('bufferline').setup {
      options = {
        get_element_icon = function(element)
          local icon, hl = MiniIcons.get('file', element.path)
          return icon, hl
        end,
        offsets = { { filetype = 'NvimTree', text = 'File Explorer', padding = 1 } },
        buffer_close_icon = 'x',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        show_tab_indicators = true,
        enforce_regular_tabs = false,
        view = 'multiwindow',
        show_buffer_close_icons = true,
        show_close_icon = false,
      },
    }
  end,
}
