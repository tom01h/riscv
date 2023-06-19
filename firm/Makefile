PREFIX  = /opt/riscv32
ARCH    = riscv32-unknown-elf
BINDIR  = $(PREFIX)/bin
ADDNAME = $(ARCH)-

AR      = $(BINDIR)/$(ADDNAME)ar
AS      = $(BINDIR)/$(ADDNAME)as
CC      = $(BINDIR)/$(ADDNAME)gcc
LD      = $(BINDIR)/$(ADDNAME)ld
NM      = $(BINDIR)/$(ADDNAME)nm
OBJCOPY = $(BINDIR)/$(ADDNAME)objcopy
OBJDUMP = $(BINDIR)/$(ADDNAME)objdump
RANLIB  = $(BINDIR)/$(ADDNAME)ranlib
STRIP   = $(BINDIR)/$(ADDNAME)strip

OBJS  = startup.o main.o
OBJS += 

TARGET = main

#CFLAGS = -nostdinc -nostdlib -fno-builtin -march=rv32i -mabi=ilp32
CFLAGS = -nostartfiles -fno-builtin -march=rv32i -mabi=ilp32
CFLAGS += -I.
#CFLAGS += -g
CFLAGS += -O
CFLAGS += 

LFLAGS = -static -n -Tld.scr -L.

#DFLAGS = --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
DFLAGS = --disassemble-all --disassemble-zeroes

.SUFFIXES: .c .o
.SUFFIXES: .s .o

all :		$(TARGET)

$(TARGET) :	$(OBJS)
		$(CC) $(OBJS) -o $(TARGET).elf $(CFLAGS) $(LFLAGS)
		$(STRIP) $(TARGET).elf -o $(TARGET)
		$(OBJDUMP) $(TARGET).elf  $(DFLAGS) > $(TARGET).dump
		$(OBJCOPY) -O binary $(TARGET) $(TARGET).bin
		hexdump $(TARGET).bin -s 0 -n 4096 -v -e '1/4 "%08X\n"' > inst.hex
		hexdump $(TARGET).bin -s 4096 -n 4096 -v -e '1/4 "%08X\n"' > data.hex
.c.o :		$<
		$(CC) -c $(CFLAGS) $<

.s.o :		$<
		$(CC) -c $(CFLAGS) $<

clean :
		rm $(OBJS) $(TARGET) $(TARGET).elf $(TARGET).dump $(TARGET).bin inst.hex data.hex
