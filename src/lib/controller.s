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
BTN_MASK_A      = %00000001
BTN_MASK_B      = %00000010
BTN_MASK_SEL    = %00000100
BTN_MASK_STR    = %00001000
BTN_MASK_UP     = %00010000
BTN_MASK_DOWN   = %00100000
BTN_MASK_LEFT   = %01000000
BTN_MASK_RIGHT  = %10000000

; ------------------ Macros ----------------------
.proc PoolControllerA
  ; Pulse JOYPAD_A to start pooling
  lda #$01
  sta JOYPAD_A
  lda #$00
  sta JOYPAD_A
  sta joypad_a_data

@loop:
  lda JOYPAD_A
  lsr a 
  rol
  bcc @loop

  rts
.endproc