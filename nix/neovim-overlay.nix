# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin =
    src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  # pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};
  pkgs-wrapNeovim = import inputs.nixpkgs {
    inherit (pkgs) system;
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      (final: prev: { neovim-unwrapped = prev.neovim; })
    ];
    config = { };
  };

  extraPackages = with pkgs; [
    lazygit
    fd
    ripgrep
    gcc
    tree-sitter
    nodejs
  ];

  extraLuaPackages =
    p: with p; [
      jsregexp
    ];

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix {
    inherit pkgs-wrapNeovim;
  };

  all-plugins = with pkgs.vimPlugins; [
    # (mkNvimPlugin inputs.lazy-nvim "lazy.nvim")
    lazy-nvim
    # (mkNvimPlugin inputs.which-key-nvim "which-key.nvim")
    # (mkNvimPlugin inputs.tokyonight-nvim "tokyonight.nvim")
    which-key-nvim
    tokyonight-nvim
    (mkNvimPlugin inputs.nvim-treesitter "nvim-treesitter")
    # (mkNvimPlugin inputs.plenary-nvim "plenary.nvim")
    plenary-nvim
    (mkNvimPlugin inputs.luasnip "LuaSnip")
    # (mkNvimPlugin inputs.nvim-cmp "nvim-cmp")
    # (mkNvimPlugin inputs.cmp-buffer "cmp-buffer")
    # (mkNvimPlugin inputs.cmp-path "cmp-path")
    # (mkNvimPlugin inputs.cmp-luasnip "cmp_luasnip")
    # (mkNvimPlugin inputs.flash-nvim "flash.nvim")
    nvim-cmp
    cmp-buffer
    cmp-path
    flash-nvim
    (mkNvimPlugin inputs.dressing-nvim "dressing.nvim")
    (mkNvimPlugin inputs.nvim-lspconfig "nvim-lspconfig")
    (mkNvimPlugin inputs.cmp-nvim-lsp "cmp-nvim-lsp")
    (mkNvimPlugin inputs.fidget-nvim "fidget.nvim")
    # (mkNvimPlugin inputs.nvim-metals "nvim-metals")
    nvim-metals
    (mkNvimPlugin inputs.mini-nvim "mini.nvim")
    (mkNvimPlugin inputs.lazygit-nvim "lazygit.nvim")
    (mkNvimPlugin inputs.conform-nvim "conform.nvim")
    (mkNvimPlugin inputs.nvim-colorizer-lua "nvim-colorizer.lua")
    (mkNvimPlugin inputs.lazydev-nvim "lazydev.nvim")
  ];

  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
    inherit extraLuaPackages;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
  };
in
{
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = nvim-pkg;
}
