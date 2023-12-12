.scope Map
  .proc init
    
    SetVramAddress CABINET_LOCATION
    lda #CABINET_TILE
    sta PPU_DATA
    lda #CABINET_TILE+1
    sta PPU_DATA

    SetVramAddress CABINET_LOCATION+PPU_LINE_LENGTH
    lda #CABINET_TILE+2
    sta PPU_DATA
    lda #CABINET_TILE+3
    sta PPU_DATA

    rts
  .endproc
  
  .proc update
    rts
  .endproc

  .proc frameUpdate
    rts
  .endproc
  CABINET_TILE = $01
  CABINET_LOCATION = $20b7
.endscope