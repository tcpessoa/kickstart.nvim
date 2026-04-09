return {
  'sindrets/diffview.nvim',
  opts = {
    enhanced_diff_hl = true,
    view = {
      merge_tool = { layout = 'diff4_mixed' },
    },
    file_panel = {
      listing_style = 'tree',
      win_config = { width = 35 },
    },
  },
}
