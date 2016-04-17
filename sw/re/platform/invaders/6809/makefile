# platform options

#TARGET = inv1
#TARGET = a8

#PLATFORM = coco3

ifeq (,$(TARGET))
	TARGET = inv1
endif

ifeq (,$(PLATFORM))
	PLATFORM = coco3
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
LDR = siboot
EXE = $(TARGET)
ROMWAK = \devkit\neodev\m68k\bin\romwak
MAKEFILE = makefile

ifeq ($(PLATFORM),coco3)
  FQLN = $(LDR).bin
  FQEN = $(TARGET)rom.bin
  MEDIA = inv1_6809.dsk
endif

ASFLAGS = -l -o -s
LDFLAGS = -i

LDR_OBJS = $(LDR).rel
EXE_OBJS = $(EXE).rel

all: $(MEDIA)

%.dsk: $(FQLN) $(FQEN)
#	$(CP) $(FQLN) klldr.bin
#	imgtool create coco_jvc_rsdos kl_6809.dsk
#	imgtool put coco_jvc_rsdos kl_6809.dsk klldr.bin $(FQEN)
	$(RM) -f $(MEDIA)
	file2dsk $(MEDIA) $(FQLN) $(FQEN) si.bas

# COCO3 BIN format file
$(FQLN): $(LDR_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) -t $<

$(FQEN): $(TARGET).rom
	ldrom -v $(TARGET).rom $(FQEN)
	
%.rom: %.ihx
	$(HEX2BIN) -e r0m $<
	$(ROMWAK) /p $*.r0m $@ 16 255

$(TARGET).ihx: $(EXE_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $<

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(RM) -f *.rom
	$(ECHO) Deleting executables...
	$(RM) -f $(FQLN)
	$(RM) -f $(FQEN)
	$(RM) -f $(MEDIA)
  