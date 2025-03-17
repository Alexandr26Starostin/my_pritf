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
;entry: rdi = address on str (const char* buffer)
;       rsi = 2 argument
;       rdx = 3 argument
;       rcx = 4 argument
;       r8  = 5 argument
;       r9  = 6 argument
;       7, 8, ... arguments = stack
;
;exit:  rax = count of writing symbols
;
;destr: rax = int and count of writing symbols
;       rdi = stdout
;       rsi = const char* buffer
;       rdx = len      
;
;must save:    rbp, rbx, r12-15
;mustn't save: others registers
;---------------------------------------------------------------------------------------------------------

global my_printf   ;global func: other files can see this func (for ld) 

my_printf:

    push rbx

    xor rax, rax

    fill_the_buffer:

    mov rcx, [len_buffer]
    mov rdx, buffer_for_printf

    continue_fill_the_buffer:

        mov bl, [rdi]
        cmp bl, 0
        je break_fill_the_buffer

        mov [rdx], bl
        inc rdi
        inc rdx
        inc rax

        loop continue_fill_the_buffer
    
    break_fill_the_buffer:

    ;----------------------------------------------------------------------

    push rdi    ;save rdi = address on next symbol in str
    push rax

    ; interrupt rax = 0x01: print buffer (address = rsi) with len (len = rdx) on flow (flow = rdi) 
    mov rax, 0x01                ;int  

    mov rdx, [len_buffer]
    sub rdx, rcx                 ;rdx == len

    mov rsi, buffer_for_printf   ;rsi == const char* buffer
    mov rdi, 1                   ;rdi == 1 => stdout
    syscall

    pop rax
    pop rdi

    cmp bl, 0
    je end_of_my_printf

    jmp fill_the_buffer

    end_of_my_printf:

    ;inc rax  last symbol == '\0'

    pop rbx

    ret
;---------------------------------------------------------------------------------------------------------

section .data   ;has data

len_buffer dq 10
buffer_for_printf: times 20 db 0
