return {
  'NvChad/nvim-colorizer.lua',
  ft = { 'nix' },
  cmd = {
    'ColorizerAttachToBuffer',
    'ColorizerDetachFromBuffer',
    'ColorizerReloadAllBuffers',
    'ColorizerToggle',
  },
  opts = {
    filetypes = {
      nix = {
        css = true,
        css_fn = true,
      },
    },
  },
}