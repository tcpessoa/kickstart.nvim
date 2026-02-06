-- Options

local opt = vim.opt
local o = vim.o

-- Line numbers
opt.number = false
opt.relativenumber = false

-- Mouse
o.mouse = 'a'

-- Don't show mode (statusline handles it)
o.showmode = false

-- Clipboard (sync with OS)
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- Indentation
o.breakindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

-- Undo
o.undofile = true

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = true

-- UI
o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 10
o.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.inccommand = 'split'

-- Splits
o.splitright = true
o.splitbelow = true

-- Performance
o.updatetime = 250
o.timeoutlen = 300

-- Behavior
o.confirm = true
