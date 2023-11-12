.segment "HEADER"
  .byte "NES", $1A          ; iNES header identifier
  .byte 2                   ; 2x 16KB PRG-ROM Banks
  .byte 1                   ; 1x  8KB CHR-ROM
  .byte $00                 ; mapper 0 (NROM)      

.segment "VECTORS"
  .addr nmi, reset, 0
.segment "STARTUP"

.segment "ZEROPAGE"
  joypad_a_data: .byte 0

.segment "CODE"
; Library includes
.include "lib/ppu.s"
.include "lib/apu.s"
.include "lib/controller.s"

.proc reset
  sei          ; disable IRQs
  cld          ; disable decimal mode
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
  lda #$15
@ram_reset_loop:
  sta $000, x
  sta $100, x
  sta $200, x
  sta $400, x
  sta $500, x
  sta $600, x
  sta $700, x
  inx
  bne @ram_reset_loop

  VblankWait

  jsr LoadPalettes

  LoadNametables
  
@GameLoop:
  jsr PoolControllerA
  jmp @GameLoop
.endproc

.proc nmi
  LDA #%10010000   ; enable NMI sprites, from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00         ;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  RTI
.endproc

.segment "CHARS"
  .incbin "CHR_ROM.chr"