READCHAR MACRO DST
    ; MACRO THAT READS A CHARACTER
             PUSH AX

             MOV  AH, 01H
             INT  21H
             MOV  BYTE PTR DST, AL

             POP  AX
ENDM

PRINTCHAR MACRO CHAR
    ; MACRO THAT PRINTS A CHARACTER
              PUSH AX
              PUSH DX

              MOV  AH, 02H
              MOV  DL, BYTE PTR CHAR
              INT  21H
 
              POP  DX
              POP  AX
ENDM

PRINT_MSG MACRO MSG_PTR
    ; MACRO THAT PRINTS A '$'-TERMINATED STRING
              PUSH AX
              PUSH DX

              MOV  AH, 09H
              MOV  DX, MSG_PTR
              INT  21H

              POP  DX
              POP  AX
ENDM