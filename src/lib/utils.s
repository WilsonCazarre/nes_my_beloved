

.macro SaveRegisters
  ; Call this macro at the start of a procedure to save the internal registers.
  ; The code below push the registers A, Y and X (in that order) to the stack.
  ; The registers need to be restored at the reverse order (see RestoreRegisters).
  pha
  tya
  pha
  txa
  pha
.endmacro

.macro RestoreRegisters
  ; Call this macro at the end of a procedure to restore the internal registers.
  ; The order 
  pla
  tax
  pla
  tay
  pla
.endmacro