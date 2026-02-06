-- Keymaps

local map = vim.keymap.set

-- General
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- File explorer (mini.files)
map('n', '<leader>o', function()
  local MiniFiles = require 'mini.files'
  local _ = MiniFiles.close() or MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
  vim.defer_fn(function()
    MiniFiles.reveal_cwd()
  end, 30)
end, { desc = 'Toggle Explorer (current file)' })

-- Standard operations
map('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save' })
map('n', '<leader>q', '<cmd>confirm q<cr>', { desc = 'Quit' })
map('n', '<leader>Q', '<cmd>confirm qall<cr>', { desc = 'Quit all' })
map('n', '<leader>n', '<cmd>enew<cr>', { desc = 'New File' })
map('n', '|', '<cmd>vsplit<cr>', { desc = 'Vertical Split' })
map('n', '\\', '<cmd>split<cr>', { desc = 'Horizontal Split' })

-- Package manager
map('n', '<leader>pm', '<cmd>Mason<cr>', { desc = 'Mason Installer' })

-- Buffers
map('n', 'L', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
map('n', 'H', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
map('n', '<leader>bc', '<cmd>bd<cr>', { desc = 'Close [C]urrent buffer' })
map('n', '<leader>bw', '<cmd>BufferLineCloseOthers<cr>', { desc = 'Close all others' })
map('n', '<leader>bl', '<cmd>BufferLineCloseRight<cr>', { desc = 'Close buffers to the right' })
map('n', '<leader>bh', '<cmd>BufferLineCloseLeft<cr>', { desc = 'Close buffers to the left' })
map('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = 'Toggle [P]in buffer' })

-- Diagnostics
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show line [E]rrors' })
map('n', '<leader>E', vim.diagnostic.setloclist, { desc = 'Send diagnostics to loclist' })

-- Utils (console.log, node REPL, etc.)
map('n', '<leader>lc', function()
  require('utils').insert_snippet('clog', false)
end, { desc = '[C]onsole.log this word' })
map('n', '<leader>lj', function()
  require('utils').insert_snippet('clogo', false)
end, { desc = 'Console.log with [J]SON.stringify' })
map('v', '<leader>lc', function()
  require('utils').insert_snippet('clog', true)
end, { desc = '[C]onsole.log this word' })
map('v', '<leader>lj', function()
  require('utils').insert_snippet('clogo', true)
end, { desc = 'Console.log with [J]SON.stringify' })
map('n', '<leader>lr', require('utils').fzf_run, { desc = '[R]un a script' })
map('n', '<leader>ln', function()
  require('utils').run_node(false)
end, { desc = 'Run in [n]ode' })
map('v', '<leader>ln', function()
  require('utils').run_node(true)
end, { desc = 'Run in [n]ode' })
map('v', '<leader>lo', function()
  require('utils').run_node_with_obj(true)
end, { desc = 'Analyze [o]bject in node' })
map('v', '<leader>le', require('utils').escape_for_regex, { desc = '[E]scape for regex' })
map('n', '<leader>lg', require('utils').open_commit_files, { desc = 'Open [g]it commit files' })
map('n', '<leader>lt', require('utils').create_or_toggle_checkbox, { desc = '[T]oggle checkbox' })

-- Copy utils
map('n', '<leader>yf', function()
  local full_path = vim.fn.expand '%:p'
  local cwd = vim.fn.getcwd()
  local rel_path = full_path:sub(#cwd + 2)
  vim.fn.setreg('+', rel_path)
  print('Copied: ' .. rel_path)
end, { desc = 'Copy relative file path to clipboard' })
map('n', '<leader>yb', '<cmd>let @+ = expand("%:t:r")<cr>', { desc = 'Copy file basename to clipboard' })

-- Copilot toggle
map('n', '<leader>tc', function()
  if vim.g.copilot_enabled == nil then
    vim.g.copilot_enabled = true
  end
  if vim.g.copilot_enabled then
    vim.cmd 'Copilot disable'
    vim.notify('Copilot disabled', vim.log.levels.INFO)
  else
    vim.cmd 'Copilot enable'
    vim.notify('Copilot enabled', vim.log.levels.INFO)
  end
  vim.g.copilot_enabled = not vim.g.copilot_enabled
end, { desc = '[T]oggle [C]opilot' })

-- Diffview
map('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'DiffviewOpen' })
map('n', '<leader>gc', '<cmd>DiffviewClose<cr>', { desc = 'DiffviewClose' })
map('n', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = 'DiffviewFileHistory' })
map('n', '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', { desc = 'DiffviewFileHistory (current file)' })
map('n', '<leader>gr', '<cmd>DiffviewRefresh<cr>', { desc = 'DiffviewRefresh' })
map('n', '<leader>gt', '<cmd>DiffviewToggleFiles<cr>', { desc = 'DiffviewToggleFiles' })

-- TypeScript
map('n', '<leader>tp', function()
  require('utils').typecheck 'project'
end, { desc = '[T]ypecheck [P]roject' })
map('n', '<leader>tF', function()
  require('utils').typecheck 'file'
end, { desc = '[T]ypecheck [F]ile' })

-- Tests (auto-detects vitest/jest/bun)
map('n', '<leader>Ta', function()
  require('utils').run_tests 'all'
end, { desc = '[T]est [A]ll' })
map('n', '<leader>Tf', function()
  require('utils').run_tests 'file'
end, { desc = '[T]est [F]ile' })
map('n', '<leader>Ts', function()
  require('utils').run_tests_picker()
end, { desc = '[T]est [S]elect runner' })
