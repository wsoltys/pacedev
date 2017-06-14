# Apple IIGS Asteroids makefile

TARGET = asteroid

CC65_DIR = cc65

# compiler, linker and utilities
AS = $(CC65_DIR)/bin/ca65
LD = $(CC65_DIR)/bin/ld65
HEX2BIN = hex2bin
ECHO = @echo
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
	$(DD) if=$(BIN) of=$(TARGET)#060803.BIN bs=1 skip=4

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
	