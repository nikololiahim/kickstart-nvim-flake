return {
  'scalameta/nvim-metals',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/cmp_nvim_lsp',
  },
  ft = { 'scala', 'sbt', 'java' },
  opts = function()
    local default_capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('cmp_nvim_lsp').default_capabilities(default_capabilities)
    local metals_config = require('metals').bare_config()
    metals_config.capabilities = capabilities
    metals_config.on_attach = require('config.lsp').on_attach
    metals_config.settings = {
      metalsBinaryPath = vim.g.NVIM_METALS_METALS_EXECUTABLE,
      sbtScript = vim.g.NVIM_METALS_SBT_EXECUTABLE,
      scalaCliLauncher = vim.g.NVIM_METALS_SCALA_CLI_EXECUTABLE,
      javaHome = vim.g.NVIM_METALS_JAVA_HOME,
      autoImportBuild = 'off',
      defaultBspToBuildTool = true,
      showImplicitArguments = true,
      showImplicitConversionsAndClasses = true,
      showInferredType = true,
      superMethodLensesEnabled = true,
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
