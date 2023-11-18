POOL_CONTROLLER = $30
.segment "HEADER"
  .byte "NES", $1A          ; iNES header identifier
  .byte 2                   ; 2x 16KB PRG-ROM Banks
  .byte 1                   ; 1x  8KB CHR-ROM
  .byte $00                 ; mapper 0 (NROM)      
  .byte $00                 ; mapper 0 (NROM)
  

.segment "VECTORS"
  .addr nmi, reset, 0
.segment "STARTUP"

.segment "ZEROPAGE"

.segment "CODE"
; Library includes
.include "lib/ppu.s"
.include "lib/apu.s"
.include "lib/controller.s"
.include "lib/utils.s"


.proc reset
  ; The reset procedure is the entry point for our game. 
  ; It puts the processor in a know state before starting to run the game.
  ; Roughtly, the set of steps the routine does:
  ;   1. Disable Interrupt Requests and Decimal mode. This 6502 features are not used by the NES.
  ;   2. Initalize the stack pointer to $FF
  ;   3. Disable the PPU and APU
  ;   4. Initialize all RAM addresses to $00
  ;   5. Load the Color Palettes and initial Nametables
  ;   6. Init the PPU and APU
  ;   7. Run the infinite Game Loop
  sei          ; disable Interrupt Requests
  cld          ; disable decimal mode
  ; disable APU frame IRQ
  ldx #$40
  stx APU_FRAME_COUNTER  

  ; Set up stack
  ldx #$FF
  txs

  inx             ; X = 0
  stx PPU_CTRL    ; disable NMI
  stx PPU_MASK    ; disable rendering
  stx DMC_IRQ     ; disable DMC IRQs
  
  lda #$00
@ram_reset_loop:
  sta $000, x
  sta $100, x
  sta $200, x
  sta $300, x
  sta $400, x
  sta $500, x
  sta $600, x
  sta $700, x
  inx 
  bne @ram_reset_loop

  jsr LoadPalettes

  ; jsr LoadNametables
  LoadAddressToVram LoadNametables::TILES_BUFFER, CTRL_TILES, #$06
  LoadStringToVram $2081, hello
  
  InitPPU

  InitApu

  VramReset

@GameLoop:
  ; The Game Loop executes all the game logic.
  ; It starts by reading the Controller inputs (we're only using the joypad 1)
  ; The game loop should NEVER write to the PPU. Writes to the PPU should happen only
  ; at the NMI.
  
  ; As a rule of thumb, if you're reading or writing to the PPU registers 
  ; in a code executed during the Game Loop, you're probably doing someting wrong.

  ; Reading Controller Input
  jsr PoolControllerA
  lda PoolControllerA::PRESSED_DATA
  ; Play beep sound on every key press
  cmp #%00000000
  bne @playSound
  jmp @return
@playSound:
  jsr PlayBeep
@return:
  jmp @GameLoop

CTRL_TILES:
  .byte $F0, $F1, $F2, $F3, $F4, $F5

hello:
  .byte "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.", $0

.endproc

.proc nmi
  ; The NMI procedure is called at the end of every frame.
  ; This is the only period where we can write data to the PPU.
  ; Here we'll do all the logic that update our sprites and backgrounds (nametables)

  ; Because we don't have any control as to WHEN the NMI is called, we
  ; need to save the current state of the registers to the stack.
  ; The NMI can (and probably will) be called in the middle of a procedure that is
  ; currently using the 6502 registers.
  SaveRegisters

  bit PPU_STATUS
  lda #.HIBYTE(LoadNametables::CTRL_BUFFER)
  sta PPU_ADDR
  lda #.LOBYTE(LoadNametables::CTRL_BUFFER)
  sta PPU_ADDR
  
  lda PoolControllerA::BUTTON_TILES
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+1
  sta PPU_DATA
  ; Not showing start and select on screen
  lda PoolControllerA::BUTTON_TILES+4
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+5
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+6
  sta PPU_DATA
  lda PoolControllerA::BUTTON_TILES+7
  sta PPU_DATA

  VramReset

  RestoreRegisters

  rti
  

.endproc

.segment "CHARS"
  .incbin "CHR_ROM.chr"