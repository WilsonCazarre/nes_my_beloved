.scope Player
  PLAYER_X = $0200
  PLAYER_Y = $0203
  PLAYER_FLAGS = $0206
  PLAYER_HAND = $0201
  ONION_TILE = $03

  .scope Initial
    player_x = $20
    player_y = $20

  .endscope

  .segment "ZEROPAGE"
    facing: .res 1 ; 0 = facing right, 1 = facing left
    hand_item: .res 1
    player_collision_x: .res 1
    player_collision_y: .res 1
    colliding_tile: .res 1
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
    lda PLAYER_X+4
    lsr
    lsr
    lsr
    sta player_collision_x

    lda PLAYER_Y+4
    and #%11110000
    lsr
    lsr
    lsr
    ; lsr
    sta player_collision_y

    ldy player_collision_x
    jsr mul8
    ldx mul8::prodlo


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
    ; x_cord, sprite_index, sprite_attr, y_cord

    ; Hand
    .byte Initial::player_x+$4, $03, %00000000, Initial::player_y+$6
    ; Body
    .byte Initial::player_x,    $01, %00000000, Initial::player_y
    .byte Initial::player_x+$8, $11, %00000000, Initial::player_y
.endscope