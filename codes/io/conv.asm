DATA_SEG SEGMENT
    buffer DB 50, ?, 50 DUP('$')
    output_buffer DB 50 DUP(0)
    newline     DB 0Dh, 0Ah, '$'  ; 换行符，用于输出换行
DATA_SEG ENDS

STACK_SEG SEGMENT STACK
    DW 100h DUP(?)            ; 堆栈段，大小为 256 字节
STACK_SEG ENDS

CODE_SEG SEGMENT
ASSUME CS:CODE_SEG, DS:DATA_SEG, SS:STACK_SEG

START:
    ; 初始化数据段
    MOV AX, DATA_SEG
    MOV DS, AX

    ; 初始化堆栈段
    MOV AX, STACK_SEG
    MOV SS, AX
    MOV SP, 100h               ; 堆栈指针初始化为段顶部

INPUT:
    ; 从键盘读取输入
    LEA DX, buffer             ; DX指向输入缓冲区
    MOV AH, 0Ah                ; 功能号0Ah - 缓冲区输入
    INT 21h                    ; 调用DOS中断s

    CALL CONVERT_INPUT
    CALL NumberToString        ; 调用 NumberToString 将 AX 中的值转换为字符串并存储到 output_buffer

OUTPUT:
    ; 输出换行符
    LEA DX, newline
    MOV AH, 09h                ; 功能号09h - 输出字符串
    INT 21h                    ; 调用DOS中断

    ; 输出转换后的字符串
    LEA DX, output_buffer      ; DX指向 output_buffer
    MOV AH, 09h                ; 功能号09h - 输出字符串
    INT 21h                    ; 调用DOS中断

End_Program:
    ; 结束程序
    MOV AH, 4Ch                ; 功能号4Ch - 退出程序
    INT 21h                    ; 调用DOS中断

;把buffer里的数字转换并放入ax
CONVERT_INPUT PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV AX, 0          ; 清空 AX，存储结果
    LEA SI, buffer+2   ; SI 指向 buffer+2，即输入字符串的第一个字符

ConvertLoop:
    MOV BL, [SI]       ; 将当前字符读取到 BL
    CMP BL, 0Dh        ; 检查是否遇到回车符 (0Dh)
    JE DoneConvert     ; 如果遇到回车，结束转换

    SUB BL, '0'        ; 将 ASCII 数字字符转换为数值 ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    MOV BH, 0          ; 清空高字节
    MOV CX, 10         ; 准备乘以 10
    MUL CX             ; AX = AX * 10 (为新的数字腾出位置)
    ADD AX, BX         ; 将转换的数值加到 AX 中

    INC SI             ; 指向下一个字符
    JMP ConvertLoop    ; 继续转换下一个字符

DoneConvert:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    RET                ; 返回主程序

CONVERT_INPUT ENDP

; 将 AX 中的数值转换为字符串并存储在 output_buffer 中
NumberToString PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV CX, 0         ; 初始化位数计数器
    MOV BX, 0Ah
    LEA SI, output_buffer + 49  ; SI 指向 output_buffer 的末尾
    MOV BYTE PTR [SI], '$'      ; 在缓冲区末尾存入结束符 '$'
    DEC SI                      ; 移到存储数字字符的位置

ConvertToStringLoop:
    XOR DX, DX        ; 清除 DX，用于除法操作
    DIV BX            ; AX = AX / 10, DX = AX % 10 (余数放在 DX 中)
    ADD DL, '0'       ; 将数字转换为字符（0-9）
    MOV [SI], DL      ; 将字符存入缓冲区
    DEC SI            ; 移动到下一个存储位置
    INC CX            ; 计数

    CMP AX, 0         ; 如果 AX 不为 0，继续转换
    JNE ConvertToStringLoop

    INC SI            ; SI 现在指向第一个有效数字的位置

    ; 移动有效字符串部分到缓冲区的起始位置
    LEA DI, output_buffer      ; DI 指向 output_buffer 的起始位置
MoveString:
    MOV AL, [SI]              ; 将有效字符读取到 AL
    MOV [DI], AL              ; 将字符写入缓冲区起始位置
    INC SI                    ; 移动到下一个字符
    INC DI                    ; 移动到下一个写入位置
    CMP AL, '$'               ; 检查是否到达结束符
    JNE MoveString            ; 如果不是结束符，继续移动

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET               ; 返回主程序
NumberToString ENDP

CODE_SEG ENDS
END START
