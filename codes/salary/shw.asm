.MODEL small

PUBLIC clear_screen, print_string    ; 公开子模块中的函数
EXTRN color:BYTE, output_buffer:BYTE                    ; 声明外部变量 color

CODE SEGMENT
ASSUME CS:CODE

; 清屏函数
clear_screen PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX

    MOV DI, 0
    MOV CX, 2000
clear_loop:
    MOV AL, ' '                      ; 空格字符
    MOV ES:[DI], AL
    MOV AL, color                    ; 使用 color 变量
    MOV ES:[DI+1], AL
    ADD DI, 2
    LOOP clear_loop

    POP ES
    POP DI
    POP CX
    POP BX
    POP AX
    RET
clear_screen ENDP

; 打印字符串函数
print_string PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    CLD
    MOV SI, OFFSET output_buffer
print_loop:
    LODSB
    CMP AL, '$'
    JZ print_done

    MOV ES:[DI], AL
    MOV AL, color                    ; 使用 color 变量
    MOV ES:[DI+1], AL
    ADD DI, 2
    JMP print_loop
print_done:
    POP ES
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
print_string ENDP

CODE ENDS
END
