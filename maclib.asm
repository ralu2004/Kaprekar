;macro to read a character from the keyboard
READ_CHAR MACRO X
    PUSH AX

    MOV AH, 01H
    INT 21h
    MOV X, AL

    POP AX
ENDM

 ;macro to validate user selection of running mode (only take 0 or 1)
VALID MACRO X, Y
    PUSH AX

        MOV X, 0
        MOV AL, '0'
        CMP AL, Y
        JE OK
        MOV AL, '1'
        CMP AL, Y
        JE OK
        MOV AL, 1
        MOV X, 1
        OK:
    POP AX
ENDM