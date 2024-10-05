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

**C语言源代码：**

```c
#include <stdio.h>

int main()
{
	char a = 'a';

	int i = 2;
	int j = 13;

	while (i) {
		j = 13;
		while (j) {
			printf("%c", a);
			a++;
			j--;
		}
		printf("\n");
		i--;
	}

	return 0;
}

```

**反汇编后的代码（尝试对应，但是对应不起来）：**

![](/codes/loop/loop-c-asm.png)

---

# 作业三：求和

> **本次作业源码都放在`[repo-root]/codes/loop/`目录下**

**基本要求：求1+2+3...+100，并将结果`5050`打印到屏幕**

注意和的结果数据表示范围，结果的进制转换问题

1. 尝试结果放在寄存器，放在数据段中，放在栈中等不同位置的操作
2. 用户输入1-100内任何一个数，完成十进制结果输出
3. 用C语言实现后察看反汇编代码并加注释

---

### 打印求和

- 把累加的数和最终结果放在`dataseg`里面

  ```assembly
  .data
      msg db 1           ; 初始值为 1
      sum dw 0           ; 存储最终累加结果
      buffer db 6 dup(0) ; 用于存储转换后的十进制字符串，最大支持 65535 的 5 位数字加上一个结束符
  ```

- 循环计算并储存结果

  ```assembly
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
  ```

- 使用buffer存储转换后的字符串

  ```assembly
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
  ```

- 用除法取余的方式得到10进制的结果

  ```assembly
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
  ```

**核心代码：**

```assembly
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
```

---

### 输入并输出

- 使用中断读取键盘输入

  ```assembly
      ; 读取用户输入
      mov ah, 01h        ; DOS 中断功能：读取键盘输入
      int 21h
      sub al, '0'        ; 将 ASCII 转换为数字
      mov bl, al         ; 保存用户输入的数字
  ```

- 将输入的数字转换为十进制字符串

  ```assembly
  ; 将输入的数字转换为十进制字符串
      mov ax, 0          ; 将 AX 清零
      mov al, bl         ; 将用户输入的数值复制到 AX 中
      lea si, buffer     ; SI 指向 buffer
      call convert_to_string
  ```

**核心代码：**

```assembly
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

```

#### 问题

- 输入多位数字的代码依旧有问题，转换过程不正确，当前只实现了输入一个字符的功能（只能输入1-10）
- 问题代码放在了`input.asm`里
- 只能输入1-10的代码放在了`input1.asm`里

