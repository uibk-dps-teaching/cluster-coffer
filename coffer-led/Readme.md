# Coffer LED

Arduino project to drive the neopixel LED strip in the cluster coffer.

## Hardware

The hardware is an Arduino Nano, which uses an ATmega328P microcontroller, connected to a strip of Neopixels, which use the WS2812 LED chip.

### Wiring

The data signal for the LEDs is connected to pin 6 on the arduino.

## Protocol

The protocol is fixed length of 17 bytes and currently supports two modes:

```
MSG: HEADER_BYTE + DATA_BYTE0 + ... + DATA_BYTE15

HEADER_BYTE:
    HIGH_NIBBLE = 0b1111 /* Magic number */
    LOW_NIBBLE = MODE

MODE:
    NONE = 0b0000
    BOOT = 0b0001
    LOAD = 0b0010

DATA_BYTE in BOOT mode:
    0b0 = Node has not booted
    0b1 = Node has booted

DATA_BYTE in LOAD mode:
    [0..100] = Load of the node as integer between 0 and 100 inclusive
```

A small test example implementing and demonstrating the protocol is available [here](https://goedis.dps.uibk.ac.at/Markus.Wippler/coffer-led-protocol).

### Magic number

The magic number in the header is used to stay in-sync with the host. The arduino keeps track of the header to know where a message starts. When a new header is received during a message, everything received so far is discarded and the new message is received instead.

### Modes

Only `BOOT` and `LOAD` are valid modes. `NONE` is only used internally and should not be sent as a message.

### Data

Data bytes with values greater or equal to 240 will cause problems, because that will be interpreted as a header. This is not a problem, however, because 100 is the greatest legal data byte value.

## Communication

The communication with the arduino is facilitated by an FTDI RS232 UART <-> USB chip.

### UART config

The UART is configured with the following settings:

- Baud rate: 2400
- Data bits: 8
- Parity: None
- Stop bits: 1
- Flow control: None

The very slow baud rate of 2400 is necessary, because the neopixel library disables interrupts while shifting out data to the LEDs. The hardware receive buffer still receives data, but only 1 byte can be buffered, otherwise the next byte received will overwrite the buffered byte. Therefore, interrupts can only be disabled for as long as it takes to receive 1 byte. The baud rate of 2400 guarantees that only 1 byte can be received while interrupts are disabled.

## Building on Windows

The easiest way to build the code is to use [Atmel Studio](https://www.microchip.com/mplab/avr-support/atmel-studio-7), which is based on Visual Studio Isolated Shell.
Just open the `led.atsln` file and you're ready to go.

**The arduino IDE is not required, because all dependencies are shipped directly.**

### Flashing

In order to flash the program to the arduino avrdude is required.
In Atmel Studio configure the custom programming tool to use the path to avrdude and the correct COM port, for example: `C:\bin\avrdude-6.3\avrdude.exe -v -patmega328p -carduino -PCOM3 -b115200 -D -Uflash:w:"$(OutputDirectory)\$(Name).hex":i`.
This setting can be found under `(Project) Properties -> Tool -> Custom Programming Tool`.

## Building on Linux

A makefile is provided for building on linux.

### Dependencies

```console
$ sudo apt-get install make avrdude gcc-avr avr-libc binutils-avr
```

### Building

```console
$ make
```

### Flashing

```console
$ make flash
```

The makefile expects the arduino to be under `/dev/ttyUSB0`, change the makefile if this is not correct.
The makefile can be run as non-root user, because avrdude is launched through `sudo`. This should work for root as well. If not, remove `sudo` from all avrdude invocations.
