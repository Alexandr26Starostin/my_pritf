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
;       rsi = len of str for printf
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

    ; interrupt rax = 0x01: print buffer (address = rsi) with len (len = rdx) on flow (flow = rdi) 
    mov rax, 0x01      ;int  
    mov rdx, rsi       ;rdx == len
    mov rsi, rdi       ;rsi == const char* buffer
    mov rdi, 1         ;rdi == 1 => stdout
    syscall

    mov rax, rsi

    ret
;---------------------------------------------------------------------------------------------------------

section .data   ;has data

len_buffer dw 20
buffer_for_printf: times 20 db 0x00  
