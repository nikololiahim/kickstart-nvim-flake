local M = {}

---@class KeymapDefinition
---@field mode string|table
---@field opts table<string, any>
---@field key string
---@field command string|(fun())
---@field desc string

---@return KeymapDefinition
local function keymap()
  return {
    mode = 'n',
    opts = { noremap = true, silent = true },
    key = nil,
    command = nil,
    desc = nil,
  }
end

local function merge(tbl1, tbl2)
  return vim.tbl_deep_extend('force', tbl1, tbl2)
end

local pick = require('mini.extra').pickers

M.keymaps = {
  lsp_references = merge(keymap(), {
    key = 'gR',
    command = function()
      pick.lsp({ scope = 'references' })
    end,
    desc = 'Show LSP references',
  }),

  go_to_declaration = merge(keymap(), {
    key = 'gD',
    command = function()
      pick.lsp({ scope = 'declaration' })
    end,
    desc = 'Go to declaration',
  }),

  lsp_definitions = merge(keymap(), {
    key = 'gd',
    command = function()
      pick.lsp({ scope = 'definition' })
    end,
    desc = 'Show LSP definitions',
  }),

  lsp_implementations = merge(keymap(), {
    key = 'gi',
    command = function()
      pick.lsp({ scope = 'implementation' })
    end,
    desc = 'Show LSP implementations',
  }),

  lsp_type_definitions = merge(keymap(), {
    key = 'gt',
    command = function()
      pick.lsp({ scope = 'type_definition' })
    end,
    desc = 'Show LSP type definitions',
  }),

  code_actions = merge(keymap(), {
    mode = { 'n', 'v' },
    key = '<leader>ca',
    command = vim.lsp.buf.code_action,
    desc = 'Show available code actions',
  }),

  smart_rename = merge(keymap(), {
    key = '<leader>rn',
    command = vim.lsp.buf.rename,
    desc = 'Smart rename',
  }),

  all_diagnostics = merge(keymap(), {
    key = '<leader>D',
    command = function()
      pick.diagnostic({ scope = 'all' })
    end,
    desc = 'Show diagnostics in all buffers',
  }),

  buffer_diagnostics = merge(keymap(), {
    key = '<leader>d',
    command = function()
      pick.diagnostic({ scope = 'current' })
    end,
    desc = 'Show line diagnostics',
  }),

  lsp_hover = merge(keymap(), {
    key = 'K',
    command = vim.lsp.buf.hover,
    desc = 'Show documentation for what is under cursor',
  }),

  lsp_restart = merge(keymap(), {
    key = '<leader>rs',
    command = ':LspRestart<CR>',
    desc = 'Restart LSP server',
  }),

  previous_diagnostic = merge(keymap(), {
    key = '[d',
    command = function()
      vim.diagnostic.jump({ count = -1 })
    end,
    desc = 'Go to previous diagnostic',
  }),

  next_diagnostic = merge(keymap(), {
    key = ']d',
    command = function()
      vim.diagnostic.jump({ count = 1 })
    end,
    desc = 'Go to next diagnostic',
  }),
}

M.on_attach = function(keymaps)
  return function(_, bufnr)
    for _, settings in pairs(keymaps) do
      settings.opts.buffer = bufnr
      settings.opts.desc = settings.desc
      vim.keymap.set(settings.mode, settings.key, settings.command, settings.opts)
    end
  end
end

return M
