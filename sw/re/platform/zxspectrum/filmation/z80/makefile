# platform options

#PLATFORM = zx
#PLATFORM = trs80

ifeq (,$(PLATFORM))
	PLATFORM = zx
endif

ifeq (,$(GAME))
  GAME = kl
endif

ifeq ($(GAME),kl)
  START=6108
  EXEC=af6c
  SP=5b8a
endif

ifeq ($(GAME),a8)
  START=6288
  EXEC=a631
  SP=f0fe
endif

# compiler, linker and utilities
AS = asz80
LD = aslink
HEX2BIN = hex2bin
ECHO = @echo
RM = rm
MD = mkdir
OBJC = objcopy
TARGET = $(GAME)_z80
MAKEFILE = makefile

ifeq ($(PLATFORM),zx)
	FQTN = $(TARGET).sna
endif

ifeq ($(PLATFORM),trs80)
	FQTN = $(TARGET).cmd
endif

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

# ZX SPECTRUM SNA dump format file
%.sna: %.bin
	bin2sna -a$(START) -i3f -m1 -n0 -s$(SP) -x$(EXEC) $<

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
