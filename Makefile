LDFLAGS=-melf_i386 -N
CCFLAGS=-march=i386 -m16 -mpreferred-stack-boundary=2 -ffreestanding
ASFLAGS=

all: kernel.bin loader.bin

kernel.bin: kernel.o utilities.o
	ld $(LDFLAGS) -Ttext 0xA100 --oformat binary -o $@ $^
kernel.o: kernel.c utilities.h
	gcc $(CCFLAGS) -c $^
utilities.o: utilities.asm
	nasm $(ASFLAGS) -f elf32 -o $@ $^
loader.o: loader.asm
	nasm $(ASFLAGS) -f elf32 -o $@ $^
loader.bin: loader.o
	ld $(LDFLAGS) -Ttext 0x7c00 --oformat binary -o $@ $^

build:
	dd if=loader.bin of=OS.img conv=notrunc
	dd if=kernel.bin of=OS.img conv=notrunc oflag=seek_bytes seek=512
clean:
	rm *.bin -f 
	rm *.o -f 
	rm *.gch -f
run:
	bochs -q