INCLUDE proclib.asm 

CODE SEGMENT PARA PUBLIC 'CODE'

                      ASSUME    CS:CODE, DS:DATA
START PROC FAR
                      PUSH      DS
                      XOR       AX, AX
                      MOV       DS, AX
                      PUSH      AX
                      MOV       AX, DATA
                      MOV       DS, AX
    ; USER IS ABLE TO CHOOSE WORKING MODE: AUTOMATIC RUN OR USER INPUT
                      PRINT_MSG ADR_MSG4
                      READCHAR  MODE
                      CALL      NEW_LINE
                      CMP       MODE, 'U'
                      JE        INTERMEDIARY
    AUTOMATIC_RUN:    
                     
    ;CREATE FILE
                      MOV       AH, 3CH
                      XOR       CX, CX
                      OR        CX, ATTR_NORMAL
                      MOV       DX, ADR_FILE_NAME
                      INT       21H
    ;OPEN FILE
                      MOV       AH, 3DH
                      MOV       AL, 0
                      OR        AL, READ_WRITE
                      MOV       DX, ADR_FILE_NAME
                      INT       21H
                      MOV       BX, AX
    ; WRITE IN FILE
    ; LOAD NUMBER OF ITERATIONS IN CX
                      MOV       CX, 9999
                      MOV       AX, 0
                      JMP       HOPA
    INTERMEDIARY:     JMP       TYPE_NUMBER
    HOPA:             
    WRITE_ALL_NUMBERS:
                      MOV       COUNTER_AUTO, 0
                      PUSH      AX
                      CALL      PUT_IN_DIGITS
    ; WRITE NUMBER
                      MOV       DX, OFFSET DIGITS          
                      MOV       CX, 4                     
                      MOV       AH, 40h                    
                      INT       21h                       
    ; WRITE SPACE
                      MOV       DX, OFFSET SPACE
                      MOV       CX, 1
                      MOV       AH, 40h
                      INT       21h
                      CALL KAPREKAR

    ; WRITE NUMBER OF ITERATIONS
                      ADD       COUNTER_AUTO,'0'
                      MOV       DX, OFFSET COUNTER_AUTO
                      MOV       CX, 1
                      MOV       AH, 40h
                      INT       21h
                      
                      MOV       DX, OFFSET NEWLINE
                      MOV       CX, 2
                      MOV       AH, 40h
                      INT       21h

                      POP       AX
                      INC       AX
                      CMP       AX, 9999
                      JA        EXIT_LOOP
                      LOOP      WRITE_ALL_NUMBERS
    EXIT_LOOP:        

    ; CLOSE FILE
                      MOV       AH, 3EH
                      INT       21H
                      JMP       END_AUTOMATIC
    TYPE_NUMBER:      
    ; READ NUMBER FROM CONSOLE
                      PRINT_MSG ADR_MSG1
                      CALL      READ_DEC_NUMBER

    ; IF NUMBER IS 0 OR KAPREKAR'S CONSTANT, PROGRAM ENDS
                      CMP       NUMBER, 0
                      JE        END_PROGRAM
                      CMP       NUMBER, 6174
                      JE        END_PROGRAM
    ; INITIALISE CX WITH VALUE 7, SINCE IT TAKES AT MOST 7 OPERATIONS TO REACH A RESULT
                      MOV       CX, 7
                   
    START_LOOP_EXT:   
   
    ; STORE A COPY OF THE INITIAL NUMBER
                      MOV       AX, NUMBER
                      MOV       NUMBER_AUX, AX
    ; SORT DESCENDING: RESULT IS STORED IN DX
                      CALL      SORT_DESC
                      CALL      NEW_LINE
                      CALL      PRINT_DEC_NUMBER
                      PRINTCHAR MINUS
                      MOV       DX, AX
    ; SORT ASCENDING: RESULT IS STORED IN AX
                      MOV       AX, NUMBER_AUX             ; LOAD AX WITH INITIAL INPUT NUMBER
                      CALL      SORT_ASC
                      CALL      PRINT_DEC_NUMBER
                      PRINTCHAR EQUAL
    ; PERFORM SUBTRACTION
                      SUB       DX, AX
                      MOV       AX, DX
                      CALL      PRINT_DEC_NUMBER
    ; UPDATE VALUE OF NUMBER
                      MOV       NUMBER, AX
                   
    ; INCREMENT NUMBER OF OPERATIONS NEEDED
                      PUSH      AX
                      MOV       AL, COUNTER
                      INC       AL
                      MOV       COUNTER, AL
                      POP       AX
    ; IF RESULT IS 0 OR KAPREKAR'S CONSTANT, PROGRAM ENDS
                      CMP       AX, 0
                      JE        END_PROGRAM
                      CMP       AX, 6174
                      JE        END_PROGRAM
                      LOOP      START_LOOP_EXT
    END_PROGRAM:      
    ; RESULT IS PRINTED
    ; TURN DECIMAL DIGIT INTO CHARACTER BY ADDING '0'
                      CALL      NEW_LINE
                      PRINT_MSG ADR_MSG2
                      MOV       BL, COUNTER
                      ADD       BL, '0'
                      PRINTCHAR BL
    END_AUTOMATIC:    
                      RET
START ENDP
CODE ENDS
END START