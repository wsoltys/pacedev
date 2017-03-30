# platform options

#PLATFORM = zx
#PLATFORM = trs80

ifeq (,$(PLATFORM))
	PLATFORM = trs80
	START = 5000
	#START = 5200
	EXEC = $(START)
endif

# compiler, linker and utilities
AS = asz80
LD = aslink
HEX2BIN = hex2bin
ECHO = @echo
RM = rm
MD = mkdir
OBJC = objcopy
TARGET = invforce
MAKEFILE = makefile

FQTN = $(TARGET).cmd

ASFLAGS = -l -o -s
LDFLAGS = -i

OBJS = $(TARGET).rel
	
all: $(FQTN)
.PHONY: all

.SECONDARY: $(TARGET).bin

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

%.ihx: $(OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<

%.bin: %.ihx
	$(HEX2BIN) $<

# TRS-80 CMD format file
%.cmd: %.bin
	bin2cmd -o$(START) -x$(EXEC) $(TARGET)

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(RM) -f *.bin
	$(ECHO) Deleting executables...
	$(RM) -f $(FQTN)
