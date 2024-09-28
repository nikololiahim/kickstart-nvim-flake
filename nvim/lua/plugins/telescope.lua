return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>,', '<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>', desc = 'Switch buffer' },
    { '<leader>/', '<cmd>Telescope live_grep<cr>', desc = 'Grep (Root Dir)' },
    { '<leader>:', '<cmd>Telescope command_history<cr>', desc = 'Command History' },
    { '<leader><space>', '<cmd>Telescope find_files<cr>', desc = 'Find Files (Root Dir)' },
    { '<leader>fb', '<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>', desc = 'Buffers' },
    { '<leader>sj', '<cmd>Telescope jumplist<cr>', desc = 'Jumplist' },
    { '<leader>sl', '<cmd>Telescope loclist<cr>', desc = 'Location list' },
    { '<leader>st', '<cmd>Telescope builtin<cr>', desc = 'All Telescope pickers' },
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
  },
}
