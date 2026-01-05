-- Editor enhancement plugins

return {
  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
          },
        },
      })

      -- Keymaps
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', 'bb', builtin.buffers, { desc = 'Telescope buffers' })
    end,
  },

  -- File explorer (sidebar)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup({
        view = {
          width = 30,
          side = 'left',
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
          ignore = false,
        },
        tab = {
          sync = {
            open = true,
            close = true,
          },
        },
        actions = {
          open_file = {
            quit_on_open = false,
            window_picker = {
              enable = false,
            },
          },
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')

          local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- Custom mapping: Enter to open in new tab
          vim.keymap.set('n', '<CR>', function()
            local node = api.tree.get_node_under_cursor()
            if node.type == 'file' then
              api.node.open.tab(node)
            else
              api.node.open.edit()
            end
          end, opts('Open in new tab or expand'))

          -- Keep 'o' for opening in current window
          vim.keymap.set('n', 'o', api.node.open.edit, opts('Open in current window'))
        end,
      })

      -- Keymaps
      vim.keymap.set('n', ',f', '<Cmd>NvimTreeToggle<CR>', { noremap = true, silent = true, desc = 'Toggle file tree' })

      -- Set background color for nvim-tree
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'NvimTree',
        callback = function()
          vim.cmd('setlocal winhighlight=Normal:NvimTreeNormal,NormalNC:NvimTreeNormalNC,EndOfBuffer:NvimTreeEndOfBuffer')
        end,
      })
    end,
  },

  -- Treesitter for syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')
      ts.setup({
        ensure_install = { 'lua', 'vim', 'vimdoc', 'go', 'terraform', 'hcl', 'bash' },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Surround operations
  {
    'tpope/vim-surround',
  },

  -- Comment operations
  {
    'numToStr/Comment.nvim',
    opts = {},
  },

  -- Switch true/false, etc.
  {
    'AndrewRadev/switch.vim',
    config = function()
      vim.keymap.set('n', '!', '<Cmd>Switch<CR>', { noremap = true, silent = true })
    end,
  },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
}
