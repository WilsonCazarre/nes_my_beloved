.scope Player
  PLAYER_Y = $0200
  PLAYER_X = $0203
  PLAYER_FLAGS = $0206
  PLAYER_HAND = $0201
  EGG_TILE = $04
  SUGAR_TILE = $13

  .scope Initial
    player_x = $50
    player_y = $50

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
    jsr checkOven1Collision
    jsr checkOven2Collision
    
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
    lda PLAYER_X
    sec
    sbc #Map::MAP_X_MIN
    bcc @checkRight

    dec PLAYER_X
    dec PLAYER_X+4
    dec PLAYER_X+8
    dec PLAYER_X
    dec PLAYER_X+4
    dec PLAYER_X+8
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

    lda PLAYER_X
    sec
    sbc #Map::MAP_X_MAX
    bcs @checkDown
    ; Update Player position
    inc PLAYER_X
    inc PLAYER_X+4
    inc PLAYER_X+8
    inc PLAYER_X
    inc PLAYER_X+4
    inc PLAYER_X+8

  @checkDown:
    lda PoolControllerA::BUTTON_DATA
    and #BTN_MASK_DOWN
    cmp #BTN_MASK_DOWN
    bne @checkUp

    lda PLAYER_Y
    sec 
    sbc #Map::MAP_Y_MAX
    bpl @checkUp

    inc PLAYER_Y
    inc PLAYER_Y+4
    inc PLAYER_Y+8
    inc PLAYER_Y
    inc PLAYER_Y+4
    inc PLAYER_Y+8

  @checkUp:
    lda PoolControllerA::BUTTON_DATA
    and #BTN_MASK_UP
    cmp #BTN_MASK_UP
    bne @return
    ; Check Collision
    lda PLAYER_Y
    sec
    sbc #Map::MAP_Y_MIN
    bmi @return
    ; Update position
    dec PLAYER_Y
    dec PLAYER_Y+4
    dec PLAYER_Y+8
    dec PLAYER_Y
    dec PLAYER_Y+4
    dec PLAYER_Y+8
  @return:
    rts
  .endproc

  .proc update
    jsr handleInteract
    rts
  .endproc

  .proc handleInteract
    lda colliding_tile
    cmp #$00
    beq @return
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
    lda colliding_tile
    jmp @finish
  @emptyHand:
    lda #$00
  @finish:
    sta PLAYER_HAND
  @return:
    rts
  .endproc

  .proc checkOven1Collision
    

    ; Checking for x collision
    lda PLAYER_X+8
    sec
    sbc Map::OVEN_1_X
    ; Values between 5C - 6C = colliding
    cmp #$6C
    bcs @notColliding
    cmp #$5C
    bcc @notColliding
    ; Checking for y collision
    lda PLAYER_Y+8
    sec
    sbc Map::OVEN_1_Y
    cmp #$A8
    bne @notColliding
    lda #EGG_TILE
    sta colliding_tile
    jmp @return
  @notColliding:
    lda #$00
    sta colliding_tile
  @return:
    rts
  .endproc

  .proc checkOven2Collision
    

    ; Checking for x collision
    lda PLAYER_X+8
    sec
    sbc Map::OVEN_2_X
    sta colliding_tile
    ; ; Values between CC - DC = colliding
    cmp #$DC
    bcs @notColliding
    cmp #$CC
    bcc @notColliding
    ; Checking for y collision
    lda PLAYER_Y+8
    sec
    sbc Map::OVEN_2_Y
    cmp #$A7
    bne @notColliding
    lda #SUGAR_TILE
    sta colliding_tile
    jmp @return
  @notColliding:
    lda #$00
    sta colliding_tile
  @return:
    rts
  .endproc


  playerSprites:
    ; y_cord, sprite_index, sprite_attr, x_cord

    ; Hand
    .byte Initial::player_y+$4, $00, %00000010, Initial::player_x+$6
    ; Body
    .byte Initial::player_y,    $01, %00000000, Initial::player_x
    .byte Initial::player_y+$8, $11, %00000000, Initial::player_x

  
  .endscope