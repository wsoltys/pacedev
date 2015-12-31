# platform options

#PLATFORM = zx
#PLATFORM = trs80

ifeq (,$(PLATFORM))
	PLATFORM = zx
endif

# compiler, linker and utilities
AS = asz80
LD = aslink
HEX2BIN = hex2bin
ECHO = @echo
RM = rm
MD = mkdir
OBJC = objcopy
TARGET = kl_z80
MAKEFILE = makefile

ifeq ($(PLATFORM),zx)
	FQTN = $(TARGET).sna
endif

ifeq ($(PLATFORM),trs80)
	FQTN = $(TARGET).cmd
endif

ASFLAGS = -l -o -s
LDFLAGS = -i

OBJS = kl_z80.rel
	
all: $(FQTN)
.PHONY: all

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

%.ihx: $(OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<

%.bin: %.ihx
	$(HEX2BIN) $<

# ZX SPECTRUM SNA dump format file
%.sna: %.bin
	bin2sna -a6108 -i3f -m1 -n0 -s5b8a -xaf6c $<

# TRS-80 CMD format file
%.cmd: %.bin
	bin2cmd -o6108 -xaf6c kl_z80

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(RM) -f *.bin
	$(ECHO) Deleting executables...
	$(RM) -f $(FQTN)
