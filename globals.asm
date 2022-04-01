/*
 * globals.asm
 * Written for use with GNU AS

 * Copyright © 2022 Ben Sampson <github.com/billyrayvalentine>
 * This work is free. You can redistribute it and/or modify it under the
 * terms of the Do What The Fuck You Want To Public License, Version 2,
 * as published by Sam Hocevar. See the COPYING file for more details.
 *
 * Globals
*/

* CONSTANTS
SEGA_STRING: .ascii "SEGA"

* VDP Registers
VDP_CTRL_PORT = 0xC00004
VDP_DATA_PORT = 0xC00000

VDP_REG_MODE1 = 0x8000
VDP_REG_MODE2 = 0x8100
VDP_REG_MODE3 = 0x8B00
VDP_REG_MODE4 = 0x8C00

VDP_REG_PLANEA = 0x8200
VDP_REG_PLANEB = 0x8400
VDP_REG_SPRITE = 0x8500
VDP_REG_WINDOW  = 0x8300
VDP_REG_HSCROLL = 0x8D00

VDP_REG_SIZE = 0x9000
VDP_REG_WINX = 0x9100
VDP_REG_WINY = 0x9200
VDP_REG_INCR = 0x8F00
VDP_REG_BGCOL = 0x8700
VDP_REG_H_INT = 0x8A00

* IO
IO_CTRL_PORT1 = 0xA10009
IO_DATA_PORT1 = 0xA10003

* General Settings
TOTAL_SCREEN_SIZE_TILES = 960
FONT_TILE_COUNT = 96
*IMAGE_TILE_COUNT = 768
IMAGE_TILE_COUNT = 672
SCENE_TEXT_LENGTH = TOTAL_SCREEN_SIZE_TILES - IMAGE_TILE_COUNT
BUTTON_PRESS_COUNT = 8
SLIDESHOW_MODE_COUNT = 350

* Engine Values
GAME_STATE_AWAITING_NEXT = 0x02
GAME_STATE_LOAD_NEW_SCENE = 0x01

GAME_SLIDESHOW_MODE = 0x01

* RAM MAP
RAM_CONTROLLER_1 = 0xFF0000         /* 1 byte */
RAM_CONTROLLER_2 = 0xFF0001         /* 1 byte */
RAM_GAME_STATE = 0xFF0002           /* 4 bytes */
RAM_SLIDE_POINTER = 0xFF0006        /* 4 bytes */
RAM_BUTTON_PRESS_COUNT = 0xFF000A   /* 2 bytes */
RAM_VBLANK_COUNTER = 0xFF000C       /* 2 bytes */
RAM_GAME_MODE = 0xFF000E            /* 1 byte */
