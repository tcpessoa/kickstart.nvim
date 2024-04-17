-- NeoTree
vim.keymap.set('n', '<leader>o', '<cmd>Neotree toggle<cr>', { desc = 'Toggle Explorer' })

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
vim.keymap.set('n', '<leader>bcc', '<cmd>bd<cr>', { desc = 'Close current buffer' })

-- Close all other buffers
vim.keymap.set('n', '<leader>bco', '<cmd>BufferLineCloseOthers<cr>', { desc = 'Close all others' })

-- Pin/unpin a buffer (toggle pin)
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = 'Toggle pin buffer' })
