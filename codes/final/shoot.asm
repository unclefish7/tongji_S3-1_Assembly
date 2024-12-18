.MODEL small
.STACK 100h

PUBLIC clear_screen, print_string
PUBLIC color, output_buffer         ; 现在我们自己定义这些变量

DATA SEGMENT
    color DB 0Fh                    ; 白色前景色，黑色背景
    output_buffer DB 'Hello, World!$'   ; 输出缓冲区
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

; 清屏过程
clear_screen PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h                   ; 显存段地址
    MOV ES, AX

    MOV DI, 0                        ; 起始偏移地址
    MOV CX, 2000                     ; 25行 * 80列 = 2000个字符位置
clear_loop:
    MOV AL, ' '                      ; 空格字符
    MOV ES:[DI], AL                  ; 写入字符
    MOV AL, color                    ; 颜色属性
    MOV ES:[DI+1], AL               ; 写入颜色
    ADD DI, 2                        ; 下一个字符位置
    LOOP clear_loop

    POP ES
    POP DI
    POP CX
    POP BX
    POP AX
    RET
clear_screen ENDP

; 打印字符串过程
print_string PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    CLD                             ; 设置正向字符串操作
    MOV SI, OFFSET output_buffer    ; 源字符串地址

print_loop:
    LODSB                           ; 加载字符到AL
    CMP AL, '$'                     ; 检查是否到字符串结尾
    JE print_done

    MOV ES:[DI], AL                 ; 写入字符
    MOV AL, color                   ; 颜色属性
    MOV ES:[DI+1], AL              ; 写入颜色
    ADD DI, 2                       ; 下一个显示位置
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

; 主程序
START:
    MOV AX, DATA
    MOV DS, AX

    ; 清屏
    CALL clear_screen

    ; 设置显示位置并打印
    MOV DI, 350                   ; 第二行开始位置
    CALL print_string

    ; 等待按键
    MOV AH, 1
    INT 21h

    ; 退出程序
    MOV AX, 4C00h
    INT 21h

CODE ENDS
END START
