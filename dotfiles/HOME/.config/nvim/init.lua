-- Neovim Configuration
-- Entry point for Neovim settings

-- Set encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = { 'ucs-bom', 'utf-8', 'cp932', 'sjis', 'euc-jp', 'iso-2022-jp' }
vim.opt.fileformats = { 'unix', 'dos', 'mac' }

-- Load basic configuration
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- Load plugin system
require('plugins.init')
