-- Basic editor options

local opt = vim.opt

-- Line numbers
opt.number = true

-- Indentation
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Search
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true

-- UI
opt.cursorline = true
opt.fillchars = { vert = " " }
opt.scrolloff = 3
opt.visualbell = true
opt.errorbells = false
opt.showmatch = true
opt.matchtime = 1

-- Clipboard
opt.clipboard:append({ 'unnamed', 'unnamedplus' })

-- Backup and swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Behavior
opt.hidden = true
opt.wildmenu = true
opt.wildmode = { 'list:longest', 'full' }
