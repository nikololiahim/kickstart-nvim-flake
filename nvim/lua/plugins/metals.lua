return {
  'scalameta/nvim-metals',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
  ft = { 'scala', 'sbt', 'java' },
  opts = function()
    local default_capabilities = vim.lsp.protocol.make_client_capabilities()
    local metals = require('metals')
    local capabilities = require('cmp_nvim_lsp').default_capabilities(default_capabilities)
    local metals_config = metals.bare_config()
    local personal_lspconfig = require('config.lsp')
    local metals_extended_keymaps = vim.tbl_deep_extend('force', personal_lspconfig.keymaps, {
      lsp_restart = {
        command = function()
          vim.notify('Restarting Metals LSP server...', vim.log.levels.INFO)
          metals.restart_metals()
        end,
      },
    })
    metals_config.capabilities = capabilities
    metals_config.on_attach = personal_lspconfig.on_attach(metals_extended_keymaps)
    metals_config.settings = {
      useGlobalExecutable = true,
      verboseCompilation = true,
      autoImportBuild = 'on',
      defaultBspToBuildTool = true,
      showImplicitArguments = true,
      showImplicitConversionsAndClasses = true,
      showInferredType = true,
      superMethodLensesEnabled = true,
      inlayHints = {
        hintsInPatternMatch = { enable = true },
        implicitArguments = { enable = true },
        implicitConversions = { enable = true },
        inferredTypes = { enable = true },
        typeParameters = { enable = true },
      },
      excludedPackages = {
        'akka.actor.typed.javadsl',
        'com.github.swagger.akka.javadsl',
      },
    }
    metals_config.init_options.statusBarProvider = 'off'
    vim.opt_global.shortmess:remove('F')
    return metals_config
  end,
  config = function(self, metals_config)
    local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = self.ft,
      callback = function()
        require('metals').initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
