; controller.s - Macros and constants for the controller input handling
; https://www.nesdev.org/wiki/Controller_reading
; For most input devices a standard procedure is used for reading input:
;   1. Write 1 to $4016 to signal the controller to poll its input
;   2. Write 0 to $4016 to finish the poll
;   3. Read polled data one bit at a time from $4016 or $4017

; ------------ Joypad Registers ------------------
JOYPAD_A = $4016
JOYPAD_B = $4017

; --------------- Input Masks --------------------
BTN_MASK_A      = 1 << 7 
BTN_MASK_B      = 1 << 6
BTN_MASK_SEL    = 1 << 5
BTN_MASK_STR    = 1 << 4
BTN_MASK_UP     = 1 << 3
BTN_MASK_DOWN   = 1 << 2
BTN_MASK_LEFT   = 1 << 1
BTN_MASK_RIGHT  = 1 << 0

; ------------------ Macros ----------------------
.proc PoolControllerA
  ; BUTTON_DATA
  ; A - B - 

  BUTTON_TILES = $600
  
  .segment "ZEROPAGE"
    PRESSED_DATA: .res 1
    RENDER_FLAG: .res 1
    BUTTON_DATA: .res 1
  .segment "CODE"
  
  
  ; Save previous BUTTON_DATA into y
  ldy BUTTON_DATA
  
  ; Pulse JOYPAD_A to start pooling
  lda #$01
  sta JOYPAD_A
  sta BUTTON_DATA
  lsr 
  sta JOYPAD_A

  ; Update BUTTON_DATA with new button press
@controllerLoop:
  lda JOYPAD_A
  lsr 
  rol BUTTON_DATA
  bcc @controllerLoop

  ; Retrieve old BUTTON_DATA and compares it to new
  tya
  eor BUTTON_DATA
  and BUTTON_DATA
  sta PRESSED_DATA

  ; Update Input Display tiles
  ldx #7
  ldy BUTTON_DATA
@tilesLoop:
  tya
  lsr
  tay
  lda #$30
  adc #0
  sta BUTTON_TILES, x
  dex
  bpl @tilesLoop

  
  lda #BTN_MASK_A 
  cmp BUTTON_DATA
  bne endButtonHandle
  lda RENDER_FLAG
  lsr
  bcs notPressed
  lda #1
  sta RENDER_FLAG
  jmp endButtonHandle
notPressed:
  lda #0
  sta RENDER_FLAG
endButtonHandle:
  
  rts

  
.endproc

