LD=./env/bin/i686-elf-ld.exe
CC=./env/bin/i686-elf-gcc.exe
NASM=./bin/nasm.exe
DD=./bin/dd.exe
BOCHS=./bin/bochs.exe
# LD=ld
# CC=gcc
# NASM=nasm
# DD=dd
# BOCHS=bochs

LDFLAGS=-m elf_i386
CCFLAGS=-march=i386 -m16 -mpreferred-stack-boundary=2 -ffreestanding
ASFLAGS=

all: kernel.bin loader.bin kernel.o utilities.o  loader.o

kernel.bin: kernel.o utilities.o
	$(LD) $(LDFLAGS) -Ttext 0xA100 --oformat binary -o $@ $^
kernel.o: kernel.c utilities.h
	$(CC) $(CCFLAGS) -o kernel.o -c kernel.c
utilities.o: utilities.asm
	$(NASM) $(ASFLAGS) -f elf32 -o $@ $^
loader.o: loader.asm
	$(NASM) $(ASFLAGS) -f elf32 -o $@ $^
loader.bin: loader.o
	$(LD) $(LDFLAGS) -Ttext 0x7c00 --oformat binary -o $@ $^
build:
	$(DD) if=loader.bin of=OS.img conv=notrunc
	$(DD) if=kernel.bin of=OS.img conv=notrunc bs=512 seek=1
clean:
	-rm *.bin
	-rm *.o
	-rm *.gch
	-rm bochsout.txt
run:
	$(BOCHS) -q

auto:
	make clean
	make all
	make build
	make run

# 不知道为什么，这个rm一直不行