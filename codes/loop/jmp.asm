STKSEG SEGMENT STACK
    DW 32 DUP(0)
STKSEG ENDS

DATASEG SEGMENT
    MSG DB 'A'         ; 初始化为 'A'
    NEWLINE DB 13, 10, '$' ; 换行符（CR, LF）
DATASEG ENDS

CODESEG SEGMENT
    ASSUME CS:CODESEG, DS:DATASEG, SS:STKSEG
MAIN PROC FAR
    ; 把数据段的地址放到 DS 寄存器
    MOV AX, DATASEG
    MOV DS, AX

    ; 外循环：2 行
    MOV CX, 2          ; 行数
OUTER_LOOP:
    MOV BX, 0          ; 行内字符计数器，初始化为 0

INNER_LOOP:
    MOV DL, [MSG]      ; 将当前字符加载到 DL
    MOV AH, 02h        ; 设置功能号：输出字符
    INT 21H            ; 调用中断输出字符
    INC [MSG]          ; 增加 MSG 中的字符
    INC BX             ; 增加行内计数器

    CMP BX, 13         ; 检查是否到达每行的字符数量
    JAE PRINT_NEWLINE   ; 如果到达 13 个字符，跳转到打印换行

    JMP INNER_LOOP     ; 否则继续内循环

PRINT_NEWLINE:
    ; 输出换行
    MOV DX, OFFSET NEWLINE ; 设置换行字符串的地址
    MOV AH, 09h          ; 功能号：输出字符串
    INT 21h              ; 调用中断

    DEC CX               ; 减少外循环计数器
    JNZ OUTER_LOOP       ; 如果还没有输出 2 行，继续外循环

    MOV AX, 4C00h       ; 退出程序
    INT 21h
MAIN ENDP
CODESEG ENDS
END MAIN
