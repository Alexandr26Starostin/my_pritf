#! /bin/bash

nasm -f elf64 -l my_printf.lst my_printf.s

g++ -static main.cpp my_printf.o  -o my_printf
