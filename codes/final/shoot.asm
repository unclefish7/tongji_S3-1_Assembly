.MODEL small
.STACK 100h

PUBLIC clear_screen, print_string
PUBLIC color, output_buffer

DATA SEGMENT
    color DB 0Fh
    enemy_color DB 04h              ; 敌对飞机颜色（红色）
    output_buffer DB 'Press A/D to move, Q to quit$'    ; 修改提示文字
    plane_char DB '^'              ; 飞机图标
    enemy_char DB 'V'               ; 敌对飞机图标
    plane_pos DW 3760             ; 飞机初始位置(第14行中间位置)
    prev_plane_pos DW 3760        ; 记录飞机之前的位置
    enemy_pos DW 90                 ; 敌对飞机初始位置（屏幕顶端）
    enemy_speed DW 160              ; 敌对飞机移动速度
    enemy_move_counter DW 0         ; 敌对飞机移动计数器
    enemy_move_interval DW 10       ; 敌对飞机移动间隔
    game_over_msg DB 'Game Over$'
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

; 擦除飞机过程
erase_plane PROC
    PUSH AX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, prev_plane_pos
    
    MOV AL, ' '                   ; 用空格字符擦除
    MOV ES:[DI], AL
    MOV AL, color
    MOV ES:[DI+1], AL

    POP ES
    POP DI
    POP AX
    RET
erase_plane ENDP

; 显示敌对飞机过程
draw_enemy PROC
    PUSH AX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, enemy_pos
    
    MOV AL, enemy_char
    MOV ES:[DI], AL
    MOV AL, enemy_color
    MOV ES:[DI+1], AL

    POP ES
    POP DI
    POP AX
    RET
draw_enemy ENDP

; 擦除敌对飞机过程
erase_enemy PROC
    PUSH AX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, enemy_pos
    
    MOV AL, ' '
    MOV ES:[DI], AL
    MOV AL, color
    MOV ES:[DI+1], AL

    POP ES
    POP DI
    POP AX
    RET
erase_enemy ENDP

; 更新敌对飞机位置过程
update_enemy PROC
    INC enemy_move_counter
    MOV AX, enemy_move_interval
    CMP enemy_move_counter, AX
    JL skip_enemy_move

    MOV enemy_move_counter, 0
    CALL erase_enemy
    MOV AX, enemy_speed
    ADD enemy_pos, AX               ; 根据速度移动敌对飞机
    CMP enemy_pos, 4000             ; 检查是否到达屏幕底端
    JLE draw_enemy
    MOV enemy_pos, 90               ; 重置敌对飞机位置到屏幕顶端
    CALL draw_enemy

skip_enemy_move:
    RET
update_enemy ENDP

; 显示游戏结束信息过程
show_game_over PROC
    PUSH AX
    PUSH DI
    PUSH ES

    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 1920 + 35 * 2           ; 屏幕中央位置（第12行中间）

    MOV SI, OFFSET game_over_msg
game_over_loop:
    LODSB
    CMP AL, '$'
    JE game_over_done
    MOV ES:[DI], AL
    MOV AL, 4Fh                     ; 红色背景，白色前景
    MOV ES:[DI+1], AL
    ADD DI, 2
    JMP game_over_loop

game_over_done:
    POP ES
    POP DI
    POP AX
    RET
show_game_over ENDP

; 检查碰撞过程
check_collision PROC
    PUSH AX
    MOV AX, plane_pos
    CMP AX, enemy_pos
    JE collision_detected
    POP AX
    RET

collision_detected:
    CALL show_game_over
    MOV AH, 4Ch
    INT 21h
check_collision ENDP

; 处理输入过程 - 增加寄存器保护
handle_input PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES
    PUSHF
    
    MOV AH, 1
    INT 16h
    JZ input_done_pop

    MOV AH, 0
    INT 16h
    
    CMP AL, 'a'
    JE move_left
    CMP AL, 'd'
    JE move_right
    CMP AL, 'q'
    JE quit_game
    JMP input_done_pop

update_plane:
    MOV AX, plane_pos
    MOV prev_plane_pos, AX
    CALL draw_plane
    JMP input_done_pop

quit_game:
    POPF
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
    POPF
    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

move_left:
    MOV BX, plane_pos
    CMP BX, 3680
    JLE input_done_pop
    CALL erase_plane
    SUB plane_pos, 2
    JMP update_plane

move_right:
    MOV BX, plane_pos
    CMP BX, 3838
    JGE input_done_pop
    CALL erase_plane
    ADD plane_pos, 2
    JMP update_plane

handle_input ENDP

; 延时过程 - 使用时钟计数器
delay PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES
    PUSHF
    
    MOV AH, 00h
    INT 1Ah
    MOV BX, DX
wait_loop:
    MOV AH, 00h
    INT 1Ah
    SUB DX, BX
    CMP DX, 1
    JB wait_loop
    
    POPF
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

    ; 设置显示位置并打印提示
    MOV DI, 160
    CALL print_string

    ; 绘制初始位置的飞机
    CALL draw_plane

    ; 绘制初始位置的敌对飞机
    CALL draw_enemy

game_loop:
    CALL handle_input
    CALL update_enemy
    CALL check_collision
    CALL delay
    JMP game_loop

CODE ENDS
END START
