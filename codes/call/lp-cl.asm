STKSEG SEGMENT STACK
    DW 32 DUP(0)        ; 定义栈段，分配 32 个字（64 字节）的空间
STKSEG ENDS

DATASEG SEGMENT
    MSG DB "a"          ; 定义字符 MSG，初始值为 'a'
    NEWLINE DB 13, 10, '$' ; 定义换行符（CR 和 LF），用于输出换行
DATASEG ENDS

CODESEG SEGMENT
    ASSUME CS:CODESEG, DS:DATASEG, SS:STKSEG ; 设置段寄存器的假定

MAIN PROC FAR
    ; 将数据段的地址放入 DS 寄存器
    MOV AX, DATASEG
    MOV DS, AX

    MOV CX, 2
O_L:
    CALL L             ; 调用子进程

    ; 输出换行
    MOV DX, OFFSET NEWLINE ; 设置换行字符串的地址到 DX
    MOV AH, 09h          ; 设置功能号为 09，用于输出字符串
    INT 21h              ; 调用 DOS 中断 21h，输出换行
    
    LOOP O_L            ; 外循环计数，CX 自动减 1，若不为 0 则跳回外循环

    ; 退出程序
    MOV AX, 4C00H      ; 设置退出程序的功能号
    INT 21H            ; 调用 DOS 中断 21h，退出程序

    ret
MAIN ENDP

L PROC
    PUSH CX
    MOV CX, 13          ; 设置内循环次数为 13，表示每行输出 13 个字母
    
    ; 调用 2 号功能
    MOV AH, 2           ; 设置功能号为 2，用于输出字符
I_L: ; 内循环标签
    MOV DL, [MSG]       ; 将当前字符（MSG）加载到 DL 中
    INT 21H             ; 调用 DOS 中断 21h，输出字符
    INC [MSG]           ; 将 MSG 中的字符增加 1
    LOOP I_L            ; 循环内计数，CX 自动减 1，若不为 0 则跳回内循环

    POP CX

    RET

L ENDP


CODESEG ENDS
END MAIN
