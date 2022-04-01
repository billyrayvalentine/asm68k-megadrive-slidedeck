/*
 * slidedeck.asm
 * Written for use with GNU AS

 * Copyright © 2022 Ben Sampson <github.com/billyrayvalentine>
 * This work is free. You can redistribute it and/or modify it under the
 * terms of the Do What The Fuck You Want To Public License, Version 2,
 * as published by Sam Hocevar. See the COPYING file for more details.
*/

* Everything kicks off here.  Must be at 0x200
.include "rom_header.asm"

cpu_entrypoint:
    * Set up the system byte of the status register
    * Disable trace mode
    * We want to catch VBlank interrupts which are level 6 so set the
    * mask to 5 (lower)  (bits 0,1,2)
    move.w 0b0000010100000000, sr

    * Setup the TMSS stuff
    jsr     tmss

    * Initialise joypad 1
    move.b  #0x40, IO_CTRL_PORT1
    move.b  #0x40, IO_DATA_PORT1

    * Setup the VDP registers
    jsr     init_vdp

    * Load the font Palette and Font into VDP
    * Load the palette into CRAM as palette #2
    move.l  #0xC0200000, VDP_CTRL_PORT

    lea     BRVFontPalette0, a0
    moveq   #16-1, d0

1:  move.w  (a0)+, VDP_DATA_PORT
    dbra    d0, 1b

    * Load the font tiles in VRAM
    move.l  #0x40000000, VDP_CTRL_PORT

    lea     BRVFontImage0, a0
    move.w  #FONT_TILE_COUNT * 8 -1, d0

1:  move.l  (a0)+, VDP_DATA_PORT
    dbra    d0, 1b

    * If SLIDESHOW_MODE_COUNT > 0 the set RAM_GAME_MODE = 1
    move.w #SLIDESHOW_MODE_COUNT, d5
    cmpi.b #0, d5
    beq 1f
    move.b #GAME_SLIDESHOW_MODE, RAM_GAME_MODE
    * Move the delay value to the current count so not to delay loading the
    * first slide
    move.w #SLIDESHOW_MODE_COUNT, RAM_VBLANK_COUNTER

1:
    * Set the RAM_SLIDE_POINTER to the beginning of the slide data
    * and set the RAM_GAME_STATE to LOAD_NEW_SCENE
    lea SlideDataStart, a0
    move.l a0, RAM_SLIDE_POINTER
    move.q #GAME_STATE_LOAD_NEW_SCENE, d0
    move.b d0, RAM_GAME_STATE
    lea SlideDataStart, a1

/*
 * Main loop
 * Wait for the VBLANK to start
 * Get the input for the joy pad
 * Get the Game state - this is persisted in RAM rather than registers for the sake of
 * convenience rather that speed.
 * Load RAM_SLIDE_POINTER from RAM which is expected to be at the start of the
 * scene to load
 * Wait for the VBLANK to end
 *
*/
forever:
    jsr     wait_vblank_start
    jsr     read_controller_1

    * Get RAM_GAME_STATE
    move.b  RAM_GAME_STATE, d6

    * If the engine is in slideshow mode (SLIDESHOW_MODE > 0) then
    * skip SLIDESHOW_MODE many frames until setting loading a new scene state
    cmpi.b  #GAME_SLIDESHOW_MODE, RAM_GAME_MODE
        bne 1f
    cmpi.w  #SLIDESHOW_MODE_COUNT, RAM_VBLANK_COUNTER
        blt 2f
    move.w  #0, RAM_VBLANK_COUNTER
    move.b  #GAME_STATE_LOAD_NEW_SCENE, RAM_GAME_STATE
    move.b  RAM_GAME_STATE, d6
1:
    cmpi.b  #GAME_STATE_LOAD_NEW_SCENE, d6
    bne     1f
        jsr     draw_scene
        jmp     done
1:

    * Check for a button press
    cmpi.b  #GAME_STATE_AWAITING_NEXT, d6
    bne     2f

        move.b  RAM_BUTTON_PRESS_COUNT, d7

        * Check for anything pressed and increment counter
        cmpi.b  #0, RAM_CONTROLLER_1
        beq     1f
        addq    #1, d7
        move.b  d7, RAM_BUTTON_PRESS_COUNT

        1:
        cmpi.b  #BUTTON_PRESS_COUNT, d7
        blt     2f
        move.b  #0, RAM_BUTTON_PRESS_COUNT
        move.b  #GAME_STATE_LOAD_NEW_SCENE, RAM_GAME_STATE
        jmp     done
2:

done:
    jsr     wait_vblank_end
    jmp     forever

draw_scene:
/*
 * Load a scene from ROM
 * use a1 the point to the slide data

 * For some reason this won't work if the palette is set to #2
 * Load the image Pallete as palette #1
*/

    move.l  RAM_SLIDE_POINTER, a1

    * Load image pallete
    move.l  #0xC0000000, VDP_CTRL_PORT
    moveq   #16-1, d2

1:  move.w  (a1)+, VDP_DATA_PORT
    dbra    d2, 1b

    * Load image tiles after the font tiles
    move.l  #0x4C000000, VDP_CTRL_PORT
    move.w  #IMAGE_TILE_COUNT * 8 -1, d2

1:  move.l  (a1)+, VDP_DATA_PORT
    dbra    d2, 1b

    * Set image table in plane B - use palette #1
    * The tile ID = n + FONT_TILE_COUNT
    move.l  #0x60000003, VDP_CTRL_PORT
    move.w  #0b0000000000000000 + FONT_TILE_COUNT, d2

1:  move.w  d2, VDP_DATA_PORT
    addq    #1, d2
    cmpi.w  #IMAGE_TILE_COUNT + FONT_TILE_COUNT, d2
    bne     1b

    * The text tiles are still in VDP RAM so clear these with blank tiles
    * use D2
    * Skip 786 tiles - not sure why this isn't 786
    move.l  #0x45400003, VDP_CTRL_PORT
    move.w  #SCENE_TEXT_LENGTH -1, d2
1:  move.w  #0x00, VDP_DATA_PORT
    dbra    d2, 1b

    * Print the text to the screen
    * Use palette #1
    move.w  #0x2000, d0
    * Skip 786 tiles
    move.l  #0x45400003, VDP_CTRL_PORT

    * loop through the bytes in a0 which are ascii values until 0x00
1:  move.b  (a1)+, d0
    cmpi.b  #0,    d0
    beq     2f

    subi.b  #0x20, d0
    move.w  d0, VDP_DATA_PORT
    bra     1b
2:
    * If the slide pointer is at the end of the slide data then
    * reset it to the beginning - (loop the slides forever)
    lea     SlideDataEnd, a2
    cmpa.l  a1, a2
    bne     1f
    lea     SlideDataStart, a1
1:
    * Scene is loaded skip setting GAME_STATE_AWAITING_NEXT if in slideshow mode
    cmpi.b  #GAME_SLIDESHOW_MODE, RAM_GAME_MODE
        beq 1f

    * Scene is loaded set the GAME_STATE to GAME_STATE_AWAITING_NEXT
    move.b  #GAME_STATE_AWAITING_NEXT, RAM_GAME_STATE
1:
    move.l  a1, RAM_SLIDE_POINTER
    rts

read_controller_1:
    * Read controller 1 input into $FF0000
    move.l  #IO_DATA_PORT1, a0
    move.b  #0x40, (a0)
    nop
    nop
    move.b  (a0), d0

    move.b  #0x00, (a0)
    nop
    nop
    move.b  (a0), d1

    andi.b  #0x3f, d0
    andi.b  #0x30, d1
    lsl.b   #2, d1
    or.b    d1, d0

    * NOT The bits so that that we have SACBRLDU
    * and a 1 rather than 0 when the bit is set
    * Finally write the value to RAM
    not    d0
    move.b d0, RAM_CONTROLLER_1
    rts

wait_vblank_start:
    * Bit 4 of the VDP register is set to 1 when the vblanking is in progress
    * Keep looping until this is set
    * The VDP register can be read simply by reading from the control port
    * address
    move.w  VDP_CTRL_PORT, d0
    btst.b  #4-1, d0
    beq     wait_vblank_start
    rts

wait_vblank_end:
    * Similar to wait_vblank_start but the inverse
    move.w  VDP_CTRL_PORT, d0
    btst.b  #4-1, d0
    bne     wait_vblank_end
    rts

.include "globals.asm"
.include "init_vdp.asm"
.include "tmss.asm"
.include "assets/brvfont.asm"
.include "assets/slide_data.asm"

/*
 * Interrupt handler
*/
cpu_exception:
    rte
int_null:
    rte
int_hinterrupt:
    rte
int_vinterrupt:
    addi.w #1, RAM_VBLANK_COUNTER
    rte
rom_end:
