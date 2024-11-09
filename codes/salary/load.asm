.MODEL small

PUBLIC load_avg, load_dnum, load_num, load_year

DATA_SEGMENT segment PUBLIC
    ;以下是表示 21 年的 21 个字符串
    EXTRN year:BYTE
    ;以下是表示 21 年公司总收的 21 个 dword 型数据
    EXTRN total:dword
    ;以下是表示 21 年公司雇员人数的 21 个 word 型数据
    EXTRN em:word
    EXTRN color:BYTE
    EXTRN output_buffer:BYTE
DATA_SEGMENT ends

TABLE_SEGMENT segment PUBLIC
    EXTRN table:BYTE
TABLE_SEGMENT ends

CODE SEGMENT
ASSUME CS:CODE, DS:DATA_SEGMENT, ES:TABLE_SEGMENT

load_year PROC
; 把SI开始的4位的年份读取到output_buffer
    PUSH AX
    PUSH DI
    PUSH SI

    MOV AX, TABLE_SEGMENT
    MOV ES,AX

    MOV AX, DATA_SEGMENT
    MOV DS, AX

    MOV DI, OFFSET output_buffer  ; DI 指向输出缓冲区
    MOV AX, ES:[SI]              ; 读取 ES:[SI] 的前 2 个字节到 AX
    MOV DS:[DI], AX              ; 写入 AX 到 DS:[DI]

    MOV AX, ES:[SI+2]            ; 读取 ES:[SI+2] 的接下来的 2 个字节到 AX
    MOV DS:[DI+2], AX            ; 写入 AX 到 DS:[DI+2]

    MOV AL, '$'                  ; 将结束符 '$' 放入 AL
    MOV DS:[DI+4], AL            ; 写入结束符到 DS:[DI+4]

    POP SI
    POP DI
    POP AX

load_year ENDP

load_dnum PROC NEAR
    PUSH AX            ; 保存寄存器
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV AX, TABLE_SEGMENT
    MOV ES,AX

ReadLowWord:
    MOV AX, ES:[SI + 5]    ; 从 ES:[SI+5] 读取低 16 位
    XOR DX, DX             ; 清空 DX（高位）
    PUSH SI

    ; 初始化
    MOV BX, 10         ; 除数为 10
    LEA SI, output_buffer + 49 ; SI 指向缓冲区末尾
    MOV BYTE PTR [SI], '$' ; 在缓冲区末尾存入结束符 '$'
    DEC SI             ; SI 指向有效数字存储位置

ConvertLowWord:
    DIV BX             ; AX = DX:AX / 10, DX = 余数
    ADD DL, '0'        ; 将余数转换为 ASCII 字符
    MOV [SI], DL       ; 存入缓冲区
    DEC SI             ; 缓冲区指针前移
    CMP AX, 0          ; 检查 AX 是否为 0
    JNE ConvertLowWord ; 如果 AX 不为 0，继续循环
    MOV DI, SI

ReadHighWord:
    POP SI
    MOV AX, ES:[SI + 7]    ; 从 ES:[SI+7] 读取高 16 位
    CMP AX, 0              ; 检查高位是否为 0
    JE EndConversion       ; 如果高位为 0，跳转到结束

ConvertHighWord:
    MOV SI, DI
    DIV BX             ; AX = DX:AX / 10, DX = 余数
    ADD DL, '0'        ; 将余数转换为 ASCII 字符
    MOV [SI], DL       ; 存入缓冲区
    DEC SI             ; 缓冲区指针前移
    CMP AX, 0          ; 检查 AX 是否为 0
    JNE ConvertHighWord ; 如果 AX 不为 0，继续处理

EndConversion:
    INC SI             ; SI 指向第一个有效数字

MoveConvertedString:
    LEA DI, output_buffer ; DI 指向缓冲区起始位置
MoveLoop:
    MOV AL, [SI]       ; 从缓冲区读取字符
    MOV [DI], AL       ; 写入到 output_buf
    INC SI             ; 读取下一个字符
    INC DI             ; 写入下一个位置
    CMP AL, '$'        ; 检查结束符
    JNE MoveLoop       ; 如果未到结束符，继续复制

    ; 恢复寄存器
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
load_dnum ENDP


load_num PROC
    PUSH AX
    MOV AX, TABLE_SEGMENT
    MOV ES,AX

    MOV AX, ES:[SI+10]
    CALL NumberToString
    POP AX

load_num ENDP

load_avg PROC
    PUSH AX
    MOV AX, TABLE_SEGMENT
    MOV ES,AX

    MOV AX, ES:[SI + 13]
    CALL NumberToString
    POP AX
load_avg ENDP

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

CODE ENDS
END