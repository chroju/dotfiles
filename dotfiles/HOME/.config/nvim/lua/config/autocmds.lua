-- Auto commands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight cursorline only in current window
local cursorline_group = augroup('CursorLine', { clear = true })

autocmd('WinEnter', {
  group = cursorline_group,
  callback = function()
    vim.opt_local.cursorline = true
  end,
})

autocmd('WinLeave', {
  group = cursorline_group,
  callback = function()
    vim.opt_local.cursorline = false
  end,
})
