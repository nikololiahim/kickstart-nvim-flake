local function keymap(mode, rhs, lhs, desc)
  vim.keymap.set(mode, rhs, lhs, {silent = true, noremap = true, desc = desc })
end

keymap("n", "-", "<cmd>Ex<cr>", "Open Netrw in the current directory")
keymap("n", "<esc>", "<cmd>nohlsearch<cr>", "Remove search highlights")

