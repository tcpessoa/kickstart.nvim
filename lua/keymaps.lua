-- NeoTree
-- Toggle default NeoTree on the right
vim.keymap.set('n', '<leader>o', '<cmd>Neotree toggle position=right<cr>', { desc = 'Toggle Explorer' })

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

-- Trouble
vim.keymap.set('n', '<leader>xx', function()
  require('trouble').toggle()
end, { desc = 'Trouble' })
vim.keymap.set('n', '<leader>xw', function()
  require('trouble').toggle 'workspace_diagnostics'
end, { desc = 'Trouble Workspace' })
vim.keymap.set('n', '<leader>xd', function()
  require('trouble').toggle 'document_diagnostics'
end, { desc = 'Trouble Document' })
vim.keymap.set('n', '<leader>xq', function()
  require('trouble').toggle 'quickfix'
end, { desc = 'Trouble Quickfix' })
vim.keymap.set('n', '<leader>xl', function()
  require('trouble').toggle 'loclist'
end, { desc = 'Trouble Loclist' })
vim.keymap.set('n', 'gR', function()
  require('trouble').toggle 'lsp_references'
end, { desc = 'Trouble LSP References' })
