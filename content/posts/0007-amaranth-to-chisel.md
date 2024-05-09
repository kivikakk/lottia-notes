---
title: Amaranth to Chisel
created_at: 2024-05-09T17:45:00+0300
kind: article
description: >-
  Learning your second HDL is kinda like learning your second programming language.
  Or just learning your second language.
---

<section id="top">

Adapted from [kalaturg's README].

[kalaturg's README]: https://github.com/kivikakk/kalaturg

---

My days of using Amaranth are over. I don't feel able — nor do I _want_ — to
depend on something I'm not allowed(!)[^lol] to contribute to, so I need a way
to continue on with my FPGA studies without it. I don't really view just trying
to cobble together Verilog as viable for me right now; I'm rather dependent on
having a decent higher-level thing going, and I already feel all the wind sucked
out of my sails from having to make any change whatsoever.

[^lol]: May it suffice to say: lol.

I've experimented with doing my own HDL using what I learned from working with
and on Amaranth (and Yosys, which I'll happily continue to depend on), but it's
way too much work. After surveying the scene, I've chosen [Chisel]. Scala is not
exactly my favourite, and this means really learning it properly, but y'know
what? That's how I felt about Python too, but I still did [some cursed stuff]
with it!

[Chisel]: https://www.chisel-lang.org/
[some cursed stuff]: https://github.com/amaranth-lang/amaranth/pull/830

I plan to bootstrap my way out of this hole by creating a small component in
Amaranth, workbench it using CXXRTL, then duplicating that component in Chisel,
using the same CXXRTL workbench to test it. This way I'm staying connected to
"doing useful/measurable stuff" in a way I know. I'm also furthering my own [HDL
experiments] while I go, letting Amaranth and Chisel combine in my head.

[HDL experiments]: https://github.com/kivikakk/eri

Done so far:

* Bring [`hdx`][hdx], `rainhdx`, and all their dependencies — including Amaranth
  — up to date.
  * New `abc` revision.
  * Amaranth depends on a newer `pdm-backend`, which I [needed to
    package][pdm-backend package] since it's not in nixpkgs.
  * Had to unbreak rainhdx's Nix, that last refactor was bad.
* Add [basic cxxsim support] to `rainhdx`. This was mostly pulled from [I²C, oh!
  Big stretch][i2c_obs], which I maintain is impeccably named.
  * There was also the option to pull the Zig–CXXRTL support from [sh1107], but
    the extra toolchain weight doesn't feel like it helps me move any faster
    here.
* A basic [UART echo], tested with Amaranth's simulator.
* A clone of the Python simulator [with CXXRTL].
* Learn to do a [very basic Chisel module with tests][Chisel Top] and Verilog
  output.
* Build the Chisel module with CXXRTL and integrate it into the simulator —
  it'll be very _wrong_, but the key is the integration.
* [Write a little unbuffered UART pair, test them, integrate. **Done.**][done]
* Extend the test case to exercise the Amaranth version's buffers on TX/RX.
* ~~Write a FIFO in Chisel and buffer the TX/RX.~~
* Discover `Queue` and learn how to use `Decoupled` -- use that in RX and TX.
* Redo the base UART module using `Queue`.
* Test it on the iCEBreaker!
* Mess around with SB_RGBA_DRV. Buffer the clock input with SB_GB.
* Drop all the Python; it's no longer necessary.
* Actions CI for unit tests, cxxsim, synthesis.
* Introduce a "Platform" notion to build separately for iCE40 and CXXRTL.
* [Split off the project-independent bits][chryse].
* Redo the testbench to have the test unit as a blackboxed instance, rather than
  it driving everything through lines from the top. ~~Get it working first with
  Amaranth, then Chisel.~~

[hdx]: https://github.com/kivikakk/hdx
[pdm-backend package]: https://github.com/kivikakk/hdx/commit/27c3609f5b90e97ed89ca11a7e5747d4b8d0d90b#diff-14a0b9fe455f18efa8eb5b66ab3f4818d6ef7c32
[basic cxxsim support]: https://github.com/kivikakk/hdx/commit/d52075e49ac05a7297b8ed8cd6cdd8a2808e72b0
[i2c_obs]: https://github.com/kivikakk/i2c_obs
[sh1107]: https://github.com/kivikakk/sh1107
[UART echo]: https://github.com/kivikakk/kalaturg/commit/cd7b97cfb697ac7def0d5d0689da9c03f403d3e0
[with CXXRTL]: https://github.com/kivikakk/kalaturg/commit/d4c853a680c494fe9acc36aa91b83a7cd2d4d026
[Chisel Top]: https://github.com/kivikakk/kalaturg/commit/35a791d597e0f31a2affda72a9de2c3f21161e36
[done]: https://github.com/kivikakk/kalaturg/commit/9d704aa2968ab3d287fe23ccfad2bdf26a88d5e3
[chryse]: https://github.com/kivikakk/chryse

---

And now, 12 days later, I'm done! I have a fair bit more ground to re-cover in
terms of (a) actually putting together more complex designs --- I'll start with
an SPI OLED (maaaaaybe with a Zig counterpart, like [sh1107]) and then move onto
a RISC-V core again --- and (b) creating my own framework to iterate on
different projects quickly, but I've moved really fast[^minimal] and I'm quite
happy with it.

[^minimal]: With minimal tools! At the start of these 12 days I didn't even have
a desk, or an external monitor. Or a dev board!

It's been interesting to decompose "HDL and digital design, as I learned it
through Amaranth" --- the way I write things has become a lot more fluent, a lot
less "eighty stage FSM", and I spend a lot more time looking at Verilog, which I
think is a good thing right now. I grok a lot more of what's under the covers,
especially having to reimplement some of it.

I can re-archive all my Amaranth stuff again, now that I've finished leaning on
it.

</section>
