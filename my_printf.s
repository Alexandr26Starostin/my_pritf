;---------------------------------------------------------------------------------------
;program on Linux-nasm-64
;has code with my_printf                   
;---------------------------------------------------------------------------------------
section .text   ;has text with program
global _start   ;ld can see the point of entry in program (for ld)
extern main     ;main in other file (for ld)

_start:         ;point of entry in program
    call main  

    mov rax, 0x3C      ; end of program
    xor rdi, rdi       ;return rdi;  //rdi == 0
    syscall

;---------------------------------------------------------------------------------------------------------


;---------------------------------------------------------------------------------------------------------
;                                       my_printf 
;print buffer with len on stdout
;
;entry: rdi = address on str (const char* str)
;       rsi = 2 argument
;       rdx = 3 argument
;       rcx = 4 argument
;       r8  = 5 argument
;       r9  = 6 argument
;       7, 8, ... arguments = stack
;
;exit:  rax = count of writing symbols
;
;destr: rax = number in interrupt, 
;             count of writing symbols
;       rcx = index of count symbols in buffer
;       rdx = address of buffer, 
;             count of symbols in buffer in print
;       rsi = const char* buffer_for_printf (in interrupt)
;       rdi = address on str, 
;             stdout
;       r10 = old rbp 
;       r11 = address to return
;
;must save:    rbp, rbx, r12-15
;mustn't save: others registers
;---------------------------------------------------------------------------------------------------------

global my_printf   ;global func: other files can see this func (for ld) 

my_printf:

    ;------------------------------------------------------------------------------
    ;trampoline    (System V AMD64 ABI)

    mov r10, rbp  ;r10 = old rbp
    
    pop r11   ;r11 = address to return

    push r9
    push r8
    push rcx
    push rdx
    push rsi    ;complement list of arguments (5 arguments)

    mov rbp, rsp  ;bp = address on buffer with arguments

    ;all arguments - in stack
    ;------------------------------------------------------------------------------

    push rbx   ;must save rbx

    xor rax, rax    ;rax = 0
    xor rbx, rbx    ;rbx = 0

    fill_the_buffer:

    mov rcx, [len_buffer]        ;rcx = index of count symbols in buffer
    mov rdx, buffer_for_printf   ;rdx = address of buffer

    continue_fill_the_buffer:

        mov bl, [rdi]     ;bl == [rdi] == next symbol in str

        cmp bl, 0   
        je break_fill_the_buffer   ;if (bl == '\0') {break;}

        cmp bl, '%'
        je do_print_argument       ;if (bl == '%') {do_print_argument ();}

        ;print_usual_symbol
        mov [rdx], bl
        inc rdi
        inc rdx
        inc rax

        jmp skip_print_argument

        do_print_argument:
        call print_argument

        skip_print_argument:
        loop continue_fill_the_buffer  ;while (rcx != 0) {continue_fill_the_buffer ();}
    
    break_fill_the_buffer:

    ;----------------------------------------------------------------------

    push rdi    ;save rdi == address on next symbol in str
    push rax    ;save rax == count of writing symbols
    push r10    ;save r10 == old rbp           (syscall uses it)
    push r11    ;save r11 == address to return (syscall uses it)

    ; interrupt rax = 0x01: print buffer (address = rsi) with len (len = rdx) on flow (flow = rdi) 
    mov rax, 0x01                ;int  

    mov rdx, [len_buffer]
    sub rdx, rcx                 ;rdx == len

    mov rsi, buffer_for_printf   ;rsi == const char* buffer
    mov rdi, 1                   ;rdi == 1 => stdout
    syscall

    pop r11
    pop r10
    pop rax
    pop rdi    

    cmp bl, 0
    je end_of_my_printf      ;if (bl == '\0') {end_print ();}

    jmp fill_the_buffer      ;fill buffer again

    end_of_my_printf:   ;rax = count of writing symbols

    ;inc rax  last symbol == '\0'

    ;----------------------------------------------------------------------------------------------------

    pop rbx     ;must save rbx

    add rsp, 40   ;rsp = rsp + 5 * 8 (old value rsp - in beginning of program; 5 - push 5 arguments)
    push r11      ;r11 = address to return
    mov rbp, r10  ;r10 = old rbp

    ;stack before rsp 'now' == stack before rsp 'in beginning of program'

    ret
;---------------------------------------------------------------------------------------------------------







































;---------------------------------------------------------------------------------------------------------
;                                       print_argument
;print argument of str
;
;entry: rdi = address on symbol in str (const char* str)
;       rdx = buffer for printf        (const char* buffer)
;       rax = count of writing symbols
;       rbp = address on arguments
;       rcx = count of free symbols in buffer
;
;exit:  
;
;destr:    
;
;---------------------------------------------------------------------------------------------------------
print_argument:

    inc rdi  ;skip '%'

    mov bl, [rdi]
    sub bl, 'a'     ;bl = symbol_after_% - 'a'

    jmp [type_of_argument + rbx * 8]   ;use jmp_table
 
    type_c:                ;%c
        mov rbx, [rbp]     ;rpb = address on free argument (== symbol)
        mov [rdx], bl      ;print one symbol

        add rbp, 8         ;rbp = address on the next argument
        inc rdi            
        inc rdx
        inc rax
        
        jmp end_print_argument
    
    end_print_argument:

    type_a:   ;default
    type_b:

    ret
;---------------------------------------------------------------------------------------------------------

section .data   ;has data

len_buffer dq 16
buffer_for_printf: times 16 db 0

align 8    ;8 bytes
type_of_argument:     ;jmp_table
    dq   type_a
    dq   type_b
    dq   type_c
