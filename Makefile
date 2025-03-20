all: my_printf

my_printf: main.o my_printf.o
	@ld -s -o my_printf main.o my_printf.o

main.o: main.cpp
	@g++ main.cpp -S main.s -O0
	@as main.s -g -o main.o

my_printf.o: my_printf.s
	@nasm -f elf64 -g -l my_printf.lst my_printf.s

clean:
	@rm -rf *.o my_printf
