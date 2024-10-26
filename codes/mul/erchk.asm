DATA_SEG SEGMENT
    table   db 7,2,3,4,5,6,7,8,9             ;9*9表数据
            db 2,4,7,8,10,12,14,16,18
            db 3,6,9,12,15,18,21,24,27
            db 4,8,12,16,7,24,28,32,36
            db 5,10,15,20,25,30,35,40,45
            db 6,12,18,24,30,7,42,48,54
            db 7,14,21,28,35,42,49,56,63
            db 8,16,24,32,40,48,56,7,72
            db 9,18,27,36,45,54,63,72,81
    output_buffer DB 50 DUP(0)
    x_y DB "x  y$"
    error DB "   error$"
    spacer DB "  $"
    end_p DB "accomplish!$"
    newline     DB 0Dh, 0Ah, '$'  ; 换行符，用于输出换行
    mul_table_buffer DB 200 DUP(0) ; 用于存储99乘法表
DATA_SEG ENDS

STACK_SEG SEGMENT STACK
    DW 1000h DUP(?)            ; 堆栈段，大小为 64kb
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
    MOV SP, 1000h                ; 堆栈指针初始化为段顶部

    LEA DX, x_y
    MOV AH, 09h
    INT 21h

    LEA DX, newline
    MOV AH, 09h
    INT 21h

    MOV BX, 1                   ; BX代表当前行数
OUTERLOOP:
    MOV CX, 1                   ; CX代表当前列数
INNERLOOP:
    MOV AX, 9

    PUSH BX                     ; (BX - 1) * 9 + CX - 1 = 当前指向table的指针
    DEC BX
    MUL BX
    POP BX

    ADD AX, CX
    DEC AX

    PUSH BX
    MOV BX, AX
    MOV AH, 0
    MOV AL, [table + BX]        ; AX 内变为当前table的值
    POP BX

    CALL CHK

    INC CX
    CMP CX, 9
    JLE INNERLOOP

    INC BX
    CMP BX, 9
    JLE OUTERLOOP

End_Program:
    LEA DX, end_p
    MOV AH, 09h
    INT 21h

    ; 结束程序
    MOV AH, 4Ch                ; 功能号4Ch - 退出程序
    INT 21h                    ; 调用DOS中断



;判断AX是否等于BX*CX，并打印所有错误结果
CHK PROC
    PUSH AX
    PUSH BX
    PUSH CX

    PUSH CX

    PUSH CX
    PUSH AX
    POP CX
    POP AX          ; AX, CX 互换，以便进行乘法操作

    MUL BX
    CMP AX, CX
    POP CX
    JE RIGHT

WRONG:
    MOV AX, BX
    CALL NumberToString

    ; 打印BX
    LEA DX, output_buffer      ; DX指向 output_buffer
    MOV AH, 09h                ; 功能号09h - 输出字符串
    INT 21h                    ; 调用DOS中断

    LEA DX, spacer             
    MOV AH, 09h                
    INT 21h    

    MOV AX, CX
    CALL NumberToString

    ; 打印CX
    LEA DX, output_buffer      ; DX指向 output_buffer
    MOV AH, 09h                ; 功能号09h - 输出字符串
    INT 21h                    ; 调用DOS中断

    LEA DX, error             
    MOV AH, 09h                
    INT 21h

    LEA DX, newline             
    MOV AH, 09h                
    INT 21h 

RIGHT:
    POP CX
    POP BX
    POP AX
    RET
CHK ENDP

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