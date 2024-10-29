return {
  'echasnovski/mini.nvim',
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesWindowUpdate',
      callback = function(args)
        local win_id = args.data.win_id
        local max_lines = vim.o.lines
        local config = vim.api.nvim_win_get_config(win_id)
        config.height = max_lines - 3
        config.border = 'double'
        config.title_pos = 'left'
        vim.api.nvim_win_set_config(win_id, config)
      end,
    })

    local files = require('mini.files')

    vim.keymap.set('n', '-', function()
      files.open(vim.api.nvim_buf_get_name(0), true)
    end, { noremap = false, silent = true, desc = 'Open mini.files (Directory of Current File)' })

    vim.keymap.set('n', '<leader>fm', function()
      files.open(vim.uv.cwd(), true)
    end, { desc = 'Open mini.files (cwd)', silent = true, noremap = true })
  end,

  config = function()
    local max_width = vim.o.columns
    local small_width = math.floor(max_width / 4)
    local large_width = max_width - small_width * 2 - 6

    -- ================== mini.icons ==================
    require('mini.icons').setup({})
    -- ================== mini.icons ==================

    -- ================== mini.pairs ==================
    require('mini.pairs').setup({})
    -- ================== mini.pairs ==================

    -- ================== mini.files ==================
    require('mini.files').setup({

      mappings = {
        go_in_plus = '<CR>',
        go_out_plus = '-',
      },

      windows = {
        preview = true,
        width_focus = small_width,
        width_nofocus = small_width,
        width_preview = large_width,
        max_number = 3,
      },

      options = {
        use_as_default_explorer = true,
      },
    })
    -- ================== mini.files ==================
  end,
}
