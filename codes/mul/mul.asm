DATA_SEG SEGMENT
    output_buffer DB 50 DUP(0)
    newline     DB 0Dh, 0Ah, '$'  ; 换行符，用于输出换行
    mul_table_buffer DB 200 DUP(0) ; 用于存储99乘法表
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

    ; 调用 PrintMultiplicationTable 打印 99 乘法表
    CALL PrintMultiplicationTable

End_Program:
    ; 结束程序
    MOV AH, 4Ch                ; 功能号4Ch - 退出程序
    INT 21h                    ; 调用DOS中断

; 打印99乘法表
PrintMultiplicationTable PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV CX, 9          ; 外循环次数 (1 到 9)
OuterLoop:
    MOV BX, 1          ; 内循环初始化 (1 到 CX)
InnerLoop:
    MOV AX, CX         ; AX = 当前外循环数值
    MUL BX             ; AX = CX * BX
    CALL NumberToString ; 将乘积转换为字符串，结果在 output_buffer 中

    ; 准备输出 "BX * CX = 结果"
    MOV DL, '0'
    ADD DL, BL        ; 将 BX 转换为字符
    MOV mul_table_buffer, DL

    MOV DL, 'x'
    MOV mul_table_buffer + 1, DL

    MOV DL, '0'
    ADD DL, CL       ; 将 CX 转换为字符
    MOV mul_table_buffer + 2, DL

    MOV DL, '='
    MOV mul_table_buffer + 3, DL

    ; 将转换后的乘积复制到 mul_table_buffer 中
    LEA SI, output_buffer
    LEA DI, mul_table_buffer + 4
CopyResult:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    CMP AL, '$'
    JNE CopyResult

    DEC DI
    MOV DL, 32
    MOV [DI], DL

    INC DI
    MOV DL, '$'
    MOV [DI], DL

    ; 输出当前的结果行
    LEA DX, mul_table_buffer
    MOV AH, 09h
    INT 21h

    INC BX             ; 内循环递增
    CMP BX, CX
    JLE InnerLoop      ; 如果 BX <= CX，继续内循环

    ; 添加换行符
    LEA DX, newline
    MOV AH, 09h
    INT 21h

    LOOP OuterLoop     ; 外循环递减，继续下一个外循环

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PrintMultiplicationTable ENDP

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
