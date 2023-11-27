.scope HUD

  CURSOR_TILE = $81
  SPACE_TILE = $20
  HUD_ADDRESS = $2341
  POKEMON_ADDRESS = $2301

  .segment "ZEROPAGE"
    cursor_state: .res 1
    render_flag: .res 1
  .segment "CODE"

  .proc init
    LoadStringToVram HUD_ADDRESS+1, navItem1
    LoadStringToVram HUD_ADDRESS+PPU_LINE_LENGTH+1, navItem2
    LoadStringToVram HUD_ADDRESS+(PPU_LINE_LENGTH*2)+1, navItem3
    
    lda #$00

    sta cursor_state
    lda #$01
    sta render_flag
    jsr HUD::vramUpdate
    
    rts
    
  .endproc

  .proc updateState
    lda PoolControllerA::PRESSED_DATA
    cmp #BTN_MASK_DOWN
    bne @nextButton
    jsr handleBtnDown
    lda #$01
    sta render_flag
  @nextButton:
    cmp #BTN_MASK_UP
    bne @return
    jsr handleBtnUp
    lda #$01
    sta render_flag
  @return:
    jsr vramUpdate
    rts
    
  .endproc

  .proc handleBtnDown
    lda cursor_state
    cmp #$06
    beq @return
    clc
    adc #$03
    sta cursor_state
  @return:
    rts
  .endproc

  .proc handleBtnUp
    lda cursor_state
    cmp #$00
    beq @return
    sec
    sbc #$03
    sta cursor_state
  @return:
    rts
  .endproc

  .proc vramUpdate
    lda render_flag
    cmp #$01
    bne @return
    lda #$03 ; Data len
    jsr vramPush
    lda #$01 ; Enable Vertical mode
    jsr vramPush
    lda #.HIBYTE(HUD_ADDRESS) ; High-byte of vram address
    jsr vramPush
    lda #.LOBYTE(HUD_ADDRESS) ; Low-byte of vram address
    jsr vramPush
    
    ldx cursor_state
    ldy #$00
  @nextByte:
    lda cursorStates, x
    jsr vramPush
    inx
    iny
    cpy #$03
    bne @nextByte
  @return:
    lda #$00
    sta render_flag
    rts
  .endproc
  
  navItem1: .asciiz "Fight"
  navItem2: .asciiz "Spare"
  navItem3: .asciiz "Run"

  cursorStates: 
    .byte CURSOR_TILE, SPACE_TILE, SPACE_TILE
    .byte SPACE_TILE, CURSOR_TILE, SPACE_TILE
    .byte SPACE_TILE, SPACE_TILE, CURSOR_TILE
    .byte SPACE_TILE, SPACE_TILE, SPACE_TILE
.endscope