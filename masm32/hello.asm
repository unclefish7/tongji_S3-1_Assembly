.386                         ; 指定 80386 指令集
.model flat,stdcall          ; 平坦内存模式，stdcall 调用约定
option casemap:none          ; 区分大小写

include masm32.inc           ; 引入 MASM32 的基本函数
include kernel32.inc         ; 引入 Windows API
includelib masm32.lib        ; 链接 MASM32 库
includelib kernel32.lib      ; 链接 Kernel32 库

; 数据段
.data
    len equ 6                ; 定义输入字符串的长度
    prompt db "Input: ", 0   ; 提示信息
    szText db len dup(?)     ; 为用户输入分配空间

; 代码段
.code
main PROC
    ; 输出提示信息
    invoke StdOut, offset prompt

    ; 接收用户输入
    invoke StdIn, offset szText, len

    ; 输出用户输入
    invoke StdOut, offset szText

    ; 程序退出
    invoke ExitProcess, 0
main ENDP

END main
