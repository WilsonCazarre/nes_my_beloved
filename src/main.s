POOL_CONTROLLER = $30
.segment "HEADER"
  .byte "NES", $1A          ; iNES header identifier
  .byte 2                   ; 2x 16KB PRG-ROM Banks
  .byte 1                   ; 1x  8KB CHR-ROM
  .byte $00                 ; mapper 0 (NROM)      
  .byte $00                 ; mapper 0 (NROM)
  

.segment "VECTORS"
  .addr nmi, reset, 0
.segment "STARTUP"

.segment "ZEROPAGE"

.segment "CODE"
; Library includes
.include "lib/ppu.s"
.include "lib/apu.s"
.include "lib/controller.s"

.proc reset
  sei          ; disable IRQs
  cld          ; disabe decimal mode
  ; disable APU frame IRQ
  ldx #$40
  stx APU_FRAME_COUNTER  

  ; Set up stack
  ldx #$FF
  txs

  inx             ; X = 0
  stx PPU_CTRL    ; disable NMI
  stx PPU_MASK    ; disable rendering
  stx DMC_IRQ     ; disable DMC IRQs
  VblankWait
  lda #$00
@ram_reset_loop:
  sta $000, x
  sta $100, x
  sta $200, x
  sta $300, x
  sta $400, x
  sta $500, x
  sta $600, x
  sta $700, x
  inx 
  bne @ram_reset_loop

  VblankWait ;

  jsr LoadPalettes

  jsr LoadNametables
  
  InitPPU
  InitApu
  VramReset

@GameLoop:
  lda POOL_CONTROLLER
  cmp #$01
  bne @GameLoop
@PoolController:
  jsr PoolControllerA
  lda PoolControllerA::PRESSED_DATA
  cmp #%00000000
  bne @playSound
  jmp @GameLoop
@playSound:
  jsr PlayBeep
  ; lda #$00
  ; sta POOL_CONTROLLER

  jmp @GameLoop
.endproc

.proc nmi
  ; Save registers
  pha
  tya
  pha
  txa
  pha


  lda #$01
  sta POOL_CONTROLLER

  bit PPU_STATUS
  lda #.HIBYTE(LoadNametables::CTRL_BUFFER)
  sta PPU_ADDR
  lda #.LOBYTE(LoadNametables::CTRL_BUFFER)
  sta PPU_ADDR
  
  lda PoolControllerA::BUTTON_TILES
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+1
  sta PPU_DATA
  ; Not showing start and select on screen
  lda PoolControllerA::BUTTON_TILES+4
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+5
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+6
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+7
  sta PPU_DATA
  VramReset

  ; Restore registers
  pla
  tax
  pla
  tay
  pla

  rti

hello:
  .byte $28, $25, $2c, $2c, $2f
  

.endproc

.segment "CHARS"
  .incbin "CHR_ROM.chr"