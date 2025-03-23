;---------------------------------------------------------------------------------------
;program on Linux-nasm-64
;has code with my_printf                   
;---------------------------------------------------------------------------------------
section .text   ;has text with program
global my_printf   ;global func: other files can see this func (for ld) 

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
;destr: rax = count of writing symbols
;       rcx = index of count free places in buffer
;       rdx = address of buffer
;       rdi = address on str, 
;           = stdout
;       r10 = old rbp 
;       r11 = address to return
;
;must save:    rbp, rbx, r12-15
;mustn't save: others registers
;---------------------------------------------------------------------------------------------------------
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

    mov rcx, [len_buffer]        ;rcx = index of count free places in buffer
    mov rdx, buffer_for_printf   ;rdx = address of buffer

    continue_fill_the_buffer:

        mov bl, [rdi]     ;bl == [rdi] == next symbol in str

        cmp bl, 0   
        je break_fill_the_buffer   ;if (bl == '\0') {break;}

        cmp bl, '%'
        je do_print_argument       ;if (bl == '%') {do_print_argument ();}

        ;print_usual_symbol
        mov [rdx], bl   ;mov symbol in buffer
        inc rdi         ;next symbol in str
        inc rdx         ;nest free place in buffer
        inc rax         ;+1 writing symbol
        jmp skip_print_argument

        ;print_argument
        do_print_argument:  
        call print_argument
        inc rcx                 ;rcx = rcx + 1 - 1 (+1: inc rcx, -1: loop) = rcx (rcx was changed by print_argument)

        skip_print_argument:
        loop continue_fill_the_buffer  ;while (rcx != 0) {continue_fill_the_buffer ();}  //while free place is in buffer, continue print str
    
    break_fill_the_buffer:  ;buffer is full or see '\0'

    ;----------------------------------------------------------------------

    call print_buffer    ;print symbols in buffer

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
;print buffer with symbols
;entry: rdi = address on next symbol in str
;       rax = count of writing symbols
;       r10 = old rbp
;       r11 = address to return
;       rcx = count of free places in buffer
;       rdx = address of the first free place in buffer
;       
;exit:  rdi = address on next symbol in str (not changed)
;       rax = count of writing symbols (not changed)
;       r10 = old rbp (not changed)
;       r11 = address to return (not changed)
;       rcx = len of buffer: all places in buffer are free
;       rdx = address on buffer: the first place in buffer is free
;       
;destr: rcx = len of buffer
;       rdx = adress on buffer
;
;use:   rax = number of interrupt
;       rdx = count of symbols in buffer for print
;       rsi = address on buffer
;       rdi = stdout 
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
    syscall ;!!! change r10, r11

    pop r11
    pop r10
    pop rax
    pop rdi     ;save rdi, rax, r10, r11

    mov rcx, [len_buffer]        ;rcx = index of count symbols in buffer
    mov rdx, buffer_for_printf   ;rdx = address of buffer

    ret
;---------------------------------------------------------------------------------------------------------


;---------------------------------------------------------------------------------------------------------
;                                       print_symbols_from_stack
;value --> (calculus system) --> array of numbers in stack (little end)
;print this numbers from stack
;
;entry: rcx = count of free places in buffer
;       r8  = len array of numbers in stack
;       rdx = address of the next free place in buffer  
;       rax = r8 (old rax in stack: see end of func)     
;       rdi = address on next symbol in str (now == <type>)
;
;exit:  rdx = address of the next free place in buffer  
;       rcx = count of free places in buffer
;       rax = count of writing symbols
;       rdi = address on next symbol in str (now == symbol after <type>)
;
;destr: r13 = save address of return for this func 
;       rcx = count of free places in buffer (new)
;       rdx = address of the next free place in buffer (new)
;       r8  = 0 (all numbers in stack are printed)
;       r9  = old rax
;       rax = count of writing symbols
;       rbx = symbol from stack (= bl)
;       rdi = address on next symbol in str (skip <type>)
;---------------------------------------------------------------------------------------------------------
print_symbols_from_stack:

    pop r13  ;save address of return for this func
    ;in stack - all numbers

    print_symbol:

        cmp rcx, 0  
        jne continue_print_next_symbol  ;rcx != 0 --> can put symbol in buffer

        ;rcx == 0 --> buffer doesn't have free places --> print and clear buffer --> can put symbols in buffer
        call print_buffer  
        continue_print_next_symbol:

        pop rbx         ;take symbol from stack to bl
        mov [rdx], bl   ;put symbol in buffer         
        inc rdx         ;+1 - next free symbol in buffer
        dec rcx         ;-1 free place in buffer
        dec r8          ;-1 number in stack

        cmp r8, 0     
        jne print_symbol ;r8 != 0 --> print the next number from stack

    ;r8 == 0 --> all numbers in stack are printed   

    pop r9      ;now in stack must be old rax
    add rax, r9 ;new rax = r9 (= old rax) + rax (= r8 in beginning of func)

    inc rdi     ;skip 'type'

    push r13   ;save address of return for this func

    ret
;---------------------------------------------------------------------------------------------------------


;---------------------------------------------------------------------------------------------------------
;                                       print_argument
;print argument of str
;can print: %c, %d, %b, %o, %x, %s, %%  (%d - for int)
;
;entry: rdi = address on next symbol in str (const char* str)
;       rdx = address on the next free place in buffer for printf (const char* buffer)
;       rax = count of writing symbols
;       rbp = address on arguments in stack
;       rcx = count of free places in buffer
;       bl  = symbol from str (='%')
;
;exit:  rax = count of writing symbols
;       rdx = address on the next free place in buffer
;       rcx = count of free places in buffer
;       rdi = address on next symbol in str
;
;destr: bl  = symbol from str
;       rax = count of writing symbols
;       rbp = address on the next arguments in stack
;       rdx = address on the next free place in buffer
;       rcx = count of free places in buffer
;       rdi = address on next symbol in str
;       r8  = count of numbers in stack from value (for %d, %b, %o, %x)
;
;use:   r9  = 10: footing of 10 calculus system (for %d)
;       r12 = save rdx = address on the next free place in buffer (for %d, %u)
;           = save rax = value of argument from stack (for %b, %o, %x)
;           = value % cl = value % r14 = little number from value(for %b, %o, %x)
;       r13 = save address of return of print_symbols_from_stack (for %d, %u %b, %o, %x)
;           = for mask_for_sign (for %d)    
;           = old_rax + 1 (for %d if print '-')
;       r14 = footing of calculus system (for %b, %o, %x)
;       r15 = save rcx = count of free places in buffer (for %b, %o, %x)
;---------------------------------------------------------------------------------------------------------
print_argument:

    inc rdi  ;skip '%'

    mov bl, [rdi]   ;bl = <type> (=symbol_after_%)

                                               ;bl = symbol_after_% - '%'  - shifting for jmp_table
    jmp [type_of_argument + (rbx - '%') * 8]   ;use jmp_table (rbx = bl = shifting for jmp_table)
 
    ;----------------------------------------------------------------------

    type_c:                ;%c
        mov rbx, [rbp]     ;rpb = address on next argument (== symbol)
        mov [rdx], bl      ;print one symbol (put it in buffer)

        add rbp, 8    ;rbp = address on the next argument
        inc rdi       ;+1 - the next symbol in str
        inc rdx       ;+1 - the next free place in buffer        
        dec rcx       ;-1 count of free places in buffer
        inc rax       ;+1 count of writing symbols
        
        jmp end_print_argument ;end of func

    ;----------------------------------------------------------------------

    type_d:   ;%d   (for int)
        push r13 
        push r12   ;must save r12, r13

        push rax   ;save rax for end func, when func will count new rax = count of writing symbols
        mov r12, rdx  ;save rax, rdx for div and rdx for sign

        mov rax, [rbp]     ;rpb = address on next argument (rax = value)
        add rbp, 8         ;rbp = address on the next argument
        
        mov r13, [mask_for_sign]   ;r13 = mask_for_sign

        xor rdx, rdx   ;rdx = 0
        mov edx, eax  
        and rdx, r13   ;rdx = eax and r13

        jz continue_write_int_10  ;rdx == 0 --> unsigned value
                                  ;rdx != 0 -->   signed value

        pop r13
        inc r13  ;r13 = old_rax += 1
        push r13 ;push new_rax

        neg eax   ;eax *= -1  ;rax = 0...0not(eax)

        mov rdx, r12  ;rdx = address on the free place in buffer (old rdx)

        mov [rdx], byte '-'   ;put '-' in buffer         
        inc rdx         ;+1 - next free symbol in buffer
        dec rcx         ;-1 free place in buffer

        ;rcx == 0: will be checked by print_symbols_from_stack

        mov r12, rdx ;save rdx

        jmp continue_write_int_10

    type_u:   ;%u
        push r13 
        push r12   ;must save r12, r13

        push rax   ;save rax for end func, when func will count new rax = count of writing symbols
        mov r12, rdx  ;save rax, rdx for div

        mov rax, [rbp]     ;rpb = address on next argument (rax = value)
        add rbp, 8         ;rbp = address on the next argument

        ;-----------------------------------------------------------------------------------------------------
        continue_write_int_10:

        xor r8, r8  ;r8 = 0 (count of numbers in value symbols for number_10)

        count_next_symbol_in_number_10:  ;take number from value and put it in stack

        cqo          ;rax --> rdx:rax
        mov r9, 10   ;r9  = footing of 10 calculus system 
        div r9       ;rax = rax // 10
                     ;rdx = rax %  10
        inc r8       ;+1 count of numbers in stack
        add rdx, '0' ;numbers --> 'numbers' (ascii)
        push rdx     ;put number in stack

        cmp rax, 0
        jne count_next_symbol_in_number_10 ;rax != 0 --> can put number from rax in stack

        ;all numbers from value in stack
        mov rax, r8    ;rax = count of numbers in stack (count of writing symbols will be counted in print_symbols_from_stack)
        mov rdx, r12   ;rdx = address on the next free place in buffer 

        ;---------------------------------------------------------------

        call print_symbols_from_stack        

        ;mov r13, 0
        ;mov [flag_of_sign], r13

        pop r12
        pop r13   ;save r12, r13

        jmp end_print_argument  ;end of print_argument

    ;----------------------------------------------------------------------
    
    type_b:    ;%b
        push r14    ;must save r14
        mov r14, 1  ;r14 = footing of calculus system = 2^1 = 2 (for shiftings)
        jmp continue_print_argument_with_footing

    type_o:    ;%o
        push r14    ;must save r14
        mov r14, 3  ;r14 = footing of calculus system = 2^3 = 8 (for shiftings)
        jmp continue_print_argument_with_footing

    type_x:    ;%x
        push r14    ;must save r14
        mov r14, 4  ;r14 = footing of calculus system = 2^4 = 16 (for shiftings)
        jmp continue_print_argument_with_footing

    continue_print_argument_with_footing:
    push r13
    push r12
    push r15        ;must save r13, r12, r15

    push rax        ;save rax for end func, when func will count new rax = count of writing symbols

    mov rax, [rbp]     ;rpb = address on free argument (== int_r14)
                       ;rax = value of argument from stack  
    add rbp, 8         ;rbp = address on the next argument

    xor r8, r8  ;r8 = 0 (count of numbers in value symbols for number_r14)

    mov r15, rcx    ;save rcx = count of free places in buffer
    mov rcx, r14    ;rcx = cl = r14 = footing of calculus system

    count_next_symbol_in_number:
    mov r12, rax   ;save rax

    shr rax, cl  
    shl rax, cl    ;rax = (rax >> cl) << cl
                   
    sub r12, rax   ;r12 = r12 - rax 
                   ;r12 = value % cl = little number from value

    shr rax, cl    ;rax = rax >> cl
                   ;rax = value // cl

    cmp r12, 10   
    js have_number    ;r12 < 10 --> r2 - number

    ;have_latter
    sub r12, 10
    add r12, 'A'    ;number --> 'latter' (acscii)
    jmp write_r12_in_stack

    have_number:
    add r12, '0'    ;number --> 'number' (ascii)

    ;pur number in stack
    write_r12_in_stack:

    inc r8    ;+1 count numbers in stack
    push r12  ;pur number in stack

    cmp rax, 0 
    jne count_next_symbol_in_number  ;rax != 0 --> can put number from rax in stack

    ;all numbers from value in stack
    mov rcx, r15   ;rcx = r15 = count of free places in buffer
    mov rax, r8    ;rax = count of numbers in stack (count of writing symbols will be counted in print_symbols_from_stack)

    ;--------------------------------------------------------------- 

    call print_symbols_from_stack
    
    pop r15
    pop r12
    pop r13
    pop r14    ;save r15, r12, r13, r14

    jmp end_print_argument ;end of print_argument
    ;----------------------------------------------------------------------

    type_s:     ;%s

        push rdi  ;save address on next symbol in "main" str

        mov rdi, [rbp]     ;rpb = address on free argument (== const char*)
                           ;rdi = address on "argument" str
        add rbp, 8         ;rbp = address on the next argument

        continue_print_str:

            mov bl, [rdi]       ;bl = symbol from "argument" str

            cmp bl, 0   
            je break_print_str  ;bl == 0 --> end print "argument" str

            ;print_usual_symbol
            mov [rdx], bl      ;put symbol from "argument" str on free place in buffer
            inc rdi            ;+1 - next symbol in "argument" str  
            inc rdx            ;+1 - next free place in buffer
            inc rax            ;+1 - count of writing symbols

            loop continue_print_str  ;rcx -= 1 (-1 count of free places in buffer)

        ;----------------------------------------------------------------------

        ;rcx == 0 && bl != '\0' --> buffer is full
        call print_buffer          ;print and clear buffer
        jmp continue_print_str     ;fill buffer again

        break_print_str:       ;end print "argument" str
        pop rdi                ;rdi = address on next symbol in "main" str
        inc rdi                ;skip 's'

        jmp end_print_argument ;end print_argument
    ;----------------------------------------------------------------------

    type_percent:     ;%%
        mov bl, '%'   ;bl = '%'

        mov [rdx], bl   ;print '%'
        inc rdi         ;skip '%'
        inc rdx         ;+1 - next free place in buffer
        inc rax         ;+1 - count of writing symbols
        dec rcx         ;-1 - count of free places in buffer

        jmp end_print_argument  ;end print_argument
    ;----------------------------------------------------------------------

    end_print_argument:

    default_:  ;default

    ret
;---------------------------------------------------------------------------------------------------------

section .data   ;has data
len_buffer dq 16   ;len buffer == max count of free places in buffer
buffer_for_printf: times 16 db 0  ;buffer for symbols
mask_for_sign dd 1<<31   ;mask_for_sign in int (for %d)

section .rodata
align 8    ;8 bytes between labels
type_of_argument:       ;jmp_table
    dq   type_percent   ;%%
    times 'b' - '%' - 1 dq default_
    dq   type_b         ;%b 
    dq   type_c         ;%c
    dq   type_d         ;%d
    times 'o' - 'd' - 1 dq default_
    dq   type_o         ;%o
    times 's' - 'o' - 1 dq default_
    dq   type_s         ;%s
    times 'u' - 's' - 1 dq default_
    dq   type_u         ;%u
    times 'x' - 'u' - 1 dq default_
    dq   type_x         ;%x
    times 'z' - 'x'     dq default_
    

