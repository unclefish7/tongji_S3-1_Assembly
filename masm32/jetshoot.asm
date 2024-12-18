.386
.model flat,stdcall
option casemap:none

include windows.inc
include masm32.inc
include kernel32.inc
includelib masm32.lib
includelib kernel32.lib

.data
    message db "Hello, World!", 0
    xPos dd 10                    ; 改用 dd
    yPos dd 5                     ; 改用 dd
    attribute db 1Eh              ; 修正十六进制表示
    videoMemory dd 0B8000h        ; 显存地址

.code
main PROC
    ; 显存起始地址
    mov edi, dword ptr [videoMemory]

    ; 计算显存位置
    mov eax, [yPos]              ; 修正: 使用方括号
    mov ebx, 80                  ; 每行80字符
    mul ebx                      ; eax = yPos * 80
    add eax, [xPos]             ; 加上 X 坐标
    shl eax, 1                  ; 每字符占2字节
    add edi, eax                ; EDI = 目标地址

    ; 输出字符串
    mov esi, offset message      ; 获取字符串地址
output_loop:
    mov al, byte ptr [esi]      ; 修正: 使用 byte ptr
    test al, al
    jz end_output
    mov byte ptr [edi], al      ; 修正: 使用 byte ptr
    mov al, [attribute]
    mov byte ptr [edi+1], al    ; 修正: 使用 byte ptr
    add edi, 2
    inc esi
    jmp output_loop

end_output:
    ; 等待2秒
    invoke Sleep, 2000
    
    invoke ExitProcess, 0
main ENDP

END main
