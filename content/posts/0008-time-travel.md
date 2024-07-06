---
title: Time travel
created_at: 2024-07-06T17:07:00+0300
kind: article
description: >-
  The typical hypothetical "who are you coding for" example meant to shock
  you into writing better code is "yourself in six months", but it turns out
  four is completely adequate to get lost.
---

<section id="top">

The typical hypothetical "who are you coding for" example meant to shock
you into writing better code is "yourself in six months", but it turns out
four is completely adequate to get lost.

</section>

<section id="start">

## Start

In February I started writing my first RV32 core. By the end of the month, I
had enough of one going to run some sample code compiled with GCC for RV32I,
interacting with UART via MMIO, which was such a nice feeling. It was written
in a very dumb manner --- meaning it used 95% of the UP5K and took 3 minutes to
synthesise --- but on the other hand it ran pretty much at one cycle per cycle!
(I hadn't pipelined instruction memory fetches, so it _didn't_, but that was the
only thing standing in the way of that. It was written very, uh, plainly.)

Next I wanted to tackle RV32C, and one thing I wasn't happy with was [how I was
actually defining the ISA][isa-def]. It was very manual, and it felt like there
was a lot that could be extracted out in less ad-hoc ways, so that I didn't then
have to repeat myself even more when adding RV32C, or e.g. making it possible to
define a thing called "RV32E" (which is just RV32I with 16 X registers insteah
of 32) as a refinement of RV32I instead of repeating a whole bunch of code, and
then making that selectable as the basis for a core/hart. This also provided an
opportunity to expose more metadata for the built-in assembler and disassembler
used by the test suite.

[isa-def]: https://github.com/kivikakk/sae/blob/4faae64a780bf0521fc8aa73bf8cc7b70add193c/sae/rtl/rv32.py

I started to extract a bit of a "construction kit" for ISAs, and as was my Python
style at the time, there was a _lot_ of magic involved. One of the commits describes
redoing something ["with just slightly less magic"][less-magic], but iunno, a lot
of magic follows in the commits after that one.

[less-magic]: https://github.com/kivikakk/sae/commit/d23fdd79a948a7cc1f4c1edc94295e4f4cfe6bff

And then, on March 5, [a small "wip" commit][wip] is the last of the branch, with
some code that's kind of half-there, half-nonsense, and the following intentionally 
syntactically incomplete line:

[wip]: https://github.com/kivikakk/sae/commit/666247bfea908253d2aa1aa5c2bd8b208fa231fd

```diff
             clone.xfrms.append(pipe)
+            clone.asm_args. ## RESUME XXX GOOD LUCK
```

</section>

<section id="change">

## Change

At that stage I was about a month off moving to Estonia, and so all work
stopped. By the time I started to do HDL again, two months later, I'd decided
to stop using Amaranth entirely and
[learned to do digital design in Chisel][chisel], which was a big undertaking.
A lot of the machinery around the design needed to be implemented --- connecting
to resources on IO pins, the concept of building for different platforms, etc.
--- a lot of the toolchain needed to be replaced/ rebuilt, but the actual manner
of design changed a lot too. I'd taught myself HDL with Amaranth, and I sort
of retaught myself it with Chisel, grasping the fundamentals more clearly.

[chisel]: 0007-amaranth-to-chisel.html

(I also wrote a framework for Chisel in this time, [Chryse], which is where all
my non-project-specific bits went, including the replacements for what Amaranth
gave outside the HDL itself. I had a project framework for Amaranth, [Rain], so
Chryse was like Amaranth build'n'platform plus Rain.)

[Chryse]: https://github.com/kivikakk/chryse
[Rain]: https://github.com/kivikakk/hdx#rain

Three-ish weeks ago, I started using Amaranth again, and it was time to see
where my old work was at. First, I ported everything new from Chryse back to
Rain, freeing it from its weird Nix flake and so giving it a new name, [Niar].
Then I ported my last Chisel project back to Amaranth, [ili9341spi], using it as
the basis for testing Niar. (It's just an TFT LCD controller, rendering Conway's
Game of Life.)

[Niar]: https://github.com/kivikakk/hdx?tab=readme-ov-file#rain
[ili9341spi]: https://github.com/kivikakk/ili9341spi

Once I'd gotten things to my satisfaction, it was time for my next project. I'd
remembered Sae as my last big project before moving/switching off Amaranth, but
my memory didn't extend much further than that --- except maybe the atrocious
build times.

My next project wants a little CPU core of some kind in it, and I decided to be
responsible and actually bring Sae back to life with my new sensibilities, instead
of just starting fresh and having all that work sit there.

</section>

<section id="necromancy">

<h2 title="Naturally sequent.">Necromancy</h2>

There was the `main` branch, [last modified February 28][main], and then 27
commits of WIP on the `rv32c` branch ending in the `RESUME XXX GOOD LUCK`
comment. I took one look at the code in that branch and I realised the comment
was extremely apposite. I didn't have a clue what any of the existing magic
was doing, and I certainly didn't understand what the final half-commit was
driving towards either. The tests were extremely broken, and so there was
nowhere really to get a foothold on it.

[main]: https://github.com/kivikakk/sae/commit/f67fec675ff137eba41ca636b9f04d981784a7a1

So it was back to February 28. First I ported it to Niar, which was uneventful,
and then added a [test using CXXRTL][cxxrtl] to run the same thing we build for
the actual FPGA, which is [this delightful little program][princess]. Synthesis
still takes 3 minutes, and it turns out all but 10 seconds of this is in
place-and-route. CXXRTL elaboration and compile is much faster, and running real
RV code gives me more certainty than the (extensive but still artificial) unit
tests that I haven't broken anything.

[cxxrtl]: https://github.com/kivikakk/sae/commit/e48cc2778003023fea6037908e0cc3f9b0eb57fb
[princess]: https://github.com/kivikakk/sae/blob/4faae64a780bf0521fc8aa73bf8cc7b70add193c/rv/shrimprw.c

At this stage I could've considered getting back onto the WIP, but the core
gateware design issue was pretty pressing: no matter how good an experience I
have of specifying an ISA, if I only have 260ish gates free, I'm not doing much
with it, and the build time sucks even if I can mostly test without it. (I don't
want to be _discouraged_ from putting it on the FPGA!)

```
[2024-07-03 13:05:25,148] niar: DEBUG: starting synthesis/pnr
[2024-07-03 13:05:25,148] niar: INFO: [run]   execute_build
[2024-07-03 13:08:12,179] niar: DEBUG: synthesis/pnr finished in 0:02:47.031564
...
[2024-07-03 13:08:12,208] niar: INFO: Device utilisation:
[2024-07-03 13:08:12,208] niar: INFO:            ICESTORM_LC:  5033/ 5280    95%
```

So instead I spent time fixing this, which meant separating the core out into
stages, defining an ALU instead of repeating the ops everywhere, putting the
registers into BRAM (that was 40% of the UP5K's LCs right there), and generally
making the thing slower at runtime and tightening up some definitions in
exchange for 80x faster PNR and using a third of the logic resources. It's at
least somewhat amenable to pipelining, which is something I'm going to enjoy
implementing later.

I proceeded methodically and generally did before-and-after builds of every
change, comparing the bytecount of the generated RTLIL for a rough idea of "how
much raw IL does the Amaranth input given produce", synthesis plus PNR time, and
comparing `ICESTORM_LC` counts of the final design (or just cells reported by
Yosys where PNR was failing because the design got too big).

This is extremely fraught and open to misinterpretation, because Yosys' output
is optimised, and with many passes involved, there is no direct link between
a given change and the effect on output size. PNR is similar, especially when
up against resource limits, and so the whole thing requires investing not too
much importance in any one result. You're just kinda vibing it out, making
hypotheses about what might be cheaper post-opt, and then, usually, trying to
reason to yourself why it wasn't cheaper. There's a lot of holding of judgment
because maybe you need to change _all_ the things of class X before you can
observe the true difference between two methods.

The entire log of this process is included in the raw log with the subheading
["Decombing"](0009-time-travel-raw.html#decombing). At the entry to this stage,
synthesis took 2:47 and PNR completed with 5033/5280 (95%) of `ICESTORM_LC`s
used. We finished at synthesis taking 0:10 and using 2194/5280 (41%).

</section>

<section id="chrononautics">

## Chrononautics

Now we were in a position to start understanding the refactor WIP.

Step one was rebasing the old branch onto the new. I'd refactored and moved
things around a lot (including e.g. using Amaranth's new async testbench stuff),
so any commit that touched the existing gateware or testing infrastructure
conflicted, but these were nice little opportunities to understand what I was
doing in context. The branch itself had a lot of nice refactors in other areas
too, so by the time I'd finished rebasing, I felt in a fairly good position,
except for the fact that neither building it nor running any of the tests worked
because there was a syntax error in the core ISA definition machinery.

The next step was to get it running, because I couldn't hope to complete
whatever it was I was doing in March without understanding any of its context,
namely the entire new ISA kit, and understanding a system is so much easier when
you can see it running.

To start with, I just commented out the broken line, and it ran, with 44/64
tests passing. Without much in the way of understanding everything around it, I
was able to identify something one specific case needed to happen right at that
same spot,  put together an ultra-specific hack in situ, and we got to 54/64.
At this point, I kind of understand what I was going for, but now I need to
understand everything else to know how to make it happen.

The way to do that turned out to be just reading the new code over and over
again, eventually defining it from the top down. The entire log of this process
is included in the raw log under the subheading ["Design"], and by the end of
it, I'd recapitulated every decision made in coming up with it. The next steps
I'd imagined [followed naturally], and although I entered this stage with no
intention to continue to use this design (on account of its magic-ness), it
still made sense to me to finish my last WIP before turning my mind to simpler
design, since without a fully proven concept I can't say I've grasped it enough
to actually design it again. This got us to 63/64 tests, with the last one being
the first (prospective) RVC test.

["Design"]: 0009-time-travel-raw.html#design
[followed naturally]: https://github.com/kivikakk/sae/commit/456f51b6c0e1aeff93e77b3cf34a5f97f2b2f660

More than proving the concept, though, I just really enjoyed _finally_
completing that change, over 4 months later, in a completely different place and
time. Continuity in the face of countless discontinuities.

Incidentally, this branch doesn't include much in the way of actual RV32C
support, since I got completely caught up with designing the new ISA kit with
just the existing RV32I support as a basis. I think I won't bother with that,
though, since it'll likely entail further support from the ISA kit, and in the
current design that means even more magic. Time to simplify.

[Raw notes] follow.

[Raw notes]: 0009-time-travel-raw.html

</section>
