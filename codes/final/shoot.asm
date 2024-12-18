.MODEL small
.STACK 100h

PUBLIC clear_screen, print_string
PUBLIC color, output_buffer

DATA SEGMENT
    color DB 0Fh
    output_buffer DB 'Press 4/6 to move, Q to quit$'    ; 修改提示文字
    plane_char DB '^'              ; 飞机图标
    plane_pos DW 2160             ; 飞机初始位置(第14行中间位置)
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

; 清屏过程
clear_screen PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h                   ; 显存段地址
    MOV ES, AX

    MOV DI, 0                        ; 起始偏移地址
    MOV CX, 2000                     ; 25行 * 80列 = 2000个字符位置
clear_loop:
    MOV AL, ' '                      ; 空格字符
    MOV ES:[DI], AL                  ; 写入字符
    MOV AL, color                    ; 颜色属性
    MOV ES:[DI+1], AL               ; 写入颜色
    ADD DI, 2                        ; 下一个字符位置
    LOOP clear_loop

    POP ES
    POP DI
    POP CX
    POP BX
    POP AX
    RET
clear_screen ENDP

; 打印字符串过程
print_string PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    CLD                             ; 设置正向字符串操作
    MOV SI, OFFSET output_buffer    ; 源字符串地址

print_loop:
    LODSB                           ; 加载字符到AL
    CMP AL, '$'                     ; 检查是否到字符串结尾
    JE print_done

    MOV ES:[DI], AL                 ; 写入字符
    MOV AL, color                   ; 颜色属性
    MOV ES:[DI+1], AL              ; 写入颜色
    ADD DI, 2                       ; 下一个显示位置
    JMP print_loop

print_done:
    POP ES
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
print_string ENDP

; 显示飞机过程
draw_plane PROC
    PUSH AX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, plane_pos
    
    MOV AL, plane_char
    MOV ES:[DI], AL
    MOV AL, color
    MOV ES:[DI+1], AL

    POP ES
    POP DI
    POP AX
    RET
draw_plane ENDP

; 处理输入过程 - 增加寄存器保护
handle_input PROC
    PUSH AX
    PUSH BX
    PUSH CX                 ; 保护更多寄存器
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES
    PUSHF                   ; 保存标志寄存器
    
    MOV AH, 1              
    INT 16h
    JZ input_done_pop      

    MOV AH, 0              
    INT 16h
    
    CMP AL, '4'            
    JE move_left
    CMP AL, '6'            
    JE move_right
    CMP AL, 'q'           
    JE quit_game
    JMP input_done_pop     

move_left:
    MOV BX, plane_pos      ; 使用BX而不是AX来存储和比较
    CMP BX, 2080          
    JLE input_done_pop     
    SUB plane_pos, 2      
    JMP input_done_pop

move_right:
    MOV BX, plane_pos      ; 使用BX而不是AX来存储和比较
    CMP BX, 2238         
    JGE input_done_pop    
    ADD plane_pos, 2       
    JMP input_done_pop

quit_game:
    POPF                    ; 恢复标志寄存器
    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    MOV AH, 4Ch
    INT 21h

input_done_pop:
    POPF                    ; 恢复标志寄存器
    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
handle_input ENDP

; 延时过程 - 增加寄存器保护
delay PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI                 ; 保护更多寄存器
    PUSH DI
    PUSH ES
    PUSHF                   ; 保存标志寄存器
    
    MOV CX, 0h             
    MOV DX, 4240h          
    MOV AH, 86h
    INT 15h                
    
    POPF                    ; 恢复标志寄存器
    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
delay ENDP

; 主程序
START:
    MOV AX, DATA
    MOV DS, AX

    ; 清屏
    CALL clear_screen

game_loop:
    CLI                     ; 禁用中断
    CALL clear_screen
    
    MOV DI, 160            
    CALL print_string
    
    CALL handle_input
    CALL draw_plane
    
    STI                     ; 允许中断
    CALL delay             ; 延时期间允许中断
    
    JMP game_loop

CODE ENDS
END START
