---
title: Nix revisited
created_at: 2023-07-14T23:49:00+1000
kind: article
description: >-
  An unsystematic collection of thoughts while adopting Nix.
draft: true
---

I realized I was in error in not using [Nix], and have been addressing that.
(The primary artifact so far that is public is [`hdx`], a response to
[Installing an HDL toolchain from source].)  I have some knowledge of it from
previous experiments.  Some observations:

[Nix]: https://nixos.org/
[`hdx`]: https://github.com/charlottia/hdx
[Installing an HDL toolchain from source]: https://notes.hrzn.ee/posts/0001-hdl-toolchain-source/

* You must thread the needle between "properly sitting down and reading the
  language guide" and "actively replacing previously-statefully-configured
  parts of your system and build environments".  Without the former none of the
  idioms make sense; without the latter you won't remember anything from the
  former.

* As with anything, keep the stdlib source open in a window/tab/pane.  Here
  this means `/nix/var/nix/profiles/per-user/root/channels/nixpkgs/`.

* Builds may _not_ generally be reproducible between NixOS and Nix on a
  different platform.  [Ahem].

  [Ahem]: https://github.com/charlottia/hdx/commit/b3af8a0bc323931b4866475d72352ea2f00605c1

  I think this implies building [nixpkgs 23.05's
  icestorm][icestorm/default.nix] on macOS today would fail.

  [icestorm/default.nix]: https://github.com/NixOS/nixpkgs/blob/23.05/pkgs/development/embedded/fpga/icestorm/default.nix

  Let's verify.  We want to use `nix-build --option substitute false` to
  disable binary substitution, but first invoke the `nix-shell` once for the
  derivation so we don't build all its dependencies from source too:

  ```console
  ~ $ # After a lot of fucking around with nix-store --gc:
  ~ $ nix-shell '<nixpkgs>' -A icestorm
  these 16 paths will be fetched (2.62 MiB download, 16.98 MiB unpacked):
    /nix/store/sm3f0jqk0y1bmwpprjy15icb7bw9kfyp-apple-framework-CoreFoundation-11.0.0
    /nix/store/iqh2hzmrnj9rvw6ahdzzsp9cqzf3ji6w-cctools-binutils-darwin-wrapper-973.0.1

  [ ... lots of output ... ]

  copying path '/nix/store/7v4rbxd8i0hsk2hgy8jnd4qn9vk89a86-clang-wrapper-11.1.0' from 'https://cache.nixos.org'...
  copying path '/nix/store/mas4ifv1v6llnqkyxq5w235x0hdq5yq3-stdenv-darwin' from 'https://cache.nixos.org'...

  [nix-shell:~]$ exit
  exit
  ~ $ nix-build --option substitute false '<nixpkgs>' -A icestorm
  this derivation will be built:
    /nix/store/iqw5iqqkm71vx5dl4s6xzpm5ymxjddyq-icestorm-2020.12.04.drv
  building '/nix/store/iqw5iqqkm71vx5dl4s6xzpm5ymxjddyq-icestorm-2020.12.04.drv'...

  [ ... lots of output ... ]

  patching script interpreter paths in /nix/store/jxfzqadgp6ygd0dfdi7s0jx0nwbd3kxh-icestorm-2020.12.04
  stripping (with command strip and flags -S) in  /nix/store/jxfzqadgp6ygd0dfdi7s0jx0nwbd3kxh-icestorm-2020.12.04/bin
  /nix/store/jxfzqadgp6ygd0dfdi7s0jx0nwbd3kxh-icestorm-2020.12.04
  ~ $
  ```

  It works!  Joke's on me: the revision used in Nixpkgs is about 8 commits
  before the macOS fix that now needs to be worked around.
  
  Let's verify this by building the derivation with the revision overridden.
  The name is also overridden, to avoid the package name + version being used:

  ```nix
  with import <nixpkgs> {};
  icestorm.overrideAttrs ({ src, ... }: {
    name = "icestorm";
    src = src.override {
      rev = "d20a5e9001f46262bf0cef220f1a6943946e421d";
      sha256 = lib.fakeSha256;
    };
  })'
  ```

  We do the little dance to get the fixed-output derivation hash suitable for the
  site it's used:

  ```console?prompt=$
  ~ $ nix-build -E 'with import <nixpkgs> {}; icestorm.overrideAttrs ({ src, ... }: { name = "icestorm"; src = src.override { rev = "d20a5e9001f46262bf0cef220f1a6943946e421d"; sha256 = lib.fakeSha256; }; })'
  these 2 derivations will be built:
    /nix/store/wpcxl7fz89sk1b45xy2m36cv3gljgzmp-source.drv
    /nix/store/gjs2rm2la5as2yh139yaqcz0q5hjgsc7-icestorm.drv
  building '/nix/store/wpcxl7fz89sk1b45xy2m36cv3gljgzmp-source.drv'...

  trying https://github.com/YosysHQ/icestorm/archive/d20a5e9001f46262bf0cef220f1a6943946e421d.tar.gz
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                   Dload  Upload   Total   Spent    Left  Speed
    0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  100  926k    0  926k    0     0  1195k      0 --:--:-- --:--:-- --:--:-- 5570k
  unpacking source archive /private/tmp/nix-build-source.drv-0/d20a5e9001f46262bf0cef220f1a6943946e421d.tar.gz
  error: hash mismatch in fixed-output derivation '/nix/store/wpcxl7fz89sk1b45xy2m36cv3gljgzmp-source.drv':
           specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
              got:    sha256-dEBmxO2+Rf/UVyxDlDdJGFAeI4cu1wTCbneo5I4gFG0=
  error: 1 dependencies of derivation '/nix/store/gjs2rm2la5as2yh139yaqcz0q5hjgsc7-icestorm.drv' failed to build
  ~ $ nix-build -E 'with import <nixpkgs> {}; icestorm.overrideAttrs ({ src, ... }: { name = "icestorm"; src = src.override { rev = "d20a5e9001f46262bf0cef220f1a6943946e421d"; sha256 = "dEBmxO2+Rf/UVyxDlDdJGFAeI4cu1wTCbneo5I4gFG0="; }; })'
  this derivation will be built:
    /nix/store/9klhbj6biiqn9696zzvyy8cmyjfjaw2d-icestorm.drv
  building '/nix/store/9klhbj6biiqn9696zzvyy8cmyjfjaw2d-icestorm.drv'...

  [ ... lots of output ... ]

         > cp icebox_vlog.py    /nix/store/1rdvdwvz44kkhirbvpn0yx2njwalrbf2-icestorm/bin/icebox_vlog
         > cp icebox_stat.py    /nix/store/1rdvdwvz44kkhirbvpn0yx2njwalrbf2-icestorm/bin/icebox_stat
         > sed -i '' 's+import iceboxdb+import iceboxdb as iceboxdb+g' /nix/store/1rdvdwvz44kkhirbvpn0yx2njwalrbf2-icestorm/bin/icebox.py
         > sed: can't read s+import iceboxdb+import iceboxdb as iceboxdb+g: No such file or directory
         > make[1]: *** [Makefile:65: install] Error 2
         > make[1]: Leaving directory '/private/tmp/nix-build-icestorm.drv-0/source/icebox'
         > make: *** [Makefile:13: install] Error 2
         For full logs, run 'nix-store -l /nix/store/9klhbj6biiqn9696zzvyy8cmyjfjaw2d-icestorm.drv'.
  ~ $
  ```

  Sure enough, it does fail.

* Nix feels very appropriate for people like whose thought processes or
  short-term memory may be disturbed without warning, given the nature of
  work-in-progress state with declarative systems.

* I'm avoiding `nix-env` and flakes.  I don't like the look of workflows that
  involve either.  [Xe describes] flakes as being suitable for use cases where
  you might use Niv or Lorri.  Niv and Lorri also appear to be tools for
  workflows I don't like the look of.  Lorri refers to "fast direnv integration
  for robust CLI and editor integration", and for whatever reason, that's a
  slightly repellent notion to me at this stage.

  [Xe describes]: https://xeiaso.net/blog/nix-flakes-1-2022-02-21

  I expect my opinion on flakes will change as I continue.

* Did I mention builds may not be reproducible?
