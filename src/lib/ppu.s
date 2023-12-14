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

OAM_BUFFER = $0200

PPU_LINE_LENGTH = $20

PPU_BUFFER = $0100

.macro EnableRendering
  lda #%00011110
  sta PPU_MASK
.endmacro

.macro DisableRendering
  lda #%00011110
  sta PPU_MASK
.endmacro

.scope PpuController
  buffer_pointer = $30
  .proc init
    lda #%10010000
    sta PPU_CTRL
    EnableRendering

    ; No scrolling
    lda #$00
    sta PPU_SCROLL
    sta PPU_SCROLL
    sta buffer_pointer
    lda #$01
    sta buffer_pointer+1
    rts
  .endproc

  .proc setVerticalVram
    lda #%10010100
    sta PPU_CTRL
    rts
  .endproc

  .proc setHorizontalVram
    lda #%10010000
    sta PPU_CTRL
    rts
  .endproc
.endscope




.macro VblankWait
: bit PPU_STATUS  ; N = NMI started
  bpl :-          ; Jump to last anon label if N = 0
.endmacro

.proc LoadPalettes
  bit PPU_STATUS
  ldx #.LOBYTE(PALETTES) ; x = $00
  lda #.HIBYTE(PALETTES) ; a = $3f

  ; Tell the PPU write to 3f00
  sta PPU_ADDR  
  stx PPU_ADDR
  
@load_pallete_loop:
  lda color_palletes, x ; color_palletes[0]
  sta PPU_DATA
  inx
  cpx #32
  bne @load_pallete_loop
  rts

color_palletes:
  ; Background Palettes
  .byte $03, $06, $17, $2D;PAREDES
  .byte $03, $3D, $16, $2D ;MOVEIS
  .byte $03, $16, $27, $20;ALIMENTOS
  .byte $0c, $20, $0d, $37

  ; Sprite Palettes
  .byte $03, $27, $22, $07 ;PLAYER1
  .byte $03, $15, $37, $26 ;PLAYER2
  .byte $0c, $2a, $15, $0d
  .byte $0c, $20, $0d, $37
.endproc

.macro VramReset
  bit PPU_STATUS
  lda #0
  sta PPU_ADDR
  sta PPU_ADDR
.endmacro

.macro SetVramAddress VramAddress
  bit PPU_STATUS
  lda #.HIBYTE(VramAddress)
  sta PPU_ADDR
  lda #.LOBYTE(VramAddress)
  sta PPU_ADDR
.endmacro

.macro LoadByteToVram VramAddress, LoadByte, Counter
  ; Loads A to the VramAdress in the PPU VRAM. Use Counter to repeat the operation.
  SetVramAddress VramAddress
  lda LoadByte
  ldx Counter
: 
  sta PPU_DATA
  dex
  bne :-
.endmacro

.macro LoadAddressToVram VramAddress, RamAddress, Len
  ; Loads RamAdress[0:Len] to VramAdress
  SetVramAddress VramAddress
  ldx #$00
:
  lda RamAddress, x
  sta PPU_DATA
  inx
  cpx Len
  bne :-
.endmacro


.macro LoadStringToVram VramAddress, RamAddress
  ; Keeps incremetly loading RamAddress to VramAddress until finds a byte $0 or
  ; the X register reaches 255.
  ; Common use case is to load a string into memory.
  ; So you can define a string with a label:
  ; | hello:
  ; |   .byte "Hello, World!", $0
  ; The $0 there is important so the macro knows when to stop reading the string.
  ; Then you can invoke the macro like so:
  ; | LoadStringToVram $2081, hello

  ; `$2081` is an arbitrary Vram Nametable address where you would want 
  ; you string to start rendering.
  ; 
  ; NOTE: This only works if the because the ASCII Char tiles are position inside
  ; the CHR file at the same index they would appear at the ASCII Table.
  ; So for example, 'D' in the ASCII is the hex $44, so if you need to place
  ; the 'D' symbol at tile index $44 in the second page inside the CHR file.

  .scope
    SetVramAddress VramAddress
    ldx #$00
  @loadNextByte:
    lda RamAddress, x
    cmp $0
    beq @end
    sta PPU_DATA
    inx 
    bne @loadNextByte
  @end:
  .endscope
.endmacro

.proc LoadNametables
  TILES_BUFFER = $239a
  CURSOR_TILE = $81
  CTRL_BUFFER = TILES_BUFFER + PPU_LINE_LENGTH
  .segment "ZEROPAGE"
    pointer1: .res 1
  .segment "CODE"

  LoadAddressToVram TILES_BUFFER, JOYPAD_TILES, #$06
  

  lda $2002
	lda #$20
	sta $2006
	lda #$00
	sta $2006
	lda #<TestNametable
	sta pointer1
	lda #>TestNametable
	sta pointer1+1
	ldy #$00
	ldx #$04
@loop:
	lda (pointer1),y
	sta $2007
	iny
	bne @loop
	inc pointer1+1
	dex
	bne @loop

	lda $2002
	lda #$23
	sta $2006
	lda #$C0
	sta $2006
	ldx #$00
@loop1:
  lda TestAttributes,x
	sta $2007
	inx
	cpx #64
	bne @loop1
  rts

  TestNametable:
    .incbin "bin/nametable.bin"

  TestAttributes:
    .incbin "bin/testattributes.bin"

  JOYPAD_TILES:
    .byte $F0, $F1, $F2, $F3, $F4, $F5


.endproc


.proc vramPush
  .segment "ZEROPAGE"
    load_value: .res 1
  .segment "CODE"
  sta load_value
  tya
  pha
  ldy #$00
  lda load_value
  sta (PpuController::buffer_pointer), y
  inc PpuController::buffer_pointer
  pla
  tay
  rts
.endproc

