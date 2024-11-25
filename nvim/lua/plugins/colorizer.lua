return {
  'NvChad/nvim-colorizer.lua',
  ft = { 'nix', 'conf' },
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
      conf = {
        css = true,
        css_fn = true,
      },
    },
  },
}
