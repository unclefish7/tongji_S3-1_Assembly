.MODEL small
.STACK 100h

EXTRN clear_screen:PROC, print_string:PROC  ; 声明子模块中的过程
EXTRN calculate_average:PROC
EXTRN load_avg:PROC, load_dnum:PROC, load_num:PROC, load_year:PROC
PUBLIC year, total, em, color, output_buffer, table

DATA_SEGMENT segment PUBLIC
;以下是表示 21 年的 21 个字符串
    year db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
         db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
         db '1993','1994','1995'
    ;以下是表示 21 年公司总收的 21 个 dword 型数据
    total dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
          dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
    ;以下是表示 21 年公司雇员人数的 21 个 word 型数据
    em dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
       dw 11542,14430,15257,17800
    color db 0Fh
    output_buffer db 256 dup('$')
    newline     DB 0Dh, 0Ah, '$'  ; 换行符，用于输出换行
    spacer DB ' $'
DATA_SEGMENT ends

TABLE_SEGMENT segment PUBLIC
    table db 21 dup('year summ ne ?? ')
TABLE_SEGMENT ends

CODE SEGMENT
ASSUME CS:CODE, DS:DATA_SEGMENT

START:
    MOV AX, DATA_SEGMENT
    MOV DS, AX

    CALL calculate_average
    CALL clear_screen

    MOV SI, OFFSET table

    MOV AX, 09h

    MOV CX, 21
    MOV DI, 160
loop_print:
    CALL load_year
    CALL print_string
    
    ADD DI, 40
    CALL load_dnum
    CALL print_string

    ADD DI, 40
    CALL load_num
    CALL print_string

    ADD DI, 40
    CALL load_avg
    CALL print_string

    ADD DI, 40
    ADD SI, 16
    LOOP loop_print
    

    MOV AX, 4C00h                     ; 程序结束
    INT 21h
CODE ENDS
END START
