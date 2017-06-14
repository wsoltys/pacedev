.import __STARTUP_LOAD__, __BSS_LOAD__ ; Linker generated

.segment "EXEHDR"
.addr __STARTUP_LOAD__ ; Start address
.word __BSS_LOAD__ - __STARTUP_LOAD__ ; Size

.segment "RODATA"
MSG: .ASCIIZ "Hello world!"

.segment "STARTUP"

LDA #$8D ; next line
JSR $FDED
LDX #0
LDA MSG,X ; load initial char
@LP: ORA #$80
JSR $FDED ; cout
INX
LDA MSG,X
BNE @LP
LDA #$8D ; next line
JSR $FDED
JMP $03D0 ; warm start

