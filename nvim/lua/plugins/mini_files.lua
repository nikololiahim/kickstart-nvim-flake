return {
  'echasnovski/mini.files',
  opts = {
    mappings = {
      go_in_plus = '<CR>',
      go_out_plus = '-',
    },
    windows = {
      preview = true,
      width_focus = 30,
      width_preview = 90,
    },
    options = {
      use_as_default_explorer = false,
    },
  },
  keys = function()
    local files = require('mini.files')
    return {
      {
        '-',
        function()
          files.open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = 'Open mini.files (Directory of Current File)',
      },
      {
        '<leader>fm',
        function()
          files.open(vim.uv.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    }
  end,
}
