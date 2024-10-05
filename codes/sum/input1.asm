.model small
.stack 100h
.data
    buffer db 6 dup(0) ; 用于存储转换后的十进制字符串，最大支持 65535 的 5 位数字加上一个结束符
    input_prompt db 'Enter a number between 1 and 100: $'
    invalid_input db 'Invalid input! Please enter a number between 1 and 100.$'
    newline db 0Dh, 0Ah, '$'

.code
main proc
    mov ax, @data      ; 初始化数据段
    mov ds, ax

input_loop:
    ; 打印输入提示
    lea dx, input_prompt ; DX 指向输入提示字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

    ; 读取用户输入
    mov ah, 01h        ; DOS 中断功能：读取键盘输入
    int 21h
    sub al, '0'        ; 将 ASCII 转换为数字
    mov bl, al         ; 保存用户输入的数字

validate_input:
    ; 验证输入是否在 1-100 范围内
    cmp bl, 1          ; 输入是否小于 1
    jb invalid         ; 如果小于 1，跳转到无效输入处理
    cmp bl, 100        ; 输入是否大于 100
    ja invalid         ; 如果大于 100，跳转到无效输入处理

    ; 将输入的数字转换为十进制字符串
    mov ax, 0          ; 将 AX 清零
    mov al, bl         ; 将用户输入的数值复制到 AX 中
    lea si, buffer     ; SI 指向 buffer
    call convert_to_string

    ; 打印转换后的字符串
    lea dx, buffer     ; DX 指向转换后的字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

    ; 打印换行
    lea dx, newline    ; DX 指向换行符字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

    jmp exit_program

invalid:
    ; 打印无效输入提示
    lea dx, invalid_input ; DX 指向无效输入提示字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

    ; 打印换行
    lea dx, newline    ; DX 指向换行符字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

exit_program:
    ; 退出程序
    mov ax, 4C00h
    int 21h
main endp

; 子程序：将 AX 中的数字转换为十进制字符串
convert_to_string proc
    lea si, buffer + 5  ; SI 指向 buffer 的最后一位
    mov byte ptr [si], '$' ; 在最后一位为字符串添加结束符
    dec si              ; SI 前移，准备存放每个转换的字符

convert_loop:
    mov dx, 0           ; 扩展为 32 位除法
    mov bx, 10          ; 除数为 10
    div bx              ; AX 除以 10，商在 AX，余数在 DX
    add dl, '0'         ; 将余数转换为 ASCII
    mov [si], dl        ; 将转换后的字符存入 buffer
    dec si              ; SI 前移一位
    cmp ax, 0           ; 检查商是否为 0
    jne convert_loop    ; 如果商不为 0，则继续循环

    ret
convert_to_string endp

end main
