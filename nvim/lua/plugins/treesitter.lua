return {
  'nvim-treesitter/nvim-treesitter',
  build = function()
    require('nvim-treesitter.install').update({ with_sync = true })()
  end,
  config = function()
    local parser_install_dir = vim.fn.stdpath('cache') .. '/treesitter'
    vim.fn.mkdir(parser_install_dir, 'p')
    vim.opt.runtimepath:append(parser_install_dir)

    require('nvim-treesitter').setup({
      modules = {},
      ignore_install = {},
      ensure_installed = {},
      install_dir = parser_install_dir,
      auto_install = true,
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true, additional_vim_regex_highlighting = false },
    })

    -- https://github.com/nvim-lua/kickstart.nvim/pull/1657#issuecomment-3119533001
    ---@param buf integer
    ---@param language string
    ---@return boolean
    local function attach(buf, language)
      -- check if parser exists before starting highlighter
      if not vim.treesitter.language.add(language) then
        return false
      end
      vim.treesitter.start(buf, language)
      return true
    end

    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then
          return
        end
        if attach(buf, language) then
          return
        end
        -- attempt to start highlighter after installing missing language
        require('nvim-treesitter').install(language):await(function()
          attach(buf, language)
        end)
      end,
    })
  end,
}
