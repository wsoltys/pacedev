# platform options

#PLATFORM = coco3

ifeq (,$(PLATFORM))
	PLATFORM = coco3
endif

# compiler, linker and utilities
AS = as6809
LD = aslink
HEX2BIN = hex2bin
ECHO = @echo
RM = rm
MD = mkdir
OBJC = objcopy
TARGET = kl_ldr
MAKEFILE = makefile

ifeq ($(PLATFORM),coco3)
	FQTN = $(TARGET).bin
endif

ASFLAGS = -l -o -s
LDFLAGS = -t

OBJS = $(TARGET).rel
	
all: $(FQTN)
.PHONY: all

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

# COCO3 BIN format file
%.bin: $(OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<
	file2dsk kl_6809.dsk kl_ldr.bin

%.bin: %.ihx
	$(HEX2BIN) $<

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(RM) -f *.bin
	$(ECHO) Deleting executables...
	$(RM) -f $(FQTN)
