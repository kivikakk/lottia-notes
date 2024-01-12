---
title: Comrak on Akkoma
created_at: 2024-01-02T15:38:00+1100
kind: article
description: >-
  I've barely touched Elixir before. How hard could shoving a Rust dependency into it be?
---

<section id="top">

Adapted from the original [Fediverse post].

[Fediverse post]: https://lottia.net/notice/AdQMmMEosy8aiz10e8

---

First up: I've never done more than toy with Elixir before, and never with Nix
or Rust, so this "simply stuff Nix, Elixir and Rust into a magic hat" trick was
guaranteed to be at least a little bit Fun™. And it was! :)

Stock Akkoma uses [Earmark](https://github.com/pragdave/earmark), which
looks like a lovely library, but maybe a lil out of date and out of step with
CommonMark/GFM. **We deserve [Comrak](https://github.com/kivikakk/comrak)**.

Happily enough, a Google search revealed a Nathan Faucett had already done
most of the hard work of using Comrak from Elixir in
[`ex-markdown`](https://gitlab.com/nathanfaucett/ex-markdown). Thank you! This never gets old.

Ported it for Comrak and [Rustler](https://github.com/rusterlium/rustler)
changes in the last 5 years, and then learned about the various ways to
juggle Elixir and Mix releases/deps in Nix. [Several hundred lines of hack-ish
later](https://github.com/kivikakk/ex-markdown/compare/master...lottia) and
`ex-markdown` was now fit for purpose.

Special care was taken to ensure both `nix develop`- and `nix build`-based
builds work — this one always wants to be able to quickly iterate in my checkout
without waiting all day for non-incremental builds, but at the end a `nix build`
should:

* match the behaviour of a clean `nix develop --command bash -c "mix deps.get &&
  mix test"`;
* always cleanly succeed; and,
* run `mix test` itself as a post-install check so we don't get blindsided by
  differences in the dev shell/closure-built artefact only when later using it
  (i.e. in Akkoma).

This required some finesse: we want to build the native Rust dependency as
usual when doing `nix build`, which means doing the usual Cargo/Nix dance
and compiling that artefact as its own derivation (and all its crate deps as
their own, etc. etc.). On the other hand, in `nix develop` we want the usual
compile-on-demand to happen. Happily, Rustler is portable enough to support this
workflow! (see the `MARKDOWN_NATIVE_SKIP_COMPILATION` env var.)

One tricky thing is the fucken Mix dependencies. The `ex-markdown` derivation
itself needs to introduce its own Mix deps to `beamPackages.buildMix` so it can
actually build and test. But that's no good when we're building Akkoma — we want
to use a release-wide resolved version of those dependencies, with all BEAM deps
in the one closure and no overlap.

For now we hack it somewhat, and reproduce some of `ex-markdown`'s derivation in
our Akkoma fork — `beamPackages` doesn't have anything like `overrideBeamAttrs`
or `overrideMixAttrs` at the moment.
[There's a fair bit more Nix](https://github.com/kivikakk/akkoma/compare/v3.10.4...lottia)
involved therein.

We started with upstream Nixpkgs' Akkoma package definition (again, copying the
original as a base due to lack of override), add our `:markdown` package to the
`mixNixDeps` — we pull the source, native package and toolchain deps through the
`ex-markdown` flake :)! —, adjust the call-sites, and then as a cherry on top,
expose a NixOS module that sets `config.services.akkoma.package` to the package
exposed. Using the new Akkoma in my personal config is as simple as referring
the module.

And there you have it!

</section>

<section id="future-work">

## Future work

* `ex-markdown` only used a native call for parsing the input; the rendering is
  done in Elixir. Let's add the missing NIF for rendering too!
* Working out a nicer way to share the `ex-markdown` derivation for use in
  downstream projects' `mixNixDeps`.
* Working out a nicer way to override some properties of Nixpkgs' Akkoma
  derivation.
* Unify version numbers and revisions.
* I've just noticed below that Comrak's (GFM-compliant) autolink feature breaks
  remote user refs by turning them into mailto's! Oops.

</section>

<section id="reflections">

## Reflections

Having never really touched Elixir much, this was a reasonably intimidating
circus of interdependent parts to dive right into. It was super fun and — as
usual — I credit Nix with making this _at all_ possible, and more importantly
_worthwhile_. The fact that I don't have to worry about accumulating platform
tools (or getting them installed on the target server etc.) is only a small part
of it.

I did indeed spend quite a while fucking around with Making All This Shit Work
With Nix, but I'd probably have spent as long or longer if I was just doing
this on some pleb distro because of build artefacts left over from successive
attempts — and of course, most of the work would be rendered null next time I
had to set up a new server! The amount of discovery (and number of dead ends) I
got to rebase into concrete learnings is _incredible_.

(I once again express my thanks to those who got me here — especially
[@cadey@pony.social](https://pony.social/@cadey) for putting the idea in my head
years ago, and my ex-qpf for using Nix in the year of our lord 2023, which was a
strong enough signal to finally Just Do It.)

</section>
