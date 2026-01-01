return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    {
      '~whynothugo/lsp_lines.nvim',
      config = function()
        -- Disable virtual_text since it's redundant due to lsp_lines.
        vim.diagnostic.config({ virtual_text = false })
        vim.diagnostic.config({ virtual_lines = true })
      end,
    },
    {
      'folke/lazydev.nvim',
      ft = 'lua', -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
  },
  config = function()
    local lspconfig = require('lspconfig')
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    local personal_lspconfig = require('config.lsp')

    local on_attach = personal_lspconfig.on_attach(personal_lspconfig.keymaps)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    lspconfig['nixd'].setup({
      on_init = function(client)
        local path = vim.fs.joinpath(client.root_dir, '.nixd.json')
        local contents = vim.secure.read(path)
        if contents == nil then
          vim.notify('Could not find .nixd.json in the current or parent directories', vim.log.levels.INFO)
          return true
        elseif type(contents) == 'boolean' then
          vim.notify('.nixd.json is a directory')
          return true
        else
          local nixd_settings = vim.json.decode(contents)
          if nixd_settings == nil then
            vim.notify('Error while loading nixd_settings from .nixd.json', vim.log.levels.ERROR)
            return true
          end
          client.config.settings['nixd'] = nixd_settings
          client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
          return true
        end
      end,
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        nixd = {
          formatting = {
            command = { 'nixfmt' },
          },
        },
      },
    })

    lspconfig['lua_ls'].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end,
}
