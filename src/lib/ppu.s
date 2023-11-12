; ppu.s - Macros and constants for the NES Picture Processing Unit

; ---------------------- Registers --------------------------

; Controller ($2000) > write
; https://www.nesdev.org/wiki/PPU_registers#PPUCTRL
PPU_CTRL = $2000

; Mask ($2001) > write
; Responsible for controlling effects and show/hide sprites and backgrounds
; https://www.nesdev.org/wiki/PPU_registers#PPUMASK
PPU_MASK = $2001

; Status ($2002) < read
; https://www.nesdev.org/wiki/PPU_registers#PPUSTATUS
PPU_STATUS = $2002

; Scroll ($2005) >> write x2
; Controlls the scroll position, sort of the "camera" in a 2d game.
; Scrolling is not used in this game.
; https://www.nesdev.org/wiki/PPU_registers#PPUSCROLL
PPU_SCROLL = $2005

; Address ($2006) >> write x2 / Data ($2007) <> read/write
; Because the PPU and CPU don't share the same data bus, we need to use this
; registers to put data inside the VRAM
; See https://www.nesdev.org/wiki/PPU_registers#PPUADDR for register info
; See https://www.nesdev.org/wiki/PPU_memory_map to know which data to put where in the VRAM
PPU_ADDR = $2006
PPU_DATA = $2007

; ---------------------- OAM Registers --------------------------
; Additionally to the VRAM, the PPU also store data inside the Object Attribute Memory.
; The following registers are used to read and write data to this region of the PPU memory.

; OAM address ($2003) > write
; Similar to the VRAM, we can write to specific bytes of the OAM, but this is usually
; not recomended because it's a very slow process and the NMI time window is very short.
; Prefer OAM_DMA when possible.
; https://www.nesdev.org/wiki/PPU_registers#OAMADDR
OAM_ADDR = $2003
OAM_DATA = $2004

; OAM DMA ($4014) > write
; https://www.nesdev.org/wiki/PPU_registers#OAMDMA
OAM_DMA = $4014

; ------- Global VRAM Adresses ------------
NAMETABLE_A = $2000
NAMETABLE_B = $2400
NAMETABLE_C = $2800
NAMETABLE_D = $2c00
ATTR_A      = $23c0
ATTR_B      = $27c0
ATTR_C      = $2bc0
ATTR_D      = $2fc0
PALETTES    = $3f00


.macro VblankWait
: bit PPU_STATUS  ; N = NMI started
  bpl :-          ; Jump to last anon label if N = 0
.endmacro

.proc LoadPalettes
  bit PPU_STATUS
  ldx #$00
  ; Set top address of ppu as 3f (palettes location)
  lda #$3f
  sta PPU_ADDR
  stx PPU_ADDR
  
  @load_pallete_loop:
    lda color_palletes, x
    sta PPU_DATA
    inx
    cpx #32
    bne @load_pallete_loop
    rts
  color_palletes:
    ; Background Palettes
    .byte $0C, $14, $23, $37
    .byte $0C, $14, $23, $37
    .byte $0C, $14, $23, $37
    .byte $0C, $14, $23, $37

    ; Sprite Palettes
    .byte $0C, $14, $23, $37
    .byte $0C, $14, $23, $37
    .byte $0C, $14, $23, $37
    .byte $0C, $14, $23, $37
.endproc

.macro LoadNametables
  ; load $20 tiles
  bit PPU_STATUS
  ldx #$00
  ; Set top address of ppu as 20 (NAMETABLE)
  lda #$20
  sta PPU_ADDR
  stx PPU_ADDR
  lda #$10
@loop:
  sta PPU_DATA
  inx
  cpx $20
  bne @loop


.endmacro