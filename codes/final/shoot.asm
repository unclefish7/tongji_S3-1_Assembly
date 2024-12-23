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
    enemy_pos DW 400                ; 敌对飞机初始位置（第三行）
    enemy_speed DW 160              ; 敌对飞机移动速度
    enemy_move_counter DW 0         ; 敌对飞机移动计数器
    enemy_move_interval DW 1       ; 敌对飞机移动间隔
    game_over_msg DB 'Game Over$'
    MAX_ENEMIES EQU 5
    enemy_positions DW MAX_ENEMIES DUP(400)
    enemy_active DB MAX_ENEMIES DUP(0)
    spawn_counter DW 0
    spawn_interval DW 5       ; 多少次循环后生成一架敌机
    rand_seed DW 0                   ; 添加随机数种子
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

; 获取随机列偏移过程
get_random_col PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; 使用系统时钟更新种子
    MOV AH, 0
    INT 1Ah
    ADD rand_seed, DX               ; 累加时钟值到种子
    
    ; 使用线性同余法生成随机数
    MOV AX, rand_seed
    MOV BX, 1357                    ; 乘数
    MUL BX
    ADD AX, 13579                   ; 加数
    MOV rand_seed, AX               ; 保存新的种子
    
    ; 取余操作得到列号
    XOR DX, DX
    MOV BX, 76                      ; 限制在0-75列之间，留出边界
    DIV BX
    
    ; 转换为显存偏移
    MOV AX, DX
    SHL AX, 1                       ; 乘2得到字符偏移
    ADD AX, 320                     ; 加上第三行的基址
    
    POP DX
    POP CX
    POP BX
    RET
get_random_col ENDP

spawn_enemy PROC
    ; 寻找空闲的敌机槽并激活
    PUSH AX
    PUSH BX
    PUSH CX
    XOR BX, BX
find_slot:
    CMP BL, MAX_ENEMIES
    JAE no_slot
    MOV AL, enemy_active[BX]
    CMP AL, 0
    JNE next_slot
    ; 该槽可用，生成新敌机
    CALL get_random_col
    MOV SI, BX
    SHL SI, 1
    MOV [enemy_positions + SI], AX
    MOV enemy_active[BX], 1
    PUSH DI
    PUSH ES
    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, [enemy_positions + SI]
    MOV AL, enemy_char
    MOV ES:[DI], AL
    MOV AL, enemy_color
    MOV ES:[DI+1], AL
    POP ES
    POP DI
    JMP slot_done
next_slot:
    INC BL
    JMP find_slot
no_slot:
    ; 没有空闲
slot_done:
    POP CX
    POP BX
    POP AX
    RET
spawn_enemy ENDP

update_enemy PROC
    ; 每个敌机都检查移动
    PUSH AX
    PUSH BX
    PUSH CX

    ; 生成新敌机计数逻辑
    INC spawn_counter
    MOV AX, spawn_counter
    CMP AX, spawn_interval
    JL skip_spawn
    MOV spawn_counter, 0
    CALL spawn_enemy
skip_spawn:

    XOR BX, BX
update_loop:
    CMP BL, MAX_ENEMIES
    JAE done_update
    MOV AL, enemy_active[BX]
    CMP AL, 0
    JE next_update

    PUSH BX
    CALL erase_enemy_array
    MOV AX, enemy_speed
    MOV SI, BX
    SHL SI, 1
    ADD [enemy_positions + SI], AX
    MOV AX, [enemy_positions + SI]
    CMP AX, 4000
    JLE draw_again
    ; 飞机离开底端，标记为空闲
    MOV enemy_active[BX], 0
    JMP skip_draw
draw_again:
    ; 移除这里的 PUSH BX，避免多次 PUSH 只 POP 一次
    ; PUSH BX
    CALL draw_enemy_array
skip_draw:
    POP BX
next_update:
    INC BL
    JMP update_loop
done_update:
    POP CX
    POP BX
    POP AX
    RET
update_enemy ENDP

; 改造敌机显示/擦除以支持敌机数组索引
draw_enemy_array PROC
    ; 使用 BX 作为索引
    PUSH AX
    PUSH DI
    PUSH ES
    MOV AX, 0B800h
    MOV ES, AX
    MOV SI, BX
    SHL SI, 1
    MOV DI, [enemy_positions + SI]
    MOV AL, enemy_char
    MOV ES:[DI], AL
    MOV AL, enemy_color
    MOV ES:[DI+1], AL
    POP ES
    POP DI
    POP AX
    RET
draw_enemy_array ENDP

erase_enemy_array PROC
    PUSH AX
    PUSH DI
    PUSH ES
    MOV AX, 0B800h
    MOV ES, AX
    MOV SI, BX
    SHL SI, 1
    MOV DI, [enemy_positions + SI]
    MOV AL, ' '
    MOV ES:[DI], AL
    MOV AL, color
    MOV ES:[DI+1], AL
    POP ES
    POP DI
    POP AX
    RET
erase_enemy_array ENDP

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
    PUSH BX
    MOV AX, plane_pos
    XOR BX, BX
collision_loop:
    CMP BL, MAX_ENEMIES
    JAE no_collision
    MOV CL, enemy_active[BX]
    CMP CL, 0
    JE skip
    MOV SI, BX
    SHL SI, 1
    MOV DX, [enemy_positions + SI]
    CMP AX, DX
    JE collision_detected
skip:
    INC BL
    JMP collision_loop
collision_detected:
    POP BX
    POP AX
    CALL show_game_over
    MOV AH, 4Ch
    INT 21h
no_collision:
    POP BX
    POP AX
    RET
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

game_loop:
    CALL handle_input
    CALL update_enemy
    CALL check_collision
    CALL delay
    JMP game_loop

CODE ENDS
END START
