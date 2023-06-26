---
title: Installing an HDL toolchain from source
created_at: 2023-06-26T17:04:00+1000
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
manager, and macOS users using [Homebrew].  I'm going to avoid installing almost
anything globally, however, that wouldn't already get installed by your package
manager as a matter of course, especially when there's reasons you might need
multiple versions around.

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

That was easy. Now the opinions start.

Install the [`asdf` Multiple Version Runtime Manager][asdf]. The [Getting
Started][asdf getting started] page has commands for dependency installation
through package manager.  Use the official `git` method to download `asdf`
itself, and then follow the instructions for your shell.

Now install the Python `asdf` plugin, and install the latest stable version of
Python:

```console
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
→ https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tar.xz
Installing Python-3.11.4...
Installed Python-3.11.4 to /home/charlotte/.asdf/installs/python/3.11.4
~ $ asdf global python 3.11.4
~ $
```

(You might get some warnings about extensions not being compiled. That's OK.
There's also 3.12.0b3 available at time of writing, if you don't mind a beta.)

The last command makes it the default Python for our user. `asdf` puts some
shims in our PATH which use a combination of our configured defaults (`global`),
our current path (`local`), and environment variables (`shell`) to select the
desired version:

```console
~ $ which python
/home/charlotte/.asdf/shims/python
~ $ asdf current python
python          3.11.4          /home/charlotte/.tool-versions
~ $ asdf which python
/home/charlotte/.asdf/installs/python/3.11.4/bin/python
~ $ python
Python 3.11.4 (main, Jun 26 2023, 16:06:57) [GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

[asdf]: https://asdf-vm.com/
[asdf getting started]: https://asdf-vm.com/guide/getting-started.html

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
development snapshot. You may want to clone it within your project directory, perhaps as a Git submodule, or along-side. I'm going with along-side.

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

[Amaranth installation instructions]: https://amaranth-lang.org/docs/amaranth/latest/install.html
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

    There's more that I've decided was better left forgotten.

[Yosys on Windows]: https://github.com/YosysHQ/yosys/blob/2310a0ea9a61ed14d2769f01283a5a7590cbe558/guidelines/Windows

[^wsl]: tl;dr: use your Linux user home directory, not your Windows user one;
    when it comes time to flash your board, follow the guide to [Connect USB
    devices] using [usbipd-win]. Don't mind the scary warning on the guide: I
    didn't have to recompile my kernel even on Windows 10.

[Connect USB devices]: https://learn.microsoft.com/en-us/windows/wsl/connect-usb
[usbipd-win]: https://github.com/dorssel/usbipd-win
