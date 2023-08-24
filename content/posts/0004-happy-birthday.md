---
title: Happy birthday!
created_at: 2023-08-22T15:24:00+1000
updated_at: 2023-08-24T16:13:00+1000
kind: article
description: >-
  It's always your birthday!
---

<section id="opening">

I'm writing a little hardware I²C clock stretcher ([I²C, oh! Big stretch]) to
help me make my I²C controller implementation actually support it.

These are some moments I've had while doing so.

[I²C, oh! Big stretch]: https://github.com/charlottia/i2c_obs

</section>

<section id="oobe">

## Out-of-band experience

I added a [tiny UART module] to help me debug it. First I emitted a `<`
character when starting a big stretch, and a `>` character once we're all
relaxed.

[tiny UART module]: https://github.com/charlottia/i2c_obs/commit/1078a55c9f5bd63fae9707586393535ed7afcd07#diff-fbbd4dd0ae5cec5958577b18349c32c4e93ed8df0846aacdfe916267b503e6f4

I was going to then write the number of cycles counted during the SCL tLOW
period in decimal but eventually decided, Who Really Can Be Bothered, and just
shoved it out onto the UART, LSB first.

The initial test went great:

```console?prompt=>
@vyx ~> tio /dev/ttyUSB1 -b9600
[15:05:11.940] tio v2.5
[15:05:11.940] Press ctrl-t q to quit
[15:05:11.941] Connected
[15:10:05.065] Switched to hexadecimal mode
3c 0f 3e 3c 3e 3c 3e 3c 3e 3c 0f 3e
```

`3c` and `3e` are `<` and `>` respectively. You can see I had some fun while
realizing that I need to actually take steps to restart the FSM --- disabling it
isn't enough.

The I²C bus is running at 400kHz, meaning we expect the SCL low period to last
1/800,000th of a second.

The iCEBreaker the sleepy kitty is running on is running at 12MHz. At that
speed, 1/800,000th of a second passes in 12,000,000/800,000[^maths] = 15 cycles.

[^maths]: 1/(12MHz/800kHz) = 1/((1/12,000,000)/(1/800,000)) = 12,000,000/800,000.

And we were seeing `0f` in the output, 15! Perfect.

I recompiled the controller to run at 100kHz and continued the test.

```console
3c 3c 3e 3c 3c 3e 3c 3c 3e 3c 3c 3e 3c 3c 3e 3c 3c 3e
```

??? I thought I made a logic error and we were somehow resetting back to the
initial state without finishing measurement.

And then I said, "don't fucking tell me," because it's not too hard to add `0f`
to itself repeatedly in your head and so `0f`, `1e`, `2d`, `3c`. Happy birthday!

At this point I promptly changed the start/stop characters to `ff` and `fe`, and
then --- detecting that I was just setting up the next, much larger footgun for
myself --- decided to dump the count one _nibble_ at a time and thus render any
byte with a non-zero high nibble officially out-of-band, and [thus]:

```console
ff 0c 03 fe
```

</section>

<section id="measurement">

## Modes of measurement

The I²C controller I'm testing with/for outputs its clock at a 50% duty
cycle exactly[^fv]. I probably even verified that with a logic analyzer or
oscilloscope at some stage! Point is, my initial idea was to train on the SCL
tLOW period, and then start holding it low for ~twice that period as of the next
low, and thus stretch the clock (a LOT).

When you're a noob like me, you may encounter [this]:

[![a few breadboards with various boards on them, an OLED, a few LEDs, an oscilloscope, way too many cables, a mess][half-pull.jpg]][half-pull.jpg]

[this]: https://aperture.ink/@charlotte/110931900646817865
[half-pull.jpg]: https://aperture.ink/system/media_attachments/files/110/931/897/543/950/932/original/60650d4451ef74f2.jpeg

Here we have the bus only getting pulled up halfway. This is what it looks like
when someone is trying to ground your bus _at the same time_ as someone trying
to put high out on it. An I²C bus is designed to be _pulled_ high so that anyone
can pull it low, but we're seeing it _driven_ high.

The controller [needed] to turn SCL's output-enable off, to let it get pulled up
high on its own, and then only to switch the output-enable on when it needs to
be driven low. This lets anyone else on the bus keep SCL low, thus stretching
the clock.

[needed]: https://github.com/charlottia/sh1107/commit/bb7388b9f1a3635711337a304bc17e3c682c8508

This worked [nicely] when it comes to letting the bus stretch, but today I was
trying to get the measurement to come out right --- I wanted to have the little
debugging app that talks via UART reporting the correct I²C bus speed --- and
noticed that, actually, we're getting it wrong _not only because I'm failing to
count correctly_, but because the waveform _doesn't_ have a 50% duty cycle!

[nicely]: https://aperture.ink/@charlotte/110931938447021110

My poor baby oscilloscope can't actually measure fast enough to see it, but
_turns out_ letting a pull-up resistor bring a bus high takes a little bit
longer than driving it high. As a result, the tail end of the tLOW period is
eating into the start of tHIGH as it shakily makes its way back up to full
voltage. I absolutely need a way to see this, so I need a better scope I guess.

Anyway, I'll also measure from rising edge to rising edge (and falling edge to
falling edge), and that should give me some more insight. Logically, I expect
the falling-to-falling to be very consistent, because that transition is driven,
whereas the rising-to-rising might vary depending on when the signal gets high
enough to be considered "high" each cycle.

I just need to not accidentally reinvent the [Glasgow Interface Explorer] while
I'm here.

[Glasgow Interface Explorer]: https://www.crowdsupply.com/1bitsquared/glasgow

[^fv]: Hey, that sounds like something I could really formally verify.
  I have [the start] of a verification setup, might as well use it.
  
  [the start]: https://github.com/charlottia/sh1107/blob/7b05e685eb6ee53b9f069410c9f12005cd580d99/sh1107/formal/__init__.py#L133-L155

</section>

[thus]: https://github.com/charlottia/i2c_obs/commit/da9b89b43319114f3bb0fd43511ae934b10b7fac
