# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
with final.pkgs.lib;
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
    gcc
    tree-sitter
    nodejs
  ];

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix {
    inherit pkgs-wrapNeovim;
  };

  all-plugins = with pkgs.vimPlugins; [
    (mkNvimPlugin inputs.lazy-nvim "lazy.nvim")
    (mkNvimPlugin inputs.which-key-nvim "which-key.nvim")
    (mkNvimPlugin inputs.tokyonight-nvim "tokyonight.nvim")
    (mkNvimPlugin inputs.nvim-treesitter "nvim-treesitter")
  ];

  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    withSqlite = false;
  };
in
{
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = nvim-pkg;

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    nvim = nvim-pkg;
    plugins = all-plugins;
  };
}
