{
  inputs.flake-compat = {
    # for shell.nix.
    url = github:edolstra/flake-compat;
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-compat,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      ruby = pkgs.ruby;
    in {
      formatter = pkgs.alejandra;

      devShells.default = let
        env = pkgs.bundlerEnv {
          name = "notes-bundler-env";
          inherit ruby;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          # Hacks in platforms for commonmarker and nokogiri per
          # https://github.com/nix-community/bundix/issues/71.
          gemset =
            import ./gemset.nix
            // (
              if pkgs.stdenv.isDarwin
              then import ./gemset-darwin.nix
              else import ./gemset-linux.nix
            );
        };
      in
        pkgs.mkShell {
          name = "notes";
          buildInputs = [
            ruby
            env
          ];
        };
    });
}
