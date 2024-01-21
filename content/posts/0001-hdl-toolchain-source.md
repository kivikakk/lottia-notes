---
title: Installing an HDL toolchain from source
created_at: 2023-06-27T19:12:00+1000
kind: article
back_to_top: scope
description: >-
  A fairly detailed guide on building and installing a gateware toolchain in a
  self-contained and repeatable way.
---

<section id="opening">

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
environments, so I'm describing it for posterity/others.

[requirements]: https://hrzn.ee/kivikakk/sh1107/tree/aeb1c3f77d3226760755331624dd7920779cc2b7#requirements
[OSS CAD Suite]: https://github.com/YosysHQ/oss-cad-suite-build

[^baby]: _baby's first gateware_, in fact.

</section>

<section id="scope">

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

[Amaranth] is the [HDL] I'm using. It is a Python library which consists of a
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

[nextpnr] and [Project IceStorm] are for targeting the Lattice [iCE40] family
of FPGAs, which is known for its relative accessibility. I've been learning with
an [iCEBreaker] ([see also][iCEBreaker on Crowd Supply]), which is built around
the iCE40UP5k FPGA, and have found this to be true.

[SymbiYosys] and [Z3] are for [formal verification]. I promise it's good.

Instructions are verified for Linux `x86_64` and macOS `arm64`. I intended to
cover Windows, too, but over four months found the experience
inconsistent[^windows] enough that it was easier to use WSL 2[^wsl]. On Linux
and WSL, I've used Debian.

I assume Linux users can install packages using the distribution package
manager, and macOS users using [Homebrew]. I'm going to avoid installing almost
anything globally, however, that wouldn't already get installed by your package
manager as a matter of course, especially when there's reasons you might need
multiple versions around.

[HDL]: https://en.wikipedia.org/wiki/Hardware_description_language
[Verilog]: https://en.wikipedia.org/wiki/Verilog
[VHDL]: https://en.wikipedia.org/wiki/VHDL
[Yosys manual]: https://yosys.readthedocs.io/_/downloads/en/latest/pdf/
[portable Yosys]: https://pypi.org/project/amaranth-yosys/
[iCE40]: https://en.wikipedia.org/wiki/ICE_(FPGA)#iCE40_(40_nm)
[iCEBreaker]: https://1bitsquared.com/products/icebreaker
[iCEBreaker on Crowd Supply]: https://www.crowdsupply.com/1bitsquared/icebreaker-fpga
[formal verification]: https://en.wikipedia.org/wiki/Formal_verification
[Homebrew]: https://brew.sh/

[^windows]: * Lots of random things are a little bit broken.
    * Building Yosys is certainly achievable but [you simply don't wanna][Yosys
      on Windows].
    * _Everything runs slower_. Everything. Git runs slower. Python runs slower.
      Batch scripts run slower. Yosys runs slower. `iceprog` communicates
      (much!) slower.
    * Think you can fix some of this by using MSYS2 or Cygwin? Now you have two
      problems.

    There's more that I've decided was better left forgotten.

[Yosys on Windows]: https://github.com/YosysHQ/yosys/blob/2310a0ea9a61ed14d2769f01283a5a7590cbe558/guidelines/Windows

[^wsl]: tl;dr: use your Linux user home directory, not your Windows user one; if
    CMake takes forever during configure, check if your `PATH` is full of
    `/mnt/...` — if it is, it's probably searching your Windows partition very
    slowly (disable [`interop.appendWindowsPath`] or modify your `PATH` just for
    configure); when it comes time to flash your board, follow the guide to
    [Connect USB devices] using [usbipd-win]. Don't mind the scary warning on
    the guide: I didn't have to recompile my kernel even on Windows 10.

[`interop.appendWindowsPath`]: https://learn.microsoft.com/en-us/windows/wsl/wsl-config#interop-settings
[Connect USB devices]: https://learn.microsoft.com/en-us/windows/wsl/connect-usb
[usbipd-win]: https://github.com/dorssel/usbipd-win

</section>

<section id="git">

## Git

The [Git] website's [Downloads][Git downloads] page has instructions for
acquiring it through your relevant package manager.

[Git downloads]: https://git-scm.com/downloads

</section>

<section id="python-3">

## Python 3

That was easy. Now the opinions start.

Install the [`asdf` Multiple Version Runtime Manager][asdf]. The [Getting
Started][asdf getting started] page has commands for dependency installation
through package manager. Use the official `git` method to download `asdf`
itself, and then follow the instructions for your shell.

Now install the Python `asdf` plugin, and install the latest stable version of
Python:

```console?prompt=$
~ $ asdf plugin add python
initializing plugin repository...Cloning into '/home/charlotte/.asdf/repository'...
remote: Enumerating objects: 5273, done.
remote: Counting objects: 100% (481/481), done.
remote: Compressing objects: 100% (88/88), done.
remote: Total 5273 (delta 419), reused 445 (delta 393), pack-reused 4792
Receiving objects: 100% (5273/5273), 1.21 MiB | 29.47 MiB/s, done.
Resolving deltas: 100% (2849/2849), done.
~ $ asdf latest python
3.11.4
~ $ asdf install python 3.11.4
python-build 3.11.4 /home/charlotte/.asdf/installs/python/3.11.4
Downloading Python-3.11.4.tar.xz...
-> https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tar.xz
Installing Python-3.11.4...
Installed Python-3.11.4 to /home/charlotte/.asdf/installs/python/3.11.4
~ $ asdf global python 3.11.4
~ $
```

(You might get some warnings about extensions not being compiled. That's OK.
There's also 3.12.0b3 available at time of writing, if you don't mind a beta.)

The last command makes it the default Python for our user. `asdf` puts some
shims in our `PATH` which use a combination of our configured defaults
(`global`), our current path (`local`), and environment variables (`shell`) to
select the desired version:

```console?prompt=$,>>>
~ $ which python
/home/charlotte/.asdf/shims/python
~ $ asdf current python
python          3.11.4          /home/charlotte/.tool-versions
~ $ asdf where python
/home/charlotte/.asdf/installs/python/3.11.4
~ $ asdf which python
/home/charlotte/.asdf/installs/python/3.11.4/bin/python
~ $ python
Python 3.11.4 (main, Jun 26 2023, 16:06:57) [GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

[asdf]: https://asdf-vm.com/
[asdf getting started]: https://asdf-vm.com/guide/getting-started.html

</section>

<section id="venv">

### venv

The last thing we want to do is actually a per-project step. We're about to
install Amaranth, which is a Python dependency, and so we want to make sure
we're installing Python dependencies in a separate [virtual environment] per
project, that they don't interfere or conflict with each other.

In your project directory, create a new virtual environment called `venv`, and
then activate it:

```console
prj $ python -m venv venv
prj $ source venv/bin/activate
(venv) prj $
```

(Note there are a few different `activate` variants in the `bin` directory for
different shells.)

Add `venv` to your `.gitignore` or similar.

It's important to remember to activate the virtual environment before running
Python or installing dependencies with `pip`. Many IDEs will automatically
activate (or prompt to activate) virtual environments when they're detected in
the root of a project. Similarly, some shells can be configured to do similar.

Note that the Python instance used by the virtual environment is tied to the
specific version we had chosen through `asdf`, and not the shim:

```console
(venv) prj $ readlink venv/bin/python
/home/charlotte/.asdf/installs/python/3.11.4/bin/python
(venv) prj $
```

We're ready to install Python dependencies.

[virtual environment]: https://docs.python.org/3/library/venv.html

</section>

<section id="amaranth">

## Amaranth

Firstly, note Amaranth's own [installation instructions][Amaranth installation
instructions]. We'll follow along, and deviate from them somewhat.

Install GTKWave from your package manager. We'll come back to Yosys.

Verify we do in fact have the latest `pip`:

```console
(venv) prj $ pip install --upgrade pip
Requirement already satisfied: pip in ./venv/lib/python3.11/site-packages (23.1.2)
(venv) prj $
```

We do not pass `--user` to `pip`—it is rejected in a virtual environment, for
`--user` implies writing to your home directory, which would escape the virtual
environment.

We're going to skip the latest release and go straight to an editable
development snapshot. You may want to clone it within your project directory,
perhaps as a Git submodule, or along-side. I'm going with along-side.

Clone Amaranth and install it in editable mode, with the built-in Yosys:

```console
(venv) prj $ cd ..
(venv) ~ $ git clone https://github.com/amaranth-lang/amaranth
Cloning into 'amaranth'...
remote: Enumerating objects: 8651, done.
remote: Counting objects: 100% (272/272), done.
remote: Compressing objects: 100% (95/95), done.
remote: Total 8651 (delta 170), reused 227 (delta 162), pack-reused 8379
Receiving objects: 100% (8651/8651), 1.71 MiB | 29.14 MiB/s, done.
Resolving deltas: 100% (6474/6474), done.
(venv) ~ $ cd amaranth
(venv) amaranth $ pip install --editable .[builtin-yosys]
Obtaining file:///home/charlotte/amaranth
  Installing build dependencies ... done
  Checking if build backend supports build_editable ... done
  Getting requirements to build editable ... done
  Preparing editable metadata (pyproject.toml) ... done

[... lots of output ...]

Successfully built amaranth
Installing collected packages: wasmtime, pyvcd, MarkupSafe, Jinja2, amaranth-yosys, amaranth
Successfully installed Jinja2-3.1.2 MarkupSafe-2.1.3 amaranth-0.4.dev134+g99417d6 amaranth-yosys-0.25.0.0.post72 pyvcd-0.4.0 wasmtime-9.0.0
(venv) amaranth $
```

Note that the virtual environment remained active even as we left the directory
we created it in. This is desirable: it means the editable snapshot was
installed in our virtual environment.

We'll install the [board definitions][amaranth-boards] now, too. Clone the
repository and install it the same way, except without the `[builtin-yosys]`
option:

```console
(venv) amaranth $ cd ..
(venv) ~ $ git clone https://github.com/amaranth-lang/amaranth-boards
Cloning into 'amaranth-boards'...
remote: Enumerating objects: 1353, done.
remote: Counting objects: 100% (532/532), done.
remote: Compressing objects: 100% (136/136), done.
remote: Total 1353 (delta 426), reused 405 (delta 396), pack-reused 821
Receiving objects: 100% (1353/1353), 307.90 KiB | 17.11 MiB/s, done.
Resolving deltas: 100% (943/943), done.
(venv) ~ $ cd amaranth-boards/
(venv) amaranth-boards $ pip install --editable .
Obtaining file:///home/charlotte/amaranth-boards
  Installing build dependencies ... done
  Checking if build backend supports build_editable ... done
  Getting requirements to build editable ... done
  Preparing editable metadata (pyproject.toml) ... done

[... lots of output ...]

Successfully built amaranth-boards
Installing collected packages: amaranth-boards
Successfully installed amaranth-boards-0.1.dev228+g54e6ac4
(venv) amaranth-boards $
```

We're ready. We can verify the installations by using a Python shell in the
virtual environment:

```console?prompt=$,>>>
(venv) prj $ python
Python 3.11.4 (main, Jun 26 2023, 16:06:57) [GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from amaranth import *
>>> Signal
<class 'amaranth.hdl.ast.Signal'>
>>> from amaranth_boards.icebreaker import *
>>> ICEBreakerPlatform
<class 'amaranth_boards.icebreaker.ICEBreakerPlatform'>
>>>
```

[Amaranth installation instructions]: https://amaranth-lang.org/docs/amaranth/latest/install.html
[amaranth-boards]: https://github.com/amaranth-lang/amaranth-boards

</section>

<section id="yosys">

## Yosys

Clone the [Yosys repo] and read its README. [§ Building from Source] tells you
which packages from the package manager it needs.

By default, Yosys will install into `/usr/local`, but we'll override it to use
`~/.local` instead. We do this by setting the `PREFIX` variable, and
importantly, we need it set for the build step too, not only install. Otherwise,
the `yosys-config` helper that gets installed will report the wrong values.

Yosys's Makefile will include `Makefile.conf` if it exists; we'll put it in
there so we can't forget, and don't have to stash Makefile changes when we pull
the latest. Then we build in parallel and install:

```console?prompt=%20yosys%20$
(venv) yosys $ echo 'PREFIX = $(HOME)/.local' > Makefile.conf
(venv) yosys $ make -j8
[Makefile.conf] PREFIX = $(HOME)/.local
[  0%] Building kernel/version_2310a0ea9.cc
[  0%] Building kernel/driver.o
[  0%] Building techlibs/common/simlib_help.inc
[  0%] Building techlibs/common/simcells_help.inc
[  1%] Building kernel/rtlil.o

[... lots of output ...]

[ 94%] ABC: `` Compiling: /src/bdd/llb/llb4Nonlin.c
[ 94%] ABC: `` Compiling: /src/bdd/llb/llb4Sweep.c
[ 94%] ABC: `` Building binary: abc-1de4eaf
[100%] Building yosys-abc

  Build successful.

(venv) yosys $ make install
[Makefile.conf] PREFIX = $(HOME)/.local
mkdir -p /home/charlotte/.local/bin
cp yosys yosys-config yosys-abc yosys-filterlib yosys-smtbmc yosys-witness /home/charlotte/.local/bin
strip -S /home/charlotte/.local/bin/yosys
strip /home/charlotte/.local/bin/yosys-abc
strip /home/charlotte/.local/bin/yosys-filterlib
mkdir -p /home/charlotte/.local/share/yosys
cp -r share/. /home/charlotte/.local/share/yosys/.
(venv) yosys $
```

You may need to add `~/.local/bin` to your `PATH`. Test the installed binary.
Check the `yosys-config` output:

```console
(venv) yosys $ yosys-config --datdir
/home/charlotte/.local/share/yosys
(venv) yosys $
```

[Yosys repo]: https://github.com/yosyshq/yosys
[§ Building from Source]: https://github.com/yosyshq/yosys#building-from-source

</section>

<section id="project-icestorm">

## Project IceStorm

Before [nextpnr], we need the technology-specific support. That's this step.

Clone [Project IceStorm]. There's no `Makefile.conf` here, so edit the first
line of `config.mk`:

```diff
-PREFIX ?= /usr/local
+PREFIX = $(HOME)/.local
```

Install the libftdi development package; it's `libftdi-dev` on Debian and
`libftdi` in Homebrew.

Now compile and install Project IceStorm. I've avoided compiling in parallel as
its build script sometimes gets ahead of itself:

```console?prompt=icestorm%20$
(venv) icestorm $ make
make -C icebox all
make[1]: Entering directory '/home/charlotte/icestorm/icebox'
python3 icebox_chipdb.py -3 > chipdb-384.new
mv chipdb-384.new chipdb-384.txt

[... lots of output ...]

cc -MD -MP -O2  -Wall -std=c99 -I/home/charlotte/.local/include    -c -o mpsse.o mpsse.c
cc -o iceprog  iceprog.o mpsse.o -lm -lstdc++ -lftdi
make[1]: Leaving directory '/home/charlotte/icestorm/iceprog'
(venv) icestorm $ make install
for dir in icebox icepack icemulti icepll icebram icetime iceprog; do \
        make -C $dir install || exit; \
done
make[1]: Entering directory '/home/charlotte/icestorm/icebox'
mkdir -p /home/charlotte/.local/share/icebox

[... lots of output ...]

mkdir -p /home/charlotte/.local/bin
cp iceprog /home/charlotte/.local/bin/iceprog
make[1]: Leaving directory '/home/charlotte/icestorm/iceprog'
(venv) icestorm $
```

If you have an iCEBreaker, at this stage you can try using `iceprog` to say hi:

```console
(venv) icestorm $ iceprog -t
init..
cdone: high
reset..
cdone: low
flash ID: 0xEF 0x40 0x18 0x00
cdone: high
Bye.
(venv) icestorm $
```

</section>

<section id="troubleshooting">

### Troubleshooting

The following error indicates the device wasn't found by `iceprog`:

```
init..
Can't find iCE FTDI USB device (vendor_id 0x0403, device_id 0x6010 or 0x6014).
ABORT.
```

macOS users, check System Information → USB. If you don't see the iCEBreaker
listed, check your connections and consider trying a different USB cable,
adaptor or hub, as appropriate.

Linux users, check `lsusb`. If you can see something with ID `0403:6010`, that's
good. If it identifies itself as an iCEBreaker, even better. You may need a
[udev] rule to ensure the device node is writable by your user.

Create the file `/etc/udev/rules.d/53-lattice-ftdi.rules` with the following
content:

```
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0660", GROUP="plugdev", TAG+="uaccess"
```

This will make any device with ID `0403:6010` writable by the group `plugdev`.
Check the output of the `id` command to verify your user groups:

```console
(venv) icestorm $ id -Gn
charlotte adm sudo plugdev
(venv) icestorm $
```

If `plugdev` is listed somewhere, you're good. Otherwise, add yourself to the
group. (e.g. `sudo adduser $(whoami) plugdev`) After this, unplug and replug for
the new rule to take effect.

WSL 2 users (or recalcitrant Windows users) should also consult the
footnote[^wslice].

[udev]: https://opensource.com/article/18/11/udev

[^wslice]: Firstly, create (or edit) the file `/etc/wsl.conf` and ensure you
    have the following stanza (or know what you're doing already):

    ```ini
    [boot]
    command="service udev restart"
    ```

    Run `sudo service udev restart` to get udev going immediately. You can
    `usbipd wsl detach -i 0403:6010` and then `attach` again instead of
    physically messing around with cables.

    This likely only applies to Windows Steelman Enthusiasts, but you _may_ also
    need to use [Zadig]. Use the WinUSB driver. Check "List All Devices" in the
    options menu. You should see two entries that correspond to the iCEBreaker —
    "Interface 0" and "Interface 1" — and they might identify themselves as the
    iCEBreaker, or something less obvious (like "Dual RS232-HS"). Make sure you
    use the same driver for both. When in doubt, unplug and replug.

[Zadig]: https://zadig.akeo.ie/

</section>

<section id="nextpnr">

## nextpnr

Ensure Project IceStorm ([↴](#project-icestorm)) is installed first.

Fetch [nextpnr] and install the appropriate [§ Prerequisites]. Then, check out
the specific instructions for [nextpnr-ice40]. We'll need to adapt them
slightly.

We specify the iCE40 arch, the install prefix, the install prefix for Project
IceStorm, the root directory for our active Python installation, and finally, a
[runtime search path][rpath] to add to the final binary. This is because nextpnr
will link against our Python install, but our Python install's shared libraries
aren't on the [system search path][ldso].


```console?prompt=nextpnr%20$,%20%20%20%20
(venv) nextpnr $ cmake . -DARCH=ice40 \
                 -DCMAKE_INSTALL_PREFIX=$HOME/.local \
                 -DICESTORM_INSTALL_PREFIX=$HOME/.local \
                 -DPython3_ROOT_DIR="$(asdf where python)" \
                 -DCMAKE_INSTALL_RPATH="$(asdf where python)"/lib
-- Building with IPO
-- Found Python3: /home/charlotte/.asdf/installs/python/3.11.4/bin/python3 (found suitable version "3.11.4", minimum required is "3.5") found components: Interpreter
-- Found Python3: /home/charlotte/.asdf/installs/python/3.11.4/include/python3.11 (found suitable version "3.11.4", minimum required is "3.5") found components: Development Development.Module Development.Embed
-- Found Boost: /usr/include (found version "1.74.0") found components: filesystem program_options iostreams system thread regex chrono date_time atomic
-- Found Boost: /usr/include (found version "1.74.0") found components: program_options filesystem system
-- Configuring architecture: ice40
-- Enabled iCE40 devices: 384;1k;5k;u4k;8k
-- Found Python3: /home/charlotte/.asdf/installs/python/3.11.4/bin/python3 (found suitable version "3.11.4", minimum required is "3.5") found components: Interpreter
-- IceStorm install prefix: /home/charlotte/.local
-- icebox data directory: /home/charlotte/.local/share/icebox
-- Using iCE40 chipdb: /home/charlotte/nextpnr/ice40/chipdb
-- Configuring architecture: ecp5
-- Enabled ECP5 devices: 25k;45k;85k
-- Trellis install prefix: /home/charlotte/.local
-- Trellis library directory: /usr/local/lib/trellis
-- Trellis data directory: /home/charlotte/.local/share/trellis
-- Using ECP5 chipdb: /home/charlotte/nextpnr/ecp5/chipdb
-- Configuring done
-- Generating done
-- Build files have been written to: /home/charlotte/nextpnr
(venv) nextpnr $ make -j8
[  2%] Generating chipdb/chipdb-384.bba
[  2%] Building CXX object bba/CMakeFiles/bbasm.dir/main.cc.o
[  4%] Generating chipdb/chipdb-1k.bba
[  5%] Linking CXX executable bbasm

[... lots of output ...]

[ 97%] Building CXX object CMakeFiles/nextpnr-ice40.dir/ice40/pack.cc.o
[ 98%] Building CXX object CMakeFiles/nextpnr-ice40.dir/ice40/pcf.cc.o
[100%] Linking CXX executable nextpnr-ice40
[100%] Built target nextpnr-ice40
(venv) nextpnr $ make install
[  7%] Built target chipdb-ice40-bbas
[ 10%] Built target bbasm
[ 17%] Built target chipdb-ice40-bins
[ 32%] Built target chipdb-ice40
[100%] Built target nextpnr-ice40
Install the project...
-- Install configuration: "Release"
-- Installing: /home/charlotte/.local/bin/nextpnr-ice40
-- Set runtime path of "/home/charlotte/.local/bin/nextpnr-ice40" to "/home/charlotte/.asdf/installs/python/3.11.4/lib"
(venv) nextpnr $
```

Test the installed binary to make sure it works.

```console
(venv) nextpnr $ nextpnr-ice40
"nextpnr-ice40" -- Next Generation Place and Route (Version nextpnr-0.6-29-g54b20457)

General options:
  -h [ --help ]                         show help
  -v [ --verbose ]                      verbose output
  -q [ --quiet ]                        quiet mode, only errors and warnings
                                        displayed
  --Werror                              Turn warnings into errors
  -l [ --log ] arg                      log file, all log messages are written
                                        to this file regardless of -q

[... lots of output ...]

  --opt-timing                          run post-placement timing optimisation
                                        pass (experimental)
  --tmfuzz                              run path delay estimate fuzzer
  --pcf-allow-unconstrained             don't require PCF to constrain all IO

(venv) nextpnr $
```

At this point our Amaranth can now use our installed tooling to program the
iCEBreaker. The board definitions we installed earlier can be executed directly
to program a test blink gateware—doing this exercises the full toolchain.
Verify:

```console?prompt=nextpnr%20$
(venv) nextpnr $ python -m amaranth_boards.icebreaker
init..
cdone: high
reset..
cdone: low
flash ID: 0xEF 0x40 0x18 0x00
file size: 104090
erase 64kB sector at 0x000000..
erase 64kB sector at 0x010000..
programming..
done.
reading..
VERIFY OK
cdone: high
Bye.
(venv) nextpnr $
```

[§ Prerequisites]: https://github.com/YosysHQ/nextpnr#prerequisites
[nextpnr-ice40]: https://github.com/YosysHQ/nextpnr#nextpnr-ice40
[rpath]: https://duerrenberger.dev/blog/2021/08/04/understanding-rpath-with-cmake/
[ldso]: https://unix.stackexchange.com/a/22999/577154

</section>

<section id="symbiyosys">

## SymbiYosys

[Formal verification] can be orchestrated with SymbiYosys. To get started with
formal verification and Amaranth, have a look at [Robert Baruch's graded
exercises for Amaranth HDL][amaranth-exercises], which start with formal methods
from the very first exercise. They use the tools we install here.

[SymbiYosys] is a relatively simple frontend, so fetch the repo and install. It
also has a Python dependency, `click`. Check that `sby -h` doesn't give an
error:

```console?prompt=sby%20$
(venv) sby $ make PREFIX=$HOME/.local install
mkdir -p /home/charlotte/.local/bin
mkdir -p /home/charlotte/.local/share/yosys/python3
cp sbysrc/sby_*.py /home/charlotte/.local/share/yosys/python3/
sed -e 's|##yosys-program-prefix##|"''"|' < sbysrc/sby_core.py > /home/charlotte/.local/share/yosys/python3/sby_core.py
sed 's|##yosys-sys-path##|sys.path += [os.path.dirname(__file__) + p for p in ["/share/python3", "/../share/yosys/python3"]]|;' < sbysrc/sby.py > /home/charlotte/.local/bin/sby
chmod +x /home/charlotte/.local/bin/sby
(venv) sby $ pip install click
Collecting click
  Using cached click-8.1.3-py3-none-any.whl (96 kB)
Installing collected packages: click
Successfully installed click-8.1.3
(venv) sby $ sby -h
usage: sby [options] [<jobname>.sby [tasknames] | <dirname>]

positional arguments:
  <jobname>.sby | <dirname>

[... lots of output ...]

  --init-config-file INIT_CONFIG_FILE
                        create a default .sby config file
(venv) sby $
```

Check `sby -h` doesn't give an error.

[amaranth-exercises]: https://github.com/RobertBaruch/amaranth-exercises

</section>

<section id="z3">

## Z3

[Z3] is a [theorem prover] — it does the heavy lifting of formal verification.
Clone the repo; we're going to follow the [CMake instructions].  The defaults
are all good, except for the install prefix:

```console
(venv) z3 $ mkdir build
(venv) z3 $ cd build
(venv) build $ cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/.local
-- The CXX compiler identification is GNU 12.2.0
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Z3 version 4.12.3.0

[... lots of output ...]

-- Configuring done
-- Generating done
-- Build files have been written to: /home/charlotte/z3/build
(venv) build $ make -j8
[  0%] Building CXX object src/util/CMakeFiles/util.dir/approx_set.cpp.o
[  0%] Building CXX object src/util/CMakeFiles/util.dir/approx_nat.cpp.o
[  0%] Building CXX object src/util/CMakeFiles/util.dir/debug.cpp.o

[... lots of output ...]

[ 98%] Linking CXX shared library ../libz3.so
[100%] Linking CXX executable ../../z3
[100%] Built target shell
[100%] Built target libz3
(venv) build $ make install
[  6%] Built target util
[  8%] Built target params
[  9%] Built target polynomial
[  9%] Built target automata

[... lots of output ...]

-- Installing: /home/charlotte/.local/include/z3_spacer.h
-- Installing: /home/charlotte/.local/include/z3_version.h
-- Installing: /home/charlotte/.local/bin/z3
(venv) build $
```

Done.

[theorem prover]: https://en.wikipedia.org/wiki/Automated_theorem_proving
[CMake instructions]: https://github.com/Z3Prover/z3/blob/master/README-CMake.md

</section>

<section id="overview">

## Overview

You're now ready to write and deploy gateware, with a toolchain selected, built
and installed by yourself in a self-contained and repeatable way.

There are many ways to pivot from here.

##### You need a different Python version.
`asdf` and virtual environments make this easy.

##### You want to understand Amaranth better.
You can modify your editable install directly, adding print debugging.

##### You need to write pure Verilog.
You can drive Yosys yourself.

##### You want to understand decisions made by Yosys better.
You can step-through debug Yosys: run your Amaranth build once, then invoke
Yosys with your debugger of choice using the arguments from the generated
`build/build_top.sh`.

##### You need to target a different family of boards.
nextpnr [supports][nextpnr README] a range of architectures.

##### You want to use a different solver with SymbiYosys.
If it's [supported][sby components] and on your `PATH`, it'll work.

[nextpnr README]: https://github.com/YosysHQ/nextpnr#readme
[sby components]: https://symbiyosys.readthedocs.io/en/latest/install.html#recommended-components

</section>
