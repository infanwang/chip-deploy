# RISC-V 固件编译
CROSS    = riscv64-unknown-elf-
CC       = $(CROSS)gcc
OBJCOPY  = $(CROSS)objcopy
OBJDUMP  = $(CROSS)objdump
SIZE     = $(CROSS)size

CFLAGS   = -march=rv32i -mabi=ilp32 -Os -ffreestanding \
           -Wall -Wextra -I.
LDFLAGS  = -T linker.ld -nostdlib -Wl,--no-relax
LIBS     = -lgcc

OBJS     = start.o main.o

all: firmware.elf firmware.hex firmware.bin firmware.dis

firmware.elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< $@

firmware.hex: firmware.bin bin2hex.py
	python3 bin2hex.py $< $@

firmware.dis: firmware.elf
	$(OBJDUMP) -d $< > $@

size: firmware.elf
	$(SIZE) $<

clean:
	rm -f *.o *.elf *.hex *.bin *.dis

.PHONY: all clean size
