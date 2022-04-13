# asm68k-megadrive-slidedeck
Simple engine to display simple slides for presentation.

![slideshow.gif](misc/slideshow.gif)

Slides can be progressed by setting a timer or by pressing any button on the
joypad.

Each slide can have an optional picture and optional text.

All 95 printable ASCII are implemented.

Each slide image has one palette on one plane and is therefor limited a maximum
of 16 colours.

Text is always displayed in white.

This ROM runs in NTSC H32/V30 mode (256 x 224).

# Configuration
The engine can be configured to progress slides either by a joypad button press
(default) or automatically based on a time delay.

Setting ```SLIDESHOW_MODE_COUNT = N``` in ```globals.asm``` enables automatic
progression of slides by ```N``` frames.  Setting a value of ```250``` on a PAL system
would wait 5 seconds before loading next frame. (50fps)

A setting of ```0``` disables this mode and slides are only progressed when a
joypad button is pressed.

# Creating Slides
The assembler expects the file ```assets/slide_data.asm``` to contain the labels
```SlideDataStart``` and ```SlideDataEnd```

Between these labels one of more slides must be defined in the following format and order:

Slide header = 4 bytes total

bytes 00 - 01 = Size of image in images tiles.  Can be set to 0 when no image
used.

bytes 02 - 03 = unused but must be set.

32 bytes that define the colour palette

21,504 bytes tile data.  (672 tiles)

288 bytes of ASCII code values.  This must be terminated with a zero and must be of
even length

Example slides can be found in ```assets```.

# Building
Use ```make``` to build the rom

Requires GNU Assembler a.k.a. GNU AS / GAS and requires GNU Linker for m68k.

These are known to be available in the default repos for SuSELeap and Ubuntu.

# Download
Binary releases can be downloaded from [releases](https://github.com/billyrayvalentine/asm68k-megadrive-slidedeck/releases)
