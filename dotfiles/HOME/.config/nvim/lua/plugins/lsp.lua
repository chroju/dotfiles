-- LSP configuration

return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf, noremap = true, silent = true }

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<Space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<Space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<Space>f', function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })

      -- Capabilities for nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Go
      vim.lsp.config.gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.work', 'go.mod', '.git' },
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      }

      -- Terraform
      vim.lsp.config.terraformls = {
        cmd = { 'terraform-ls', 'serve' },
        filetypes = { 'terraform', 'terraform-vars', 'hcl' },
        root_markers = { '.terraform', '.git' },
        capabilities = capabilities,
      }

      -- Bash
      vim.lsp.config.bashls = {
        cmd = { 'bash-language-server', 'start' },
        filetypes = { 'sh', 'bash' },
        root_markers = { '.git' },
        capabilities = capabilities,
      }

      -- Enable LSP servers
      vim.lsp.enable({ 'gopls', 'terraformls', 'bashls' })

      -- Diagnostic settings
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}
