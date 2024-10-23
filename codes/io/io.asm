DATA_SEG SEGMENT
    buffer DB 50, ?, 50 DUP('$')
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

    ; 从键盘读取输入
    LEA DX, buffer             ; DX指向输入缓冲区
    MOV AH, 0Ah                ; 功能号0Ah - 缓冲区输入
    INT 21h                    ; 调用DOS中断s

    ; 输出换行符
    LEA DX, newline
    MOV AH, 09h                ; 功能号09h - 输出字符串
    INT 21h                    ; 调用DOS中断

    ; 输出用户输入的字符串
    LEA DX, buffer+2         ; DX指向input_data
    MOV AH, 09h                ; 功能号09h - 输出字符串
    INT 21h                    ; 调用DOS中断

    ; 结束程序
    MOV AH, 4Ch                ; 功能号4Ch - 退出程序
    INT 21h                    ; 调用DOS中断

CODE_SEG ENDS
END START
