-- Autocommands

-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Format JSON/YAML with jq/yq
local function parse_error(output, filetype)
  local file = vim.fn.expand '%:p'
  if filetype == 'json' then
    local line, col = output:match 'line (%d+), column (%d+)'
    if line and col then
      return { { filename = file, lnum = tonumber(line), col = tonumber(col), text = output } }
    end
  elseif filetype == 'yaml' or filetype == 'yml' then
    local line = output:match 'line (%d+):'
    if line then
      return { { filename = file, lnum = tonumber(line), col = 1, text = output } }
    end
  end
  return { { filename = file, lnum = 1, col = 1, text = output } }
end

local function format_buffer()
  local filetype = vim.bo.filetype
  local cmd, args
  if filetype == 'json' then
    cmd = 'jq'
    args = '.'
  elseif filetype == 'yaml' or filetype == 'yml' then
    cmd = 'yq'
    args = 'eval .'
  else
    vim.notify('Unsupported filetype for formatting', vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  local output = vim.fn.system(string.format('%s %s', cmd, args), content)

  if vim.v.shell_error ~= 0 then
    local qf_entries = parse_error(output, filetype)
    vim.fn.setqflist({}, ' ', {
      title = 'Formatting Error',
      items = qf_entries,
    })
    vim.cmd 'copen'
    vim.notify('Formatting failed. See quickfix list for details.', vim.log.levels.ERROR)
  else
    local formatted_lines = vim.split(output, '\n')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_lines)
    vim.notify('Formatting successful', vim.log.levels.INFO)
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'yaml', 'yml', 'json' },
  callback = function(event)
    vim.keymap.set('n', '<leader>lf', format_buffer, {
      buffer = event.buf,
      desc = '[F]ormat file with yq/jq',
    })
  end,
})
