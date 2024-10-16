return {
  'nvim-treesitter/nvim-treesitter',
  build = function()
    require('nvim-treesitter.install').update({ with_sync = true })()
  end,
  config = function()
    local parser_install_dir = vim.fn.stdpath('cache') .. '/treesitter'
    vim.fn.mkdir(parser_install_dir, 'p')
    vim.opt.runtimepath:append(parser_install_dir)

    require('nvim-treesitter.configs').setup({
      modules = {},
      ignore_install = {},
      ensure_installed = {},
      parser_install_dir = parser_install_dir,
      auto_install = true,
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true, additional_vim_regex_highlighting = false },
    })
  end,
}
