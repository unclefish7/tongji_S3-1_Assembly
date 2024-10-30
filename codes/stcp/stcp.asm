DATA_SEG SEGMENT 
    STRBUF DB 'ASASAASASSASSAASASAS' ; 待扫描的字符串
    COUNT EQU $ - STRBUF             ; 计算字符串长度
    STRING DW 'AS'                   ; 查找的子串，直接存入一个字（'AS'）
    MESSG  DB "The Number of 'AS' is: $"
    newline DB 0Dh, 0Ah, '$'
    output_buffer DB 50 DUP(0)
DATA_SEG ENDS

STACK_SEG SEGMENT STACK
    DW 100h DUP(?)            ; 堆栈段，大小为 256 字节
STACK_SEG ENDS

CODESEG SEGMENT
    ASSUME CS:CODESEG, DS:DATA_SEG, SS:STACK_SEG

START:
    ; 初始化数据段
    MOV AX, DATA_SEG
    MOV DS, AX

    ; 初始化堆栈段
    MOV AX, STACK_SEG
    MOV SS, AX
    MOV SP, 100h

    ; 初始化查找过程
    MOV SI, OFFSET STRBUF      ; SI 指向 STRBUF 的起始地址
    MOV CX, COUNT              ; CX 设为 STRBUF 的长度，控制查找范围
    MOV DX, 0                  ; DX 用来存储子串出现次数的计数
    CLD                        ; 清除方向标志，确保指针递增

SEARCH_LOOP:
    ; 首先查找字符 'A'
    MOV AL, 'A'                ; 将字符 'A' 加载到 AL
    REPNE SCASB                ; 按字节扫描 STRBUF，直到找到 'A' 或 CX = 0
    JNE SEARCH_DONE            ; 如果 CX = 0 且未找到 'A'，跳出循环

    ; 如果找到 'A'，检查下一个字符是否是 'S'
    MOV AL, 'S'                ; 将字符 'S' 加载到 AL
    SCASB                      ; 检查下一个字符是否是 'S'
    JNE SEARCH_LOOP            ; 如果不匹配，返回重新查找 'A'

    ; 子串匹配，增加计数
    INC DX                     ; 计数加 1

    JMP SEARCH_LOOP            ; 继续查找下一个匹配

SEARCH_DONE:
    ; 输出 DX 中的计数结果
    ; 此处可添加输出代码，显示 DX 中的计数结果


    MOV AX, DX
    CALL NumberToString

    MOV AH, 09h
    MOV DX, OFFSET MESSG
    INT 21h

    MOV DX, OFFSET output_buffer
    INT 21h

    MOV DX, OFFSET newline
    INT 21h

    MOV AX, 4c00h
    INT 21h

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

CODESEG ENDS
END START

