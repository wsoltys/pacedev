# Apple IIGS Asteroids makefile

TARGET = asteroid
LA = 2000

TYPE = apple2
CC65_DIR = cc65
C2D_DIR = c2d-master

# compiler, linker and utilities
AS = $(CC65_DIR)/bin/ca65.exe
LD = $(CC65_DIR)/bin/ld65.exe
HEX2BIN = hex2bin
ECHO = @echo
C2D = $(C2D_DIR)/bin/c2d.exe
CP = copy
DD = dd
RM = rm
MD = mkdir
OBJC = objcopy
BIN = $(TARGET).bin
MAKEFILE = makefile

SPLASH = splash.bin
MEDIA = asteroid.dsk

M6502_OBJS = \
	asteroid2.o

M65816_OBJS = \
	iigs.o \
	render.o \
	erase.o \
	bitmaps.o

OBJS = $(M6502_OBJS) $(M65816_OBJS)

all: $(MEDIA)

%.dsk : $(BIN)
	$(DD) if=$< of=$(TARGET)#06$(LOAD).BIN bs=1 skip=4
	$(DD) if=$< of=6502.BIN bs=1 skip=6148 count=6144
	$(C2D) -t $(SPLASH) -r 23 -s $(LA) -b $< $@
	
$(M6502_OBJS) : %.o : %.asm
	$(AS) -t $(TYPE) $< -o $@ -l $*.lst

$(M65816_OBJS) : %.o : %.asm
	$(AS) -t $(TYPE) --cpu 65816 $< -o $@ -l $*.lst

$(BIN) : $(OBJS)
	$(LD) -o $@ $(OBJS) --start-addr 0x$(LA) -C apple2enh-asm.cfg -vm -m asteroid2.map

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.o
	$(ECHO) Deleting executables...
	$(RM) -f $(BIN)
	$(RM) -f $(TARGET)#06$(LA).BIN
	$(ECHO) Deleting dsk file...
	$(RM) -f $(MEDIA)
	