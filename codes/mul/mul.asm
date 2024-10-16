.MODEL SMALL
.STACK 100H
.DATASEG
    msg DB ' ', '$'                    ; 空格用于格式化输出
    newline DB 0DH, 0AH, '$'          ; 换行符
    result DB 4 DUP(?)                ; 用于存储计算结果，最多两位数和空格

.CODESEG
    ASSUME CS:CODESEG, DS:DATASEG
START:
    MOV AX, DATASEG                    ; 初始化数据段寄存器
    MOV DS, AX                       ; 加载数据段地址到 DS

    MOV CX, 9                        ; 外循环计数器：从 9 开始到 1
OUTER_LOOP:
    MOV BX, 1                        ; 内循环计数器：从 1 到 CX

INNER_LOOP:
    ; 计算 BX * CX，结果放入 AX
    MOV AL, BL                       ; AL = BX
    MUL AL, CL                           ; AX = BX * CX

    ; 将结果转换为 ASCII 并存储到 result 中
    MOV DI, OFFSET result
    CALL NUMBER_TO_STRING            ; 调用子程序将数字转换为字符串

    ; 显示结果
    MOV DX, OFFSET result
    MOV AH, 09H                      ; DOS 功能号：显示字符串
    INT 21H

    ; 显示空格
    MOV DX, OFFSET msg
    MOV AH, 09H
    INT 21H

    INC BX                           ; BX = BX + 1
    CMP BX, CX
    JLE INNER_LOOP                   ; 如果 BX <= CX，继续内循环

    ; 换行
    MOV DX, OFFSET newline
    MOV AH, 09H
    INT 21H

    DEC CX                           ; CX = CX - 1
    JNZ OUTER_LOOP                   ; 如果 CX 不为 0，继续外循环

    ; 程序结束
    MOV AX, 4C00H                    ; DOS 中断：退出程序
    INT 21H

; 子程序：将数字转换为字符串
NUMBER_TO_STRING PROC
    ; 输入：AX = 数字 (0-81)
    ; 输出：结果保存在 DI 指向的内存位置，以 '$' 结尾
    MOV BX, 10
    XOR DX, DX                       ; 清除 DX
    DIV BL                           ; AX / 10，商在 AL，余数在 AH
    ADD AH, '0'                      ; 余数转换为字符
    MOV [DI], AH                     ; 存储个位数字符
    INC DI
    CMP AL, 0
    JE ONE_DIGIT
    ADD AL, '0'                      ; 商转换为字符（十位数）
    MOV [DI], AL                     ; 存储十位数字符
    INC DI
ONE_DIGIT:
    MOV [DI], ' '                    ; 添加空格用于格式化
    INC DI
    MOV [DI], '$'                    ; 添加字符串结束符
    RET
NUMBER_TO_STRING ENDP

CODESEG ENDS
END START