# Apple IIGS Asteroids makefile

TARGET = asteroid

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

MEDIA = ast.dsk

all: $(MEDIA)

%.dsk : $(BIN)
	$(DD) if=$< of=$(TARGET)#060803.BIN bs=1 skip=4
	$(C2D) -b $< $@
	
$(TARGET).o : $(TARGET).s
	$(AS) -t apple2 $(TARGET).s -o $@

$(BIN) : $(TARGET).o
	$(LD) -o $@ $< -C apple2.cfg

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.o
	$(ECHO) Deleting executables...
	$(RM) -f $(BIN)
	$(RM) -f $(TARGET)#060803.BIN
	