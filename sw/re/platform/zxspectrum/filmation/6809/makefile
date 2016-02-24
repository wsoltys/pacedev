# platform options

#TARGET = kl
#TARGET = a8

#PLATFORM = coco3

ifeq (,$(TARGET))
	TARGET = kl
endif

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
LDR = $(TARGET)_ldr
#EXE = $(TARGET)_6809
EXE = $(TARGET)
MAKEFILE = makefile

ifeq ($(PLATFORM),coco3)
	FQLN = $(LDR).bin
  FQEN = $(EXE).bin
endif

ASFLAGS = -l -o -s
LDFLAGS = -t

LDR_OBJS = $(LDR).rel
EXE_OBJS = $(EXE).rel
	
all: $(FQLN) $(FQEN)
	file2dsk kl_6809.dsk $(FQLN) $(FQEN)

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

# COCO3 BIN format file
$(FQLN): $(LDR_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<

# COCO3 BIN format file
$(FQEN): $(EXE_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<

%.bin: %.ihx
	$(HEX2BIN) $<

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(RM) -f *.bin
	$(ECHO) Deleting executables...
	$(RM) -f $(FQLN)
	$(RM) -f $(FQEN)
