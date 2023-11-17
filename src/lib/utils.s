.macro SaveRegisters
  pha
  tya
  pha
  txa
  pha
.endmacro

.macro RestoreRegisters
  pla
  tax
  pla
  tay
  pla
.endmacro