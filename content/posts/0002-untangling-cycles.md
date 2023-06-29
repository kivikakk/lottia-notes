---
title: Untangling cycles
created_at: 2023-06-29T10:51:00+1000
kind: article
---

This is straight from my journal, so it starts without warning.

---

The bit packing is turning out to be surprisingly tricky!

Memory is synchronous but our uses of `addr[0]` were all comb, so they didn't
align with the actual target in the cycle it got transmitted from memory when we
were advancing `addr` every cycle. This was a really good exercise in Being
Confused As Heck.

Going to try to explicate the above a bit more clearly for my own elucidation.
Ignoring the write half of the equation for simplicity—the issues faced are the
same.

This post is literate Python. Why not. We have the following as baseline:

```python literate
import math
from typing import Optional

from amaranth import Elaboratable, Memory, Module, Record, Signal
from amaranth.build import Platform
from amaranth.hdl.ast import ShapeCastable
from amaranth.hdl.mem import ReadPort
from amaranth.hdl.rec import DIR_FANIN, DIR_FANOUT
from amaranth.sim import Simulator


class ROMBus(Record):
    def __init__(self, addr: ShapeCastable, data: ShapeCastable):
        super().__init__(
            [
                ("addr", addr, DIR_FANIN),
                ("data", data, DIR_FANOUT),
            ],
            name="ROMBus",
        )

class Downstream(Record):
    def __init__(self):
        super().__init__(
            [
                ("data", 8, DIR_FANIN),
                ("stb", 1, DIR_FANIN),
            ]
        )
```

A `ROMBus` is a connectable path to access some read-only memory. `Downstream`
here is a hypothetical recipient of data being read from ROM. (The ROM is
actually a RAM that gets filled on power-on from flash.)

The key problem I was solving was that, until now, I've been storing all my data
in 8-bit wide `Memory` instances, but a lot of the actual embedded block RAM I'm
using has 16-bit wide words. As a result, the upper 8 bits of every word has
been left unused.

It'd be nice to add a translation layer that transparently forwarded reads and
writes from an 8-bit addressable space into the 16-bit words. Even bytes in the
lower halves, odd bytes in the upper halves. Here's what that'd look like:

```python literate
ROM_CONTENT_PACKED = [0x2211, 0x4433, 0x6655, 0x8877]
ROM_LENGTH = 8
```

The length of the ROM that all the downstream consumers care about is the 8-bit
addressable one—address 0 has `0x11`, address 1 `0x22`, etc. The fact that we
have 8 bytes packed into 4 words of 16 bits is irrelevant to them.

Here's where our example will play out:

```python literate
class Example(Elaboratable):
    def __init__(self):
        self.downstream = Downstream()

    def elaborate(self, platform: Optional[Platform]):
        m = Module()
```

The `Downstream` is exposed on the instance so we can access it from our
simulator process.

We now need to do the following things:

* Determine the size of the packed RAM.
* Create our `Memory` instance for it.
    * We'll initialize it with `init` here, and completely ignore the write
      aspect of the scenario. The issues it will suffer from are the same. (I
      sure suffered!)
* Get the `ReadPort` for our RAM. I'm asserting the lengths here illustratively for the reader's benefit.

```python literate
        packed_size = math.ceil(ROM_LENGTH / 2)
        rom_mem = Memory(
            width=16,
            depth=packed_size,
            init=ROM_CONTENT_PACKED,
        )
        m.submodules.rom_rd = rom_rd = rom_mem.read_port()
        assert len(rom_rd.addr) == 2
        assert len(rom_rd.data) == 16
```

`rom_rd.addr` determines the address in the 16-bit-wide RAM (`0x0`–`0x3`), and
`rom_rd.data` returns those 16 bits. `Memory` is [synchronous by
default](https://github.com/amaranth-lang/amaranth/blob/99417d6499b006a172d5b8cba413fd6181737374/amaranth/hdl/mem.py#L153)
(and the read enable is also [always on under default
settings](https://github.com/amaranth-lang/amaranth/blob/99417d6499b006a172d5b8cba413fd6181737374/amaranth/hdl/mem.py#L165-L169)),
so, given a made-up `mem[x]` operator, the following timeline applies:

* cycle *n*+0: some process assigns `rom_rd.addr.eq(x)`
* cycle *n*+1: the read port sees its new `addr` value and assigns
  `rom_rd.data.eq(mem[x])`
* cycle *n*+2: `rom_rd.data` takes the value of `mem[x]`

Now we'll create our `ROMBus`. This is what all the RTL I had was already
using—it was connected directly to the read port of the 8-wide memory.

```python literate
        rom_bus = ROMBus(range(ROM_LENGTH), 8)
        assert len(rom_bus.addr) == 3
        assert len(rom_bus.data) == 8
```

We're going to put the actual translation logic and state machine in separate
functions, so they can be changed later while preserving the literacy of this
post. _Why not_.

```python literate
        self.translation(m, rom_rd, rom_bus)
        self.fsm(m, rom_bus)

        return m
```

We want to hook up the ROM bus to the memory in a transparent fashion. Here's
what I started with:

```python literate
    def translation(self, m: Module, rom_rd: ReadPort, rom_bus: ROMBus):
        m.d.comb += [
            rom_rd.addr.eq(rom_bus.addr >> 1),
            rom_bus.data.eq(
                rom_rd.data.word_select(rom_bus.addr[0], 8)
            ),
        ]
```

* We shift off the last bit of the input (8-bit) address to create the output
  (16-bit) address, creating the following mapping:

  |   8-bit address | 16-bit address |
  | --------------: | -------------: |
  | `0x0` / `0b000` | `0x0` / `0b00` |
  | `0x1` / `0b001` | `0x0` / `0b00` |
  | `0x2` / `0b010` | `0x1` / `0b01` |
  | `0x3` / `0b011` | `0x1` / `0b01` |
  | `0x4` / `0b100` | `0x2` / `0b10` |
  | `0x5` / `0b101` | `0x2` / `0b10` |
  | `0x6` / `0b110` | `0x3` / `0b11` |
  | `0x7` / `0b111` | `0x3` / `0b11` |

* We select the 8-bit word from the 16-bit data coming out of the memory corresponding to the LSB of the input (8-bit) address.
    * `a.word_select(b, w)` is essentially `a[b*w : (b+1)*w]`.
    * When the LSB of the 8-bit address is 0, this will select `rd_data[0:8]`.
      When the LSB is 1, this will select `rd_data[8:16]`.
    * So:
        * 8-bit address `0x0` will select `mem[0x0][0:8]`,
        * 8-bit address `0x1` will select `mem[0x0][8:16]`,
        * 8-bit address `0x2` will select `mem[0x1][0:8]`,
        * 8-bit address `0x3` will select `mem[0x1][8:16]`,
        * etc.

Now we implement a reader from our ROM:

```python literate
    def fsm(self, m: Module, rom_bus: ROMBus):
        m.d.sync += self.downstream.stb.eq(0)

        with m.FSM():
            with m.State("INITIAL"):
                # cycle n+0
                m.d.sync += rom_bus.addr.eq(0)
                m.next = "WAIT"

            with m.State("WAIT"):
                # cycle n+1 / n'+1
                m.next = "READ"

            with m.State("READ"):
                # cycle n+2, n'+0
                m.d.sync += [
                    self.downstream.data.eq(rom_bus.data),
                    self.downstream.stb.eq(1),
                    rom_bus.addr.eq(rom_bus.addr + 1),
                ]
                m.next = "WAIT"
```

This is a simple process that reads data and passes them along to some
downstream process (which needs to be able to accept this data as fast as we
give it to them!).

* We start at address zero (*n*+0),
* wait a cycle for the memory to see it (*n*+1),
* and then pass it to the downstream (*n*+2) while advancing the address we read
  (*n*’+0).
* The next cycle we're back in `WAIT` as advanced address is seen by the memory
  (*n*’+1).

We end up strobing the downstream every other cycle. (That strobe is seen in the
*n*+1 / *n*’+1 cycle.)

Let's simulate it and report the results:

```python literate
def main():
    dut = Example()

    def process():
        count = 0
        yield
        while True:
            if (yield dut.downstream.stb):
                print(f"data: {(yield dut.downstream.data):02x}")
                count += 1
                if count == 8:
                    return
            yield

    sim = Simulator(dut)
    sim.add_clock(1e-6)
    sim.add_sync_process(process)
    sim.run()
```

This can now be run:

```console
$ python -c 'import ex; ex.main()'
data: 11
data: 22
data: 33
data: 44
data: 55
data: 66
data: 77
data: 88
```

It's perfect!

Almost. Let's revisit the timeline for accessing the synchronous memory:

* cycle *n*+0: `rom_rd.addr.eq(x)`
* cycle *n*+1: read port sees new `addr`, assigns `rom_rd.data.eq(mem[x])`
* cycle *n*+2: `rom_rd.data` sees `mem[x]`

The important part is that you can assign a new address `y` in cycle *n*+1,
without impacting what happens in cycle *n*+2, such that `mem[y]` is now
available to use in cycle *n*+3. The read port will only see the address `y` in
the same cycle that it's already propagated `mem[x]` into its data register.

Let's now change our state machine to take advantage of this:

```python literate
def fsm(self: Example, m: Module, rom_bus: ROMBus):
    m.d.sync += self.downstream.stb.eq(0)

    with m.FSM():
        with m.State("INITIAL"):
            # cycle n+0
            m.d.sync += rom_bus.addr.eq(0)
            m.next = "WAIT"

        with m.State("WAIT"):
            # cycle n+1, n'+0
            m.d.sync += rom_bus.addr.eq(1)
            m.next = "READ"

        with m.State("READ"):
            # cycle n+2, n'+1, n''+0
            m.d.sync += [
                self.downstream.data.eq(rom_bus.data),
                self.downstream.stb.eq(1),
                rom_bus.addr.eq(rom_bus.addr + 1),
            ]


Example.fsm = fsm
```

- We start at address zero (*n*+0),
- while waiting a cycle for the memory to see it (*n*+1), we also increment the
  address to one (*n*’+0),
- and then pass the first result the downstream (*n*+2), while the memory is
  just now seeing the second result (*n*’+1), and simultaneously increment the
  address we read (*n*’’+0).

We don't change state once we're in `READ`: every cycle we hand to downstream
the data from the address we set two cycles ago; every cycle the memory is
seeing the address we gave one cycle ago; every cycle we increment the address
to keep it going.

This is pretty theoretical in this form, but I have a few state machines that do
this kind of sliding continuous read in a limited fashion.

So what happens?

```console
$ python -c 'import ex; ex.main()'
data: 22
data: 11
data: 44
data: 33
data: 66
data: 55
data: 88
data: 77
```

All the bytes are reversed! (This was a _lot_ weirder to debug when the same
problem might have been affecting the initial write to RAM, too.)

Why?

We'll review the translation statements:

```python
m.d.comb += [
    rom_rd.addr.eq(rom_bus.addr >> 1),
    rom_bus.data.eq(
        rom_rd.data.word_select(rom_bus.addr[0], 8)
    ),
]
```

This translation happens in the combinatorial domain, meaning that `rom_rd.addr`
will change to `rom_bus.addr >> 1` as soon as a change on `rom_bus.addr` is
registered — there isn't an additional cycle between the requested 8-bit address
on the ROM bus changing and the read port's 16-bit address changing:

| cycle |    statement issued | <nobr>ROM bus</nobr> addr | <nobr>read port</nobr> addr | <nobr>read port</nobr> data |
| ----: | ------------------: | -----------: | -------------: | -------------: |
| 0     | `rom_rd.addr.eq(0)` |          _x_ |            _x_ |            _x_ |
| 1     | `rom_rd.addr.eq(1)` |          `0` |            `0` |            _x_ |
| 2     | `rom_rd.addr.eq(2)` |          `1` |            `0` |       `0x2211` |
| 3     | `rom_rd.addr.eq(3)` |          `2` |            `1` |       `0x2211` |
| 4     | `rom_rd.addr.eq(4)` |          `3` |            `1` |       `0x4433` |
| 5     | `rom_rd.addr.eq(5)` |          `4` |            `2` |       `0x4433` |

Similarly, the ROM bus data port will be updated as soon as the read port's data
port (`rom_rd.data`) changes.

It will _also_ be updated as soon as the LSB of the ROM bus's requested address
changes (`rom_bus.addr[0]`).

But by the time we're actually getting data in the read port for an address, the
ROM bus has registered the next address!  Thus we select the half of the 16-bit
word based on the LSB of the _following_ address, which (given the addresses are
sequential) will always be the opposite half to the one we really want:

| cycle | <nobr>ROM bus</nobr> addr | <nobr>read port</nobr> data | <nobr>ROM bus</nobr> <nobr>addr [0]</nobr> |  <nobr>ROM bus</nobr> data |
| ----: | -----------: | -------------: | ---------------: | ------------: |
| 0     |          _x_ |            _x_ |              _x_ |           _x_ |
| 1     |          `0` |            _x_ |              `0` |           _x_ |
| 2     |          `1` |       `0x2211` |              `1` |        `0x22` |
| 3     |          `2` |       `0x2211` |              `0` |        `0x11` |
| 4     |          `3` |       `0x4433` |              `1` |        `0x44` |
| 5     |          `4` |       `0x4433` |              `0` |        `0x33` |

We need to introduce a delay in the address as used by the translation on the
way back out, to account for the fact that read data corresponds to the address
from the previous registered cycle, not this one:


```python literate
def translation(
    self: Example,
    m: Module,
    rom_rd: ReadPort,
    rom_bus: ROMBus,
):
    last_addr = Signal.like(rom_bus.addr)
    m.d.sync += last_addr.eq(rom_bus.addr)

    m.d.comb += [
        rom_rd.addr.eq(rom_bus.addr >> 1),
        rom_bus.data.eq(rom_rd.data.word_select(last_addr[0], 8)),
    ]


Example.translation = translation
```

This gives:

| cycle | <nobr>ROM bus</nobr> addr | last <nobr>ROM bus</nobr> addr | <nobr>read port</nobr> data | last <nobr>ROM bus</nobr> <nobr>addr [0]</nobr> |  <nobr>ROM bus</nobr> data |
| ----: | --------: | ------: | ----------: | ---------: | ----------: |
| 0     |       _x_ |     _x_ |         _x_ |        _x_ |         _x_ |
| 1     |       `0` |     _x_ |         _x_ |        _x_ |         _x_ |
| 2     |       `1` |     `0` |    `0x2211` |        `0` |      `0x11` |
| 3     |       `2` |     `1` |    `0x2211` |        `1` |      `0x22` |
| 4     |       `3` |     `2` |    `0x4433` |        `0` |      `0x33` |
| 5     |       `4` |     `3` |    `0x4433` |        `1` |      `0x44` |

And so:

```console
$ python -c 'import ex; ex.main()'
data: 11
data: 22
data: 33
data: 44
data: 55
data: 66
data: 77
data: 88
```

I like how the _x_’s in this table don't flow back "up" in time as the data
dependencies flow right, whereas in the previous table, they do.
