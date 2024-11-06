.MODEL small
.STACK 100h

DATA SEGMENT
    message db 'Hello, world!$'       ; 要显示的字符串
    color db 0Fh                        ; 设置颜色属性（0Fh 表示白色字符，黑色背景）
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

START:
    ; 设置数据段寄存器
    MOV AX, DATA
    MOV DS, AX

    ; 设置显存段寄存器
    MOV AX, 0B800h
    MOV ES, AX

    ; 清屏操作
    MOV DI, 0                           ; 从显存起始位置开始
    MOV CX, 2000                        ; 80列 x 25行 = 2000字符
clear_screen:
    MOV AL, ' '                         ; 空格字符
    MOV ES:[DI], AL                     ; 写入空格字符
    MOV AL, color                       ; 使用白色字符、黑色背景的颜色属性
    MOV ES:[DI+1], AL                   ; 写入颜色
    ADD DI, 2                           ; 移动到下一个字符位置
    LOOP clear_screen                   ; 循环，直到填满整个屏幕

    ; 开始输出字符串
    MOV SI, OFFSET message
    CLD
    MOV DI, 1986                           ; 重置到屏幕左上角位置
print_string:
    LODSB                               ; 加载 message 中的下一个字符
    CMP AL, '$'                          ; 检查是否是字符串结束符
    JZ done                             ; 如果是 0（结束符），跳转到 done

    MOV ES:[DI], AL                     ; 将字符写入显存
    MOV AL, color                       ; 使用白色字符、黑色背景的颜色属性
    MOV ES:[DI+1], AL                   ; 将颜色写入显存
    ADD DI, 2                           ; 移动到下一个字符位置
    JMP print_string                    ; 循环继续处理下一个字符

done:
    ; 程序结束
    MOV AX, 4C00h
    INT 21h                             ; 返回 DOS

CODE ENDS
END START
