;---------------------------------------------------------------------------------------
;program on Linux-nasm-64
;has code with my_printf                   
;---------------------------------------------------------------------------------------

section .text

global _start                  ; predefined entry point name for ld
extern main

_start:   
    call main

    mov rax, 0x3C      ; exit64 (rdi)
    xor rdi, rdi
    syscall

global my_printf

my_printf:

    push rdi
    push rsi 

    mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
    mov rdi, 1         ; stdout
    mov rsi, Msg
    mov rdx, MsgLen    ; strlen (Msg)
    syscall

    pop rsi 
    pop rdi

    mov rax, MsgLen

    ret

section     .data
 
Msg:        db "__Hllwrld", 0x0a
MsgLen      equ $ - Msg
