INCLUDE maclib.asm

DATA SEGMENT PARA PUBLIC 'DATA'
    ;define data here
    MSG1        DB     "Starting from: $"
    MSG2        DB     "Invalid input! Try again: $"
    MSG3        DB     "Iterations: $"
    SEL_MODE    DB     "Enter 0 for automatic mode or 1 for interactive mode: $"
    MSG4        DB     "Invalid input mode. Please enter 0 (automatic) or 1 (interactive): $"
    READ_BUF    DB     32, ?, 32 DUP(?)
    VEC         DB     4 DUP(?)
    REV_VEC     DB     4 DUP(?)
    CPY         DB     4 DUP(?)
    BOOL        DB     0
    ITERATIONS  DB     0
    SELECT      DB     ?
    FILE_NAME   DB     'data.txt'
    FILE_HANDLE DW     ?
    SPACE       DB     ' '
    CHAR        DB     ?
    NEWLINE     DB     0AH
DATA ENDS

;code segment
CODE SEGMENT PARA PUBLIC 'CODE'
    ;refere the functios used from proclib.asm (the external functions)
    EXTRN NEW_LINE:NEAR
    EXTRN NEW_LINE_IN_FILE:NEAR
    EXTRN PRINT_MSG:NEAR
    EXTRN SORT_DECR:NEAR
    EXTRN REVERSE:NEAR
    EXTRN DIFF:NEAR
    EXTRN FINAL:NEAR
    EXTRN PRINT:NEAR
    EXTRN PRINTNUM:NEAR
    EXTRN CREATE_FILE:NEAR
    EXTRN PRINT_SPACE:NEAR
    EXTRN PRINT_IT_TO_FILE:NEAR

    ASSUME CS:CODE, DS:DATA

    ;procedure to read a number
    ;if valid store it into VEC
    READS PROC NEAR
        REPEAT:
        MOV BP, SP
        MOV DI, [BP + 2]                        ;addr of VEC
        MOV SI, [BP + 4]                        ;addr of READ_BUFF
        MOV AH, 0AH
        LEA DX, READ_BUF
        INT 21H
        ;check if input is a 4 digit number
        INC SI
        MOV AL, [SI]
        CMP AL, 4
        JNE TRY_AGAN
        JMP GOON
        TRY_AGAN:
            CALL NEW_LINE
            PUSH OFFSET MSG2
            CALL PRINT_MSG
            JMP REPEAT
        GOON:
            ;check if each digit is a number
            MOV CX, 4
            INC SI
            IT:
                MOV AL, [SI]
                CMP AL, '0'
                JNB CONTINUE
                JMP TRY_AGAN
                CONTINUE:
                CMP AL, '9'
                JNA CONTINUE1
                JMP TRY_AGAN
                CONTINUE1:
                    SUB AL, '0'
                    MOV [DI], AL
                    INC DI
                    INC SI
            LOOP IT
    RET 4
    READS ENDP

    ;PROCEDURE TO PERFORM KAPREKAR ROUTINE IN INTERACTIVE MODE
    INTERACTIVE_MODE PROC NEAR
        ;ask for input
        PUSH OFFSET MSG1
        CALL PRINT_MSG
        ;read input as a string
        PUSH OFFSET READ_BUF
        PUSH OFFSET VEC
        CALL READS
        CALL NEW_LINE
        ;MAIN ROUTINE STARTS HERE
        MOV BL, 0
        MOV ITERATIONS, BL
        MOV BOOL, BL
        KAPREKAR:
            INC ITERATIONS
            ;sort digits in decreasing order
            PUSH OFFSET VEC
            CALL SORT_DECR
            ;store reverse vector
            PUSH OFFSET VEC
            PUSH OFFSET REV_VEC
            CALL REVERSE
            ;compute difference
            PUSH OFFSET VEC
            PUSH OFFSET REV_VEC
            CALL DIFF
            ;print current number
            PUSH OFFSET VEC
            CALL PRINT
            CALL NEW_LINE
            ;check for ending
            PUSH OFFSET VEC
            CALL FINAL
            MOV BOOL, BL
            MOV BH, 1
            CMP BOOL, BH
            JNE KAPREKAR
        ;MAIN ROUTINE ENDS HERE
            ;print iterations
            CALL NEW_LINE
            PUSH OFFSET MSG3
            CALL PRINT_MSG
            PUSH OFFSET ITERATIONS
            CALL PRINTNUM
    RET 
    INTERACTIVE_MODE ENDP

    ;procedure to print a 4-digit number to the file
    PRINT_TO_FILE PROC NEAR
        MOV BP, SP
        MOV DI, [BP + 4]                        ;FILE HANDLE address
        MOV SI, [BP + 2]                        ;VEC address
        XOR CX, CX
        MOV CL, 4                               ;number of bytes to be printed
        ITERR:
            MOV AL, [SI]                        ;make integer to char for printing
            ADD AL, '0'
            MOV CHAR, AL                        ;store char into a variable CHAR (makes it easier to get its addr)
            MOV DX, OFFSET CHAR                 ;load address of CHAR into DX
            PUSH CX
            MOV AH, 40H 
            MOV CX, 1
            MOV BX, [DI]                        ;load file handle
            INT 21H                             ;call interrupt
            POP CX
            INC SI
        LOOP ITERR 
    RET 4
    PRINT_TO_FILE ENDP

    AUTO_K_ROUTINE PROC NEAR
        ;initialize BOOL
        MOV BL, 0
        MOV BOOL, 0
        ;save a copy of VEC
        PUSH OFFSET VEC
        PUSH OFFSET CPY
        CALL COPY_VEC
        ;MAIN KAPREKAR ROUTINE
        MOV BL, 0
        MOV ITERATIONS, BL
        KAPREKAR_AUTO:
            INC ITERATIONS
            ;sort digits in decreasing order
            PUSH OFFSET VEC
            CALL SORT_DECR
            ;store reverse vector
            PUSH OFFSET VEC
            PUSH OFFSET REV_VEC
            CALL REVERSE
            ;compute difference
            PUSH OFFSET VEC
            PUSH OFFSET REV_VEC
            CALL DIFF
            ;check for ending
            ;FINAL returns into BL 1 if the routine has reached the end
            PUSH OFFSET VEC
            CALL FINAL
            MOV BOOL, BL
            MOV BH, 1
            CMP BOOL, BH
            JNE KAPREKAR_AUTO
        ;END OF MAIN KAPREKAR ROUTINE
        ;restore VEC
        PUSH OFFSET CPY
        PUSH OFFSET VEC
        CALL COPY_VEC
        ;print VEC to file
        PUSH OFFSET FILE_HANDLE
        PUSH OFFSET VEC
        CALL PRINT_TO_FILE
        ;print the number of iterations to file:
        ;print a space
        PUSH OFFSET FILE_HANDLE
        PUSH OFFSET SPACE
        CALL PRINT_SPACE
        ;print iterations
        PUSH OFFSET FILE_HANDLE
        PUSH OFFSET ITERATIONS
        CALL PRINT_IT_TO_FILE
        ;print a new line
        PUSH OFFSET FILE_HANDLE
        PUSH OFFSET NEWLINE
        CALL NEW_LINE_IN_FILE
    RET
    AUTO_K_ROUTINE ENDP

    AUTOMATIC_MODE PROC NEAR
        ;initialize BOOL variable (use it to mark the end of a routine later on)
        MOV AL, 0
        MOV BOOL, AL
        ;create file for output
        PUSH OFFSET FILE_HANDLE
        PUSH OFFSET FILE_NAME
        CALL CREATE_FILE
        ;generate numbers, apply Kaprekar routine and write to file
        ;for each loop we load 10 into CX (there are 10 1-digit numbers)
        ;in order to obtain all possible combinations of 4 digits
        MOV CX, 10
        MOV AX, 0
        FOR1:
        PUSH CX
        MOV CX, 10
        MOV VEC[0], AL
        PUSH AX
        MOV AX, 0
            FOR2:
            PUSH CX
            MOV CX, 10
            MOV VEC[1], AL
            PUSH AX
            MOV AX, 0
                FOR3:
                PUSH CX
                MOV CX, 10
                MOV VEC[2], AL
                PUSH AX
                MOV AX, 0
                    FOR4:
                    MOV VEC[3], AL
                    INC AX
                    PUSH AX
                    PUSH CX
                    ;for each number, run the Kaprekar routine
                    CALL AUTO_K_ROUTINE
                    POP CX
                    POP AX
                    LOOP FOR4
                    POP AX
                    INC AX
                    POP CX
                LOOP FOR3
                POP AX
                INC AX
                POP CX
            LOOP FOR2
            POP AX
            INC AX
            POP CX
        LOOP FOR1 
    RET
    AUTOMATIC_MODE ENDP

    MAIN PROC FAR
        ;instructions to allow return to OS
        PUSH DS
        XOR AX, AX
        PUSH AX
        ;initialize DS with start of data segment
        MOV AX, DATA
        MOV DS, AX
        ;main code goes here
        ;ask user to select running mode
        PUSH OFFSET SEL_MODE
        CALL PRINT_MSG
        TAKEANOTHERMODE:
        ;read running mode
        READ_CHAR SELECT
        CALL NEW_LINE
        ;check that the running mode was introduced correctly
        VALID BOOL, SELECT
        CMP BOOL, 1
        JNE VALIDMODE 
        ;display error message if running mode is invalid
        PUSH OFFSET MSG4
        CALL PRINT_MSG
        ;running mode will be reintroduced
        JMP TAKEANOTHERMODE 
        VALIDMODE:
        ;select running mode
        CMP SELECT, '1'
        JNE AUTOMATIC
        ;RUN INTERACTIVE MODE
        CALL INTERACTIVE_MODE
        JMP ENDOFPROG
        ;RUN AUTOMATIC MODE
        AUTOMATIC:
        CALL AUTOMATIC_MODE
        ENDOFPROG:
        RET;return control to OS
    MAIN ENDP
CODE ENDS

CODE2 SEGMENT PARA PUBLIC 'CODE'
ASSUME CS:CODE2
; FAR procedures declaration zone
    ;procedure to make a copy of SOURCE into DESTINATION
    COPY_VEC PROC FAR
        MOV BP, SP
        MOV SI, [BP + 6]                        ;address of SOURCE vector
        MOV DI, [BP + 4]                        ;address of DESTINATION vector
        MOV CX, 4
        ITERRR:                                 ;iterate through SOURCE and copy its contents into DESTINATIONS
            MOV AL, [SI]
            MOV [DI], AL
            INC SI
            INC DI
        LOOP ITERRR
    RET 4
    COPY_VEC ENDP
; End of FAR procedures declaration zone
CODE2 ENDS
END MAIN
