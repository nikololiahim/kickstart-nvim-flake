{
  description = "Neovim derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay/flake-update";
    nixfmt.url = "github:NixOS/nixfmt";
    nixd.url = "github:nix-community/nixd";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # Plugins
    lazy-nvim = {
      url = "github:folke/lazy.nvim";
      flake = false;
    };
    which-key-nvim = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    tokyonight-nvim = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    luasnip = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };
    flash-nvim = {
      url = "github:folke/flash.nvim";
      flake = false;
    };
    dressing-nvim = {
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    fidget-nvim = {
      url = "github:j-hui/fidget.nvim";
      flake = false;
    };
    nvim-metals = {
      url = "github:scalameta/nvim-metals";
      flake = false;
    };
    mini-nvim = {
      url = "github:echasnovski/mini.nvim";
      flake = false;
    };
    lazygit-nvim = {
      url = "github:kdheepak/lazygit.nvim";
      flake = false;
    };
    conform-nvim = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    nvim-colorizer-lua = {
      url = "github:NvChad/nvim-colorizer.lua";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      gen-luarc,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # This is where the Neovim derivation is built.
      neovim-overlay = import ./nix/neovim-overlay.nix { inherit inputs; };
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            # Import the overlay, so that the final Neovim derivation(s) can be accessed via pkgs.<nvim-pkg>
            neovim-overlay
            # This adds a function can be used to generate a .luarc.json
            # containing the Neovim API all plugins in the workspace directory.
            # The generated file can be symlinked in the devShell's shellHook.
            gen-luarc.overlays.default
          ];
        };

        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs (
          { pkgs, ... }:
          {
            projectRootFile = "flake.nix";
            programs.nixfmt = {
              enable = true;
              package = inputs.nixfmt.packages.${system}.default;
            };
            programs.stylua = {
              enable = true;
              package = pkgs.stylua;
            };
          }
        );

        shell = pkgs.mkShell {
          name = "nvim-devShell";
          buildInputs = with pkgs; [
            # Tools for Lua and Nix development, useful for editing files in this repo
            lua-language-server
            nix-tree
            stylua
            inputs.nixd.packages.${system}.default
            self.checks.${system}.pre-commit-check.enabledPackages
            inputs.nixfmt.packages.${system}.default
          ];
          shellHook = ''
            # symlink the .luarc.json generated in the overlay
            ln -fs ${pkgs.nvim-luarc-json} .luarc.json
            ${self.checks.${system}.pre-commit-check.shellHook}
          '';
        };
      in
      {

        formatter = treefmtEval.config.build.wrapper;

        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = rec {
              treefmt.enable = true;
              treefmt.package = treefmtEval.config.build.wrapper;
              treefmt.entry = "${treefmt.package}/bin/treefmt --ci";
            };
          };
          formatting = treefmtEval.config.build.check self;
        };

        packages = rec {
          default = nvim;
          nvim = pkgs.nvim-pkg;
        };

        devShells = {
          default = shell;
        };
      }
    )
    // {
      # You can add this overlay to your NixOS configuration
      overlays.default = neovim-overlay;
    };
}
