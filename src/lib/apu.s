; ppu.s - Macros and constants for the NES Audio Processing Unit

APU_FRAME_COUNTER = $4017
DMC_IRQ = $4010
APU_STATUS = $4015


.macro InitApu
  lda #%00000111 ;dmc off,noise off
  sta APU_STATUS
.endmacro

