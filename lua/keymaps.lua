-- NeoTree
-- Toggle default NeoTree on the right
vim.keymap.set('n', '<leader>o', '<cmd>Neotree toggle<cr>', { desc = 'Toggle Explorer' })

-- Open NeoTree in netrw mode, focusing on the current directory
vim.keymap.set('n', '<leader>O', '<cmd>Neotree show position=current<cr>', { desc = 'Open Explorer at current directory' })

-- Package Manager (Mason)
vim.keymap.set('n', '<leader>pm', '<cmd>Mason<cr>', { desc = 'Mason Installer' })
vim.keymap.set('n', '<leader>pM', '<cmd>MasonUpdateAll<cr>', { desc = 'Mason Update' })

-- Standard Operations
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>confirm q<cr>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>Q', '<cmd>confirm qall<cr>', { desc = 'Quit all' })
vim.keymap.set('n', '<leader>n', '<cmd>enew<cr>', { desc = 'New File' })
vim.keymap.set('n', '<C-s>', '<cmd>w!<cr>', { desc = 'Force write' })
vim.keymap.set('n', '<C-q>', '<cmd>qa!<cr>', { desc = 'Force quit' })
vim.keymap.set('n', '|', '<cmd>vsplit<cr>', { desc = 'Vertical Split' })
vim.keymap.set('n', '\\', '<cmd>split<cr>', { desc = 'Horizontal Split' })

-- Buffer operations

-- Go to the next buffer
vim.keymap.set('n', 'L', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })

-- Go to the previous buffer
vim.keymap.set('n', 'H', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })

-- Close current buffer
vim.keymap.set('n', '<leader>bc', '<cmd>bd<cr>', { desc = 'Close [C]urrent buffer' })

-- Close all other buffers
vim.keymap.set('n', '<leader>bw', '<cmd>BufferLineCloseOthers<cr>', { desc = 'Close all others' })

-- Pin/unpin a buffer (toggle pin)
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = 'Toggle [P]in buffer' })

-- Diagnostics
vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float(0, { scope = "line" })<cr>', { desc = 'Show [E]rrors' })

-- Trouble
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Trouble' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Symbols (Trouble)' })
-- gR
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })

-- Keymap to search for modified files in a Git repo using Telescope
vim.api.nvim_set_keymap('n', '<leader>sm', "<cmd>lua require('telescope.builtin').git_status()<CR>", { desc = '[S]earch git [m]odified files' })

-- Utils
vim.api.nvim_set_keymap('n', '<leader>lc', ":lua require('utils').insert_snippet('clog', false)<CR>", { desc = '[C]onsole.log this word' })
vim.api.nvim_set_keymap('n', '<leader>lj', ":lua require('utils').insert_snippet('clogo', false)<CR>", { desc = 'Console.log with [J]SON.stringify' })
vim.api.nvim_set_keymap('v', '<leader>lc', ":<C-u>lua require('utils').insert_snippet('clog', true)<CR>", { desc = '[C]onsole.log this word' })
vim.api.nvim_set_keymap('v', '<leader>lj', ":<C-u>lua require('utils').insert_snippet('clogo', true)<CR>", { desc = 'Console.log with [J]SON.stringify' })

vim.keymap.set('n', '<leader>lr', require('utils').fzf_run, { desc = '[R]un a script' })
vim.keymap.set('n', '<leader>ln', function()
  require('utils').run_node(false)
end, { desc = 'Run in [n]ode' })
vim.keymap.set('v', '<leader>ln', function()
  require('utils').run_node(true)
end, { desc = 'Run in [n]ode' })
vim.keymap.set('v', '<leader>lo', function()
  require('utils').run_node_with_obj(true)
end, { desc = 'Analyze [o]bject in node' })
vim.keymap.set('v', '<leader>le', require('utils').escape_for_regex, { desc = '[E]scape for regex' })

vim.keymap.set('n', '<leader>lg', require('utils').open_commit_files, { desc = 'Open [g]it commit files' })

vim.keymap.set('n', '<leader>lt', require('utils').create_or_toggle_checkbox, { desc = '[T]oggle checkbox' })

vim.keymap.set('n', '<leader>ta', function()
  _G.toggle_autocomplete()
end, { noremap = true, desc = '[t]oggle [a]utocompletion' })

-- COPILOT
_G.toggle_copilot = function()
  local enabled = vim.g.copilot_enabled or false

  if enabled then
    vim.cmd 'Copilot disable'
    vim.notify('Copilot disabled', vim.log.levels.INFO)
  else
    vim.cmd 'Copilot enable'
    vim.notify('Copilot enabled', vim.log.levels.INFO)
  end

  vim.g.copilot_enabled = not enabled
end

if vim.g.copilot_enabled == nil then
  vim.g.copilot_enabled = true
end

vim.keymap.set('n', '<leader>tc', function()
  _G.toggle_copilot()
end, { noremap = true, desc = '[t]oggle [c]opilot' })

-- Diffview
vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'DiffviewOpen' })
vim.keymap.set('n', '<leader>gc', '<cmd>DiffviewClose<cr>', { desc = 'DiffviewClose' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = 'DiffviewFileHistory' })
vim.keymap.set('n', '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', { desc = 'DiffviewFileHistory (current file)' })
vim.keymap.set('n', '<leader>gr', '<cmd>DiffviewRefresh<cr>', { desc = 'DiffviewRefresh' })
vim.keymap.set('n', '<leader>gt', '<cmd>DiffviewToggleFiles<cr>', { desc = 'DiffviewToggleFiles' })
