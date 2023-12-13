.scope Map
  .proc init
  
    ; CABINET
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

    ; CONVEYOR BELT
    SetVramAddress CONVEYOR_BELT_LOCATION
    lda #CONVEYOR_BELT_TILE
    sta PPU_DATA
    lda #CONVEYOR_BELT_TILE+1
    sta PPU_DATA

    SetVramAddress CONVEYOR_BELT_LOCATION+PPU_LINE_LENGTH
    lda #CONVEYOR_BELT_TILE+$10
    sta PPU_DATA
    lda #CONVEYOR_BELT_TILE+$11
    sta PPU_DATA

    SetVramAddress CONVEYOR_BELT_LOCATION+$20
    lda #CONVEYOR_BELT_TILE+$10
    sta PPU_DATA
    lda #CONVEYOR_BELT_TILE+$11
    sta PPU_DATA

    SetVramAddress CONVEYOR_BELT_LOCATION+$20+PPU_LINE_LENGTH
    lda #CONVEYOR_BELT_TILE+$10
    sta PPU_DATA
    lda #CONVEYOR_BELT_TILE+$11
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
  CONVEYOR_BELT_TILE = $98
  CONVEYOR_BELT_LOCATION = $202F
.endscope