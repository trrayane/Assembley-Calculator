; Advanced 16-bit Calculator
; Supports arithmetic/logical operations with binary, hex, and flag display

.MODEL SMALL
.STACK 100h

.DATA
    ; Input prompts
    prompt1     DB "Enter first decimal number: $"
    prompt2     DB 13, 10, "Enter second decimal number: $"
    prompt_op   DB 13, 10, "Choose operation:", 13, 10
                DB "[1] AND    [2] OR", 13, 10
                DB "[3] XOR    [4] ADD", 13, 10
                DB "[5] SUB    [6] MUL", 13, 10
                DB "[7] DIV", 13, 10
                DB "Enter choice (1-7): $"

    ; Result strings
    binaryStr1  DB 13, 10, "First number in binary:  $"
    binaryStr2  DB 13, 10, "Second number in binary: $"
    hexStr1     DB 13, 10, "First number in hex:  $"
    hexStr2     DB 13, 10, "Second number in hex: $"
    resultStr   DB 13, 10, "Result in binary:  $"
    resultDec   DB 13, 10, "Result in decimal: $"
    resultHex   DB 13, 10, "Result in hex:     $"

    ; Flag display strings
    flagsMsg    DB 13, 10, "PSW:", 13, 10
                DB "CF=  ZF=  SF=  OF=  AF=  PF= $"
    setFlag     DB "1$"
    clearFlag   DB "0$"
    flagSpace   DB "  $"

    ; Error messages
    invalidInput DB 13, 10, "Invalid input! Number must be 0-65535.$"
    invalidOp    DB 13, 10, "Invalid operation! Choose 1-7.$"
    divByZero    DB 13, 10, "Error: Division by zero!$"
    divOverflow  DB 13, 10, "Error: Division overflow!$"
    exitMsg     DB 13, 10, 13, 10, "Press any key to exit...$"

    ; Storage variables
    buffer       DB 6    ; Max length (5 digits + CR)
                 DB ?    ; Actual length
                 DB 6 DUP(?) ; Buffer for input
    num1         DW ?
    num2         DW ?
    result       DW ?
    op_choice    DB ?
    saved_flags  DW ?    ; NEW: Store flags after operation
    newline      DB 13, 10, "$"

.CODE
wait_for_key PROC
    PUSH AX
    PUSH DX

    LEA DX, exitMsg
    MOV AH, 09h
    INT 21h

    MOV AH, 08h
    INT 21h

    POP DX
    POP AX
    RET
wait_for_key ENDP

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Get first number
    LEA DX, prompt1
    MOV AH, 09h
    INT 21h

    LEA DX, buffer
    MOV AH, 0Ah
    INT 21h

    LEA SI, buffer
    CALL parse_decimal
    MOV num1, AX

    ; Show binary and hex for first number
    PUSH AX
    LEA DX, binaryStr1
    MOV AH, 09h
    INT 21h
    POP AX
    CALL print_binary

    PUSH AX
    LEA DX, hexStr1
    MOV AH, 09h
    INT 21h
    POP AX
    CALL print_hex

    ; Get second number
    LEA DX, prompt2
    MOV AH, 09h
    INT 21h

    LEA DX, buffer
    MOV AH, 0Ah
    INT 21h

    LEA SI, buffer
    CALL parse_decimal
    MOV num2, AX

    ; Show binary and hex for second number
    PUSH AX
    LEA DX, binaryStr2
    MOV AH, 09h
    INT 21h
    POP AX
    CALL print_binary

    PUSH AX
    LEA DX, hexStr2
    MOV AH, 09h
    INT 21h
    POP AX
    CALL print_hex

    ; Get operation
    LEA DX, prompt_op
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV op_choice, AL

    LEA DX, newline
    MOV AH, 09h
    INT 21h

    ; Perform operation
    CALL do_operation

    ; Show results
    MOV AX, result

    PUSH AX
    LEA DX, resultStr
    MOV AH, 09h
    INT 21h
    POP AX
    CALL print_binary

    PUSH AX
    LEA DX, resultDec
    MOV AH, 09h
    INT 21h
    POP AX
    CALL print_decimal

    PUSH AX
    LEA DX, resultHex
    MOV AH, 09h
    INT 21h
    POP AX
    CALL print_hex

    ; Wait for key press before exiting
    CALL wait_for_key

    MOV AH, 4Ch
    INT 21h
MAIN ENDP

parse_decimal PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR AX, AX
    MOV CL, [SI+1]
    XOR CH, CH
    ADD SI, 2

    ; Check input length (max 5 digits)
    CMP CL, 0
    JE parse_error
    CMP CL, 5
    JA parse_error

    MOV BX, 10
parse_loop:
    MOV DL, [SI]
    SUB DL, '0'

    CMP DL, 0
    JB parse_error
    CMP DL, 9
    JA parse_error

    PUSH DX
    MUL BX
    POP DX
    JC parse_error

    XOR DH, DH
    ADD AX, DX
    JC parse_error

    INC SI
    LOOP parse_loop

    ; Check if number exceeds 65535
    CMP AX, 65535
    JA parse_error

    JMP parse_end

parse_error:
    LEA DX, invalidInput
    MOV AH, 09h
    INT 21h
    CALL wait_for_key
    MOV AH, 4Ch
    MOV AL, 01h    ; Fixed exit code
    INT 21h

parse_end:
    POP DX
    POP CX
    POP BX
    RET
parse_decimal ENDP

print_binary PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX
    MOV CX, 16
    XOR DH, DH

print_bit:
    ROL BX, 1
    MOV DL, '0'
    JNC bit_zero
    MOV DL, '1'
bit_zero:
    MOV AH, 02h
    INT 21h

    INC DH
    CMP DH, 4
    JNE no_space

    PUSH DX
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    POP DX
    XOR DH, DH

no_space:
    LOOP print_bit

    LEA DX, newline
    MOV AH, 09h
    INT 21h

    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_binary ENDP

print_hex PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX
    MOV CX, 4

print_hex_digit:
    ROL BX, 4
    MOV AL, BL
    AND AL, 0Fh

    ADD AL, '0'
    CMP AL, '9'
    JBE print_digit
    ADD AL, 7
print_digit:
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    LOOP print_hex_digit

    LEA DX, newline
    MOV AH, 09h
    INT 21h

    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_hex ENDP

print_decimal PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    TEST AX, AX
    JNZ not_zero

    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP print_dec_end

not_zero:
    MOV BX, 10
    XOR CX, CX

dec_loop:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    TEST AX, AX
    JNZ dec_loop

print_dec:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP print_dec

print_dec_end:
    LEA DX, newline
    MOV AH, 09h
    INT 21h

    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_decimal ENDP

print_flags PROC
    PUSH AX
    PUSH DX
    PUSH SI

    LEA DX, flagsMsg
    MOV AH, 09h
    INT 21h

    MOV SI, saved_flags    ; Use saved flags

    ; Carry Flag (CF)
    TEST SI, 0001h
    LEA DX, clearFlag
    JZ cf_clear
    LEA DX, setFlag
cf_clear:
    MOV AH, 09h
    INT 21h
    LEA DX, flagSpace
    INT 21h

    ; Zero Flag (ZF)
    TEST SI, 0040h
    LEA DX, clearFlag
    JZ zf_clear
    LEA DX, setFlag
zf_clear:
    MOV AH, 09h
    INT 21h
    LEA DX, flagSpace
    INT 21h

    ; Sign Flag (SF)
    TEST SI, 0080h
    LEA DX, clearFlag
    JZ sf_clear
    LEA DX, setFlag
sf_clear:
    MOV AH, 09h
    INT 21h
    LEA DX, flagSpace
    INT 21h

    ; Overflow Flag (OF)
    TEST SI, 0800h
    LEA DX, clearFlag
    JZ of_clear
    LEA DX, setFlag
of_clear:
    MOV AH, 09h
    INT 21h
    LEA DX, flagSpace
    INT 21h

    ; Auxiliary Flag (AF)
    TEST SI, 0010h
    LEA DX, clearFlag
    JZ af_clear
    LEA DX, setFlag
af_clear:
    MOV AH, 09h
    INT 21h
    LEA DX, flagSpace
    INT 21h

    ; Parity Flag (PF)
    TEST SI, 0004h
    LEA DX, clearFlag
    JZ pf_clear
    LEA DX, setFlag
pf_clear:
    MOV AH, 09h
    INT 21h
    LEA DX, newline
    INT 21h

    POP SI
    POP DX
    POP AX
    RET
print_flags ENDP

do_operation PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, num1
    MOV BX, num2
    MOV CL, op_choice

    CMP CL, 1
    JE do_and
    CMP CL, 2
    JE do_or
    CMP CL, 3
    JE do_xor
    CMP CL, 4
    JE do_add
    CMP CL, 5
    JE do_sub
    CMP CL, 6
    JE do_mul
    CMP CL, 7
    JE do_div

    LEA DX, invalidOp
    MOV AH, 09h
    INT 21h
    CALL wait_for_key
    MOV AH, 4Ch
    MOV AL, 01h    ; Fixed exit code
    INT 21h

do_and:
    AND AX, BX
    JMP save_result
do_or:
    OR AX, BX
    JMP save_result
do_xor:
    XOR AX, BX
    JMP save_result
do_add:
    ADD AX, BX
    JMP save_result
do_sub:
    SUB AX, BX
    JMP save_result
do_mul:
    MUL BX
    JMP save_result
do_div:
    CMP BX, 0
    JE div_error
    XOR DX, DX
    DIV BX
    ; Check for overflow (quotient > 65535)
    CMP DX, 0
    JNE div_overflow
    JMP save_result

div_error:
    LEA DX, divByZero
    MOV AH, 09h
    INT 21h
    CALL wait_for_key
    MOV AH, 4Ch
    MOV AL, 01h
    INT 21h

div_overflow:
    LEA DX, divOverflow
    MOV AH, 09h
    INT 21h
    CALL wait_for_key
    MOV AH, 4Ch
    MOV AL, 01h
    INT 21h

save_result:
    MOV result, AX
    PUSHF
    POP saved_flags    ; Save flags after operation
    CALL print_flags

    POP DX
    POP CX
    POP BX
    RET
do_operation ENDP

END MAIN
