.MODEL SMALL                 ; 定义内存模型
.STACK 100H                  ; 定义堆栈段大小

.DATA
    buffer DB 256 DUP(0)     ; 定义一个长度为 256 字节的缓冲区

.CODE
START:
    MOV AX, @DATA            ; 初始化数据段寄存器
    MOV DS, AX
    MOV ES, AX

    MOV CX, 5                ; 初始化循环计数器为 5

    ; 跳转到较远的地址
    JMP FAR_LABEL

NEAR_LABEL:
    ; 距离 FAR_LABEL 超过 128 字节
    ; 一些无意义的占位符操作，用于确保代码超出 128 字节

    MOV CX, 130
    NOP
    LOOP NEAR_LABEL;            ; 插入 129 条 NOP 指令，确保跳转距离超过 128 字节

FAR_LABEL:
    LOOP NEAR_LABEL          ; LOOP 指令尝试跳回到 NEAR_LABEL，但由于超出跳转范围会产生错误

EXIT_PROGRAM:
    MOV AX, 4C00H            ; DOS 中断用于退出程序
    INT 21H

END START
