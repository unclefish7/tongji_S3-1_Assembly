.model small
.stack 100h
.data
    buffer db 6 dup(0) ; 用于存储转换后的十进制字符串，最大支持 65535 的 5 位数字加上一个结束符
    input_prompt db 'Enter a number between 1 and 100: $'
    invalid_input db 'Invalid input! Please enter a number between 1 and 100.$'
    newline db 0Dh, 0Ah, '$'
    input_buffer db 4 dup(0) ; 用于存储用户输入的字符（最大3位数）

.code
main proc far
    mov ax, @data      ; 初始化数据段
    mov ds, ax

input_loop:
    ; 清空输入缓冲区
    lea di, input_buffer
    mov cx, 4
clear_buffer:
    mov byte ptr [di], 0
    inc di
    loop clear_buffer

    ; 打印输入提示
    lea dx, input_prompt ; DX 指向输入提示字符串
    mov ah, 09h        ; DOS 中断功能：打印字符串
    int 21h

    ; 读取用户输入
    lea di, input_buffer ; DI 指向输入缓冲区
    mov cx, 0           ; 初始化输入字符计数

read_input:
    mov ah, 01h        ; DOS 中断功能：读取键盘输入
    int 21h
    cmp al, 0Dh        ; 检查是否按下回车键
    je validate_input  ; 如果是回车，跳转到验证输入
    mov [di], al       ; 将输入的字符存入缓冲区
    inc di             ; DI 前移以存储下一个字符
    inc cx             ; 增加字符计数
    cmp cx, 3          ; 检查是否超出3位数字
    ja invalid         ; 如果超出，跳转到无效输入处理
    jmp read_input     ; 继续读取输入

validate_input:
    ; 在缓冲区末尾添加 0 作为字符串终止符
    mov byte ptr [di], 0

    ; 将输入的字符串转换为数字
    lea si, input_buffer ; SI 指向输入缓冲区
    mov bx, 0           ; BX 用于保存转换后的数字

convert_input:
    mov al, [si]       ; 获取输入的字符
    cmp al, 0          ; 检查是否到达缓冲区末尾
    je check_range     ; 如果是 0，则跳转到检查范围
    sub al, '0'        ; 将 ASCII 转换为数字
    mov dl, al         ; 使用 DL 存储当前位的数字
    mov ax, bx
    mov cx, 10
    mul cx             ; AX = BX * 10
    mov bx, ax         ; 将结果存入 BX
    add bx, dx         ; BX = BX + 当前位的数字
    inc si             ; SI 前移到下一个字符
    jmp convert_input  ; 继续转换

check_range:
    ; 验证输入是否在 1-100 范围内
    cmp bx, 1          ; 输入是否小于 1
    jb invalid         ; 如果小于 1，跳转到无效输入处理
    cmp bx, 100        ; 输入是否大于 100
    ja invalid         ; 如果大于 100，跳转到无效输入处理
    
    ; 将输入的数字转换为十进制字符串
    mov ax, bx         ; 将用户输入的数值复制到 AX 中
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
