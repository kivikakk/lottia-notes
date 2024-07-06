---
title: Time travel, raw
created_at: 2024-07-06T17:07:00+0300
kind: article
description: >-
  The typical hypothetical "who are you coding for" example meant to shock
  you into writing better code is "yourself in six months", but it turns out
  four is completely adequate to get lost.
---

<section id="top">

My raw log from my notes re: [Time travel] follows.

[Time travel]: 0008-time-travel.html

## Sae

RV32I with some RV32C/refactoring WIP from long ago. The WIP probably feels way too magic for me now, but we should take a look at it. Now uses Niar.

</section>

<section id="todos">

### TODOs

* [Decombing](#decombing)
* [RV32C](#rv32c) and associated refactor
	* Then add RV32E, RV64I?
* The entire test infra could be so much more robust.
* M extension
* A extension
* "Zicsr" extension
* BMC (WHAT DID THIS MEAN)
* ili9341spi interface

</section>

<section id="decombing">

### Decombing

First priority is decombing the design to try to get the build time down. It's currently redonkulous:

```
[2024-07-03 13:05:24,917] niar: INFO: building sae for icebreaker
[2024-07-03 13:05:24,917] niar: DEBUG: starting elaboration
[2024-07-03 13:05:25,148] niar: DEBUG: elaboration finished in 0:00:00.230441
[2024-07-03 13:05:25,148] niar: DEBUG: 'sae.il': 425,987 bytes
[2024-07-03 13:05:25,148] niar: DEBUG: starting synthesis/pnr
[2024-07-03 13:05:25,148] niar: INFO: [run]   execute_build
[2024-07-03 13:08:12,179] niar: DEBUG: synthesis/pnr finished in 0:02:47.031564
[2024-07-03 13:08:12,207] niar: INFO: 
[2024-07-03 13:08:12,207] niar: INFO: === sae ===
[2024-07-03 13:08:12,207] niar: INFO: 
[2024-07-03 13:08:12,207] niar: INFO:    Number of wires:               2859
[2024-07-03 13:08:12,207] niar: INFO:    Number of wire bits:           9313
[2024-07-03 13:08:12,207] niar: INFO:    Number of public wires:        2859
[2024-07-03 13:08:12,208] niar: INFO:    Number of public wire bits:    9313
[2024-07-03 13:08:12,208] niar: INFO:    Number of ports:                  4
[2024-07-03 13:08:12,208] niar: INFO:    Number of port bits:              4
[2024-07-03 13:08:12,208] niar: INFO:    Number of memories:               0
[2024-07-03 13:08:12,208] niar: INFO:    Number of memory bits:            0
[2024-07-03 13:08:12,208] niar: INFO:    Number of processes:              0
[2024-07-03 13:08:12,208] niar: INFO:    Number of cells:               5732
[2024-07-03 13:08:12,208] niar: INFO:      $scopeinfo                     19
[2024-07-03 13:08:12,208] niar: INFO:      SB_CARRY                      452
[2024-07-03 13:08:12,208] niar: INFO:      SB_DFF                         79
[2024-07-03 13:08:12,208] niar: INFO:      SB_DFFE                        35
[2024-07-03 13:08:12,208] niar: INFO:      SB_DFFESR                    1380
[2024-07-03 13:08:12,208] niar: INFO:      SB_DFFSR                        8
[2024-07-03 13:08:12,208] niar: INFO:      SB_GB_IO                        1
[2024-07-03 13:08:12,208] niar: INFO:      SB_IO                           3
[2024-07-03 13:08:12,208] niar: INFO:      SB_LUT4                      3737
[2024-07-03 13:08:12,208] niar: INFO:      SB_RAM40_4K                    18
[2024-07-03 13:08:12,208] niar: INFO: 
[2024-07-03 13:08:12,208] niar: INFO: Device utilisation:
[2024-07-03 13:08:12,208] niar: INFO:            ICESTORM_LC:  5033/ 5280    95%
[2024-07-03 13:08:12,208] niar: INFO:           ICESTORM_RAM:    18/   30    60%
[2024-07-03 13:08:12,208] niar: INFO:                  SB_IO:     4/   96     4%
[2024-07-03 13:08:12,208] niar: INFO:                  SB_GB:     5/    8    62%
[2024-07-03 13:08:12,208] niar: INFO:           ICESTORM_PLL:     0/    1     0%
[2024-07-03 13:08:12,208] niar: INFO:            SB_WARMBOOT:     0/    1     0%
[2024-07-03 13:08:12,208] niar: INFO:           ICESTORM_DSP:     0/    8     0%
[2024-07-03 13:08:12,208] niar: INFO:         ICESTORM_HFOSC:     0/    1     0%
[2024-07-03 13:08:12,208] niar: INFO:         ICESTORM_LFOSC:     0/    1     0%
[2024-07-03 13:08:12,208] niar: INFO:                 SB_I2C:     0/    2     0%
[2024-07-03 13:08:12,208] niar: INFO:                 SB_SPI:     0/    2     0%
[2024-07-03 13:08:12,208] niar: INFO:                 IO_I3C:     0/    2     0%
[2024-07-03 13:08:12,208] niar: INFO:            SB_LEDDA_IP:     0/    1     0%
[2024-07-03 13:08:12,208] niar: INFO:            SB_RGBA_DRV:     0/    1     0%
[2024-07-03 13:08:12,208] niar: INFO:         ICESTORM_SPRAM:     0/    4     0%
[2024-07-03 13:08:12,208] niar: INFO: 
```

After moving the fault check out of `fetch.resolve`: 1:47, 4825 LCs.\
After using `.all()`: 1:44, 4802 LCs.\
After fixing our IL digest behaviour: priceless.

After splitting out just OP_IMM: 404k IL, 2:36, 5038 LCs. O_o\
I guess I need to split out the decode a little more? Or maybe it's just a matter of decomposing more.

After replacing multiple `m.d.sync += self.write_xreg(v_i.rd, ...)` with one of those and a comb wire `out` for the value: **404k IL, 1:35, 4851 LCs**.

We'll split it out as much as possible at first, and then slowly reintegrate. We already do the register save in `fetch.init`, and now with some care after splitting out OP_IMM it's a bit better again.

Need to remember that the toolchain does _much less deduplication than we assume_. Keep going on that, esp with insn decode.

Using `~insn[:16].bool()` instead of `== 0`: **404k IL, 1:52, 4800 LCs**.\
Using `wb_reg.any()` instead of `!= 0`: **no change**.

After splitting out LOAD: **404k IL, 1:59, 4945 LCs**. Uhm.\
After factoring the xreg fetch into common: **402k IL, 1:46, 4972 LCs**. Hmmmmmm.

After adding the read register: ran out of BELs. Welp. (6515 cells.)\
After changing the read register comb->sync: 6394 cells. Improved slightly.\
After splitting out OP: **371k IL, 7166 cells**. …\
After refactoring OP with `out`: 7120 cells.\
After splitting out STORE: **368k IL, 7134 cells**.\
After splitting out BRANCH: **343k IL, 6386 cells**.\
After splitting out JALR: **339k IL, 5599 cells and PNR is working again**.\
After changing `jump(m, pc)`'s context manager return to `~_.bool()`: **339k IL, 5602 cells**. Uh, ok. Reverting that for now just 'cause maybe there's a cross-over point (size of bv).

Using `any()` instead of `bool()` causes cell reduction? At 5587. **339k IL, 1:04, 4774 LCs**.\
OK, switching sync->comb on read regs bumps back up to 5664 (+77), and increases PNR time significantly (maybe because we're close to cell count?). **338k IL, 2:41, 4984 LCs (94%)**.

Next step is to do the instruction decode in one place and then pass info to following stages.

Added `imm` and `funct3` to LOAD: **342k IL, 1:06, 4905 LCs (92%)**.\
Did the same to OP_IMM: **342k IL, 0:58, 4886 LCs (92%)**.\
Removed `v_sxi` wire and just used `imm[:12].as_signed()` in place: **342k IL, 1:01, 4907 LCs (92%)**.\
Did same deal to OP: **343k IL, 1:01, 4806 LCs**.\
Did same deal to STORE: **344k IL, 1:16, 4816 LCs**. !!!\
I forgot to only use the bottom 12 bits of `imm`. Fixed: **344k IL, 1:09, 4910 LCs**. What?\
Try doing the sign-extension in resolve: **344k IL, 1:13, 4845 LCs**.\
Do the thing for BRANCH: **337k IL, 1:20, 4859 LCs**.\
JALR too, that's everything: **337k IL, 1:13, 4812 LCs**.\
Drop `v_sxi` and do the sign extension in resolve: **336k IL, 1:15, 4825 LCs**.\
Same for LOAD: **336k IL, 1:17, 4774 LCs (90%)**. Huh.

op.op_imm and op.op can be refactored.\
Hackily done: **333k IL, 0:59, 4595 LCs**. OK yeah, that helps!\
Done so that it actually works (still hack): **333k IL, 1:05, 4633 LCs (87%)**.

Put register file in memory now that it's all separated out.\
(How much is it using, really? Half XCOUNT: **288k IL, 0:19, 3340 LCs (63%)**. OK, quite a bit.)

Pico fits in 750–1000. SERV fits in 198??????

Dumped it in a register file. Gave it two read ports so no existing code has to change, I think it's just duplicated the memories but they're so small it doesn't matter. **265k IL, 0:13, 2367 LCs (44%)**.

Cleaned up our reg read and write logic: **264k IL, 0:14, 2300 LCs (43%)**.

TODOs remaining:

* [x] Read all the accepted Amaranth RFCs.

OK cool.

* [x] Do a once-over and generally clean up the Hart.

2291 LCs.\
2162 LCs after combing the MMU interface.\
2269 when I do it to the MMU write port. No point since we have to register a lot anyway. Back to 2162. Similarly it grows when I use comb to set `req_width` — maybe because everything else in the FSM (back at this point) is sync, so they all switch together. Hrm.

Let's try changing the write_xreg to comb. Basis: `8e3c38ca`, 2162 LCs. Hm, nah — this can't work. We assemble the components over multiple cycles fairly often (use `xwr_reg` to store `v_X.rd` etc.). What about read_xreg? The result is we *must* read the result when expected, since we're no longer registering the address. I anticipate a growth in LCs (but faster reads).

2266 LCs, but haven't removed the extra states yet so tests all fail.\
2303 LCs, necessitated an ALU refactor. So I don't think there's a benefit to this other than speed? Let's see how many cycles CXXRTL gains.\
57508 after change, 57505 before. Well! The ALU split is something though, if I keep that it's gonna be uglier anyway. How can I fix up?

Maybe we can tell the ALU where to read its inputs.

Adding a top-level "delay" that gates the whole FSM adds 100LCs. It'd be nice to have _one_ wait state. Ah well.

2230 LCs after centralising the ALU. Splitting it into two stages gets us to … 2246? Oh. OK. Really didn't expect that. Guess I won't do that.

If we don't have reg read _always on_, we can actually shuffle bits like `imm` _into_ `xrd2_val`.

Up to 2303 on adding `xrd[12]_en`. … and hold the phone, `xrd2_val` is comb-driven. Nvm.\
It barely helps us anyway since we need to post-process for the ALU. Cancel that.

2202 after dropping the `m.If(funct7[5])` out of the `Else()` block — _we_ know they're mutually exclusive, whereas it doesn't.

On the contrary, 2189 after changing the `m.If(funct3 == …ADDSUB): … / m.If(funct3 == ….SR)` to if/elif: easier mux? It resembles a switch (which are probably optimised …).

2202 after collapsing l.wait states. Cleaner. 2194 after fixing the default bug — that's 41%.

I would love to get a better idea _where_ all these cells are being spent, but it's pretty hard to say after optimisations.

* [x] Consider the same for the MMU.
	* [x] At minimum, use `amaranth.lib.stream` for its interface.
* [x] Stop embedding the "address bus" in the MMU along with the UART hook.
* [x] Clean up UART.
* [ ] Move onto the big task.

#### Aside: ABTest

**I feel like I want to make a little sandbox or something that makes evaluating the RTLIL diff between Amaranth expressions easier (optionally running it through `opt` or all the way through synthesis).** Ideally it could even run in-situ, i.e.

```python
with ABTest.A():
    m.d.comb += blah.eq(x[:16] == 0)
with ABTest.B():
    m.d.comb += blah.eq(~x[:16].bool())
```

Or even:

```python
m.d.comb += blah.eq(ABTest(x[:16] == 0, ~x[:16].bool()))
```

All such sites would be toggled individually (with others defaulting to "A", no cartesian product) and then outputs presented for comparison.

Sae's a bit slow to try this with right now.

</section>

<section id="rv32c">

### RV32C

This will take some re-understanding. We know the shape of the ISA(s) better now so we might be able to design something less Heppin Magic.

The cherry-picking went fairly straightforwardly, lots of conflicts but all easily resolved. Glad we did it in this order!

There's _so_ much magic in `isa.py` that I'm resolved to redesign this in a much more straightforward way.

</section>

<section id="design">

#### Design

Users of an ISA defined with this tool:

* assembler/disassembler
	* Opcodes and registers accessible via reflection, including support for defining shorthands (`J`, `LI`, etc.).
	* Need to be able to go the other way, too.
* gateware
	* Clear and easy access to layouts and op constants.
	* Exposes metadata like ILEN/XLEN/XCOUNT for gateware to use.
* subclassing ISAs
	* Can be added to, removed from (e.g. RV32E reducing XCOUNT).
	* 

Goals:

* Much less magic.
	* Avoid metaclasses, avoid `__call__`.
	* Inspecting signatures is OK
* Just enough flexibility to express RV; other ISAs are currently a non-goal.
	* I _think_ the current design encapsulates most of what we'll need here.

Notes on the existing design:

* Our current design doesn't include an intermediate representation: `IThunk.__call__` winds up calling `shape.const().as_value().value`, building up args to pass to `const()`; there's no real point of "calling it done" except for the first time it's called.
* Many layouts define immediates in groups of `imm0_4`, `imm5`, `imm6_11` kinds of things. Sometimes they also omit e.g. `imm0` (implied 0). 
* An `ISA` has a notion of a `Register`, which is a class defined in the return value of `ISA.RegisterSpecifier()` (!).
	* This uses `locals().update(members)` to define the members of an `IntEnum`, where registers is built up from a list of (name, alias0, …, aliasn) tuples and a target size.
	* I think we'll still need something like this; it's actually one of the least magic parts of this.
* All `ISA` members can define `_needs_named` and `_needs_finalised` attributes, processed in `ISAMeta.__new__`.
	* `_needs_named` causes the assignment of `__name__` and `__fullname__` attributes, according to the name being assigned to.
	* `_needs_finalised` calls `finalise` on the object with a reference to the `ISA`.
	* This lets members finish initialising themselves with an awareness of everything else defined in the `ISA`, including things defined (lexically) after them.
	* `ILayout` is an empty baseclass with an `ILayoutMeta` metaclass.
	* `ILayoutMeta.__new__` takes an optional argument `len` and assigns it to `cls.len` (where `cls` is the newly-created class).
	* If `layout` is specified, it marks the class as needing finalisation and checks that `cls.len` is in fact defined (either now, or in a superclass). Otherwise, it's considered a layout base class.
	* `ILayoutMeta.finalise`:
		* assembles the defining context dictionary by iterating the `ISA`'s MRO backwards for their `dir()`s, discounting names starting with underscore (`_`);
			* In other words, items in the `ISA` class and superclasses define the context for type-shape lookups.
		* assembles the full type-shape dictionary by iterating the `ILayout` instance's MRO backwards for annotations, starting from after `ISA.ILayout` itself;
			* In other words, annotations in class and its `ISA.ILayout` superclasses define the set of type-shapes available to `layout` items.
			* The context dictionary is used as `locals()` here.
		* iterates over the `layout` tuple given by the subclass, constructing `cls._fields` by matching names to `ShapeCastable`s:
			* Members can be strings, in which case they refer to an annotation with a matching name.
				* If the exact match lookup is unsuccessful, the class's `resolve()` function is called with some context (the remaining items in the layout, length of instruction remaining needing to be allocated to a field), which must succeed.
			* Members can be `(name, shapecastable)`.
		* initialises `cls.shape = StructLayout(cls._fields)`.
		* initialises `cls.values` and `cls.defaults` by calling `resolve_values` on the class's existing (set by subclass definition) `values` and `defaults` members, if any.
			* These may not overlap.
			* `ints` are `ints`, strings are treated as keys for the `ShapeCastable` for the corresponding field.
				* If item lookup fails, the `ShapeCastable`'s `__call__` is tried.
	* `ILayoutMeta.resolve` just raises an error. Is this really exposed on subclass instances? Surprising.
	* `ILayoutMeta.xfrm` constructs the class and calls `xfrm` on it.
		* If `I` is an `ILayout` subclass, this just means `I.xfrm(…)` is the same as `I().xfrm()`, i.e. get an unrefined thunk and then transform it.
			* _Digression:_ for whatever reason we really like being able to use classes in these positions. It "must" be a class because it's the result of defining something with `class Blah:`, which itself is needed because we often want to supply code, nested classes, etc. But why the insistence on calling the class itself? We don't _ever_ have class instances, and doesn't that seem a bit strange?
			* Thinking forward, the class instances should be the intermediate representation, not a separate thunk class. You call `I()` or `I(a=b)`, you get a `<myisa.MyISA.I object>`, with the args hitting `I.__init__` like a regular human being.
			* This prevents our delightful (…) hack with `I(s)`. We can actually just call it `I.shape(s)`, which already exists because that's what it does lol!!
			* I have some lingering concerns here around repeated work that currently happens in `finalise` etc. but let's deoptimise now, and reoptimise after the design is sane.
	* `ILayoutMeta.__call__` allows zero or one positional arguments, plus kwargs.
		* In the above example, this is `I(…)`.
		* Zero positionals asserts a layout is defined, and returns a new `IThunk(cls, kwargs)`.
			* In other words, `"I(a=b)"`. This denotes a partially refined instruction based on `I`.
			* Note that even `I()` is valid syntax, to get the same kind of thunk but not refining any part of it.
		* One positional asserts a `Signal` argument is given and wraps it in the subclass's `shape` (`cls.shape(s)`), so you can call `I(s)` to decode `s`.
	* The `IThunk` is as close as we get to an "intermediate representation" here.
		* Sets `_needs_named`, as it's probably going to be assigned in an expression like `ADDI = I(funct3=I.IFunct.ADDI)`.
		* Stores the class it was constructed from and the `kwargs` we got.
		* `xfrms` initialised to empty.
		* `asm_args` is defined from `list(self.layout)`: it's the list of arguments an assembly call need to provide. If your layout is `("opcode", "rd", "imm")`, we need an opcode, dest register and immediate.
			* `opcode` is defined as type `Opcode` and `rd` as `Reg` in the defining context, and `imm` is handled in `IL.resolve` when it's in the final position.
			* The `opcode` is refined by being specified in `kwargs`, leaving just `rd` and `imm` for the "asm args". So how does that happen?
		* We iterate over all `values` and `defaults` in the IL class, and names in `kwargs`, removing from `asm_args` any specified there.
		* Next we iterate names in `kwargs`, asserting all specified are a part of the `layout`, and none are part of the IL class's `values` (the distinction between `values` and `defaults` being whether they can be overridden in a thunk ctor or not).
	* It has `clone()` and `partial(**kwargs)`; the former returns a new `IThunk` with copies of all settings (for declaration, immutable definition), the latter clones and updates `clone.kwargs` with given kwargs, removing those from `clone.asm_args` (further refinement of an `IThunk`).
	* It also has `xfrm(xfn, **kwarg_defaults)`, which appends a new transform to `clone.xfrms`, with some optional default kwargs.
		* Transforms are a function which are handed a set of kwargs, and return a dict to update kwargs given to the next one (or to the `ilcls.shape.const(…)` call at the end).
		* The kwargs start out as the thunk's own `kwargs` mixed with any given to the `IThunk.__call__`, latter superseding the former.
		* The transform function's signature is analysed: if you take a parameter `x`, the kwarg `x` is filled in (mandatory). If you specify `x=default`, then `kwarg_defaults` and finally `default` are used as fallbacks.
			* I wonder why `kwarg_defaults` is only allowed when no default is given. I guess they're either really mandatory to specify, or possibly optional.
			* An example here is `shamt_xfrm(shamt, *, imm11_5=0)`. `SRAI` overrides this with `SRAI = I(funct3=I.IFunct.SRI).xfrm(I.shamt_xfrm, imm11_5=0b0100000)`; the others don't override it at all.
			* In other words, `kwarg_defaults` is more like "default overrides". In either case I don't imagine a user is actually setting one in a thunk, so maybe they should be treated that way.
		* What's unspecified here is a way for transforms to also transform `asm_args`, and that's where I got up to with`# clone.asm_args. ## RESUME XXX GOOD LUCK`.
	* When an `IThunk` is called, we resolve the `args_for` the given kwargs.
		* We call the transform pipe with `self.kwargs | args`, i.e. those given while constructing the thunk mixed with those given while calling it.
		* The result of the pipe is asserted to match the layout and not override anything it's not allowed to override.
		* The `ilcls.values`, `ilcls.defaults` (both already 'resolved') and result of resolving the pipe's output are all combined and become the args passed to `shape.const`.
	* Note that transforms are called in the order given, so we must transform `asm_args` back-to-front, as inputs used by earlier transforms may be provided by later ones.
		* Actually this is just backwards unless we do yet-more-thunking/accumulating. Let's reverse the order of how it should be called, so we can apply `asm_args` changes as `xfrm()` is called repeatedly. Actually call the transforms in reverse order.

</section>
