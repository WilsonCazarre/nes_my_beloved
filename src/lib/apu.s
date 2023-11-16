; ppu.s - Macros and constants for the NES Audio Processing Unit

APU_FRAME_COUNTER = $4017
DMC_IRQ = $4010
APU_STATUS = $4015
PULSE1_CONTROL = $4000
PULSE1_FREQ_LO = $4002
PULSE1_FREQ_HI = $4003


.macro InitApu
  lda #%00000111 ;dmc off,noise off
  sta APU_STATUS
.endmacro



.proc PlayBeep
  lda #%10010111
  sta PULSE1_CONTROL

    lda #$C9    ;0C9 is a C# in NTSC mode
    sta PULSE1_FREQ_LO
    lda #%00111000
    sta PULSE1_FREQ_HI
  


.endproc