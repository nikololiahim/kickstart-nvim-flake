# Function for creating a Neovim derivation
{
  pkgs,
  lib,
  stdenv,
  # Set by the overlay to ensure we use a compatible version of `wrapNeovimUnstable`
  pkgs-wrapNeovim ? pkgs,
}:
with lib;
{
  # The Neovim package to wrap
  neovim-unwrapped ? pkgs-wrapNeovim.neovim-unwrapped,
  plugins ? [ ], # List of plugins
  # List of dev plugins (will be bootstrapped) - useful for plugin developers
  # { name = <plugin-name>; url = <git-url>; }
  devPlugins ? [ ],
  # Regexes for config files to ignore, relative to the nvim directory.
  # e.g. [ "^plugin/neogit.lua" "^ftplugin/.*.lua" ]
  ignoreConfigRegexes ? [ ],
  extraPackages ? [ ], # Extra runtime dependencies (e.g. ripgrep, ...)
  # The below arguments can typically be left as their defaults
  # Additional lua packages (not plugins), e.g. from luarocks.org.
  # e.g. p: [p.jsregexp]
  extraLuaPackages ? p: [ ],
  extraPython3Packages ? p: [ ], # Additional python 3 packages
  withPython3 ? true, # Build Neovim with Python 3 support?
  withRuby ? true, # Build Neovim with Ruby support?
  withNodeJs ? true, # Build Neovim with NodeJS support?
}:
let
  normalizedPlugins = pkgs-wrapNeovim.neovimUtils.normalizePlugins plugins;
  externalPackages = extraPackages;

  # This nixpkgs util function creates an attrset
  # that pkgs.wrapNeovimUnstable uses to configure the Neovim build.
  neovimConfig = pkgs-wrapNeovim.neovimUtils.makeNeovimConfig {
    inherit
      extraLuaPackages
      extraPython3Packages
      withPython3
      withRuby
      withNodeJs
      plugins
      ;
  };

  # This uses the ignoreConfigRegexes list to filter
  # the nvim directory
  nvimRtpSrc =
    let
      src = ../nvim;
    in
    lib.cleanSourceWith {
      inherit src;
      name = "nvim-rtp-src";
      filter =
        path: _:
        let
          srcPrefix = toString src + "/";
          relPath = lib.removePrefix srcPrefix (toString path);
        in
        lib.all (regex: builtins.match regex relPath == null) ignoreConfigRegexes;
    };

  # Split runtimepath into 3 directories:
  # - lua, to be prepended to the rtp at the beginning of init.lua
  # - nvim, containing plugin, ftplugin, ... subdirectories
  # - after, to be sourced last in the startup initialization
  # See also: https://neovim.io/doc/user/starting.html
  nvimRtp = stdenv.mkDerivation {
    name = "nvim-rtp";
    src = nvimRtpSrc;

    buildPhase = ''
      mkdir -p $out/nvim
      mkdir -p $out/lua
      rm init.lua
    '';

    installPhase = ''
      if [ -d "lua" ]; then
        cp -r lua $out/lua
        rm -r lua
      fi
      # Copy nvim/after only if it exists
      if [ -d "after" ]; then
          cp -r after $out/after
          rm -r after
      fi
      # Copy rest of nvim/ subdirectories only if they exist
      if [ ! -z "$(ls -A)" ]; then
          cp -r -- * $out/nvim
      fi
    '';
  };

  # The final init.lua content that we pass to the Neovim wrapper.
  # It wraps the user init.lua, prepends the lua lib directory to the RTP
  # and prepends the nvim and after directory to the RTP
  # It also adds logic for bootstrapping dev plugins (for plugin developers)
  initLua =
    ''
      vim.loader.enable()
      -- prepend lua directory
      vim.opt.rtp:prepend('${nvimRtp}/lua')

      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      require("lazy").setup({
        spec = {
          { import = "plugins" },
        },
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
              "netrw",
            },
          }
        },
        dev = {
          path = "${
            pkgs.neovimUtils.packDir {
              myNeovimPackages = (pkgs.neovimUtils.normalizedPluginsToVimPackage normalizedPlugins);
            }
          }/pack/myNeovimPackages/start",
          patterns = {""},
        },
        install = {
          -- Safeguard in case we forget to install a plugin with Nix
          missing = false,
        },
        rocks = {
          enabled = false,
        },
      })
    ''
    # Wrap init.lua
    + (builtins.readFile ../nvim/init.lua)
    # Bootstrap/load dev plugins
    + optionalString (devPlugins != [ ]) (
      ''
        local dev_pack_path = vim.fn.stdpath('data') .. '/site/pack/dev'
        local dev_plugins_dir = dev_pack_path .. '/opt'
        local dev_plugin_path
      ''
      + strings.concatMapStringsSep "\n" (plugin: ''
        dev_plugin_path = dev_plugins_dir .. '/${plugin.name}'
        if vim.fn.empty(vim.fn.glob(dev_plugin_path)) > 0 then
          vim.notify('Bootstrapping dev plugin ${plugin.name} ...', vim.log.levels.INFO)
          vim.cmd('!${pkgs.git}/bin/git clone ${plugin.url} ' .. dev_plugin_path)
        end
        vim.cmd('packadd! ${plugin.name}')
      '') devPlugins
    )
    # Prepend nvim and after directories to the runtimepath
    # NOTE: This is done after init.lua,
    # because of a bug in Neovim that can cause filetype plugins
    # to be sourced prematurely, see https://github.com/neovim/neovim/issues/19008
    # We prepend to ensure that user ftplugins are sourced before builtin ftplugins.
    + ''
      vim.opt.rtp:prepend('${nvimRtp}/nvim')
      vim.opt.rtp:prepend('${nvimRtp}/after')
    '';

  # Add arguments to the Neovim wrapper script
  extraMakeWrapperArgs =
    builtins.concatStringsSep " "
      # Add external packages to the PATH
      (optional (externalPackages != [ ]) ''--prefix PATH : "${makeBinPath externalPackages}"'');

  luaPackages = neovim-unwrapped.lua.pkgs;
  resolvedExtraLuaPackages = extraLuaPackages luaPackages;

  # Native Lua libraries
  extraMakeWrapperLuaCArgs =
    optionalString (resolvedExtraLuaPackages != [ ])
      ''--suffix LUA_CPATH ";" "${
        concatMapStringsSep ";" luaPackages.getLuaCPath resolvedExtraLuaPackages
      }"'';

  # Lua libraries
  extraMakeWrapperLuaArgs =
    optionalString (resolvedExtraLuaPackages != [ ])
      ''--suffix LUA_PATH ";" "${
        concatMapStringsSep ";" luaPackages.getLuaPath resolvedExtraLuaPackages
      }"'';

  # wrapNeovimUnstable is the nixpkgs utility function for building a Neovim derivation.
  neovim-wrapped = pkgs-wrapNeovim.wrapNeovimUnstable neovim-unwrapped (
    neovimConfig
    // {
      luaRcContent = initLua;
      wrapperArgs =
        escapeShellArgs neovimConfig.wrapperArgs
        + " "
        + extraMakeWrapperArgs
        + " "
        + extraMakeWrapperLuaCArgs
        + " "
        + extraMakeWrapperLuaArgs;
      wrapRc = true;
    }
  );

in
neovim-wrapped
