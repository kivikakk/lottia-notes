---
title: Nix revisited
created_at: 2023-07-15T02:42:00+1000
kind: article
description: >-
  An unsystematic collection of thoughts while adopting Nix.
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

* If you're fighting Nix, you're probably missing a good opportunity to use it
  instead.  Here's an example:

  1. As a heavy Git user, I have a _lot_ of terse aliases which are part of my
     muscle memory.
  2. It's unacceptable to me to type `git ` or even `g ` before those
     aliases, as even the latter represents a 200% additional load on
     commands I use extremely frequently.
  3. It's preferable to me to use Git's aliases over shell aliases to do the
     actual expansion, particularly as I use some, uh, "Git shell aliases"?

  I used to use a method that involved piping the output of this Ruby script
  into [`source`] in my shell rc:

  ```ruby
  #!/usr/bin/env ruby
  
  alias_lines = `git config --global --list`.lines.grep(/^alias\./)
  
  alias_lines.each do |line|
    line =~ /\Aalias\.([^=]+)=(.*)\n\z/
    name, exp = $1, $2
  
    if exp =~ /\A!/
      puts "alias #{name}=\"git #{name}\"  # #{exp}"
    else
      puts "alias #{name}=\"git #{exp}\""
    end
  end
  ```

  (I think the conditional was trying to make up for lack of completions
  _through_ Git aliases, which isn't necessary these days.)

  I almost took that with me.  Can you believe it?  I now have a
  `gitAliases.nix` that looks like the following[^sense]:

  ```nix
  {
    co = "checkout";
    cb = "checkout -b";
    pc = "checkout -p";
  
    s = "status -sb";
  
    b = "branch";
    ba = "branch -a";
    bd = "branch -d";

  # ...
  ```

  [^sense]: If my internal sense of what a Git alias should be called is occupied by a
      base system command that itself is in muscle memory---which only occurs for
      2-letter aliases---I transpose the two letters, or repeat a letter somewhere.

      * `git checkout -p` thus becomes `pc` to avoid `cp(1)`.
      * `git cherry-pick` is uncommon enough that it loses the fight for `pc`
        and gets `pcp`.
      * `git rm` gets `mrm`, because `mr` on its own feels like it should be
        obviously merge-related --- there are 9 aliases beginning with `m` that
        _are_ merge-related --- but at 3 characters, `mrm` is unique enough to
        be recognizable.
      * Why not `cpc` or `rmr`?  iirc, `checkout -p` got `pc` first; when it
        was time to introduce a `cherry-pick` alias, there was no consideration
        of giving it `cpc`---`pc` was an established metaphor for this
        initialism, whereas `cpc` would break that and introduce confusion.
        Moving `checkout -p` to `cpc` for consistency's sake is unacceptable
        and leaves no clear answer for `cherry-pick`.  `rmr` seems fine, but
        continuing with the weirdness is what makes a beautiful natural
        language :)

  Then, in my Home Manager configuration, effectively the following:

  ```nix
  let
    gitAliases = import ./gitAliases.nix;
  in
  {
    home-manager.users.charlotte = {
      programs.fish = {
        shellAliases = {
          # ...
        } // builtins.mapAttrs (name: _v: "git ${name}") gitAliases;
      };
  
      programs.git = {
        aliases = gitAliases;
      };
    };
  }
  ```

  This feels delicious.  I have just noticed I'm not getting `--wraps` set when
  defining the function, and so completions are not provided.  It appears
  slightly unpredictable on fish's side whether `alias x y` will use `-w y`,
  possibly to do with when in init it's happening and whether such a function
  has been [defined before].  Oh, [here we go].

  [`source`]: https://fishshell.com/docs/current/cmds/source.html
  [defined before]: https://github.com/fish-shell/fish-shell/issues/8395#issuecomment-957135261
  [here we go]: https://github.com/fish-shell/fish-shell/blob/861da91bf1029c1442f154f6c369b1b6030b29f3/share/functions/alias.fish#L61-L68

  *  Time to hack that apart.  It's almost disgusting how easy Nix makes
     patching packages I use and then having that just appear on all my
     systems!  Fuck!  I'm sure there's a less nuclear option but I just _wanna_.

* As with anything, keep the stdlib source open in a window/tab/pane.  Here
  this means `/nix/var/nix/profiles/per-user/root/channels/nixpkgs/`.

* Builds may _not_ generally be reproducible between NixOS and Nix on a
  different platform.  [Ahem].

  I think this implies building [nixpkgs 23.05's
  icestorm][icestorm/default.nix] on macOS today would fail.

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

  [Ahem]: https://github.com/charlottia/hdx/commit/b3af8a0bc323931b4866475d72352ea2f00605c1
  [icestorm/default.nix]: https://github.com/NixOS/nixpkgs/blob/23.05/pkgs/development/embedded/fpga/icestorm/default.nix

* Nix feels very appropriate for people like me, whose thought processes or
  short-term memory may be disturbed without warning, thanks to the nature of
  work-in-progress state with declarative systems.

  * By which I mean; for the most part, recovering the idea I'm halfway through
    an attempt of[^int] is more "image load" than "procedural init".  It
    doesn't require parsing shell history or terminal scrollback in order to
    learn the meaning of the current state of my system---99% of the context is
    in a file.

    [^int]: Which I have to do once every 8--10 minutes on average, at a guess.

* I'm avoiding `nix-env` and flakes.  I don't like the look of workflows that
  involve either.  [Xe describes] flakes as being suitable for use cases where
  you might use Niv or Lorri.  Niv and Lorri also appear to be tools for
  workflows I don't like the look of.  Lorri refers to "fast direnv integration
  for robust CLI and editor integration", and for whatever reason, that's a
  slightly repellent notion to me at this stage.

  I expect my opinion on flakes will change as I continue.

  [Xe describes]: https://xeiaso.net/blog/nix-flakes-1-2022-02-21

* Did I mention builds may not be reproducible?

  ```console?prompt=$
  -- Build files have been written to: /tmp/nix-build-nextpnr.drv-1/nextpnr-54b2045/build
  building
  build flags: -j10 SHELL=/nix/store/mxvgjwzdvrl81plvgqnzbrqb14ccnji6-bash-5.2-p15/bin/bash
  [  0%] Building CXX object bba/CMakeFiles/bbasm.dir/main.cc.o
  [  1%] Generating chipdb/chipdb-25k.bba
  /nix/store/mxvgjwzdvrl81plvgqnzbrqb14ccnji6-bash-5.2-p15/bin/bash: line 1: 54809 Segmentation fault: 11  /nix/store/zdd58zb8y7bm15jm0985fdjzy8wrmaci-python3-3.11.4/bin/python3.11 /tmp/nix-build-nextpnr.drv-1/nextpnr-54b2045/ecp5/trellis_import.py -L /nix/store/z3mpz8mqd858vbx849zqyh1mdv64l3vd-trellis/lib/trellis -L /nix/store/z3mpz8mqd858vbx849zqyh1mdv64l3vd-trellis/share/trellis/util/common -L /nix/store/z3mpz8mqd858vbx849zqyh1mdv64l3vd-trellis/share/trellis/timing/util -p /tmp/nix-build-nextpnr.drv-1/nextpnr-54b2045/ecp5/constids.inc -g /tmp/nix-build-nextpnr.drv-1/nextpnr-54b2045/ecp5/gfx.h 25k > chipdb/chipdb-25k.bba.new
  make[2]: *** [ecp5/CMakeFiles/chipdb-ecp5-bbas.dir/build.make:77: ecp5/chipdb/chipdb-25k.bba] Error 139
  make[1]: *** [CMakeFiles/Makefile2:359: ecp5/CMakeFiles/chipdb-ecp5-bbas.dir/all] Error 2
  make[1]: *** Waiting for unfinished jobs....
  [  2%] Linking CXX executable bbasm
  [  2%] Built target bbasm
  make: *** [Makefile:136: all] Error 2
  error: boost::bad_format_string: format-string is ill-formed
  ~ $ # ...
  ```

  (There's a segmentation fault in there :)))
