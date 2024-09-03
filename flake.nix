{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    poetry-pkgs.url = "github:nixos/nixpkgs?ref=73de017ef2d18a04ac4bfd0c02650007ccb31c2a";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, poetry-pkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        overlay = final: prev: {
          poetry = poetry-pkgs.legacyPackages.${system}.poetry;
          # python = nixpkgs.legacyPackages.${system}.python310;
          # python3 = nixpkgs.legacyPackages.${system}.python310;
        };

        pkgs = import nixpkgs {
          system = system;
          overlays = [ overlay ];
        };

        mkPoetry = (poetry2nix.lib.mkPoetry2Nix { pkgs = pkgs; });

        app = mkPoetry.mkPoetryApplication { 
            projectDir = self; 
            overrides = mkPoetry.defaultPoetryOverrides.extend (final: prev: {
              pywrap = prev.pywrap.overridePythonAttrs ( old: {
                buildInputs = old.buildInputs ++ [ prev.setuptools ];
              });
            });
            # python = nixpkgs.legacyPackages.${system}.python310;
        };

        container = pkgs.dockerTools.buildLayeredImage {
          name = "app";
          tag = "latest";
          contents = [
            app
            pkgs.coreutils
            pkgs.bashInteractive
            pkgs.findutils
          ];
          config = {
            Cmd = [ "${app}/bin/app" ];
            WorkingDir = "/app";

          };
        };
      in
      {
        app = app;
        pkgs = pkgs;
        packages = {
          app = app;
          container = container;
          default = self.packages.${system}.app;
        };

        apps = {
          app = {
            type = "app";
            program = "${app}/bin/app";
          };
        };

        # Shell for app dependencies.
        #
        #     nix develop
        #
        # Use this shell for developing your app.
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.app ];
        };

        # Shell for poetry.
        #
        #     nix develop .#poetry
        #
        # Use this shell for changes to pyproject.toml and poetry.lock.
        devShells.poetry = pkgs.mkShell {
          packages = [ pkgs.poetry ];
        };
      });
}
