local M = {}

M.on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true }
  opts.buffer = bufnr

  opts.desc = 'Show LSP references'
  vim.keymap.set('n', 'gR', '<cmd>Telescope lsp_references<CR>', opts)

  opts.desc = 'Go to declaration'
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

  opts.desc = 'Show LSP definitions'
  vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)

  opts.desc = 'Show LSP implementations'
  vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts)

  opts.desc = 'Show LSP type definitions'
  vim.keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', opts)

  opts.desc = 'Show available code actions'
  vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)

  opts.desc = 'Smart rename'
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

  opts.desc = 'Show buffer diagnostics'
  vim.keymap.set('n', '<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts)

  opts.desc = 'Show line diagnostics'
  vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)

  opts.desc = 'Go to previous diagnostic'
  vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump { count = -1 }
  end, opts)

  opts.desc = 'Go to next diagnostic'
  vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump { count = 1 }
  end, opts)
  opts.desc = 'Show documentation for what is under cursor'
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

  opts.desc = 'Restart LSP server'
  vim.keymap.set('n', '<leader>rs', ':LspRestart<CR>', opts)
end

return M