with import <nixpkgs> {}; let
  env = bundlerEnv {
    name = "notes-bundler-env";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    # NOTE: I've hacked in the platforms for commonmarker and nokogiri.
    # https://github.com/nix-community/bundix/issues/71
    gemset = ./gemset.nix;
  };
in
  stdenv.mkDerivation {
    name = "notes";
    buildInputs = [env];
  }
