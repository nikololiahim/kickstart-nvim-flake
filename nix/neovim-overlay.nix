# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin =
    src: pname: attrs:
    (pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    }).overrideAttrs
      attrs;

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  # pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};
  pkgs-wrapNeovim = import inputs.nixpkgs {
    system = pkgs.stdenv.hostPlatform.system;
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
    rust-analyzer
    nixd
    lua-language-server
    stylua
    ast-grep
    nixfmt
  ];

  extraLuaPackages =
    p: with p; [
      jsregexp
    ];

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix {
    inherit pkgs-wrapNeovim;
  };

  all-plugins = [
    (mkNvimPlugin inputs.lazy-nvim "lazy.nvim" {
      nvimSkipModule = [
        "lazy.build"
        "lazy.view.commands"
        "lazy.manage.task.init"
        "lazy.manage.runner"
        "lazy.manage.checker"
        "lazy.manage.init"
      ];
    })
    (mkNvimPlugin inputs.which-key-nvim "which-key.nvim" { nvimSkipModule = "which-key.docs"; })
    (mkNvimPlugin inputs.tokyonight-nvim "tokyonight.nvim" {
      nvimSkipModule = [
        "tokyonight.docs"
        "tokyonight.extra.fzf"
      ];
    })
    (mkNvimPlugin inputs.nvim-treesitter "nvim-treesitter" {
      nvimSkipModule = [
        "nvim-treesitter._meta.parsers"
      ];
    })
    (mkNvimPlugin inputs.plenary-nvim "plenary.nvim" {
      nvimSkipModule = [
        "plenary.neorocks.init"
        "plenary._meta._luassert"
      ];
    })
    (mkNvimPlugin inputs.luasnip "LuaSnip" { })
    (mkNvimPlugin inputs.nvim-cmp "nvim-cmp" {
      nvimSkipModule = [
        "cmp.types.lsp_spec"
        "cmp.core_spec"
        "cmp.source_spec"
        "cmp.entry_spec"
        "cmp.matcher_spec"
        "cmp.utils.keymap_spec"
        "cmp.utils.feedkeys_spec"
        "cmp.utils.binary_spec"
        "cmp.utils.api_spec"
        "cmp.utils.misc_spec"
        "cmp.utils.async_spec"
        "cmp.utils.str_spec"
        "cmp.context_spec"
      ];
    })
    (mkNvimPlugin inputs.cmp-buffer "cmp-buffer" { })
    (mkNvimPlugin inputs.cmp-path "cmp-path" { nvimSkipModule = "cmp_path"; })
    (mkNvimPlugin inputs.cmp-luasnip "cmp_luasnip" { nvimSkipModule = "cmp_luasnip"; })
    (mkNvimPlugin inputs.flash-nvim "flash.nvim" { nvimSkipModule = "flash.docs"; })
    (mkNvimPlugin inputs.lsp_lines "lsp_lines.nvim" { })
    (mkNvimPlugin inputs.dressing-nvim "dressing.nvim" { })
    (mkNvimPlugin inputs.nvim-lspconfig "nvim-lspconfig" { })
    (mkNvimPlugin inputs.cmp-nvim-lsp "cmp-nvim-lsp" { })
    (mkNvimPlugin inputs.fidget-nvim "fidget.nvim" { })
    (mkNvimPlugin inputs.nvim-metals "nvim-metals" {
      nvimSkipModule = [
        "metals.decoration"
        "metals.config"
        "metals.test_explorer"
        "metals.decoder"
        "metals.status"
        "metals.doctor"
        "metals.setup"
        "metals.handlers"
        "metals.tvp.node"
        "metals.tvp.init"
        "metals.log"
        "metals.rootdir"
        "metals.util"
        "metals.install"
        "metals"
      ];
    })
    (mkNvimPlugin inputs.mini-nvim "mini.nvim" { })
    (mkNvimPlugin inputs.lazygit-nvim "lazygit.nvim" { })
    (mkNvimPlugin inputs.conform-nvim "conform.nvim" { })
    (mkNvimPlugin inputs.nvim-colorizer-lua "nvim-colorizer.lua" { })
    (mkNvimPlugin inputs.lazydev-nvim "lazydev.nvim" { })
    (mkNvimPlugin inputs.rustaceanvim "rustaceanvim" {
      nvimSkipModule = [
        "rustaceanvim.neotest.init"
      ];
    })
    (mkNvimPlugin inputs.grug-far "grug-far.nvim" { })
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
