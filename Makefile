CROSS_COMPILE ?= arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
AS = $(CC)
LD = $(CROSS_COMPILE)ld
OC = $(CROSS_COMPILE)objcopy
OD = $(CROSS_COMPILE)objdump

CFLAGS += -Wall -Wextra -Os -g3 -nostdlib -nostartfiles
CFLAGS += -march=armv5te
CFLAGS += -I./

all:	bootloader

bootloader:
	$(AS) $(CFLAGS) -c -o boot.o boot.s
	$(CC) $(CFLAGS) -c -o sys-uart.o sys-uart.c
	$(CC) $(CFLAGS) -T link.ld -Wl,-Map=$@.map,--cref,--no-warn-mismatch \
		-o $@.elf boot.o sys-uart.o
	$(OD) -D -m arm -S $@.elf > $@.asm
	$(OC) -O binary -S $@.elf $@.bin

clean:
	rm -f ./*.o ./*.bin ./*.elf ./*.dis ./*.map
