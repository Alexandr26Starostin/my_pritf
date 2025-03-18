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
        inc rcx

        skip_print_argument:
        loop continue_fill_the_buffer  ;while (rcx != 0) {continue_fill_the_buffer ();}
    
    break_fill_the_buffer:

    ;----------------------------------------------------------------------

    call print_buffer   

    cmp bl, 0
    je end_of_my_printf      ;if (bl == '\0') {end_print ();}

    jmp continue_fill_the_buffer      ;fill buffer again

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
;                                           print_buffer
;
;entry: 
;
;exit:  
;
;destr:  
;---------------------------------------------------------------------------------------------------------
print_buffer:

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

    mov rcx, [len_buffer]        ;rcx = index of count symbols in buffer
    mov rdx, buffer_for_printf   ;rdx = address of buffer

    ret
;---------------------------------------------------------------------------------------------------------





;---------------------------------------------------------------------------------------------------------
;                                       print_symbols_from_stack
;
;
;entry: 
;
;exit:  
;
;destr:    
;
;---------------------------------------------------------------------------------------------------------
print_symbols_from_stack:

    pop r13

    print_symbol:

        cmp rcx, 0
        jne continue_print_next_symbol

        call print_buffer
        continue_print_next_symbol:

        pop rbx
        mov [rdx], bl            
        inc rdx
        dec rcx
        dec r8

        cmp r8, 0
        jne print_symbol

    pop r9
    add rax, r9

    inc rdi ;skip 'type'

    push r13

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
;       bl  = '%', symbol_after_%
;
;exit:  
;
;destr:    
;
;---------------------------------------------------------------------------------------------------------
print_argument:

    inc rdi  ;skip '%'

    mov bl, [rdi]
    sub bl, '%'     ;bl = symbol_after_% - 'a'

    jmp [type_of_argument + rbx * 8]   ;use jmp_table
 
    type_c:                ;%c
        mov rbx, [rbp]     ;rpb = address on free argument (== symbol)
        mov [rdx], bl      ;print one symbol

        add rbp, 8         ;rbp = address on the next argument
        inc rdi            
        inc rdx
        dec rcx
        inc rax
        
        jmp end_print_argument

    ;----------------------------------------------------------------------

    type_d:   ;%d
        push r13
        push r12

        push rax
        mov r12, rdx  ;save rax, rdx for div

        mov rax, [rbp]     ;rpb = address on free argument (== int_10)
        add rbp, 8         ;rbp = address on the next argument

        xor r8, r8  ;r8 = 0 (count of symbols in number_10)

        count_next_symbol_in_number_10:

        cqo
        mov r9, 10
        div r9   ;rax = rax // 10
                 ;rdx = rax %  10
        inc r8
        add rdx, '0'
        push rdx

        cmp rax, 0
        jne count_next_symbol_in_number_10

        mov rax, r8
        mov rdx, r12

        ;---------------------------------------------------------------

        call print_symbols_from_stack        

        pop r12
        pop r13

        jmp end_print_argument

    ;----------------------------------------------------------------------
    
    type_b:    ;%b
        push r14
        mov r14, 1
        jmp continue_print_argument_with_footing

    type_o:    ;%o
        push r14
        mov r14, 3
        jmp continue_print_argument_with_footing

    type_x:    ;%x
        push r14
        mov r14, 4
        jmp continue_print_argument_with_footing

    continue_print_argument_with_footing:
    push r13
    push r12
    push r15

    push rax

    mov rax, [rbp]     ;rpb = address on free argument (== int_10)
    add rbp, 8         ;rbp = address on the next argument

    xor r8, r8  ;r8 = 0 (count of symbols in number_10)

    mov r15, rcx
    mov rcx, r14
    count_next_symbol_in_number:

    nop
    nop
    nop

    mov r12, rax
    shr rax, cl    ;rax = rax // cl
    shl rax, cl
    sub r12, rax  ;r12 = rax %  cl
    shr rax, cl

    cmp r12, 10
    js have_number

    ;have_latter
    sub r12, 10
    add r12, 'A'
    jmp write_r12_in_stack

    have_number:
    add r12, '0'

    write_r12_in_stack:

    inc r8
    push r12

    cmp rax, 0
    jne count_next_symbol_in_number

    mov rcx, r15

    mov rax, r8

    ;---------------------------------------------------------------

    call print_symbols_from_stack
    
    pop r15
    pop r12
    pop r13
    pop r14

    jmp end_print_argument
    ;----------------------------------------------------------------------

    type_s:

        push rdi

        mov rdi, [rbp]     ;rpb = address on free argument (== const char*)
        add rbp, 8         ;rbp = address on the next argument

        continue_print_str:

            mov bl, [rdi]     

            cmp bl, 0   
            je break_print_str   

            ;print_usual_symbol
            mov [rdx], bl
            inc rdi
            inc rdx
            inc rax

            loop continue_print_str  

        ;----------------------------------------------------------------------

        call print_buffer   

        jmp continue_print_str      ;fill buffer again

        break_print_str:
        pop rdi
        inc rdi    ;skip 's'
        jmp end_print_argument
    ;----------------------------------------------------------------------

    type_percent:
        mov bl, '%'

        mov [rdx], bl
        inc rdi     ;skip '%'
        inc rdx
        inc rax
        dec rcx

        jmp end_print_argument
    ;----------------------------------------------------------------------

    end_print_argument:

    default_:

    ret
;---------------------------------------------------------------------------------------------------------

section .data   ;has data
len_buffer dq 16
buffer_for_printf: times 16 db 0

align 8    ;8 bytes
type_of_argument:     ;jmp_table
    dq   type_percent
    times 59 dq default_
    dq   type_b
    dq   type_c
    dq   type_d
    times 10 dq default_
    dq   type_o
    times 3 dq default_
    dq   type_s
    times 4 dq default_
    dq   type_x
    times 2 dq default_
    

