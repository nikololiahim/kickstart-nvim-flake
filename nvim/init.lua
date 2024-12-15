vim.opt.scrolloff = 1000
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.showmode = false
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.undofile = true

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function(event)
    vim.keymap.set('n', '<space>x', ':.lua<CR>', { buffer = event.buf })
    vim.keymap.set('v', '<space>x', ':lua<CR>', { buffer = event.buf })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'help',
  callback = function(event)
    vim.keymap.set('n', '<esc>', vim.cmd.helpclose, { buffer = event.buf })
  end,
})
