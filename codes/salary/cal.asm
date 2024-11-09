.MODEL small
.STACK 100h

PUBLIC calculate_average                         ; 公开计算子过程

DATA_SEGMENT segment PUBLIC
    ;以下是表示 21 年的 21 个字符串
    EXTRN year:BYTE
    ;以下是表示 21 年公司总收的 21 个 dword 型数据
    EXTRN total:dword
    ;以下是表示 21 年公司雇员人数的 21 个 word 型数据
    EXTRN em:word
DATA_SEGMENT ends

TABLE_SEGMENT segment PUBLIC
    EXTRN table:BYTE
TABLE_SEGMENT ends

CODE SEGMENT
ASSUME CS:CODE, DS:DATA_SEGMENT, ES:TABLE_SEGMENT

; 子过程：计算每年人均收入并写入表段
calculate_average PROC
    ; 保存寄存器
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    PUSH DI

    ; 设置 DS 和 ES
    MOV AX, DATA_SEGMENT   ; 加载 DATA 段地址
    MOV DS, AX             ; 设置 DS 寄存器
    MOV AX, TABLE_SEGMENT  ; 加载 TABLE 段地址
    MOV ES, AX             ; 设置 ES 寄存器

    ; 初始化循环
    XOR BX, BX             ; BX = 0，用作年份索引
    MOV DI, 0              ; DI 指向 TABLE 段的写入起始位置

process_year:

    ; 1. 写入年份（4 字节）
    MOV AX, BX             ; BX = 当前年份索引
    SHL AX, 1              ; AX = BX * 4，计算偏移量
    SHL AX, 1
    MOV SI, OFFSET year    ; SI 指向年份数据的起始地址
    ADD SI, AX             ; SI = year + BX * 4
    MOV AL, DS:[SI]           ; 获取当前年份的第一个字节
    MOV ES:[DI], AL        ; 写入到 TABLE 段
    INC DI                 ; 移动指针
    MOV AL, DS:[SI + 1]       ; 获取年份的第二个字节
    MOV ES:[DI], AL
    INC DI
    MOV AL, DS:[SI + 2]       ; 获取年份的第三个字节
    MOV ES:[DI], AL
    INC DI
    MOV AL, DS:[SI + 3]       ; 获取年份的第四个字节
    MOV ES:[DI], AL
    INC DI

    ; 写入空格
    MOV BYTE PTR ES:[DI], ' '
    INC DI

    ; 读取总收入（DWORD，4 字节）
    MOV AX, BX              ; BX = 当前年份索引
    SHL AX, 1               ; AX = BX * 4，计算偏移量
    SHL AX, 1
    MOV SI, OFFSET total     ; SI 指向总收入数据的起始地址
    ADD SI, AX              ; SI = total + BX * 4
    MOV AX, DS:[SI]         ; 读取总收入的低 16 位
    MOV ES:[DI], AX         ; 写入到 TABLE 段
    ADD SI, 2               ; 移动到高 16 位地址
    ADD DI, 2               ; 移动指针到下一个位置
    MOV AX, DS:[SI]         ; 读取总收入的高 16 位
    MOV ES:[DI], AX         ; 写入到 TABLE 段
    ADD DI, 2               ; 移动指针


    ; 写入空格
    MOV BYTE PTR ES:[DI], ' '
    INC DI

    ; 3. 写入雇员人数（WORD，2 字节）
    MOV AX, BX             ; BX = 当前年份索引
    SHL AX, 1              ; AX = BX * 2，计算雇员人数偏移量
    MOV SI, OFFSET em      ; SI 指向雇员人数数据的起始地址
    ADD SI, AX             ; SI = em + BX * 2
    MOV AX, DS:[SI]           ; 读取雇员人数
    MOV ES:[DI], AX        ; 写入到 TABLE 段
    ADD DI, 2              ; 移动指针

    ; 写入空格
    MOV BYTE PTR ES:[DI], ' '
    INC DI

    ; 4. 计算人均收入（WORD，2 字节）
    XOR DX, DX             ; 清除 DX 高位
    MOV CX, AX             ; CX = 雇员人数（保存在 CX 中）

    ; 计算总收入的偏移量
    MOV AX, BX             ; BX = 年份索引
    SHL AX, 1              ; AX = 年份索引 * 4（DWORD 偏移量）
    SHL AX, 1
    MOV SI, OFFSET total   ; SI 指向 total 起始地址
    ADD SI, AX             ; SI = total + (年份索引 * 4)

    ; 读取总收入
    MOV AX, DS:[SI]        ; AX = 总收入低 16 位
    ADD SI, 2              ; 移动到高 16 位
    MOV DX, DS:[SI]        ; DX = 总收入高 16 位（如果总收入是 DWORD）

    ; 计算人均收入
    DIV CX                 ; EAX = DX:AX / CX，结果保存在 AX

    ; 写入人均收入到 TABLE 段
    MOV ES:[DI], AX        ; 将人均收入写入 TABLE 段
    ADD DI, 2              ; 移动指针


    ; 写入空格
    MOV BYTE PTR ES:[DI], ' '
    INC DI

    ; 增加索引，处理下一年
    INC BX                  ; BX 索引加 1
    CMP BX, 21
    JE finish        ; 跳转到下一年的处理
    JMP process_year

finish:
    ; 恢复寄存器
    POP DI
    POP SI
    POP DX
    POP BX
    POP AX
    RET
calculate_average ENDP

CODE ENDS
END
