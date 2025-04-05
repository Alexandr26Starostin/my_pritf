# my_printf

## Самое важное

Самое важное, что будет в этом проекте:
- вызов ассемблерных вставок в C
- написание трамплина для обхода соглашения и вызовах
- использование системного вызова Linux
- использование ассемблера NASM
- использование jmp-таблицы
- написание функции-аналога *printf* 

## О чём этот проект

В данном проекте мы научимся делать вставки ассемблерного в код на C. В качестве примера мы напишем функцию my_printf (аналог функции printf) на ассемблере [NASM](https://metanit.com/assembler/nasm/), а потом используем её в программе на C.

Проект написан на arch-Linux, процессор Intel N95.

## Ключевые моменты в коде

### Вставка в код на C

Чтобы g++ разрешил использовать *my_printf*, нужно в файле на C объявить прототип нашей функции:
```C
extern "C" int my_printf (const char* str, ...);
```

После этого g++ будет давать возможность использовать нашу функцию:
```C
my_printf ("\n\nPrivet%d!!!\n%s\n", 1234, "dkidiin");
```

Чтобы соединить файл с кодом на C *main.cpp* и файл с кодом на NASM *my_printf.s* в один исполняемый файл, нужно выполнить ассемблировать *my_printf.s* и связать его с *main.cpp*:
```
nasm -f elf64 -l my_printf.lst my_printf.s
g++ -static main.cpp my_printf.o  -o my_printf
```

### Код на NASM

#### Информация для линкера

Чтобы линкер смог увидеть нашу функцию и связать её, нужно в файле с NASM прописать:
```asm
global my_printf
```

#### Соглашение о вызовах

В нашей архитектуре и ОС используется по умолчанию (его нельзя изменить) соглашение и вызове [System V AMD64 ABI](https://hev.cc/posts/2015/system-v-amd64-abi-calling-conventions/). По ссылке находится следующий текст (может плохо открываться):

```
Соглашение о вызове System V AMD64 ABI используется в Solaris, Linux, FreeBSD, Mac OS X и других операционных системах, совместимых с UNIX или POSIX. Первые шесть целочисленных аргументов или аргументов-указателей передаются в регистрах RDI, RSI, RDX, RCX, R8 и R9, а XMM0, XMM1, XMM2, XMM3, XMM4, XMM5, XMM6 и XMM7 используются для аргументов с плавающей запятой. Для системных вызовов вместо RCX используется R10. Как и в соглашении о вызовах Microsoft x64, дополнительные аргументы передаются по стеку, а возвращаемое значение сохраняется в RAX.

Регистры RBP, RBX и R12-R15 являются регистрами сохранения вызываемой функции; все остальные регистры должны сохраняться вызывающей функцией, если она хочет сохранить их значения.

В отличие от соглашения о вызове функций Microsoft, теневое пространство не предусмотрено; при входе в функцию адрес возврата находится рядом с седьмым целочисленным аргументом в стеке
```

#### Трамплин

Используя информацию о соглашении о вызовах, мы может написать трамплин для того, чтобы в стеке находились все аргументы нашей функции в правильном порядке.  
Создание трамплина:
```asm
;trampoline    (System V AMD64 ABI)

mov r10, rbp  ;r10 = old rbp

pop r11   ;r11 = address to return (save it)

push r9
push r8
push rcx
push rdx
push rsi    ;complement list of arguments (5 arguments)

mov rbp, rsp  ;bp = address on buffer with arguments

;all arguments - in stack
```
Закрытие трамплина:
```asm
add rsp, 40   ;rsp = rsp + 5 * 8 (old value rsp - in beginning of program; 5 - push 5 arguments)
push r11      ;r11 = address to return (this address must be on stack: address_in_stack % 16 == 0 - because it important for SSE)
mov rbp, r10  ;r10 = old rbp

;stack before rsp 'now' == stack before rsp 'in beginning of program'
```

#### Массив для печати символов

Печать символов в консоль осуществляется через системный вызов Linux. Тк он происходит медленно, то мы минимизируем количество этих вызовов путём сохранения символов для печати в один массив. Когда массив переполнится, мы его распечатаем и начнём заполнять заново.

Массив для печати символов:
```asm
len_buffer dq 16   ;len buffer == max count of free places in buffer
buffer_for_printf: times 16 db 0  ;buffer for symbols
```

Запись в этот массив происходит постоянно в разных частях программы. 

#### Системный вызов и печать массива символов
Функция с кодом с печатью массива с помощью системного вызова:
```asm
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
```

#### Обработка аргументов

*my_printf* печатает символы с строки-аргумента до тех пор, пока не встретит символ **'%'**. Если программа встретила **'%'**, то запускается функция определения типа аргумента и происходит печать самого аргумента. 

Для определения типа аргумента и куска кода для печати этого кода используется **jmp-таблица** (как при компиляции switch).

Сама **jmp-таблица**:
```asm
align 8    ;8 bytes between labels and address_of_labels % 8 == 0 
type_of_argument:       ;jmp_table
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
    ;times 'z' - 'x'     dq default_
```

Обращение к **jmp-таблица**:
```asm
jmp [type_of_argument + (rbx - 'b') * 8]   ;use jmp_table (rbx = bl = shifting for jmp_table)
```

#### Остальные нюансы работы кода

Более подробно, как работает программа, можно посмотреть по самому коду программы. Сам код содержит подробные комментарии, чтобы его было легче понять.

## Возможности функции my_printf

функция my_printf может печатать:

- строчку-аргумент (первый и обязательный аргумент функции)
- %% - печатает символ '%'
- %c - печатает ***char***
- %s - печатает строчку ***char* ***
- %d - печатает ***__int32_t*** (размер 4 байта) в 10-ой системе исчисления
- %u - печатает любой целочисленный беззнаковый аргумент (размером 1, 2, 4, 8 байт) в 10-ой системе исчисления 
- %x - печатает любой целочисленных аргумент (размером 1, 2, 4, 8 байт) в 16-ой системе исчисления
- %o - печатает любой целочисленных аргумент (размером 1, 2, 4, 8 байт) в 8-ой системе исчисления
- %b - печатает любой целочисленных аргумент (размером 1, 2, 4, 8 байт) в 2-ой системе исчисления

## Использование данной программы

Для использования данной программы необходимо:
1. Установить g++, nasm.
2. Скопировать себе ветку *master* нашего репозитория. 
3. В консоль ввести *bash run.bash*
4. В консоль ввести *./my_printf (название исходника можно поменять в *run.bash*)

На arch-Linux установить nasm можно, введя в командную строку:
```
sudo pacman -S nasm
```

Пример компиляция файла с помощью NASM можно найти в *run.bash*:
```
nasm -f elf64 -l my_printf.lst my_printf.s
```

Возвращаемое значение функции:
- Количество напечатанных функцией символов в консоль.

Возможные коды ошибок и сообщений о них (в сообщениях об ошибках выходит информация о том, в каком месте кода произошла ошибка):
- 0 - нет ошибок.

## Вывод

В данном проекте мы научились использовать ассемблер NASM на Linux, вставлять ассемблерные вставки в код на C, писать трамплин для функций, использовать системные вызовы в Linux, использовать jmp-table и написали свою упрощённую версию функцию *printf*. 

## Доработки

Список того, что нужно доработать в данном проекте:

- Дать g++ возможность проверять синтаксис my_printf, как синтаксис функции printf.
- Сделать возможность печати чисел с плавающей точкой: *%f*
- Сделать возможность печати *long*: *%ld*

