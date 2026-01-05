-- Key mappings

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Save file
keymap('n', ',,', '<Cmd>update<CR>', opts)

-- Move to line end/start
keymap({ 'n', 'v' }, '<Space>l', '$', opts)
keymap({ 'n', 'v' }, '<Space>h', '^', opts)

-- Yank to line end
keymap('n', 'Y', 'y$', opts)

-- Display line movement (swap j/k with gj/gk)
keymap({ 'n', 'v' }, 'j', 'gj', opts)
keymap({ 'n', 'v' }, 'k', 'gk', opts)
keymap({ 'n', 'v' }, 'gj', 'j', opts)
keymap({ 'n', 'v' }, 'gk', 'k', opts)

-- Tab operations
keymap('n', 'tc', '<Cmd>tabnew<CR>', opts)
keymap('n', 'tx', '<Cmd>tabclose<CR>', opts)

-- Edit init.lua
keymap('n', '<Space><Space>', '<Cmd>edit $MYVIMRC<CR>', opts)

-- Reload configuration
keymap('n', '<F5>', '<Cmd>source $MYVIMRC<CR>', opts)

-- Save with sudo
keymap('n', '<Space>,,', '<Cmd>w !sudo tee % > /dev/null<CR><Cmd>edit!<CR>', opts)

-- Change to current file directory
keymap('n', ',d', '<Cmd>lcd %:p:h<CR>', opts)

-- Buffer list (will be overridden by Telescope)
keymap('n', 'bb', '<Cmd>buffers<CR>', opts)

-- File tree (will be overridden by nvim-tree)
keymap('n', ',f', '<Cmd>Explore<CR>', opts)
