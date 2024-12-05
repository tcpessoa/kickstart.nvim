local utils = require 'utils'

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

--[[
  %bd = delete all buffers.
  e# = open the last buffer for editing (Which Is the buffer I'm working on).
  bd# to delete the [No Name] buffer that gets created when you use %bd.
  '" = keep my cursor position
--]]
-- vim.keymap.set('n', '<leader>bC', '<cmd>%bd|e#|bd#<cr>|\'"<cr>', { desc = 'Close all buffers except this one' })

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

-- Copilot Chat
vim.keymap.set({ 'n', 'v' }, '<leader>cch', function()
  local actions = require 'CopilotChat.actions'
  require('CopilotChat.integrations.telescope').pick(actions.help_actions())
end, { desc = 'CopilotChat - Help actions' })

vim.keymap.set({ 'n', 'v' }, '<leader>ccp', function()
  local actions = require 'CopilotChat.actions'
  require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
end, { desc = 'CopilotChat - Prompt actions' })

-- Utils
vim.api.nvim_set_keymap('n', '<leader>lc', ":lua require('utils').insert_snippet('clog', false)<CR>", { desc = 'console.log this word' })
vim.api.nvim_set_keymap('n', '<leader>lj', ":lua require('utils').insert_snippet('clogo', false)<CR>", { desc = 'console.log this object' })
vim.api.nvim_set_keymap('v', '<leader>lc', ":<C-u>lua require('utils').insert_snippet('clog', true)<CR>", { desc = 'console.log this word' })
vim.api.nvim_set_keymap('v', '<leader>lj', ":<C-u>lua require('utils').insert_snippet('clogo', true)<CR>", { desc = 'console.log this object' })

vim.keymap.set('n', '<leader>lr', require('utils').fzf_run, { desc = 'Run a script' })
vim.keymap.set('n', '<leader>ln', function()
  require('utils').run_node(false)
end, { desc = 'Run line in Node' })
vim.keymap.set('v', '<leader>ln', function()
  require('utils').run_node(true)
end, { desc = 'Run selection in Node' })
vim.keymap.set('v', '<leader>lo', function()
  require('utils').run_node_with_obj(true)
end, { desc = 'Analyze object in Node' })
vim.keymap.set('v', '<leader>le', require('utils').escape_for_regex, { desc = 'Escape for regex' })

vim.keymap.set('n', '<leader>lg', require('utils').open_commit_files, { desc = '[G]it commit files' })
