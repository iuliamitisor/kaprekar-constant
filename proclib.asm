DATA SEGMENT PARA PUBLIC 'DATA'
    NUMBER            DW 0
    ADR_NB            DW NUMBER

    ASCII_DIGIT       DB ?
    ADR_A_DIGIT       DW ASCII_DIGIT

    MSG1              DB 'Starting from: $'
    ADR_MSG1          DW MSG1
    MSG2              DB 'Iterations: $'
    ADR_MSG2          DW MSG2
    MSG3              DB 'Wrong input, try again: $'
    ADR_MSG3          DW MSG3
    MSG4              DB 'Choose running mode (A - Automatic run, U - User input): $'
    ADR_MSG4          DW MSG4

    DIGITS            DB 4 dup(0)
    ADR_DIGITS0       DW DIGITS
    ADR_DIGITS1       DW DIGITS + 1
    ADR_DIGITS2       DW DIGITS + 2
    ADR_DIGITS3       DW DIGITS + 3
    NUMBER_AUX        DW 0
    COUNTER           DB 0
    COUNTER_AUTO      DB 0
    MODE              DB 0

    MINUS             DB '-'
    EQUAL             DB '='
    SPACE             DB ' '
    NEWLINE           DB 13, 10

    ATTR_NORMAL       DW 0000H
    FILE_NAME         DB 'test.txt',0
    ADR_FILE_NAME     DW FILE_NAME
    READ_WRITE        DB 02H
    DIGIT_TO_FILE     DW 0
    ADR_DIGIT_TO_FILE DW DIGIT_TO_FILE
    FILE_HANDLE       DW 0
DATA ENDS

INCLUDE maclib.asm

CODE SEGMENT PARA PUBLIC 'CODE'
                        PUBLIC    READ_DEC_NUMBER
                        PUBLIC    PRINT_DEC_NUMBER
                        PUBLIC    NEW_LINE
                        PUBLIC    SORT_ASC
                        PUBLIC    SORT_DESC
                        PUBLIC    PUT_IN_DIGITS
                        PUBLIC    KAPREKAR
                        ASSUME    CS:CODE, DS:DATA

READ_DEC_NUMBER PROC NEAR
                        XOR       AX, AX
                        XOR       BX, BX
                        MOV       CX, 4
                        JMP       START_READ

    WRONG_INPUT:        
                        MOV       NUMBER, 0
                        XOR       AX, AX
                        XOR       BX, BX
                        MOV       CX, 4
                        CALL      NEW_LINE
                        PRINT_MSG ADR_MSG3
    START_READ:
                        READCHAR  ADR_A_DIGIT

    ; CHECK IF CHARACTER IS DIGIT. IF NOT, READ ANOTHER CHARACTER
                        CMP       [ADR_A_DIGIT], '0'
                        JS        WRONG_INPUT
                        CMP       [ADR_A_DIGIT], '9'
                        JG        WRONG_INPUT
    ; SUBTRACT '0' FROM READ CHARACTER TO MAKE IT A DECIMAL DIGIT
                        SUB       [ADR_A_DIGIT], '0'
    ; NUMBER <- NUMBER * 10 AND STORE CONTENTS IN CX
                        MOV       AX, NUMBER
                        MOV       BX, 10
                        MUL       BX
                        MOV       BX, AX
   
    ; ADD IT TO THE NUMBER
                        ADD       BX, [ADR_A_DIGIT]
                        MOV       NUMBER, BX
                        MOV       AX, NUMBER
                     
    ; REPEAT
                        LOOP      START_READ
    END_READ:           
                        RET
READ_DEC_NUMBER ENDP

PRINT_DEC_NUMBER PROC NEAR
                        PUSH      DX
                        PUSH      AX
                        PUSH      BX
                        PUSH      CX

                        MOV       CX, 4
                        MOV       DX, 0
    STEP_ONE:           
    ; DIVIDE NUMBER BY 10 => QUOTIENT IN AX, REMAINDER IN DX (LAST DIGIT OF NUMBER STORED IN DX)

                        MOV       BX, 10
                        DIV       BX
    ; PUSH LAST DIGIT ON STACK
                        PUSH      DX
                        MOV       DX, 0
    ; IF ALL DIGITS HAVE BEEN PUSHED ONTO STACK, GOTO SECOND STEP: PRINTING THEM
                        LOOP      STEP_ONE
    STEP_TWO:           
                        MOV       CX, 4
    PRINT:              
    ; TURN DECIMAL DIGIT INTO CHARACTER BY ADDING '0'
                        POP       BX
                        ADD       BX, '0'
                        PRINTCHAR BL

                        LOOP      PRINT
    END_LABEL:          
                        POP       CX
                        POP       BX
                        POP       AX
                        POP       DX
                        RET
PRINT_DEC_NUMBER ENDP

NEW_LINE PROC NEAR
    ; TO PRINT A NEWLINE TO CONSOLE
                        PUSH      AX
                        PUSH      DX

                        MOV       AH, 02H
                        MOV       DL, 0AH
                        INT       21H
                        MOV       DL, 0DH
                        INT       21H

                        POP       DX
                        POP       AX
                        RET
NEW_LINE ENDP

SORT_DESC PROC NEAR
                        MOV       DIGITS[0], 0
                        MOV       DIGITS[1], 0
                        MOV       DIGITS[2], 0
                        MOV       DIGITS[3], 0
    ; EXPECTS NUMBER TO BE SORTED IN AX
                        PUSH      DX
                        PUSH      BX
                        PUSH      CX
                        PUSH      SI

                        MOV       CX, 4
                        MOV       DX, 0
                        MOV       SI, 3
                        MOV       BX, 10
    GET_DIGITS_DESC:    
    ; DIVIDE NUMBER BY 10 => QUOTIENT IN AX, REMAINDER IN DX (LAST DIGIT OF NUMBER STORED IN DX)
                        DIV       BX
    ; PUSH LAST DIGIT ON STACK
                        MOV       DIGITS[SI], DL
                        MOV       DX, 0
    ; IF ALL DIGITS HAVE BEEN PUSHED ONTO STACK, START POP OPERATIONS
                        DEC       SI
                        LOOP      GET_DIGITS_DESC
    ; MOVE ALL DIGITS OF NUMBER INTO A BYTE ARRAY

    ; SORT ELEMENTS OF ARRAY IN DECREASING ORDER
                        MOV       CX, 4
                        MOV       SI, 0
    OUTER_DESC:         
                        PUSH      CX
                        MOV       CX, 4
                        MOV       DI, 0
    INNER_DESC:         
                        MOV       AL, DIGITS[SI]
                        CMP       AL, DIGITS[DI]
                        JB        NO_SWAP_DESC
                        XCHG      AL, DIGITS[DI]
                        MOV       DIGITS[SI], AL
    NO_SWAP_DESC:       
                        INC       DI
                        LOOP      INNER_DESC
                        POP       CX
                        INC       SI
                        LOOP      OUTER_DESC

                        MOV       CX, 4
                        MOV       SI, 0
                        MOV       BX, 10
                        MOV       AX, 0
    
    ; START FORMING THE NUMBER WITH SORTED DIGITS IN AX
    CREATE_NR_DESC:     
                        MUL       BX                     ; NUMBER = NUMBER * 10
                        MOV       DL, DIGITS[SI]
                        MOV       DH, 0
                        ADD       AX, DX                 ; NUMBER = NUMBER * 10 + DIGIT
                        INC       SI
                        LOOP      CREATE_NR_DESC

                        POP       SI
                        POP       CX
                        POP       BX
                        POP       DX
                        RET
SORT_DESC ENDP

SORT_ASC PROC NEAR
    ; EXPECTS NUMBER IN AX
                        MOV       DIGITS[0], 0
                        MOV       DIGITS[1], 0
                        MOV       DIGITS[2], 0
                        MOV       DIGITS[3], 0
                        PUSH      DX
                        PUSH      BX
                        PUSH      CX
                        PUSH      SI
                        MOV       CX, 4
                        MOV       DX, 0
                        MOV       BX, 10
                    
                        MOV       SI, 3
    DIGIT_ASC:                                           ; MOVE ALL DIGITS OF NUMBER INTO A BYTE ARRAY
    ; DIVIDE NUMBER BY 10 => QUOTIENT IN AX, REMAINDER IN DX (LAST DIGIT OF NUMBER STORED IN DX)
                        DIV       BX
    ; PUSH LAST DIGIT ON STACK
                        MOV       DIGITS[SI], DL
                        MOV       DX, 0
    ; IF ALL DIGITS HAVE BEEN PUSHED ONTO STACK, START POP OPERATIONS
                        DEC       SI
                        LOOP      DIGIT_ASC
    


    ; SORT ELEMENTS OF ARRAY IN DECREASING ORDER
                        MOV       CX, 4
                        MOV       SI, 0
    OUTER_ASC:          
                        PUSH      CX
                        MOV       CX, 4
                        MOV       DI, 0
    INNER_ASC:          
                        MOV       AL, DIGITS[SI]
                        CMP       AL, DIGITS[DI]
                        JA        NO_SWAP_ASC
                        XCHG      AL, DIGITS[DI]
                        MOV       DIGITS[SI], AL
    NO_SWAP_ASC:        
                        INC       DI
                        LOOP      INNER_ASC
                        POP       CX
                        INC       SI
                        LOOP      OUTER_ASC
   
                        MOV       CX, 4
                        MOV       SI, 0
                        MOV       BX, 10
                        MOV       AX, 0

    ; START FORMING THE NUMBER WITH SORTED DIGITS IN AX
    CREATE_NR_ASC:      
                        MUL       BX                     ; NUMBER = NUMBER * 10
                        MOV       DL, DIGITS[SI]
                        MOV       DH, 0
                        ADD       AX, DX                 ; NUMBER = NUMBER * 10 + DIGIT
                        INC       SI
                        LOOP      CREATE_NR_ASC

                        POP       SI
                        POP       CX
                        POP       BX
                        POP       DX
                        RET
SORT_ASC ENDP

PUT_IN_DIGITS PROC NEAR
    ; EXPECTS NUMBER IN AX
                        PUSH      DX
                        PUSH      BX
                        PUSH      CX
                        PUSH      SI

                        MOV       CX, 4
                        MOV       DX, 0
                        MOV       BX, 10
                        MOV       SI, 3
    GET_DIGS:           
    ; DIVIDE NUMBER BY 10 => QUOTIENT IN AX, REMAINDER IN DX (LAST DIGIT OF NUMBER STORED IN DX)
                        DIV       BX
    ; PUSH LAST DIGIT ON STACK
                        ADD       DL,  '0'
                        MOV       DIGITS[SI], DL
                  
                        MOV       DX, 0
                        DEC       SI
    ; IF ALL DIGITS HAVE BEEN PUSHED ONTO STACK, START POP OPERATIONS
                        LOOP      GET_DIGS
    ; MOVE ALL DIGITS OF NUMBER INTO A BYTE ARRAY
                        POP       SI
                        POP       CX
                        POP       BX
                        POP       DX
                        RET

PUT_IN_DIGITS ENDP


KAPREKAR PROC NEAR
                        PUSH      AX
                        PUSH      BX
                        PUSH      CX
                        PUSH      DX
    ; INITIALISE CX WITH VALUE 7, SINCE IT TAKES AT MOST 7 OPERATIONS TO REACH A RESULT
                        MOV       CX, 7
                   
    START_LOOP_EXT_FUNC:
   
    ; STORE A COPY OF THE INITIAL NUMBER
                        MOV       AX, NUMBER
                        MOV       NUMBER_AUX, AX
    ; SORT DESCENDING: RESULT IS STORED IN DX
                        CALL      SORT_DESC
                        MOV       DX, AX
    ; SORT ASCENDING: RESULT IS STORED IN AX
                        MOV       AX, NUMBER_AUX         ; LOAD AX WITH INITIAL INPUT NUMBER
                        CALL      SORT_ASC
    ; PERFORM SUBTRACTION
                        SUB       DX, AX
                        MOV       AX, DX
    ; UPDATE VALUE OF NUMBER
                        MOV       NUMBER, AX
                   
    ; INCREMENT NUMBER OF OPERATIONS NEEDED
                        PUSH      AX
                        MOV       AL, COUNTER_AUTO
                        INC       AL
                        MOV       COUNTER_AUTO, AL
                        POP       AX
    ; IF RESULT IS 0 OR KAPREKAR'S CONSTANT, PROGRAM ENDS
                        CMP       AX, 0
                        JE        END_FUNC
                        CMP       AX, 6174
                        JE        END_FUNC
                        LOOP      START_LOOP_EXT_FUNC

    END_FUNC:                                  
                        POP       DX
                        POP       CX
                        POP       BX
                        POP       AX
                        RET
KAPREKAR ENDP

CODE ENDS