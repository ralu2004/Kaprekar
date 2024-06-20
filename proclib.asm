INCLUDE maclib.asm

CODE SEGMENT PARA PUBLIC 'CODE' 
    PUBLIC NEW_LINE
    PUBLIC NEW_LINE_IN_FILE
    PUBLIC PRINT_MSG
    PUBLIC SORT_DECR
    PUBLIC REVERSE
    PUBLIC DIFF
    PUBLIC FINAL
    PUBLIC PRINT
    PUBLIC PRINTNUM
    PUBLIC CREATE_FILE
    PUBLIC PRINT_SPACE
    PUBLIC PRINT_IT_TO_FILE
ASSUME CS:CODE
; NEAR procedures declaration zone
    ;procedure to display a new line
    NEW_LINE PROC NEAR
        MOV DX, 10
        MOV AH, 02h
        INT 21h
        MOV DX, 13
        MOV AH, 02h
        INT 21h
    RET
    NEW_LINE ENDP 
    ;procedure to display a new line in a file
    NEW_LINE_IN_FILE PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 4]                        ;file handle
        MOV DI, [BP + 2]                        ;NEWLINE
        MOV BX, [SI]
        MOV AH, 40H
        MOV CX, 1
        MOV DX, DI
        INT 21H
    RET 4
    NEW_LINE_IN_FILE ENDP
    ;procedure to print a message to the console
    PRINT_MSG PROC NEAR
        MOV BP, SP
        MOV DX, [BP + 2]
        MOV AH, 09H
        INT 21H
    RET 2
    PRINT_MSG ENDP
;procedure to sort a given vector in decreasing order
    SORT_DECR PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 2]                        ;address of VEC
        MOV DI, [BP + 2]
        MOV CL, 4
        OUTER:                                  ;for i-> 1,len; i = DI
            PUSH CX                             ;save counter for outer loop
            MOV CL, 4                           ;set counter and index for inner loop
            MOV SI, [BP + 2]
            INNER:                              ;for j-> 1, len; j = SI
                MOV AL, [SI]
                CMP AL, [DI]
                JNB DONT
                ;swap if VEC[SI] < VEC[DI]
                MOV AH, [DI]
                MOV [DI], AL
                MOV [SI], AH
                DONT:
                INC SI
                LOOP INNER
            INC DI
            POP CX
            LOOP OUTER
    RET 2
    SORT_DECR ENDP
    ;procedure to compute the reverse of a number (a vector in this case)
    REVERSE PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 4]
        MOV DI, [BP + 2]
        ADD SI, 3
        XOR CX, CX
        MOV CL, 4
       ; MOV DI, 0
        ITER1:
            MOV AL, BYTE PTR [SI]
            MOV [DI], AL
            INC DI
            DEC SI
        LOOP ITER1
    RET 4
    REVERSE ENDP
    ;compute the difference digit by digit between VEC and REV_VEC
    ;result is stored in VEC
    DIFF PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 4]                    ;VEC
        MOV DI, [BP + 2]                    ;REV_VEC
        ADD SI, 3
        ADD DI, 3
        XOR BX, BX
        XOR CX, CX
        MOV CL, 4
        MOV BL, 0                           ;store borrow in BL
        ITER2:
            MOV AH, [SI]
            MOV AL, [DI]
            ADD AL, BL    
            CMP AH, AL                      ;is VEC[i] > REV_VEC[i] - borrow
            JB LESS
            SUB AH, AL 
            MOV BL, 0
            JMP AFTER
            LESS:
                ADD AH, 10
                SUB AH, AL
                MOV BL, 1                   ;borrow becomes 1
            AFTER:
            MOV [SI], AH
            DEC SI
            DEC DI
        LOOP ITER2
    RET 4
    DIFF ENDP
    ;procedure to determine whether 6174 or 0000 was found
    ;returns 1 in BL register if true
    FINAL PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 2]
        MOV DI, [BP + 2]
        MOV AL, [SI]
        CMP AL, 6
        JNE NOT_EQ
        INC SI
        MOV AL, [SI]
        CMP AL, 1
        JNE NOT_EQ
        INC SI
        MOV AL, [SI]
        CMP AL, 7
        JNE NOT_EQ
        INC SI
        MOV AL, [SI]
        CMP AL, 4
        JNE NOT_EQ
        MOV BL, 1
        JMP NOT_ZERO
        NOT_EQ:
        MOV CX, 4
            ITER4:
            MOV AL, [DI]
            CMP AL, 0
            JNE NOT_ZERO
            INC DI
            LOOP ITER4
            MOV BL, 1
        NOT_ZERO:
        RET 2
    FINAL ENDP
    ;procedure to print a 4-digit number stored as a vector
    PRINT PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 2]
        MOV AH, 02H
        XOR CX, CX
        MOV CL, 4
        ITER3:
            MOV AL, [SI]
            ADD AL, '0'
            MOV DL, AL
            INT 21H
            INC SI
        LOOP ITER3
    RET 2
    PRINT ENDP
    ;procedure to print a number
    PRINTNUM PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 2]
        MOV DL, [SI]
        ADD DL, '0'
        MOV AH, 02H
        INT 21H
    RET 2
    PRINTNUM ENDP
    ;procedure to create file for output
    CREATE_FILE PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 4]                        ;FILE HANDLE
        MOV AH, 3CH         
        MOV CL, 1                               ;write mode
        MOV DX, [BP + 2]                        ;offset of file name
        INT 21H
        MOV [SI], AX
    RET 4
    CREATE_FILE ENDP
    PRINT_SPACE PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 4]                        ;FILE HANDLE
        MOV DI, [BP + 2]                        ;SPACE VAR
        MOV DX, DI
        MOV AH, 40H
        MOV BX, [SI]
        MOV CX, 1
        INT 21H
    RET 4
    PRINT_SPACE ENDP
    ;procedure to print the number of iterations to the file
    PRINT_IT_TO_FILE PROC NEAR
        MOV BP, SP
        MOV SI, [BP + 4]                        ;FILE HANDLE
        MOV DI, [BP + 2]                        ;OFFSET ITERATIONS
        ;PRINT NUMBER
        MOV AL, [DI]                            ;convert it char
        ADD AL, '0'
        MOV [DI], AL
        MOV DX, DI                              ;pint it
        MOV AH, 40H 
        MOV CX, 1
        MOV BX, [SI]
        INT 21H
        MOV [DI], AL                            ;restore integer value
    RET 4
    PRINT_IT_TO_FILE ENDP
    
; End of NEAR procedures declaration zone
CODE ENDS


END