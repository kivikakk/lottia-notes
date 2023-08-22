---
title: Happy birthday!
created_at: 2023-08-22T15:24:00+1000
kind: article
description: >-
  It's always your birthday!
---

I'm writing a little hardware I²C clock stretcher ([I²C, oh! Big stretch]) to
help me make my I²C controller implementation actually support it.

I added a [tiny UART module] to help me debug it. First I emitted a `<`
character when starting a big stretch, and a `>` character once we're all
relaxed.

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

[I²C, oh! Big stretch]: https://github.com/charlottia/i2c_obs
[tiny UART module]: https://github.com/charlottia/i2c_obs/commit/1078a55c9f5bd63fae9707586393535ed7afcd07#diff-fbbd4dd0ae5cec5958577b18349c32c4e93ed8df0846aacdfe916267b503e6f4
[thus]: https://github.com/charlottia/i2c_obs/commit/da9b89b43319114f3bb0fd43511ae934b10b7fac

[^maths]: 1/(12MHz/800kHz) = 1/((1/12,000,000)/(1/800,000)) = 12,000,000/800,000.
