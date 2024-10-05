.model small
.stack 100h
.data
    msg db 1           ; 初始值为 1
    sum dw 0           ; 存储最终累加结果
    buffer db 6 dup(0) ; 用于存储转换后的十进制字符串，最大支持 65535 的 5 位数字加上一个结束符

.code
main proc
    mov ax, @data      ; 初始化数据段
    mov ds, ax

    mov cx, 100        ; 设置循环计数器，循环 100 次
    mov bx, 0          ; BX 寄存器作为累加器，初始值为 0

start_loop:
    mov al, msg        ; 将 msg 的值加载到 AL 中
    mov ah, 0          ; 将 AH 置为 0，确保 AX 中是正确的 16 位数
    add bx, ax         ; 将 AX 的值加到 BX 中
    push bx            ; 把 BX 的值压到栈中
    inc msg            ; msg 递增 1
    loop start_loop    ; 循环，直到 CX 减到 0

    ; 保存结果
    mov sum, bx        ; 将结果存入 sum

    ; 将结果转换为十进制字符串并打印（直接用寄存器里的值）
    lea si, buffer     ; SI 指向 buffer
    mov ax, bx        ; AX 中存储着累加的结果
    call convert_to_string

    ; 打印字符串
    lea dx, buffer     ; DX 指向转换后的字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h    

    ; 将结果转换为十进制字符串并打印（把结果存到dataseg里面）
    lea si, buffer     ; SI 指向 buffer
    mov ax, sum        ; AX 中存储着累加的结果
    call convert_to_string

    ; 打印字符串
    lea dx, buffer     ; DX 指向转换后的字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

    ; 将结果转换为十进制字符串并打印（用栈保存的结果）
    lea si, buffer     ; SI 指向 buffer
    pop ax             ; 把栈中的结果给 AX 
    call convert_to_string

    ; 打印字符串
    lea dx, buffer     ; DX 指向转换后的字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

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