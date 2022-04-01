# asm68k-megadrive-slidedeck
Simple engine to display simple slides for presentation.

![slideshow.gif](misc/slideshow.gif)

Slides can be progressed by setting a timer or by pressing any button on the
joypad.

Each slide must have a picture of 256x168.  This leaves room for upto 32x9 text
chars beneath the picture.  (288 chars) A minimal but regular set of ASCII characters are
available and can be used.

Each slide image has one palette on one plane and is therefor limited a maximum
of 16 colours.

Text is always displayed in white.

This ROM runs in PAL H32/V30 mode (256 x 240).  This gives the best possible vertical
depth on the megadrive.

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

32 bytes that define the colour palette

21,504 bytes tile data.  (672 tiles)

288 bytes of ASCII code values.  This must be terminated with a zero and must be of
even length

Example slides can be found in ```assets```.

# Building
Use ```make``` to build the rom

Requires GNU Assembler a.k.a. GNU AS / GAS and requires GNU Linker for m68k.

These are known to be available in the default repos for SuSELeap and Ubuntu.