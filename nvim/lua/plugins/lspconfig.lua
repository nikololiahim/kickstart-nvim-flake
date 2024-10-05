return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    local lspconfig = require('lspconfig')
    local cmp_nvim_lsp = require('cmp_nvim_lsp')

    local on_attach = require('config.lsp').on_attach
    local capabilities = cmp_nvim_lsp.default_capabilities()

    lspconfig['nixd'].setup {
      on_init = function(client)
        local path = vim.fs.joinpath(client.root_dir, '.nixd.json')
        local contents = vim.secure.read(path)
        if contents == nil then
          vim.notify('Could not find .nixd.json in the current or parent directories', vim.log.levels.INFO)
          return true
        end
        local nixd_settings = vim.json.decode(contents)
        if nixd_settings == nil then
          vim.notify('Error while loading nixd_settings from .nixd.json', vim.log.levels.ERROR)
          return true
        end
        client.config.settings['nixd'] = nixd_settings
        client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
        return true
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
    }

    lspconfig['lua_ls'].setup {
      capabilities = capabilities,
      on_attach = on_attach,
    }
  end,
}