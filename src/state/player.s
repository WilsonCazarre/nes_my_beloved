.scope Player
  PLAYER_X = $0200
  PLAYER_Y = $0203
  PLAYER_FLAGS = $0202
  SPRITE_OFFSET = 4

  .segment "ZEROPAGE"
    facing: .res 1 ; 0 = facing right, 1 = facing left
  .segment "CODE"
  .proc init
    ldx #$00
    stx facing
  @spriteLoop:
    lda playerSprites, x
    sta OAM_BUFFER, x
    inx
    cpx #$08
    bne @spriteLoop
    rts
  .endproc

  .proc update
    lda PoolControllerA::BUTTON_DATA
    cmp #BTN_MASK_LEFT
    bne @checkRight

    lda PLAYER_FLAGS
    ora #%01000000
    sta PLAYER_FLAGS
    sta PLAYER_FLAGS+SPRITE_OFFSET
    dec PLAYER_Y
    dec PLAYER_Y+SPRITE_OFFSET
  @checkRight:
    lda PoolControllerA::BUTTON_DATA
    cmp #BTN_MASK_RIGHT
    bne @checkDown

    lda PLAYER_FLAGS
    and #%10111111
    sta PLAYER_FLAGS
    sta PLAYER_FLAGS+SPRITE_OFFSET
    inc PLAYER_Y
    inc PLAYER_Y+SPRITE_OFFSET

  @checkDown:
    cmp #BTN_MASK_DOWN
    bne @checkUp
    inc PLAYER_X
    inc PLAYER_X+SPRITE_OFFSET

  @checkUp:
    cmp #BTN_MASK_UP
    bne @return
    dec PLAYER_X
    dec PLAYER_X+SPRITE_OFFSET
  
  @return:
    rts
  .endproc

  playerSprites:
    .byte $20, $01, %00000000, $20
    .byte $28, $11, %00000000, $20
.endscope