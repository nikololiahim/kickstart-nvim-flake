return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  cmd = 'Telescope',
  opts = {
    defaults = {
      sorting_strategy = 'ascending',
      layout_config = {
        width = 0.8,
        height = 0.8,
        prompt_position = 'top',
        horizontal = {
          preview_width = 0.6,
        },
      },
    },
  },
  keys = function()
    local builtin = require('telescope.builtin')
    -- local themes = require('telescope.themes')
    return {
      -- { '<leader>,', '<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>', desc = 'Switch buffer' },
      {
        '<leader>,',
        function()
          builtin.buffers { sort_mru = true, sort_lastused = true }
        end,
        desc = 'Switch buffer',
      },
      -- { '<leader>/', '<cmd>Telescope live_grep<cr>', desc = 'Grep (Root Dir)' },
      {
        '<leader>/',
        function()
          builtin.live_grep {
            layout_strategy = 'vertical',
            layout_config = {
              vertical = {
                mirror = true,
              },
            },
          }
        end,
        desc = 'Grep (Root Dir)',
      },
      { '<leader>:', builtin.command_history, desc = 'Command History' },
      { '<leader><space>', builtin.find_files, desc = 'Find Files (Root Dir)' },
      {
        '<leader>fb',
        function()
          builtin.buffers { sort_mru = true, sort_lastused = true }
        end,
        desc = 'Buffers',
      },
      { '<leader>sj', builtin.jumplist, desc = 'Jumplist' },
      { '<leader>sl', builtin.loclist, desc = 'Location list' },
      { '<leader>st', builtin.builtin, desc = 'All Telescope pickers' },
      {
        '<leader>sh',
        function()
          require('telescope.builtin').help_tags {
            attach_mappings = function(prompt_bufnr, _)
              local actions = require('telescope.actions')
              local action_state = require('telescope.actions.state')
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd('vert bo help ' .. selection.value)
              end)
              -- needs to return true if you want to map default_mappings and
              -- false if not
              return true
            end,
          }
        end,
        desc = 'Help Pages',
      },
    }
  end,
}
