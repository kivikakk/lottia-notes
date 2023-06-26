---
title: Installing an HDL toolchain from source
created_at: 2023-06-25T21:02:00+1000
kind: article
draft: true
---

It occurred to me while writing up [§ Requirements][requirements] in the README
for some[^baby] gateware that getting the whole beginner's open-source FPGA
toolchain set up can be a serious stumbling block, as I imagine it probably was
for me once.

The main pre-packaged solution that comes to mind is [OSS CAD Suite]. It's
excellent, but common to "all-in-one" solutions, it makes assumptions that mean
it's prone to inflexibility in certain ways. Rebuilding just one of the tools is
not always as simple as that — Python environment or shared library conflicts
can result, and the tools are wrapped so as to always prefer their own
distribution, necessitating further hacks for those that call each other.

With any luck, you won't run into any of these cases, but if you do, getting
everything built for yourself correctly can be a bit vexing — the YosysHQ tools'
documentation tends to point back to their own pre-built packages (and products)
in preference to (and sometimes instead of) instructing on how to build.

I've done this process three times recently while rejigging my development
environments, so I'm describing it for posterity.

[requirements]: https://github.com/charlottia/sh1107/tree/aeb1c3f77d3226760755331624dd7920779cc2b7#requirements
[OSS CAD Suite]: https://github.com/YosysHQ/oss-cad-suite-build


## Scope

By the end of this guide, you'll have the following ready to go: 

* [Git]
* [Python 3]
* [Amaranth]
* [Yosys]
* [nextpnr] with [Project IceStorm]
* [SymbiYosys] and [Z3]

[Git]: https://git-scm.com/
[Python 3]: https://www.python.org
[Amaranth]: https://amaranth-lang.org/docs/amaranth/latest/intro.html
[Yosys]: https://yosyshq.net/yosys/
[nextpnr]: https://github.com/YosysHQ/nextpnr
[Project IceStorm]: https://github.com/YosysHQ/icestorm
[SymbiYosys]: https://github.com/YosysHQ/sby
[Z3]: https://github.com/Z3Prover/z3

[Git] is for acquiring source code.

[Python 3] is for using Amaranth.

[Amaranth] is the [HDL] I'm using. It is a Python library which contains a
language for describing digital logic, as well as facilitating simulation and
building of the resulting designs. It integrates well with the ecosystem, and
permits intermixing with [Verilog] (or [VHDL]). At time of writing, its
development pace has quickened.

[Yosys] is the synthesis framework at the heart of Amaranth. It is a digital
logic synthesizer, which is a phrasing that severely understates how much work
is involved—for more information, see the [Yosys manual].

Amaranth actually comes with its own [portable Yosys] built-in, which works
beautifully. We'll use it, but we'll build it separately, too: for cases when we
want to make our own changes, or use step-through debugging to understand what's
happening. It's also necessary for formal verification.

[nextpnr] and [Project IceStorm] are for targetting the Lattice [iCE40] family
of FPGAs, which is known for its relative accessibility. I've been learning with
an [iCEBreaker] ([see also][iCEBreaker on Crowd Supply]), which is built around
the iCE40UP5k FPGA, and have found this to be true.

[SymbiYosys] and [Z3] are for [formal verification].  I promise it's good.

Instructions are verified for Linux `x86_64` and macOS `arm64`. I intended to
cover Windows, too, but over four months found the experience
inconsistent[^windows] enough that it was easier to use WSL 2[^wsl].  On Linux
and WSL, I've used Debian.

I assume Linux users can install packages using the distribution package
manager, and macOS users using [Homebrew].

[HDL]: https://en.wikipedia.org/wiki/Hardware_description_language
[Verilog]: https://en.wikipedia.org/wiki/Verilog
[VHDL]: https://en.wikipedia.org/wiki/VHDL
[Yosys manual]: https://yosys.readthedocs.io/_/downloads/en/latest/pdf/
[portable Yosys]: https://yowasp.org/
[iCE40]: https://en.wikipedia.org/wiki/ICE_(FPGA)#iCE40_(40_nm)
[iCEBreaker]: https://1bitsquared.com/products/icebreaker
[iCEBreaker on Crowd Supply]: https://www.crowdsupply.com/1bitsquared/icebreaker-fpga
[formal verification]: https://en.wikipedia.org/wiki/Formal_verification
[Homebrew]: https://brew.sh/


## Git

The [Git] website's [Downloads][Git downloads] page has instructions for
acquiring it through your relevant package manager.

[Git downloads]: https://git-scm.com/downloads


## Python 3

TODO

## Amaranth

TODO

[amaranth-boards]: https://github.com/amaranth-lang/amaranth-boards

## Yosys

TODO

## nextpnr with Project IceStorm

TODO

## SymbiYosys and Z3

TODO



[^baby]: _baby's first gateware_, in fact.

[^windows]: * Lots of random things are a little bit broken.
    * Building Yosys is certainly achievable but [you simply don't wanna][Yosys
      on Windows].
    * _Everything runs slower_. Everything. Git runs slower. Python runs slower.
      Batch scripts run slower. Yosys runs slower. `iceprog` communicates
      (much!) slower.
    * Think you can fix some of this by using MSYS2 or Cygwin? Now you have two
      problems.

<%# Is this a Comrak bug right here? Note the spacing for the list markers. The
offset is wrong. %>

    There's more that I've decided was better left forgotten.

[Yosys on Windows]: https://github.com/YosysHQ/yosys/blob/2310a0ea9a61ed14d2769f01283a5a7590cbe558/guidelines/Windows

[^wsl]: tl;dr: use your Linux user home directory, not your Windows user one;
    when it comes time to flash your board, follow the guide to [Connect USB
    devices] using [usbipd-win]. Don't mind the scary warning on the guide: I
    didn't have to recompile my kernel even on Windows 10.

[Connect USB devices]: https://learn.microsoft.com/en-us/windows/wsl/connect-usb
[usbipd-win]: https://github.com/dorssel/usbipd-win
