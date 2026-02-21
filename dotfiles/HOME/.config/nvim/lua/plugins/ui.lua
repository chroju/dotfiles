-- UI plugins

return {
  -- Nord colorscheme
  {
    'shaunsingh/nord.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme nord')

      -- Set nvim-tree background after colorscheme loads
      local bg_color = '#242933'
      vim.api.nvim_set_hl(0, 'NvimTreeNormal', { bg = bg_color })
      vim.api.nvim_set_hl(0, 'NvimTreeNormalNC', { bg = bg_color })
      vim.api.nvim_set_hl(0, 'NvimTreeEndOfBuffer', { bg = bg_color, fg = bg_color })
      vim.api.nvim_set_hl(0, 'NvimTreeWinSeparator', { bg = bg_color, fg = bg_color })

      -- Override specific nvim-tree highlight groups to use the background
      vim.api.nvim_set_hl(0, 'NvimTreeFolderName', { link = 'Directory' })
      vim.api.nvim_set_hl(0, 'NvimTreeOpenedFolderName', { link = 'Directory' })
      vim.api.nvim_set_hl(0, 'NvimTreeEmptyFolderName', { link = 'Directory' })
      vim.api.nvim_set_hl(0, 'NvimTreeRootFolder', { link = 'Directory' })

      -- 文字列の色を見やすくする (frost cyan)
      vim.api.nvim_set_hl(0, 'String', { fg = '#88C0D0' })
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'nord',
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '.',
      },
      scope = {
        enabled = false,
      },
    },
  },
}
