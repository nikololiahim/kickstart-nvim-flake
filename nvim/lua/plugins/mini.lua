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
    local pick = require('mini.pick')
    local extras = require('mini.extra')
    local diff = require('mini.diff')

    -- ================== mini.files ==================
    vim.keymap.set('n', '-', function()
      files.open(vim.api.nvim_buf_get_name(0), true)
    end, { noremap = false, silent = true, desc = 'Open mini.files (Directory of Current File)' })

    vim.keymap.set('n', '<leader>fm', function()
      files.open(vim.uv.cwd(), true)
    end, { desc = 'Open mini.files (cwd)', silent = true, noremap = true })
    -- ================== mini.files ==================

    -- ================== mini.pick ==================

    vim.keymap.set('n', '<leader>/', function()
      pick.builtin.grep_live()
    end, { desc = 'Grep (Root Dir)', silent = true, noremap = true })

    vim.keymap.set('n', '<leader><space>', function()
      pick.builtin.files()
    end, { desc = 'Find Files (Root Dir)', silent = true, noremap = true })

    vim.keymap.set('n', '<leader>sh', function()
      pick.builtin.help()
    end, { desc = 'Help Pages', silent = true, noremap = true })

    vim.keymap.set('n', '<leader>,', function()
      pick.builtin.buffers({ include_current = false })
    end, { desc = 'Switch Buffer', silent = true, noremap = true })

    vim.keymap.set('n', '<leader>:', function()
      extras.pickers.history({ scope = ':' })
    end, { desc = 'Command History', silent = true, noremap = true })

    vim.keymap.set('n', '<leader>sj', function()
      extras.pickers.list({ scope = 'jump' })
    end, { desc = 'Jumplist', silent = true, noremap = true })

    vim.keymap.set('n', '<leader>sl', function()
      extras.pickers.list({ scope = 'location' })
    end, { desc = 'Location List', silent = true, noremap = true })
    -- ================== mini.pick ==================

    -- ================== mini.diff ==================
    vim.keymap.set('n', 'ghh', function()
      diff.toggle_overlay(0)
    end, { desc = 'Toggle hunk diff overlay', silent = true, noremap = true })

    vim.keymap.set('n', 'gha', function()
      return MiniDiff.operator('apply') .. 'gh'
    end, { desc = 'Add git hunk', silent = true, expr = true, remap = true })

    vim.keymap.set('n', 'ghu', function()
      return MiniDiff.operator('reset') .. 'gh'
    end, { desc = 'Undo git hunk', silent = true, expr = true, remap = true })
    -- ================== mini.diff ==================
  end,

  config = function()
    local max_width = vim.o.columns
    local small_width = math.floor(max_width / 4)
    local large_width = max_width - small_width * 2 - 6

    -- ================== mini.icons ==================
    require('mini.icons').setup()
    -- ================== mini.icons ==================

    -- ================== mini.git ==================
    require('mini.git').setup()
    -- ================== mini.git ==================

    -- ================== mini.diff ==================
    require('mini.diff').setup()
    -- ================== mini.diff ==================

    -- ================== mini.statusline ==================
    require('mini.statusline').setup()
    -- ================== mini.statusline ==================

    -- ================== mini.pairs ==================
    require('mini.pairs').setup()
    -- ================== mini.pairs ==================

    -- ================== mini.pick ==================

    local win_config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end
    require('mini.pick').setup({
      window = {
        config = win_config,
      },
    })
    -- ================== mini.pick ==================

    -- ================== mini.extra ==================
    require('mini.extra').setup()
    -- ================== mini.extra ==================

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
