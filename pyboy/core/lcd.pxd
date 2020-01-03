#
# License: See LICENSE file
# GitHub: https://github.com/Baekalfen/PyBoy
#

import cython
from libc.stdint cimport uint8_t, uint32_t
from pyboy.utils cimport IntIOInterface

cdef unsigned short LCDC, STAT, SCY, SCX, LY, LYC, DMA, BGPalette, OBP0, OBP1, WY, WX
cdef int ROWS, COLS


cdef class LCD:
    cdef uint8_t[8 * 1024] VRAM
    cdef uint8_t[0xA0] OAM

    cdef int SCY
    cdef int SCX
    cdef int WY
    cdef int WX
    cdef public LCDCRegister LCDC
    cdef public PaletteRegister BGP
    cdef public PaletteRegister OBP0
    cdef public PaletteRegister OBP1

    cdef void save_state(self, IntIOInterface)
    cdef void load_state(self, IntIOInterface)

    cdef (int, int) getwindowpos(self)
    cdef (int, int) getviewport(self)


cdef class PaletteRegister:
    cdef LCD lcd

    cdef unsigned char value
    cdef uint32_t[4] lookup
    cdef uint32_t[4] color_palette

    @cython.locals(x=cython.ushort)
    cdef bint set(self, unsigned int)
    cdef uint32_t getcolor(self, unsigned char)


cdef class LCDCRegister:
    cdef unsigned char value

    cdef void set(self, unsigned int)

    cdef public bint lcd_enable
    cdef public bint windowmap_select
    cdef public bint window_enable
    cdef public bint tiledata_select
    cdef public bint backgroundmap_select
    cdef public bint sprite_height
    cdef public bint sprite_enable
    cdef public bint background_enable


cdef class Renderer:
    cdef array _screenbuffer_raw
    cdef array _tilecache_raw, _spritecache0_raw, _spritecache1_raw
    cdef uint32_t[:,:] _screenbuffer
    cdef uint32_t[:,:] _tilecache, _spritecache0, _spritecache1

    cdef uint8_t[144][4] _scanlineparameters

    @cython.locals(bx=int, by=int, wx=int, wy=int)
    cdef void scanline(self, int, LCD)

    @cython.locals(
        y=int,
        x=int,
        wmap=int,
        background_offset=int,
        bt=int,
        wt=int,
        bx=int,
        by=int,
        wx=int,
        wy=int,
        offset=int,
        bgpkey=uint32_t,
        spriteheight=int,
        n=int,
        tileindex=int,
        attributes=int,
        xflip=bint,
        yflip=bint,
        spritepriority=bint,
        spritecache=uint32_t[:,:],
        dy=int,
        dx=int,
        yy=int,
        xx=int,
        pixel=uint32_t,
    )
    cdef void render_screen(self, LCD)

    @cython.locals(
        x=int,
        t=int,
        k=int,
        y=int,
        byte1=uint8_t,
        byte2=uint8_t,
        colorcode=uint32_t,
        alpha=uint32_t
        )
    cdef void update_cache(self, LCD)
