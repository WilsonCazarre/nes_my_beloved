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

    SetVramAddress CONVEYOR_BELT_LOCATION+(PPU_LINE_LENGTH*2)
    lda #CONVEYOR_BELT_TILE+$10
    sta PPU_DATA
    lda #CONVEYOR_BELT_TILE+$11
    sta PPU_DATA

    SetVramAddress CONVEYOR_BELT_LOCATION+(PPU_LINE_LENGTH*3)
    lda #CONVEYOR_BELT_TILE+$10
    sta PPU_DATA
    lda #CONVEYOR_BELT_TILE+$11
    sta PPU_DATA
    
    ; FLOOR SOUTH
    SetVramAddress FLOOR_EMPTY_SOUTH
    lda #FLOOR_EMPTY_TILE
    ldx #0

  @floor_loop:
    sta PPU_DATA
    inx
    cpx #FLOOR_EMPTY_LENGTH
    bne @floor_loop
    
    ; FLOOR TOP LEFT
    ; SetVramAddress FLOOR_EMPTY_TOPLEFT
    ; lda #FLOOR_EMPTY_TILE
    ; ldx #$0 ; Row
    ; @newRow:
    ; ldy #$0 

    ; @topl_loop:
    ; sta PPU_DATA
    ; inx
    ; cpx #
    ; bne @topl_loop
    ; iny
    ; cpy #
    ; SetVramAddress FLOOR_EMPTY_TOPLEFT+PPU_LINE_LENGTH
    ; bne @newRow

    ; ; FLOOR TOP RIGHT
    ; SetVramAddress FLOOR_EMPTY_SOUTH
    ; lda #FLOOR_EMPTY_TILE
    ; ldx #0

    ; @floor_loop:
    ; sta PPU_DATA
    ; inx
    ; cpx #FLOOR_EMPTY_LENGTH
    ; bne @floor_loop

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
  FLOOR_EMPTY_TILE = $FC
  FLOOR_EMPTY_SOUTH = $2300
  FLOOR_EMPTY_TOPLEFT = $2000
  FLOOR_EMPTY_TOPRIGHT = $2017
  FLOOR_EMPTY_LENGTH = $BF
.endscope