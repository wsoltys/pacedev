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

ifeq (,$(OUTPUT))
  OUTPUT = cart
endif

# compiler, linker and utilities
AS = as6809
LD = aslink
HEX2BIN = hex2bin
ECHO = @echo
CP = copy
RM = rm
MD = mkdir
OBJC = objcopy
LDR = $(TARGET)_ldr
#EXE = $(TARGET)_6809
EXE = $(TARGET)
MAKEFILE = makefile

ifeq ($(PLATFORM),coco3)
  ifeq ($(OUTPUT),disk)
	  FQLN = $(LDR).bin
    FQEN = $(EXE).bin
    MEDIA = kl_6809.dsk
	else
	  FQEN = $(EXE).ihx
    MEDIA = $(TARGET).rom
  endif
endif

ASFLAGS = -l -o -s
ifeq ($(OUTPUT),disk)
  LDFLAGS = -t
else
  LDFLAGS = -i
endif

LDR_OBJS = $(LDR).rel
EXE_OBJS = $(EXE).rel

all: $(MEDIA)

%.dsk: $(FQLN) $(FQEN)
#	$(CP) $(FQLN) klldr.bin
#	imgtool create coco_jvc_rsdos kl_6809.dsk
#	imgtool put coco_jvc_rsdos kl_6809.dsk klldr.bin $(FQEN)
	$(RM) -f $(MEDIA)
	reloc kl_ldr.bin klldr.bin
	file2dsk $(MEDIA) klldr.bin $(FQEN) kl.bas

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

# COCO3 BIN format file
$(FQLN): $(LDR_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<

# COCO3 BIN format file / IHX
$(FQEN): $(EXE_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<

%.rom: %.ihx
	$(HEX2BIN) -e rom $<

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(RM) -f *.bin
	$(ECHO) Deleting executables...
	$(RM) -f $(FQLN)
	$(RM) -f $(FQEN)
	$(RM) -f $(MEDIA)
  