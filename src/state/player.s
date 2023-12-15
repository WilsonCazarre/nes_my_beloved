.scope Player
  PLAYER_Y = $0200
  PLAYER_X = $0203
  PLAYER_FLAGS = $0206
  PLAYER_HAND = $0201
  EGG_TILE = $04
  SUGAR_TILE = $13
  QUINDIN_TILE = $03

  COUNTER_ADRR = $2321
  COUNTER_START = $34 ; ASCII Table 4
  COUNTER_NUMBER = COUNTER_ADRR+9

  RECIPE_INSTRUCTION_ADDR = COUNTER_ADRR+PPU_LINE_LENGTH*2+8

  .scope Initial
    player_x = $50
    player_y = $50

  .endscope

  .macro ClearPlayerHand
    lda #$00
    sta cabinet_tile1
    sta cabinet_tile2
    sta PLAYER_HAND
  .endmacro

  .segment "ZEROPAGE"
    facing: .res 1 ; 0 = facing right, 1 = facing left
    hand_item: .res 1
    player_collision_x: .res 1
    player_collision_y: .res 1
    cabinet_tile1: .res 1
    cabinet_tile2: .res 1
    oven1_tile: .res 1
    oven1_state: .res 1
    conveyor_tile: .res 1
    score: .res 1
    recipe_idx: .res 1
    recipe_count: .res 1
  .segment "CODE"
  .proc init
    ldx #$00
    stx facing
    stx oven1_state
    stx score
  @spriteLoop:
    lda playerSprites, x
    sta OAM_BUFFER, x
    inx
    cpx #$0C
    bne @spriteLoop

    LoadStringToVram COUNTER_ADRR, counterTitle
    LoadStringToVram COUNTER_ADRR+PPU_LINE_LENGTH*2, recipeTitle
    LoadStringToVram RECIPE_INSTRUCTION_ADDR, initialRecipe

    rts
    counterTitle: .asciiz "Counter: 4"
    recipeTitle: .asciiz "Recipe:"
  .endproc

  .proc frameUpdate
    jsr checkEggCabinetCollision
    jsr checkSugarCabineCollision
    jsr checkOven1Collison
    jsr checkConveyorCollision
    
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
    jsr handleOvenStateMachine
    jsr handleConveyorInteract
    rts
  .endproc

  .proc handleInteract
    lda cabinet_tile1
    ora cabinet_tile2
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
    lda cabinet_tile1
    ora cabinet_tile2
    jmp @finish
  @emptyHand:
    lda #$00
  @finish:
    sta PLAYER_HAND
  @return:
    rts
  .endproc

  .proc handleOvenStateMachine
    lda PoolControllerA::PRESSED_DATA
    cmp #BTN_MASK_A
    bne @return
    lda oven1_tile
    cmp #$01
    bne @return
    ldx recipe_idx
    lda oven1_state
    cmp #$00
    bne @nextState
    lda PLAYER_HAND
    cmp recipes, x
    bne @return
    inc oven1_state
    ClearPlayerHand
    jmp @return
  @nextState:
    cmp #$01
    bne @nextState2
    lda PLAYER_HAND
    cmp recipes+1, x
    bne @nextState2
    inc oven1_state
    ClearPlayerHand
    jmp @return
  @nextState2:
    cmp #$02
    bne @return
    lda PLAYER_HAND
    cmp recipes+2, x
    bne @return
    lda #$00
    sta oven1_state
    sta cabinet_tile1
    lda #QUINDIN_TILE
    sta cabinet_tile2
    sta PLAYER_HAND
    jmp @return
  @return:
    rts
  .endproc

  .proc handleConveyorInteract
    lda PoolControllerA::PRESSED_DATA
    cmp #BTN_MASK_A
    bne @return
    lda conveyor_tile
    cmp #$01
    bne @return
    lda PLAYER_HAND
    cmp #QUINDIN_TILE
    bne @return
    ClearPlayerHand
    inc score
    ldx recipe_idx
    inx
    inx
    inx 
    stx recipe_idx
    inc recipe_count
    
    lda #$01
    jsr vramPush
    lda #$00
    jsr vramPush
    lda #.HIBYTE(COUNTER_NUMBER)
    jsr vramPush
    lda #.LOBYTE(COUNTER_NUMBER)
    jsr vramPush
    lda #COUNTER_START
    sec
    sbc recipe_count
    jsr vramPush

    lda #$06
    jsr vramPush
    lda #$00
    jsr vramPush
    lda #.HIBYTE(RECIPE_INSTRUCTION_ADDR)
    jsr vramPush
    lda #.LOBYTE(RECIPE_INSTRUCTION_ADDR)
    jsr vramPush
    ldx recipe_idx
    dex
    dex
    dex
    ldy #$00
  : 
    lda recipesInstructions, x
    jsr vramPush
    lda recipesInstructions, x
    clc
    adc #$01
    jsr vramPush
    inx
    iny
    cpy #$03
    bne :-

    lda #$00
    jsr vramPush
    
  @return:
    rts
  .endproc

  .proc checkEggCabinetCollision

    ; Checking for x collision
    lda PLAYER_X+8
    sec
    sbc Map::CABINET_1_X
    ; Values between 5C - 6C = colliding
    cmp #$6C
    bcs @notColliding
    cmp #$5C
    bcc @notColliding
    ; Checking for y collision
    lda PLAYER_Y+8
    sec
    sbc Map::CABINET_1_Y
    cmp #$A8
    bne @notColliding
    lda #EGG_TILE
    sta cabinet_tile1
    jmp @return
  @notColliding:
    lda #$00
    sta cabinet_tile1
  @return:
    rts
  .endproc

  .proc checkSugarCabineCollision
    ; Checking for x collision
    lda PLAYER_X+8
    sec
    sbc Map::CABINET_2_X
    ; ; Values between CC - DC = colliding
    cmp #$DC
    bcs @notColliding
    cmp #$CC
    bcc @notColliding
    ; Checking for y collision
    lda PLAYER_Y+8
    sec
    sbc Map::CABINET_2_Y
    cmp #$A7
    bne @notColliding
    lda #SUGAR_TILE
    sta cabinet_tile2
    jmp @return
  @notColliding:
    lda #$00
    sta cabinet_tile2
  @return:
    rts
  .endproc

  .proc checkOven1Collison
    ; Checking for x collision
    lda PLAYER_X+4
    sec
    sbc Map::CABINET_2_X
    sta oven1_tile
    cmp #$10
    bne @notColliding
    lda PLAYER_Y+8
    sec
    sbc Map::CABINET_2_Y
    sta oven1_tile
    
    ; Values between 7b -8f = colliding
    cmp #$8f
    bcs @notColliding
    cmp #$7b
    bcc @notColliding
    lda #$01
    sta oven1_tile
    jmp @return
  @notColliding:
    lda #$00
    sta oven1_tile
  @return:
    rts
  .endproc


  .proc checkConveyorCollision
    ; Checking for x collision
    lda PLAYER_X+4
    sec
    sbc Map::CABINET_1_X
    ; Values between 9C - BC = colliding
    cmp #$BC
    bcs @notColliding
    cmp #$9C
    bcc @notColliding
    lda PLAYER_Y+4
    sec
    sbc Map::CABINET_1_Y
    cmp #$2a
    bne @notColliding
    lda #$01
    sta conveyor_tile
    jmp @return
  @notColliding:
    lda #$00
    sta conveyor_tile
  @return:
    rts
  .endproc


  recipesInstructions:
    .byte  $9A, $96, $9A
    .byte  $9A,  $9A,  $96
    .byte $96, $9A,  $96
    .byte $FB, $FB,  $FB

  recipes:
    .byte EGG_TILE, EGG_TILE, SUGAR_TILE
    .byte SUGAR_TILE, EGG_TILE, SUGAR_TILE
    .byte SUGAR_TILE, SUGAR_TILE, EGG_TILE
    .byte EGG_TILE, SUGAR_TILE, SUGAR_TILE

  initialRecipe:
    .byte $96, $97, $96, $97, $9A, $9b, 0
  
  


  playerSprites:
    ; y_cord, sprite_index, sprite_attr, x_cord

    ; Hand
    .byte Initial::player_y+$4, $00, %00000010, Initial::player_x+$6
    ; Body
    .byte Initial::player_y,    $01, %00000000, Initial::player_x
    .byte Initial::player_y+$8, $11, %00000000, Initial::player_x

  
  .endscope