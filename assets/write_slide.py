#!/usr/bin/env python3
# Split stdin into files of CHUNK_SIZE lines
import sys
import os
import argparse
import textwrap

CHUNK_SIZE = 28

if __name__ == "__main__":

    # Setup command line args
    parser = argparse.ArgumentParser(description="Create asm slides for slideshow from stdin")
    parser.add_argument(
        "-d",
        "--debug",
        choices=["CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"],
        help="debug level",
        default="INFO",
    )
    parser.add_argument(
        "-i",
        "--skipinventory",
        action='store_false',
        default=True,
        help="Skip the creation of inventory.asm",
        dest="create_inventory"

    )

    args = parser.parse_args()

    chunk = 0
    written_lines = 0
    written_chars = 0

    for line in sys.stdin.readlines():
        with open("./" + str(chunk) + ".asm", "a") as a:
            if written_lines == 0:
                # write the slide header
                a.write(".long 0\n")

                a.write(".byte ")

            for char in line:
                    # Skip the last line if it's blank
                    if char == '\n' and written_lines+1 == CHUNK_SIZE:
                        continue

                    hex_byte = ord(char)
                    # Check value has been implemented in slidedeck
                    assert hex_byte >= 0x20 and hex_byte <=0x126 or hex_byte == 0x0 or hex_byte == 0x0A, f"value was 0x{hex_byte:02X} '{chr(hex_byte)}'"

                    c = str(f"{hex_byte:#X}")
                    a.write(c +  ',')
                    written_chars +=1

            written_lines += 1

            # Pad uneven files with a space before terminating
            if written_lines == CHUNK_SIZE:
                if written_chars % 2 > 0:
                    a.write("0x0\n")

                else:
                    a.write("0x20,0x0\n")

        if written_lines == CHUNK_SIZE:
            written_lines = 0
            written_chars = 0
            chunk += 1

        a.close()

    # Write inventory
    if args.create_inventory:
        with open("./" + "inventory.asm", "a") as b:
            b.write("SlideDataStart:\n")
            for slide in range(chunk):
                b.write(f'\t.include "assets/p1/{slide}.asm"\n')
            b.write("SlideDataEnd:\n")
        b.close()

