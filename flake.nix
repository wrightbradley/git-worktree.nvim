{
  description = "git-worktree.nvim - supercharge your haskell experience in neovim";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neodev-nvim = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem = {
        config,
        pkgs,
        system,
        inputs',
        ...
      }: let
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            #markdownlint.enable = true;
          };
        };
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (final: _: {
              neovim-nightly = inputs.neovim.packages.${final.system}.neovim;
            })
          ];
        };
        devShells = let
          mkDevShell = luaVersion: let
            luaEnv = pkgs."lua${luaVersion}".withPackages (lp:
              with lp; [
                busted
                luacheck
                luarocks
              ]);
          in
            pkgs.mkShell {
              name = "git-worktree-nvim";
              buildInputs = [
                luaEnv
              ];
              shellHook = let
                myVimPackage = with pkgs.vimPlugins; {
                  start = [
                    plenary-nvim
                  ];
                };
                packDirArgs.myNeovimPackages = myVimPackage;
              in
                pre-commit-check.shellHook
                + ''
                  export DEBUG_PLENARY="debug"
                  cat <<-EOF > minimal.vim
                    set rtp+=.
                    set packpath^=${pkgs.vimUtils.packDir packDirArgs}
                  EOF
                '';
            };
        in {
          default = mkDevShell "jit";
          luajit = mkDevShell "jit";
          lua-51 = mkDevShell "5_1";
          lua-52 = mkDevShell "5_2";
        };

        packages.neodev-plugin = pkgs.vimUtils.buildVimPlugin {
          name = "neodev.nvim";
          src = inputs.neodev-nvim;
        };
        packages.plenary-plugin = pkgs.vimUtils.buildVimPlugin {
          name = "plenary.nvim";
          src = inputs.plenary-nvim;
        };
        packages.telescope-plugin = pkgs.vimUtils.buildVimPlugin {
          name = "telescope.nvim";
          src = inputs.telescope-nvim;
        };

        checks = {
          inherit pre-commit-check;
          type-check-stable = pkgs.callPackage ./nix/type-check.nix {
            stable = true;
            inherit (config.packages) neodev-plugin telescope-plugin;
            inherit (inputs) pre-commit-hooks;
            inherit self;
          };
          type-check-nightly = pkgs.callPackage ./nix/type-check.nix {
            stable = false;
            inherit (config.packages) neodev-plugin telescope-plugin;
            inherit (inputs) pre-commit-hooks;
            inherit self;
          };
        };
      };
    };
}
