#! /bin/bash

#solve_square.air
#factorial_with_while.air
#factorial_with_recursive.air
#reverse_program.air

nasm -f elf64 -l my_printf.lst my_printf.s

g++ -static main.cpp my_printf.o  -o my_printf
