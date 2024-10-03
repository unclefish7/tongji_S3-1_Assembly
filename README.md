# 作业二：按要求打印ASCII表

> **本次作业的代码与源文件都放在了`[repo-root]/codes/loop/`目录下**

- 基本要求：输出ASCII表中的小写字母部分，要求每行打印13个字符
  1. **用loop指令实现**
  2. **用条件跳转指令实现**
  3. **用C语言实现后察看反汇编代码并加注释**

---

### 用loop指令实现

- 使用一个额外的寄存器`BX`来保存外循环的`CX`值

  ```assembly
  MOV BX, CX          ; 保存当前外循环计数到 BX
  ```

- 内循环打印13个字符

  ```assembly
  ; 调用 2 号功能
      MOV AH, 2           ; 设置功能号为 2，用于输出字符
  I_L: ; 内循环标签
      MOV DL, [MSG]       ; 将当前字符（MSG）加载到 DL 中
      INT 21H             ; 调用 DOS 中断 21h，输出字符
      INC [MSG]           ; 将 MSG 中的字符增加 1
      LOOP I_L            ; 循环内计数，CX 自动减 1，若不为 0 则跳回内循环
  ```

- 第一次跳出内循环后用`BX`恢复外循环的计数，并输出换行

  ```assembly
  	MOV CX, BX          ; 恢复外循环计数（CX）
  
      ; 输出换行
      MOV DX, OFFSET NEWLINE ; 设置换行字符串的地址到 DX
      MOV AH, 09h          ; 设置功能号为 09，用于输出字符串
      INT 21h              ; 调用 DOS 中断 21h，输出换行
  
      LOOP O_L            ; 外循环计数，CX 自动减 1，若不为 0 则跳回外循环
  ```

**核心代码：**

```assembly
; 外循环次数设置为 2，表示要输出两行
    MOV CX, 2
O_L: ; 外循环标签
    MOV BX, CX          ; 保存当前外循环计数到 BX
    MOV CX, 13          ; 设置内循环次数为 13，表示每行输出 13 个字母
    
    ; 调用 2 号功能
    MOV AH, 2           ; 设置功能号为 2，用于输出字符
I_L: ; 内循环标签
    MOV DL, [MSG]       ; 将当前字符（MSG）加载到 DL 中
    INT 21H             ; 调用 DOS 中断 21h，输出字符
    INC [MSG]           ; 将 MSG 中的字符增加 1
    LOOP I_L            ; 循环内计数，CX 自动减 1，若不为 0 则跳回内循环

    MOV CX, BX          ; 恢复外循环计数（CX）

    ; 输出换行
    MOV DX, OFFSET NEWLINE ; 设置换行字符串的地址到 DX
    MOV AH, 09h          ; 设置功能号为 09，用于输出字符串
    INT 21h              ; 调用 DOS 中断 21h，输出换行

    LOOP O_L            ; 外循环计数，CX 自动减 1，若不为 0 则跳回外循环
```

---

### 用jmp指令实现

- 内循环使用`JAE`来判断是否已经打印了13个字符，无条件的`JMP`来进行内循环

  ```assembly
  	MOV BX, 0          ; 行内字符计数器，初始化为 0
  
  INNER_LOOP:
      MOV DL, [MSG]      ; 将当前字符加载到 DL
      MOV AH, 02h        ; 设置功能号：输出字符
      INT 21H            ; 调用中断输出字符
      INC [MSG]          ; 增加 MSG 中的字符
      INC BX             ; 增加行内计数器
  
      CMP BX, 13         ; 检查是否到达每行的字符数量
      JAE PRINT_NEWLINE   ; 如果到达 13 个字符，跳转到打印换行
  
      JMP INNER_LOOP     ; 否则继续内循环
  ```

- 使用`JNZ`来控制外循环的次数

  ```assembly
  PRINT_NEWLINE:
      ; 输出换行
      MOV DX, OFFSET NEWLINE ; 设置换行字符串的地址
      MOV AH, 09h          ; 功能号：输出字符串
      INT 21h              ; 调用中断
  
      DEC CX               ; 减少外循环计数器
      JNZ OUTER_LOOP       ; 如果还没有输出 2 行，继续外循环
  ```

**核心代码：**

```assembly
	; 外循环：2 行
    MOV CX, 2          ; 行数
OUTER_LOOP:
    MOV BX, 0          ; 行内字符计数器，初始化为 0

INNER_LOOP:
    MOV DL, [MSG]      ; 将当前字符加载到 DL
    MOV AH, 02h        ; 设置功能号：输出字符
    INT 21H            ; 调用中断输出字符
    INC [MSG]          ; 增加 MSG 中的字符
    INC BX             ; 增加行内计数器

    CMP BX, 13         ; 检查是否到达每行的字符数量
    JAE PRINT_NEWLINE   ; 如果到达 13 个字符，跳转到打印换行

    JMP INNER_LOOP     ; 否则继续内循环

PRINT_NEWLINE:
    ; 输出换行
    MOV DX, OFFSET NEWLINE ; 设置换行字符串的地址
    MOV AH, 09h          ; 功能号：输出字符串
    INT 21h              ; 调用中断

    DEC CX               ; 减少外循环计数器
    JNZ OUTER_LOOP       ; 如果还没有输出 2 行，继续外循环
```

---

### 用C语言写并且进行反汇编

