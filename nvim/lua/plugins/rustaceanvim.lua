return {
  {
    'mrcjkb/rustaceanvim',
    ft = { 'rust' },
    lazy = false,
    config = function()
      vim.g.rustaceanvim = function()
        local mylsp = require('config.lsp')
        return {
          server = {
            on_attach = mylsp.on_attach(mylsp.keymaps),
          },
        }
      end
    end,
  },
}
