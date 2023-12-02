.scope Player
  PLAYER_X = $0200
  PLAYER_Y = $0203
  PLAYER_FLAGS = $0206
  PLAYER_HAND = $0201
  ONION_TILE = $04

  HAND_Y_RIGHT = $26
  HAND_Y_LEFT = $16

  .segment "ZEROPAGE"
    facing: .res 1 ; 0 = facing right, 1 = facing left
    hand_item: .res 1
  .segment "CODE"
  .proc init
    ldx #$00
    stx facing
  @spriteLoop:
    lda playerSprites, x
    sta OAM_BUFFER, x
    inx
    cpx #$0C
    bne @spriteLoop
    rts
  .endproc

  .proc frameUpdate
    lda PoolControllerA::BUTTON_DATA
    and #BTN_MASK_LEFT
    cmp #BTN_MASK_LEFT
    bne @checkRight
    ; Flip player sprite to right
    lda PLAYER_FLAGS
    ora #%01000000
    sta PLAYER_FLAGS
    sta PLAYER_FLAGS+4
    ; Update Player position
    dec PLAYER_Y
    dec PLAYER_Y+4
    dec PLAYER_Y+8
    dec PLAYER_Y
    dec PLAYER_Y+4
    dec PLAYER_Y+8
  @checkRight:
    lda PoolControllerA::BUTTON_DATA
    and #BTN_MASK_RIGHT
    cmp #BTN_MASK_RIGHT
    bne @checkDown
    ; Flip player sprite to left
    lda PLAYER_FLAGS
    and #%10111111
    sta PLAYER_FLAGS
    sta PLAYER_FLAGS+4
    
    ; Update Player position
    inc PLAYER_Y
    inc PLAYER_Y+4
    inc PLAYER_Y+8
    inc PLAYER_Y
    inc PLAYER_Y+4
    inc PLAYER_Y+8

  @checkDown:
    lda PoolControllerA::BUTTON_DATA
    and #BTN_MASK_DOWN
    cmp #BTN_MASK_DOWN
    bne @checkUp
    inc PLAYER_X
    inc PLAYER_X+4
    inc PLAYER_X+8
    inc PLAYER_X
    inc PLAYER_X+4
    inc PLAYER_X+8

  @checkUp:
    lda PoolControllerA::BUTTON_DATA
    and #BTN_MASK_UP
    cmp #BTN_MASK_UP
    bne @return
    dec PLAYER_X
    dec PLAYER_X+4
    dec PLAYER_X+8
    dec PLAYER_X
    dec PLAYER_X+4
    dec PLAYER_X+8
  @return:
    rts
  .endproc

  .proc update
    lda PoolControllerA::PRESSED_DATA
    cmp #BTN_MASK_A
    bne @return
    ldx hand_item
    inx
    txa
    and #$01
    sta hand_item
    cmp #$01
    bne @emptyHand
    lda #ONION_TILE
    jmp @finish
  @emptyHand:
    lda #$00
  @finish:
    sta PLAYER_HAND
  @return:
    rts
  .endproc

  playerSprites:
    ; Hand
    .byte $24, $00, %00000010, HAND_Y_RIGHT
    ; Body
    .byte $20, $01, %00000000, $20
    .byte $28, $11, %00000000, $20
.endscope